# Create the security group for the Jump Server, Master Nodes and Worker Nodes.
resource "aws_security_group" "bastian_server" {
  name        = "bastionSG"
  description = "Rules for bastion host."
  vpc_id      = var.VPC_ID

  ingress {
    description = "SSH from PUBLIC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ingress accepting loadbalancer
resource "aws_security_group" "loadbalancer" {
  name        = "ingressSG"
  description = "Rules for ingress."
  vpc_id      = var.VPC_ID

  ingress {
    description = "http for ingress traffic."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https for ingress traffic."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "master_nodes" {
  name        = "MasterNodeSG"
  description = "Security Group for Master Nodes"
  vpc_id      = var.VPC_ID

  ingress {
    description = "API Server port"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "ETCD port access"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "SSH within the Cluster"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "Weave UPD Port"
    from_port   = 6783
    to_port     = 6784
    protocol    = "udp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "Weave TCP Port"
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "Kube Controller Manager and Kube Scheduler"
    from_port   = 10251
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "Kubelet API One"
    from_port   = 20255
    to_port     = 20256
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "worker_nodes" {
  name        = "WorkerNodeSG"
  description = "Security Group for Worker Nodes"
  vpc_id      = var.VPC_ID

  ingress {
    description = "Weave UPD Port"
    from_port   = 6783
    to_port     = 6784
    protocol    = "udp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "SSH Port Within the VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "Weave TCP Port"
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "NodePort"
    from_port   = 30000
    to_port     = 32000
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  ingress {
    description = "Kubelet API One"
    from_port   = 20255
    to_port     = 20256
    protocol    = "tcp"
    cidr_blocks = [var.VPC_CIDR]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
