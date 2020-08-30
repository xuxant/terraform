data "aws_availability_zones" "available" {
  state = "available"
}

variable "VPC_NAME" {
  default = "SusantaK8sVPC"
}

variable "VPC_CIDR_BLOCK" {
  default = "172.32.0.0/16"
}

variable "PUBLIC_CIDR" {
  default = "172.32.1.0/24"
}

variable "PRIVATE_CIDR" {
  type = map

  default = {
    private-1 = "172.32.2.0/24"
    private-2 = "172.32.3.0/24"
    private-3 = "172.32.4.0/24"
  }
}
