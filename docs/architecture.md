# Architecture

## Application

OpsBoard is a Next.js 14 application using the App Router pattern.

```
┌─────────────────────────────────────────┐
│              Browser (Client)           │
│                                         │
│  Dashboard  │  Incidents  │  Forms      │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│           Next.js Server                │
│                                         │
│  ┌──────────┐  ┌─────────────────────┐  │
│  │ Middleware│  │   API Routes        │  │
│  │ (tracing)│  │ /api/incidents      │  │
│  └──────────┘  │ /api/health         │  │
│                └──────────┬──────────┘  │
│                           │             │
│  ┌────────────────────────▼──────────┐  │
│  │         Prisma ORM                │  │
│  │  (connection pool management)     │  │
│  └────────────────────────┬──────────┘  │
└───────────────────────────┼─────────────┘
                            │
                            ▼
┌─────────────────────────────────────────┐
│           PostgreSQL 16                 │
│                                         │
│  ┌─────────┐  ┌─────────┐              │
│  │Incidents│  │  Enums  │              │
│  │  table  │  │(Severity│              │
│  │         │  │ Status) │              │
│  └─────────┘  └─────────┘              │
└─────────────────────────────────────────┘
```

## Data Model

- **Incident**: Core entity tracking operational incidents
  - Severity: SEV1 (Critical) through SEV4 (Low)
  - Status: OPEN → INVESTIGATING → MITIGATED → RESOLVED
  - Assigned to a service and optionally to a team member

## Target Production Architecture

```
┌──────────────┐     ┌──────────────────────────────┐
│   GitHub     │────▶│     GitHub Actions CI/CD     │
│   (GitOps)   │     │  build → test → deploy       │
└──────────────┘     └──────────┬───────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────┐
│                    AWS EKS                        │
│                                                   │
│  ┌─────────────┐  ┌─────────────────────────────┐ │
│  │   ArgoCD    │  │     Argo Rollouts           │ │
│  │  (GitOps    │  │  (canary deployments,       │ │
│  │   sync)     │  │   auto-rollback)            │ │
│  └─────────────┘  └─────────────────────────────┘ │
│                                                   │
│  ┌─────────────────────────────────────────────┐  │
│  │  OpsBoard Pods (Next.js)                    │  │
│  │  - Liveness probe: /api/health              │  │
│  │  - Readiness probe: /api/health/ready       │  │
│  │  - Resource limits enforced                 │  │
│  │  - Security context (non-root, read-only)   │  │
│  └─────────────────────┬───────────────────────┘  │
│                        │                          │
└────────────────────────┼──────────────────────────┘
                         │
                         ▼
┌───────────────────────────────────────────────────┐
│                 AWS RDS PostgreSQL                 │
│  - Multi-AZ deployment                            │
│  - Automated backups                              │
│  - Private subnet only                            │
└───────────────────────────────────────────────────┘
```

## Key Design Decisions

- **Next.js App Router** for server-side rendering and API routes in one project
- **Prisma** for type-safe database access with migrations
- **PostgreSQL** as the primary data store
- **Docker Compose** for local development parity with production
