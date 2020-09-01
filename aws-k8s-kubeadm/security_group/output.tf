# Output the variables that might be required in other modules

output "masterSG" {
  value       = aws_security_group.master_nodes.id
  description = "Security Group for master node."
}

output "workerSG" {
  value       = aws_security_group.worker_nodes.id
  description = "Security Group for master node."
}

output "bastionSG" {
  value       = aws_security_group.bastian_server.id
  description = "Security Group for master node."
}

output "loadbalancerSG" {
  value       = aws_security_group.loadbalancer.id
  description = "Security Group for ingress lb."
}
