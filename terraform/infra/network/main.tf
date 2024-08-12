################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project}-${var.environment}"
  cidr = var.vpc_cidr

  azs              = data.aws_availability_zones.current.names
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  database_subnets = var.vpc_database_subnets

  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_nat_gateway   = var.vpc_enable_nat_gateway
  single_nat_gateway   = var.vpc_single_nat_gateway


  create_database_subnet_group = var.vpc_create_database_subnet_group
}