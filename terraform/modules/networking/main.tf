# =============================================================================
# Networking Module
# =============================================================================
# This module creates the VPC, subnets, internet gateway, and routing
# infrastructure. Candidates need to complete the private subnet and
# NAT gateway sections.
# =============================================================================

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Public Subnets
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "public"
    # Required for EKS to discover subnets for load balancers
    "kubernetes.io/role/elb" = "1"
  }
}

# TODO: Add private subnets for database and application workloads
# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------
# Hints:
#   - Use cidrsubnet(var.vpc_cidr, 8, count.index + 10) to avoid CIDR overlap
#     with public subnets
#   - Set map_public_ip_on_launch = false
#   - Tag with "kubernetes.io/role/internal-elb" = "1" for internal EKS LBs
#   - Tag with Tier = "private"
#
# resource "aws_subnet" "private" {
#   count = length(var.availability_zones)
#
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
#   availability_zone       = var.availability_zones[count.index]
#   map_public_ip_on_launch = false
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-private-${var.availability_zones[count.index]}"
#     Environment = var.environment
#     Project     = var.project_name
#     Tier        = "private"
#     "kubernetes.io/role/internal-elb" = "1"
#   }
# }

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Public Route Table
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# TODO: Add NAT Gateway for private subnet internet access
# -----------------------------------------------------------------------------
# NAT Gateway
# -----------------------------------------------------------------------------
# In production, private subnets need a NAT gateway to reach the internet
# (for pulling container images, OS updates, etc.) without being directly
# reachable from the internet.
#
# Hints:
#   - Create an aws_eip for the NAT gateway
#   - Place the NAT gateway in a public subnet
#   - For high availability, consider one NAT gateway per AZ (cost vs. resilience)
#
# resource "aws_eip" "nat" {
#   domain = "vpc"
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-nat-eip"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }
#
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-nat-gw"
#     Environment = var.environment
#     Project     = var.project_name
#   }
#
#   depends_on = [aws_internet_gateway.main]
# }

# TODO: Add private route table
# -----------------------------------------------------------------------------
# Private Route Table
# -----------------------------------------------------------------------------
# Route outbound traffic from private subnets through the NAT gateway.
#
# Hints:
#   - Default route (0.0.0.0/0) should point to the NAT gateway
#   - Associate with each private subnet
#
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }
#
#   tags = {
#     Name        = "${var.project_name}-${var.environment}-private-rt"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }
#
# resource "aws_route_table_association" "private" {
#   count = length(var.availability_zones)
#
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private.id
# }
