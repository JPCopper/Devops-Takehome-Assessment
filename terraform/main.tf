# =============================================================================
# Main Configuration - OpsBoard Infrastructure
# =============================================================================
# This file orchestrates the infrastructure modules for the OpsBoard
# application.
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  vpc_cidr = "10.0.0.0/16"
}

# -----------------------------------------------------------------------------
# Networking Module
# Sets up VPC, public/private subnets, NAT gateway(s), and routing
# -----------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = local.vpc_cidr

  availability_zones = ["us-east-1a", "us-east-1b"]

  single_nat_gateway = var.single_nat_gateway
}

# -----------------------------------------------------------------------------
# Database password — auto-generate if not explicitly provided
# -----------------------------------------------------------------------------
resource "random_password" "db_password" {
  length  = 32
  special = false
}

locals {
  db_password = var.db_password != "" ? var.db_password : random_password.db_password.result
}

# -----------------------------------------------------------------------------
# Database Module
# Provisions RDS PostgreSQL instance in private subnets
# -----------------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  environment   = var.environment
  project_name  = var.project_name
  vpc_id        = module.networking.vpc_id
  vpc_cidr      = local.vpc_cidr
  subnet_ids    = module.networking.private_subnet_ids
  db_instance_class = var.db_instance_class
  db_name       = var.db_name
  db_username   = var.db_username
  db_password   = local.db_password
}

# -----------------------------------------------------------------------------
# EKS Module
# Provisions the Kubernetes cluster and node groups in private subnets
# -----------------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  environment    = var.environment
  project_name   = var.project_name
  cluster_name   = "${var.project_name}-${var.environment}"
  cluster_version = var.eks_cluster_version
  vpc_id         = module.networking.vpc_id
  vpc_cidr       = local.vpc_cidr
  subnet_ids     = module.networking.private_subnet_ids
  node_instance_type = var.node_instance_type
  node_desired_count = var.node_desired_count
  node_min_count     = 1
  node_max_count     = 4
}

# -----------------------------------------------------------------------------
# Monitoring Module
# Provisions CloudWatch dashboards, alarms, and SNS topics for alerting
# -----------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  environment      = var.environment
  project_name     = var.project_name
  eks_cluster_name = module.eks.cluster_name
  db_instance_id   = module.database.db_instance_id
  sns_alert_email  = var.alert_email
}
