# BlockExplorer — DevOps Take-Home

## Context

BlockExplorer is a golang/react blockchain explorer, backed by PostgreSQL. Your team inherited it from a previous contractor. The app runs locally and the codebase has 5 release tags (`v1.1`–`v1.5`), but there is no deployment pipeline, no infrastructure-as-code, and no automated recovery.

**Your task: make this application production-ready.**

## Repository Layout

```
.
├── cmd/server/main.go      # Application entry point
├── internal/
│   ├── api/
│   │   ├── handlers.go     # HTTP handlers
│   │   └── router.go       # Router setup + static file serving
│   └── db/
│       ├── db.go           # Database connection + queries
│       └── models.go       # Data models
├── frontend/               # React SPA (Vite + TypeScript)
│   ├── src/
│   │   ├── pages/
│   │   │   ├── Blocks.tsx
│   │   │   └── BlockDetail.tsx
│   │   ├── App.tsx
│   │   └── main.tsx
│   └── package.json
├── db/
│   ├── schema.sql          # Database DDL
│   └── seed.sql            # Sample data
├── Dockerfile              # Multi-stage build
└── README.md
```

## Deliverables

### 1. Versioned Container Builds

The application has 5 release tags in its git history. Your tooling should support building and deploying any version by tag.

### 2. CI/CD Pipeline

A CI workflow (`.github/workflows/ci.yml`) already runs lint, build, test, and Docker build. Extend this into a full deployment pipeline:

- Build and push container image(s) to a registry
- Multi-environment promotion: dev → staging → prod
- Deployment gates — there should exist confirmation before deployment into production
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
- Pod security context (`runAsNonRoot`, `readOnlyRootFilesystem`, drop capabilitie etc)
- PodDisruptionBudget
- Environment-specific overrides in `k8s/overlays/`

### 5. GitOps and Automated Rollback

Example files are provided at `k8s/argo/`. Set up:

- ArgoCD Application manifest with sync policy (auto-sync, prune, self-heal)
- Argo Rollout with canary deployment strategy (stepped traffic: 5% → 25% → 100%)
- AnalysisTemplate that checks the health endpoint during rollout
- Automatic rollback on failed analysis

### 6. Bonus

- Monitoring module in Terraform (CloudWatch or Prometheus)
- Alerting rules and dashboard definitions
- Document your approach in `SOLUTION.md`

## Getting Started

A `docker-compose.yml` and helper scripts are included. The app submodule is pinned to `v1.5`. Explore the repo and figure out how to get it running.

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

This is a oneday-sized project. Prioritize quality over completeness — a well-documented, partial solution that has clear reasoning always beats a rushed, complete one that you cannot explain.

Prioritise clearly documented, well-reasoned changes.

## Use of AI / Agents

You are free to use any AI you think will help - consider adding agents.md/skills.md/claude.md if so.

## Submission

Fork this repository privately, complete your work, and invite the reviewer as a collaborator. Include a `SOLUTION.md` documenting your approach, decisions, and any trade-offs.
