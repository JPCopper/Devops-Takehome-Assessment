# =============================================================================
# EKS Module - Outputs
# =============================================================================

# TODO: Uncomment after implementing the aws_eks_cluster resource
# output "cluster_endpoint" {
#   description = "Endpoint URL for the EKS cluster API server"
#   value       = aws_eks_cluster.main.endpoint
# }

# TODO: Uncomment after implementing the aws_eks_cluster resource
# output "cluster_name" {
#   description = "Name of the EKS cluster"
#   value       = aws_eks_cluster.main.name
# }

# TODO: Uncomment after implementing the aws_eks_cluster resource
# output "cluster_certificate_authority" {
#   description = "Base64-encoded certificate authority data for the cluster"
#   value       = aws_eks_cluster.main.certificate_authority[0].data
# }

# IMPORTANT: These are placeholder outputs so the root module can
# reference them before the EKS cluster is implemented.
# When you uncomment the real outputs above, DELETE these placeholders
# to avoid duplicate output errors.
output "cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster API server (placeholder)"
  value       = "TODO: implement aws_eks_cluster"
}

output "cluster_name" {
  description = "Name of the EKS cluster (placeholder)"
  value       = var.cluster_name
}

output "cluster_certificate_authority" {
  description = "Base64-encoded certificate authority data (placeholder)"
  value       = "TODO: implement aws_eks_cluster"
}
