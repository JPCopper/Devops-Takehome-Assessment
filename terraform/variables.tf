# =============================================================================
# Root Variables
# =============================================================================
# These variables are used across the infrastructure configuration.
# Defaults are tuned for local development with LocalStack.
# =============================================================================

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "opsboard"
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "db_instance_class" {
  description = "RDS instance class for the PostgreSQL database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
  default     = "opsboard"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_count" {
  description = "Desired number of worker nodes in the EKS node group"
  type        = number
  default     = 2
}
