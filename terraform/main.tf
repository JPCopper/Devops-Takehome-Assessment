# =============================================================================
# Main Configuration - OpsBoard Infrastructure
# =============================================================================
# This file orchestrates the infrastructure modules for the OpsBoard
# application. Candidates should review each module and complete the
# TODO items within them.
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Networking Module
# Sets up VPC, subnets, internet gateway, and routing
# -----------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b"]
}

# -----------------------------------------------------------------------------
# Database Module
# Provisions RDS PostgreSQL instance for the application
# -----------------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  environment   = var.environment
  project_name  = var.project_name
  vpc_id        = module.networking.vpc_id
  vpc_cidr      = "10.0.0.0/16"
  subnet_ids    = module.networking.public_subnet_ids
  db_instance_class = var.db_instance_class
  db_name       = var.db_name
  db_username   = "opsboard"
  db_password   = "changeme-use-secrets-manager" # TODO: Replace with a secure secret management approach (e.g., aws_secretsmanager_secret)
}

# -----------------------------------------------------------------------------
# EKS Module
# Provisions the Kubernetes cluster and node groups
# -----------------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  environment    = var.environment
  project_name   = var.project_name
  cluster_name   = "${var.project_name}-${var.environment}"
  cluster_version = var.eks_cluster_version
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.public_subnet_ids
  node_instance_type = var.node_instance_type
  node_desired_count = var.node_desired_count
  node_min_count     = 1
  node_max_count     = 4
}

# TODO: Add monitoring module
# -----------------------------------------------------------------------------
# Monitoring Module
# Provisions CloudWatch dashboards, alarms, and SNS topics for alerting
# -----------------------------------------------------------------------------
# module "monitoring" {
#   source = "./modules/monitoring"
#
#   environment        = var.environment
#   project_name       = var.project_name
#   eks_cluster_name   = module.eks.cluster_name
#   db_instance_id     = module.database.db_endpoint
#   sns_alert_email    = var.alert_email
#
#   # TODO: Implement the monitoring module with:
#   #   - CloudWatch Log Groups for application and infrastructure logs
#   #   - CloudWatch Alarms for CPU, memory, and disk utilization
#   #   - SNS Topic for alert notifications
#   #   - CloudWatch Dashboard for operational visibility
# }
