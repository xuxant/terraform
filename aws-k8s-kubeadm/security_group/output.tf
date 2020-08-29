# Output the variables that might be required in other modules

output "masterSG" {
  value       = aws_security_group.master_nodes
  description = "Security Group for master node."
}

output "workerSG" {
  value       = aws_security_group.worker_nodes
  description = "Security Group for master node."
}

output "workerSG" {
  value       = aws_security_group.bastian_server
  description = "Security Group for master node."
}
