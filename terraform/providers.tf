# =============================================================================
# Provider Configuration - Configured for LocalStack
# =============================================================================
# This provider configuration targets LocalStack for local development
# and testing. All AWS service endpoints are overridden to point to
# the local LocalStack instance.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true

  endpoints {
    s3             = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    ecs            = "http://localhost:4566"
    eks            = "http://localhost:4566"
    rds            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    elb            = "http://localhost:4566"
    elbv2          = "http://localhost:4566"
    route53        = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}
