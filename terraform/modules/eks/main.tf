# =============================================================================
# EKS Module
# =============================================================================
# This module provisions an EKS cluster and managed node groups.
# The IAM role for the cluster control plane is provided; candidates
# must complete the cluster resource, node group, and OIDC configuration.
#
# Key concepts:
#   - The EKS cluster IAM role allows the EKS service to manage AWS
#     resources on your behalf.
#   - The node group IAM role allows worker nodes to call AWS APIs
#     (e.g., pulling images from ECR, writing logs to CloudWatch).
#   - IRSA (IAM Roles for Service Accounts) lets individual Kubernetes
#     pods assume specific IAM roles via an OIDC provider.
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for EKS Cluster
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

# TODO: Create the EKS cluster resource
# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------
# Implement the EKS cluster with the configuration below.
#
# resource "aws_eks_cluster" "main" {
#   name     = var.cluster_name
#   version  = var.cluster_version
#   role_arn = aws_iam_role.eks_cluster.arn
#
#   vpc_config {
#     subnet_ids              = var.subnet_ids
#     endpoint_private_access = true
#     endpoint_public_access  = true
#     security_group_ids      = [aws_security_group.eks_cluster.id]
#   }
#
#   # Ensure IAM role permissions are created before the cluster
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_cluster_policy,
#     aws_iam_role_policy_attachment.eks_service_policy,
#   ]
#
#   tags = {
#     Name        = var.cluster_name
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# TODO: Create a security group for the EKS cluster
# -----------------------------------------------------------------------------
# EKS Cluster Security Group
# -----------------------------------------------------------------------------
# resource "aws_security_group" "eks_cluster" {
#   name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
#   description = "Security group for EKS cluster control plane"
#   vpc_id      = var.vpc_id
#
#   ingress {
#     description = "Allow HTTPS from within VPC"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"]
#   }
#
#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# TODO: Create the EKS managed node group
# -----------------------------------------------------------------------------
# EKS Node Group
# -----------------------------------------------------------------------------
# Hints:
#   - Create an IAM role for the node group with the following policies:
#     * AmazonEKSWorkerNodePolicy
#     * AmazonEKS_CNI_Policy
#     * AmazonEC2ContainerRegistryReadOnly
#   - Configure scaling (min, max, desired)
#   - Specify instance types and disk size
#   - Use the same subnets as the cluster
#
# resource "aws_iam_role" "eks_nodes" {
#   name = "${var.project_name}-${var.environment}-eks-node-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-eks-node-role"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }
#
# resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_nodes.name
# }
#
# resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_nodes.name
# }
#
# resource "aws_iam_role_policy_attachment" "ecr_read_only" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_nodes.name
# }
#
# resource "aws_eks_node_group" "main" {
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = "${var.project_name}-${var.environment}-nodes"
#   node_role_arn   = aws_iam_role.eks_nodes.arn
#   subnet_ids      = var.subnet_ids
#
#   instance_types = [var.node_instance_type]
#
#   scaling_config {
#     desired_size = var.node_desired_count
#     min_size     = var.node_min_count
#     max_size     = var.node_max_count
#   }
#
#   update_config {
#     max_unavailable = 1
#   }
#
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_worker_node_policy,
#     aws_iam_role_policy_attachment.eks_cni_policy,
#     aws_iam_role_policy_attachment.ecr_read_only,
#   ]
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-node-group"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# TODO: Set up OIDC provider for IRSA (IAM Roles for Service Accounts)
# -----------------------------------------------------------------------------
# OIDC Provider for IRSA
# -----------------------------------------------------------------------------
# IRSA allows Kubernetes service accounts to assume IAM roles, enabling
# fine-grained access control for pods. This is the recommended approach
# for granting AWS permissions to workloads running on EKS.
#
# Steps:
#   1. Extract the OIDC issuer URL from the EKS cluster
#   2. Fetch the TLS certificate thumbprint
#   3. Create an aws_iam_openid_connect_provider resource
#
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
