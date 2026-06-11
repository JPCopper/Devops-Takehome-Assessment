#!/usr/bin/env bash
# =============================================================================
# init-backend.sh — Bootstrap the Terraform S3/DynamoDB backend in LocalStack
# =============================================================================
# This script creates the S3 bucket and DynamoDB table required by the
# Terraform remote backend. Run this once before `terraform init`.
#
# Usage: ./scripts/init-backend.sh
# =============================================================================

set -euo pipefail

BUCKET="${TF_BACKEND_BUCKET:-opsboard-terraform-state}"
TABLE="${TF_BACKEND_TABLE:-opsboard-terraform-locks}"
REGION="${AWS_REGION:-us-east-1}"
ENDPOINT="${LOCALSTACK_ENDPOINT:-http://localhost:4566}"

echo "==> Creating S3 bucket: ${BUCKET}"
aws --endpoint-url="${ENDPOINT}" s3 mb "s3://${BUCKET}" --region "${REGION}" 2>/dev/null || echo "Bucket '${BUCKET}' already exists"

echo "==> Creating DynamoDB table: ${TABLE}"
aws --endpoint-url="${ENDPOINT}" dynamodb create-table \
  --table-name "${TABLE}" \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}" 2>/dev/null || echo "Table '${TABLE}' already exists"

echo "==> Backend bootstrap complete."
