# Transfer the public key to the server
resource "aws_key_pair" "k8s_key" {
  key_name   = var.key_name
  public_key = file(var.public_key)
}

# Create Internal Loadbalancer for the instance
resource "aws_lb" "internal_lb" {
  name               = "master-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [var.private_subnet_1, var.private_subnet_2, var.private_subnet_3]

  tags = {
    Name = "k8sAPILB"
  }
}

# Create Master Nodes

data "aws_subnet_ids" "selected" {
  vpc_id = var.VPC_ID

  tags = {
    purpose = "k8s-subnet"
  }
  depends_on = [aws_lb.internal_lb]
}


# Create Master Nodes
resource "aws_instance" "master_node" {
  count                  = 3
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [var.masterSG]
  subnet_id              = tolist(data.aws_subnet_ids.selected.ids)[count.index]

  tags = {
    Name = "MasterNode"
    role = "master"
    app  = "kubernetes"
  }
  depends_on = [aws_lb.internal_lb]
}

# Create worker nodes.
resource "aws_instance" "worker_node" {
  count                  = 3
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [var.masterSG]
  subnet_id              = tolist(data.aws_subnet_ids.selected.ids)[count.index]

  tags = {
    Name = "WorkerNode"
    role = "workload"
  }
  depends_on = [aws_lb.internal_lb]
}



# Provision the listner and target group for the Network loadbalancer.

resource "aws_lb_target_group" "master_lb" {
  name        = "masterlb-tg"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = var.VPC_ID
  target_type = "ip"

  depends_on = [aws_instance.master_node]

}

data "aws_instances" "selected" {
  instance_tags = {
    app  = "kubernetes"
    role = "master"
  }
  instance_state_names = ["running"]
  depends_on           = [aws_instance.master_node]
}

resource "aws_lb_target_group_attachment" "master_lb" {
  count            = 3
  target_group_arn = aws_lb_target_group.master_lb.arn
  target_id        = tolist(data.aws_instances.selected.private_ips)[count.index]
}


resource "aws_lb_listener" "master" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.master_lb.arn
  }
}


resource "aws_lb" "external_lb" {
  name               = "ingress-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet_id]

  tags = {
    Name = "k8sIngressLb"
    app  = "kubernetes"
  }
}

data "aws_instances" "workernodes" {
  instance_tags = {
    Name = "WorkerNode"
  }
  instance_state_names = ["running"]
  depends_on           = [aws_instance.worker_node]
}


# Create the Jump/Bastion Instance

resource "template_dir" "hosts" {
  source_dir      = "templates"
  destination_dir = "hostfiles"

  vars = {
    master-1_address = aws_instance.master_node[0].private_ip
    master-2_address = aws_instance.master_node[1].private_ip
    master-3_address = aws_instance.master_node[2].private_ip
    internal_lb_dns  = aws_lb.internal_lb.dns_name
    worker_node_1    = aws_instance.worker_node[0].private_ip
    worker_node_2    = aws_instance.worker_node[1].private_ip
    worker_node_3    = aws_instance.worker_node[2].private_ip
  }
}


resource "aws_instance" "bastion_host" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  availability_zone      = data.aws_availability_zones.available.names[0]
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [var.bastionSG]
  subnet_id              = var.public_subnet_id

  tags = {
    Name = "bastion"
    role = "jump"
    app  = "kubernetes"
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "hostfiles/hosts.yaml"
    destination = "/tmp/ansible/hosts.yaml"
  }

  provisioner "file" {
    source      = var.private_key
    destination = "/home/ubuntu/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = var.private_key
    destination = "/tmp/ansible/k8s"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/ubuntu/.ssh/id_rsa",
      "chmod +x /tmp/ansible/shell.sh",
      "bash /tmp/ansible/shell.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.private_key)
    host        = self.public_ip
  }

  depends_on = [aws_instance.master_node, aws_instance.worker_node]
}

