# Outputting the variables that may be required by others modules.
output "vpc_id" {
  value       = aws_vpc.k8s_vpc.id
  description = "The VPC id of the the VPC SusantaK8sVPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "Id of the public subnet."
}

output "private_subnet_1" {
  value       = aws_subnet.private_subnet_one.id
  description = "Id of the private subnet one."
}

output "private_subnet_2" {
  value       = aws_subnet.private_subnet_two.id
  description = "Id of the private subnet one."
}

output "private_subnet_3" {
  value       = aws_subnet.private_subnet_three.id
  description = "Id of the private subnet one."
}

output "VPC_CIDR" {
  value       = var.VPC_CIDR_BLOCK
  description = "CIDR that have been applied to the VPC."
}
