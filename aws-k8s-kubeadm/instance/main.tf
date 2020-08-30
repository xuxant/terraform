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
  subnets            = [var.private_subnet_1, var.private_subnet_2, var.private_subnet_3, var.public_subnet_id]

  tags = {
    Name = "k8sAPILB"
  }
}

# Create Master Nodes

# You can create the master Server this way too but the master instances will be forced to replaced whenever the new plan is applied.

# data "aws_subnet_ids" "selected" {
#   vpc_id = var.VPC_ID

#   tags = {
#     purpose = "k8s-subnet"
#   }
#   depends_on = [aws_lb.internal_lb]
# }


# # Create Master Nodes
# resource "aws_instance" "master_node" {
#   count = 3
#   ami   = lookup(var.AMIS, var.AWS_REGION)
#   #   availability_zone      = data.aws_availability_zones.available.names[0]
#   instance_type          = "t2.medium"
#   key_name               = var.key_name
#   vpc_security_group_ids = [var.masterSG]
#   subnet_id              = tolist(data.aws_subnet_ids.selected.ids)[count.index]

#   tags = {
#     Name = "MasterNode"
#     role = "master"
#   }
#   depends_on = [aws_lb.internal_lb]
# }

resource "aws_instance" "master_node-1" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  availability_zone      = data.aws_availability_zones.available.names[0]
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [var.masterSG]
  subnet_id              = var.private_subnet_1

  tags = {
    Name = "MasterNode-1"
    role = "master"
    app  = "kubernetes"
  }
  depends_on = [aws_lb.internal_lb]
}

resource "aws_instance" "master_node-2" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  availability_zone      = data.aws_availability_zones.available.names[1]
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [var.masterSG]
  subnet_id              = var.private_subnet_2

  tags = {
    Name = "MasterNode-2"
    role = "master"
    app  = "kubernetes"
  }
  depends_on = [aws_lb.internal_lb]
}

resource "aws_instance" "master_node-3" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  availability_zone      = data.aws_availability_zones.available.names[2]
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [var.masterSG]
  subnet_id              = var.private_subnet_3

  tags = {
    app  = "kubernetes"
    Name = "MasterNode-3"
    role = "master"
  }
  depends_on = [aws_lb.internal_lb]
}

# Provision the listner and target group for the Network loadbalancer.
resource "aws_lb_target_group" "master_lb" {
  name        = "masterlb-tg"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = var.VPC_ID
  target_type = "instance"

  depends_on = [aws_instance.master_node-1, aws_instance.master_node-2, aws_instance.master_node-3]

}

data "aws_instances" "selected" {
  instance_tags = {
    app  = "kubernetes"
    role = "master"
  }
  instance_state_names = ["running"]
  depends_on           = [aws_instance.master_node-1, aws_instance.master_node-2, aws_instance.master_node-3]
}

resource "aws_lb_target_group_attachment" "master-lb" {
  count            = 3
  target_group_arn = aws_lb_target_group.master_lb.arn
  target_id        = tolist(data.aws_instances.selected.ids)[count.index]
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


# Create the Jump/Bastion Instance

resource "template_dir" "hosts" {
  source_dir      = "templates"
  destination_dir = "hostfiles"

  vars = {
    master-1_address = aws_instance.master_node-1.private_ip
    master-2_address = aws_instance.master_node-2.private_ip
    master-3_address = aws_instance.master_node-3.private_ip
    internal_lb_dns  = aws_lb.internal_lb.dns_name
  }
}


resource "aws_instance" "bastion-host" {
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
    destination = "/tmp/ansible/k8s"
  }

  provisioner "remote-exec" {
    inline = [
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

  depends_on = [aws_instance.master_node-3]
}

# Send Ansibles files to the bastion hosts
