# =============================================================================
# Root Outputs
# =============================================================================
# These outputs expose key infrastructure values for use by other tools,
# scripts, and CI/CD pipelines.
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "db_endpoint" {
  description = "Connection endpoint for the RDS PostgreSQL instance"
  value       = module.database.db_endpoint
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

# TODO: Add monitoring outputs once the monitoring module is implemented
# output "cloudwatch_dashboard_url" {
#   description = "URL of the CloudWatch dashboard"
#   value       = module.monitoring.dashboard_url
# }
#
# output "sns_alert_topic_arn" {
#   description = "ARN of the SNS topic for infrastructure alerts"
#   value       = module.monitoring.alert_topic_arn
# }
