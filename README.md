# OpsBoard — DevOps Take-Home

## Context

OpsBoard is a Next.js incident tracking dashboard backed by PostgreSQL. Your team inherited it from a previous contractor. The app runs locally and the codebase has 10 release tags (`v1.1`–`v1.10`), but there is no deployment pipeline, no infrastructure-as-code, and no automated recovery.

**Your job: make this application production-ready.**

## Repository Layout

```
.
├── app/                        # Application source (git submodule, pinned to v1.10)
│   ├── src/                    # Next.js app, API routes, components
│   ├── prisma/                 # Database schema and seed data
│   ├── Dockerfile              # Multi-stage container build
│   └── vitest.config.ts        # Test configuration
├── terraform/                  # IaC skeletons (LocalStack)
│   └── modules/                # networking, database, eks
├── k8s/
│   ├── base/                   # Kustomize base manifests
│   ├── overlays/               # dev / staging / prod overrides
│   └── argo/                   # ArgoCD + Argo Rollouts examples
├── .github/workflows/          # CI pipeline (deploy pipeline is TODO)
├── docker-compose.yml          # Local dev stack (app + postgres)
├── scripts/                    # Setup, seed, health-check, load-test helpers
└── docs/                       # Architecture and local-dev guides
```

## Deliverables

### 1. Versioned Container Builds

The application has 10 release tags in its git history. Your tooling should support building and deploying any version by tag.

### 2. CI/CD Pipeline

A CI workflow (`.github/workflows/ci.yml`) already runs lint, build, test, and Docker build. Extend this into a full deployment pipeline:

- Build and push container images to a registry
- Multi-environment promotion: dev → staging → prod
- Deployment gates — tests must pass before promotion
- Secret management (OIDC federation preferred over static credentials)
- Immutable image tagging strategy (commit SHA, semver, or both)

A skeleton deploy workflow is provided at `.github/workflows/deploy.yml.example`.

### 3. Infrastructure as Code (Terraform)

Skeleton Terraform modules are provided under `terraform/`. The provider is pre-configured for [LocalStack](https://localstack.cloud/) — no AWS account needed.

Complete the modules:

- **Networking**: VPC with public and private subnets, NAT gateway
- **Database**: RDS PostgreSQL with encryption, proper subnet placement
- **EKS**: Cluster, managed node group, OIDC provider for IRSA
- **State management**: Remote backend with locking

### 4. Kubernetes Manifests

Base manifests exist under `k8s/base/`. They are intentionally incomplete. Add:

- Liveness, readiness, and startup probes
- Resource requests and limits
- Pod security context (`runAsNonRoot`, `readOnlyRootFilesystem`, drop capabilities)
- PodDisruptionBudget
- Environment-specific overrides in `k8s/overlays/`

### 5. GitOps and Automated Rollback

Example files are provided at `k8s/argo/`. Set up:

- ArgoCD Application manifest with sync policy (auto-sync, prune, self-heal)
- Argo Rollout with canary deployment strategy (stepped traffic: 5% → 25% → 100%)
- AnalysisTemplate that checks the health endpoint during rollout
- Automatic rollback on failed analysis

### 6. Bonus

- Improve `/api/health` to verify database connectivity
- Monitoring module in Terraform (CloudWatch or Prometheus)
- Alerting rules and dashboard definitions
- Document your approach in `SOLUTION.md`

## Getting Started

A `docker-compose.yml` and helper scripts are included. The app submodule is pinned to `v1.10`. Explore the repo and figure out how to get it running.

## Evaluation Criteria

| Area | What we look for |
|------|-----------------|
| **Infrastructure** | Security, modularity, proper networking, encryption at rest |
| **CI/CD** | Gating, environment promotion, secret handling, caching |
| **Kubernetes** | Health probes, resource management, security context, disruption budgets |
| **GitOps** | Canary strategy, automated rollback, sync policies |
| **Code quality** | Clean, documented, follows conventions |
| **Debugging** | Systematic approach to any issues you encounter |

## Time Expectation

This is a oneday-sized project. Prioritize quality over completeness — a well-documented partial solution with clear reasoning beats a rushed complete one.

## Use of AI / Agents

Feel free to use any AI help you seem fit

## Submission

Fork this repository privately, complete your work, and invite the reviewer as a collaborator. Include a `SOLUTION.md` documenting your approach, decisions, and any trade-offs.
