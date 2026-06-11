# =============================================================================
# Database Module - Outputs
# =============================================================================

output "db_endpoint" {
  description = "Connection endpoint for the RDS instance (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "Port the RDS instance is listening on"
  value       = aws_db_instance.main.port
}

output "db_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}
