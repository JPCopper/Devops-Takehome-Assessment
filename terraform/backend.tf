# =============================================================================
# Backend Configuration
# =============================================================================
# Terraform state is stored in S3 with DynamoDB-based locking to support
# team collaboration and CI/CD pipelines. For local development with
# LocalStack, the endpoints are overridden. For real AWS, remove the
# endpoints block and use proper AWS credentials.
# =============================================================================

terraform {
  backend "s3" {
    bucket         = "opsboard-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "opsboard-terraform-locks"

    # LocalStack endpoint overrides (remove for real AWS)
    endpoints = {
      s3       = "http://localhost:4566"
      dynamodb = "http://localhost:4566"
    }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
