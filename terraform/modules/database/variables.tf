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

variable "db_type" {
  description = "Type of the database (e.g., mysql, postgresql)"
  type        = string
  default     = "postgres"
}

variable "db_version" {
  description = "Version of the database"
  type        = string
  default     = "15.4"
}

variable "allocated_storage" {
  description = "Initial storage allocated for the database"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage allocated for the database"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Type of storage to use for the database"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Whether the storage should be encrypted"
  type        = bool
  default     = true
}

variable "db_port" {
  description = "Port for the database"
  type        = number
  default     = 5432
}

variable "backup_window" {
  description = "Time window for database backups"
  type        = string
  default     = "03:00-04:00"
}

variable "backup_retention_period" {
  description = "Retention period for database backups"
  type        = number
  default     = 7
}

variable "maintenance_window" {
  description = "Time window for database maintenance"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "publicly_accessible" {
  description = "Whether the database should be publicly accessible"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights for the database"
  type        = bool
  default     = true
}