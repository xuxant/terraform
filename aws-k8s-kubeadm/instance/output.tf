output "bastion_host_private_ip" {
  value       = aws_instance.bastion_host.private_ip
  description = "Private IP of the bastion host."
}
