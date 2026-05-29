# =============================================================================
# Database Module - Outputs
# =============================================================================

# TODO: Uncomment after implementing the aws_db_instance resource
# output "db_endpoint" {
#   description = "Connection endpoint for the RDS instance (host:port)"
#   value       = aws_db_instance.main.endpoint
# }

# TODO: Uncomment after implementing the aws_db_instance resource
# output "db_port" {
#   description = "Port the RDS instance is listening on"
#   value       = aws_db_instance.main.port
# }

output "db_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

# IMPORTANT: These are placeholder outputs so the root module can
# reference them before the RDS instance is implemented.
# When you uncomment the real outputs above, DELETE these placeholders
# to avoid duplicate output errors.
output "db_endpoint" {
  description = "Connection endpoint for the RDS instance (placeholder)"
  value       = "TODO: implement aws_db_instance"
}

output "db_port" {
  description = "Port the RDS instance is listening on (placeholder)"
  value       = 5432
}
