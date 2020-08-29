# Include the VPC modules in the main file.
module "k8s_vpc" {
  source = "./vpc"
}

module "k8s_SG" {
  source = "./security_group"

  VPC_ID   = module.k8s_vpc.vpc_id
  VPC_CIDR = module.k8s_vpc.VPC_CIDR
}
