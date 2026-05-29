# =============================================================================
# Backend Configuration
# =============================================================================
# By default, Terraform state is stored locally. For production use,
# enable the S3 backend below to store state remotely with locking.
# =============================================================================

# TODO: Enable remote state storage for team collaboration and CI/CD.
#       Uncomment the block below and create the S3 bucket and DynamoDB
#       table before running `terraform init`.
#
# terraform {
#   backend "s3" {
#     bucket         = "opsboard-terraform-state"
#     key            = "infrastructure/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "opsboard-terraform-locks"
#     profile        = "localstack"
#
#     # LocalStack endpoint overrides (remove for real AWS)
#     endpoints = {
#       s3       = "http://localhost:4566"
#       dynamodb = "http://localhost:4566"
#     }
#
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#   }
# }
