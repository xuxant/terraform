variable "VPC_ID" {}
variable "masterSG" {}
variable "workerSG" {}
variable "bastionSG" {}
variable "private_subnet_1" {}
variable "private_subnet_2" {}
variable "private_subnet_3" {}
variable "public_subnet_id" {}
variable "AWS_REGION" {}
variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "key_name" {
  default = "k8s_key"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "public_key" {
  default = "instance/k8s.pub"
}

variable "private_key" {
  default = "instance/k8s"
}

variable "AMIS" {
  type = map
  default = {
    ap-southeast-1 = "ami-0007cf37783ff7e10"
    ap-southeast-2 = "ami-0f87b0a4eff45d9ce"
    ap-northeast-1 = "ami-01c36f3329957b16a"
  }
}

