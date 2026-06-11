# =============================================================================
# Monitoring Module - Variables
# =============================================================================

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster for log group naming"
  type        = string
}

variable "db_instance_id" {
  description = "ID of the RDS instance for alarm configuration"
  type        = string
}

variable "sns_alert_email" {
  description = "Email address to subscribe to the SNS alert topic"
  type        = string
  default     = ""
}
