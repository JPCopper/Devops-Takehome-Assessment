# =============================================================================
# Database Module
# =============================================================================
# This module provisions an RDS PostgreSQL instance for the OpsBoard
# application. The security group is provided; candidates must complete
# the subnet group and RDS instance configuration.
#
# Production considerations:
#   - Enable Multi-AZ for high availability
#   - Use a longer backup retention period (7+ days)
#   - Enable encryption at rest (storage_encrypted = true)
#   - Enable enhanced monitoring
#   - Use AWS Secrets Manager for credentials instead of plaintext
#   - Place the instance in private subnets only
#   - Enable deletion protection for production workloads
#   - Configure performance insights for query analysis
# =============================================================================

# -----------------------------------------------------------------------------
# Security Group for RDS
# -----------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL access from within the VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# TODO: Create a DB subnet group
# -----------------------------------------------------------------------------
# DB Subnet Group
# -----------------------------------------------------------------------------
# The subnet group tells RDS which subnets it can use. For production,
# these should be private subnets spanning multiple AZs.
#
# resource "aws_db_subnet_group" "main" {
#   name       = "${var.project_name}-${var.environment}-db-subnet"
#   subnet_ids = var.subnet_ids
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-db-subnet-group"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# TODO: Create the RDS PostgreSQL instance
# -----------------------------------------------------------------------------
# RDS PostgreSQL Instance
# -----------------------------------------------------------------------------
# Implement the RDS instance with the parameters below. Pay attention to
# which settings are appropriate for dev vs. production environments.
#
# resource "aws_db_instance" "main" {
#   identifier     = "${var.project_name}-${var.environment}-db"
#
#   # Engine configuration
#   engine         = "postgres"
#   engine_version = "15.4"
#   instance_class = var.db_instance_class
#
#   # Storage
#   allocated_storage     = 20
#   max_allocated_storage = 100    # Enable storage autoscaling
#   storage_type          = "gp3"
#   storage_encrypted     = true
#
#   # Database configuration
#   db_name  = var.db_name
#   username = var.db_username
#   password = var.db_password
#   port     = 5432
#
#   # Network and security
#   db_subnet_group_name   = aws_db_subnet_group.main.name
#   vpc_security_group_ids = [aws_security_group.rds.id]
#   publicly_accessible    = false
#
#   # High availability and backups
#   multi_az                  = var.environment == "production" ? true : false
#   backup_retention_period   = var.environment == "production" ? 7 : 1
#   backup_window             = "03:00-04:00"
#   maintenance_window        = "Mon:04:00-Mon:05:00"
#   copy_tags_to_snapshot     = true
#   deletion_protection       = var.environment == "production" ? true : false
#   skip_final_snapshot       = var.environment == "production" ? false : true
#   final_snapshot_identifier = var.environment == "production" ? "${var.project_name}-${var.environment}-final-snapshot" : null
#
#   # Monitoring
#   performance_insights_enabled = true
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-db"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }
