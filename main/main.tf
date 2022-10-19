provider "aws" {
  region = "ap-east-1"
}

module "networking" {
  source = "../modules/networking"
  
  name = var.name
  vpc_cidr_block = var.vpc_cidr_block
  map_az_subnet = var.map_az_subnet
}

module "sg" {
  source = "../modules/sg"

  vpc = module.networking.vpc
}

module "elb" {
  source = "../modules/elb"

  name = var.name
  instance_type = var.instance_type
  sg = module.sg.sg
  vpc = module.networking.vpc
  key_pair = var.key_pair
  image_id = var.image_id
  efs_dns_name = module.efs.efs_dns_name
  efs_mount_target = module.efs.efs_mount_target
}

module "efs" {
  source = "../modules/efs"

  name = var.name
  vpc = module.networking.vpc
  sg = module.sg.sg
}
