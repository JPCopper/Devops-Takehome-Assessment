# =============================================================================
# Database Module - Variables
# =============================================================================

variable "vpc_id" {
  description = "ID of the VPC where the database will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used for security group rules"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class (e.g., db.t3.micro, db.r6g.large)"
  type        = string
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "opsboard"
}

variable "db_password" {
  description = "Master password for the database. Use Secrets Manager in production."
  type        = string
  sensitive   = true
}
