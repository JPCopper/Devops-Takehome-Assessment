-- Create enums and tables for OpsBoard
-- Runs automatically on first postgres start via docker-entrypoint-initdb.d

CREATE TYPE "Severity" AS ENUM ('SEV1', 'SEV2', 'SEV3', 'SEV4');
CREATE TYPE "Status" AS ENUM ('OPEN', 'INVESTIGATING', 'MITIGATED', 'RESOLVED');

CREATE TABLE "Incident" (
  "id" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "severity" "Severity" NOT NULL DEFAULT 'SEV3',
  "status" "Status" NOT NULL DEFAULT 'OPEN',
  "service" TEXT NOT NULL,
  "assignee" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "resolvedAt" TIMESTAMP(3),
  CONSTRAINT "Incident_pkey" PRIMARY KEY ("id")
);

-- Seed data
INSERT INTO "Incident" ("id", "title", "description", "severity", "status", "service", "assignee", "createdAt", "updatedAt") VALUES
  ('inc_001', 'API gateway returning 502', 'Multiple users reporting 502 errors from the API gateway. Load balancer health checks are failing.', 'SEV1', 'INVESTIGATING', 'api-gateway', 'oncall-team', NOW() - INTERVAL '2 hours', NOW()),
  ('inc_002', 'Database replication lag > 30s', 'Read replica is lagging behind primary by over 30 seconds during peak traffic.', 'SEV2', 'OPEN', 'postgres-cluster', NULL, NOW() - INTERVAL '1 hour', NOW()),
  ('inc_003', 'Memory usage spike on worker nodes', 'Worker pods exceeding 90% memory utilization, risking OOM kills.', 'SEV2', 'MITIGATED', 'k8s-workers', 'platform-eng', NOW() - INTERVAL '4 hours', NOW()),
  ('inc_004', 'SSL certificate expiring in 7 days', 'Production wildcard cert expires next week. Renewal process started.', 'SEV3', 'OPEN', 'ingress', 'security-team', NOW() - INTERVAL '1 day', NOW()),
  ('inc_005', 'CDN cache hit ratio dropped below 60%', 'Cache invalidation during deployment caused a sustained drop in hit ratio.', 'SEV3', 'RESOLVED', 'cdn', 'frontend-team', NOW() - INTERVAL '3 days', NOW());
