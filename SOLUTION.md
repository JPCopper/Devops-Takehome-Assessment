# Solution — BlockExplorer DevOps Take-Home

## Overview

This document describes the approach, decisions, and trade-offs made when making the BlockExplorer application production-ready. 
Work was done across five areas: Infrastructure as Code (Terraform), CI/CD Pipeline, Kubernetes Manifests, GitOps with Argo, and container versioning.

---

## 1. Versioned Container Builds

The repository uses a git submodule for the app (`./app`). The `Dockerfile` is a multi-stage build (React frontend → Go binary → minimal Alpine image). 
The CI pipeline builds and tags images with:

- **Commit SHA** (immutable, every merge to main): `ghcr.io/org/opsboard:${{ github.sha }}`
- **Semver tag** (if the commit carries a git tag like `v1.2.3`): `ghcr.io/org/opsboard:v1.2.3`

Production overlays in Kustomize pin to SHA digests, not tags, ensuring immutability.

---

## 2. CI/CD Pipeline

### CI (`ci.yml`)

The skeleton workflow was extended with:

- **Action pinning** — all GitHub Actions referenced by immutable SHA with a comment indicating the semver version
- **`runs-on: ubuntu-24.04`** — explicit runner version for reproducibility
- **Docker layer caching** — `type=gha` with `mode=max` across the Docker build job
- **Submodule checkout** — `submodules: recursive` on build and docker jobs, since the app is a submodule

Pipeline jobs run in order: `lint → build → test → docker`.

### Deploy (`deploy.yml`)

A multi-environment promotion pipeline:

| Stage | Trigger | Environment | Gate |
|-------|---------|-------------|------|
| Build & Push | CI success | — | None (checks CI passed) |
| Deploy Dev | Build done | `dev` | None |
| Deploy Staging | Dev done | `staging` | Integration + soak tests |
| Deploy Prod | Staging done | `production` | **Manual approval** via GitHub Environments |

Each step updates the corresponding Kustomize overlay (`kustomize edit set image`), commits, and pushes back to Git. ArgoCD detects the change and syncs automatically.

**Key decisions:**
- **OIDC-ready** — the build job requests `id-token: write` for AWS/GCP federation
- **GitHub Container Registry** — uses `GITHUB_TOKEN` for auth, no static secrets
- **Concurrency groups** — per-environment (cancel-in-progress: false) to prevent conflicting promotions
- **Notifications** — pipeline outcome posted to the commit status

---

## 3. Infrastructure as Code (Terraform)

### Architecture

```
terraform/
├── main.tf                          # Module orchestration
├── providers.tf                     # AWS (LocalStack) + random + tls
├── backend.tf                       # S3 + DynamoDB state locking
├── variables.tf                     # Root variables with sensible defaults
├── outputs.tf                       # Exposed infrastructure values
├── scripts/init-backend.sh          # Bootstrap state backend
├── terraform.tfvars.example         # Configuration reference
└── modules/
    ├── networking/                  # VPC, subnets, NAT, routing
    ├── database/                    # RDS PostgreSQL
    ├── eks/                         # EKS cluster, node group, OIDC
    └── monitoring/                  # CloudWatch, SNS, dashboard
```

### Networking Module
- VPC with public subnets (for NAT gateways and load balancers) and private subnets (for EKS and RDS)
- NAT gateway strategy controlled by `single_nat_gateway` variable:
  - `true` (dev/staging): single NAT in the first AZ — cheaper (~$32/mo)
  - `false` (production): one NAT per AZ — no single point of failure, avoids cross-AZ data charges
- Private route tables match the NAT strategy: shared table for single-NAT, per-AZ tables for multi-NAT

### Database Module
- RDS PostgreSQL 15.4 with `gp3` storage, auto-scaling (`max_allocated_storage=100`)
- Encryption at rest (`storage_encrypted=true`)
- Environment-aware settings:
  - `multi_az`: true only in production
  - `deletion_protection`: true only in production
  - `backup_retention`: 7 days prod / 1 day dev
- Performance Insights enabled
- Database password auto-generated via `random_password` if not explicitly provided
- All tunable parameters (instance class, storage, engine version, backup windows) exposed as variables

### EKS Module
- EKS cluster in private subnets with both private and public endpoint access
- Managed node group with IAM roles for worker nodes (`AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`)
- OIDC provider for IRSA (IAM Roles for Service Accounts) — enables fine-grained pod-level IAM
- Security group scoped to VPC CIDR (`var.vpc_cidr`)
- Endpoint access configurable via `endpoint_private_access` and `endpoint_public_access` variables

### Monitoring Module (Bonus)
- SNS topic for alerts with optional email subscription
- CloudWatch Log Groups for EKS control plane and application logs (90-day retention in prod)
- CloudWatch Alarms for RDS CPU (>80%), free storage (<5GB), and connections (>80)
- CloudWatch Dashboard with RDS and EKS metrics widgets

