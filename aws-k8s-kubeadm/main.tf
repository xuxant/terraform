# Include the VPC modules in the main file.
module "k8s_vpc" {
  source = "./vpc"
}

module "k8s_SG" {
  source = "./security_group"

  VPC_ID   = module.k8s_vpc.vpc_id
  VPC_CIDR = module.k8s_vpc.VPC_CIDR
}

module "k8s_Server" {
  source = "./instance"

  AWS_REGION       = var.AWS_REGION
  VPC_ID           = module.k8s_vpc.vpc_id
  masterSG         = module.k8s_SG.masterSG
  workerSG         = module.k8s_SG.workerSG
  bastionSG        = module.k8s_SG.bastionSG
  loadbalancerSG   = module.k8s_SG.loadbalancerSG
  private_subnet_1 = module.k8s_vpc.private_subnet_1
  private_subnet_2 = module.k8s_vpc.private_subnet_2
  private_subnet_3 = module.k8s_vpc.private_subnet_3
  public_subnet_id = module.k8s_vpc.public_subnet_id
}

output "bastion_ip" {
  value = module.k8s_Server.bastion_host_private_ip
}
