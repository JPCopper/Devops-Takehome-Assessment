# =============================================================================
# Networking Module - Outputs
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

# TODO: Uncomment after implementing private subnets
# output "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   value       = aws_subnet.private[*].id
# }

# TODO: Uncomment after implementing the NAT gateway
# output "nat_gateway_id" {
#   description = "ID of the NAT gateway"
#   value       = aws_nat_gateway.main.id
# }
