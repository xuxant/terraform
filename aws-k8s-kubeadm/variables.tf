variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "ap-northeast-1"
}

# variable "VPC_NAME" {
#   default = "SusantaK8sVPC"
# }

# variable "VPC_CIDR_BLOCK" {
#   default = "172.32.0.0/16"
# }

# variable "PUBLIC_CIDR" {
#   default = "172.32.1.0/24"
# }

# variable "PRIVATE_CIDR" {
#   type = map

#   default = {
#     private-1 = "172.16.2.0/24"
#     private-2 = "172.16.3.0/24"
#     private-3 = "172.16.4.0/24"
#   }
# }

# variable "AMI" {
#   type = map
#   default = {
#     ap-southeast-1 = "ami-0007cf37783ff7e10"
#     ap-southeast-2 = "ami-0f87b0a4eff45d9ce"
#     ap-northeast-1 = "ami-01c36f3329957b16a"
#   }
# }