### State Management
- Remote S3 backend with DynamoDB locking configured for LocalStack
- Bootstrap script (`scripts/init-backend.sh`) creates the bucket and lock table

### Design Decisions

| Decision | Rationale |
|----------|-----------|
| Private subnets for workloads | RDS and EKS nodes should not have public IPs. NAT gateway provides egress. |
| Single source of truth for VPC CIDR | `local.vpc_cidr` in root `main.tf` passed to all modules — no duplication |
| Provider version alignment | Both root and EKS module use `hashicorp/aws ~> 6.0` to avoid init conflicts |
| One NAT vs per-AZ | Exposed as a variable — let the environment decide cost vs. resilience |
| Parameterized database module | Every RDS setting is a variable with a sensible default — prod just overrides what matters |

---

## 4. Kubernetes Manifests

### Base (`k8s/base/`)

All TODOs in the skeleton `deployment.yaml` were completed:

- **Three probes** — liveness (restart on deadlock), readiness (traffic gating), startup (slow-start tolerance)
- **Resource requests/limits** — `100m/64Mi` requests, `500m/256Mi` limits (realistic for a Go binary serving static files)
- **Pod security context** — `runAsNonRoot`, `runAsUser: 1001`, `seccompProfile: RuntimeDefault`
- **Container security context** — `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities.drop: [ALL]`
- **PodDisruptionBudget** — `minAvailable: 1` ensures at least one pod survives voluntary disruptions

**Fix applied:** The skeleton had `containerPort: 3000` but the app actually runs on `8080` per the Dockerfile (`ENV PORT=8080`). Both the deployment and service were corrected.

### Overlays

| Environment | Replicas | Resources | Image | Extra |
|-------------|----------|-----------|-------|-------|
| **dev** | 1 | 50m/32Mi → 250m/128Mi | tag | Relaxed probes |
| **staging** | 2 | base | staged tag | — |
| **prod** | 3 | 200m/128Mi → 1/512Mi | **digest** | HPA, NetworkPolicies |

**Production additions:**
- **HorizontalPodAutoscaler** — CPU 70%, memory 80%, scales 3→10
- **NetworkPolicies** — default-deny ingress+egress, allow inbound on 8080, allow outbound to HTTPS/DNS only

All manifests validated with `kubeconform`.

---

## 5. GitOps and Automated Rollback

### ArgoCD Application
- Auto-sync with `prune: true` and `selfHeal: true`
- CreateNamespace on sync, ServerSideApply for better conflict handling
- Retry with exponential backoff (5s → 2x → max 3m, 5 attempts)
- `ignoreDifferences` for `spec.replicas` and HPA metrics (fields set dynamically)
- Cascade delete via `resources-finalizer.argocd.argoproj.io`

### Canary Rollout (Argo Rollouts)

The production Rollout replaces the standard Deployment:

```
Traffic:  5% → (pause 60s) → 25% → (pause 60s) → 100%
           │                      │
           └── analysis starts ───┘
```

- **AnalysisTemplate** (`opsboard-health-check`): HTTP GET `/health` every 30s, 5 measurements, 2 failures allowed before abort
- **Anti-affinity**: canary and stable pods prefer separate nodes for blast radius isolation
- **`scaleDownDelaySeconds: 30`**: old pods stay alive briefly after traffic shifts, draining in-flight requests
- **Canary service** (`opsboard-canary`): Rollouts controller manages its selector dynamically

If the health check fails at any point, the rollout automatically aborts and traffic is redirected back to the stable version — zero manual intervention needed.

---

## What Was Not Done

- **Running Terraform against LocalStack**, due to issues and time constraints
- **Full monitoring module**, the skeleton CloudWatch module is functional but could be extended with Prometheus metrics, Grafana dashboards, or structured logging.
- **Notifications**, ArgoCD notification annotations are referenced in the Application manifest but not configured. This requires the argocd-notifications controller.
- **Secrets management**, database credentials are auto-generated but not stored in AWS Secrets Manager. The variable infrastructure supports it (just wire in `aws_secretsmanager_secret`).

---

## Final File Structure

```
.
├── SOLUTION.md                          # This file
├── .github/workflows/
│   ├── ci.yml                          # Lint, build, test, docker
│   └── deploy.yml                      # Build & promote through environments
├── terraform/
│   ├── main.tf, providers.tf, backend.tf, variables.tf, outputs.tf
│   ├── terraform.tfvars.example, scripts/init-backend.sh
│   └── modules/{networking,database,eks,monitoring}/
├── k8s/
│   ├── base/                           # Deployment, Service, PDB, ConfigMap, Namespace
│   ├── overlays/{dev,staging,prod}/    # Environment-specific Kustomize overlays
│   └── argo/                           # Application, Rollout, AnalysisTemplate, canary Service
└── app/                                # Git submodule (Go + React app)
```
