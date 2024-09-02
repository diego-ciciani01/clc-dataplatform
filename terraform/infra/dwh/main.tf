################################################################################
# Summary: 
# - Redshift  
# - Sg
################################################################################

module "redshift" {
  source = "terraform-aws-modules/redshift/aws"

  cluster_identifier    = "${var.project}-cluster-dwh-${var.environment}"
  allow_version_upgrade = true
  node_type             = var.redshift_node_type
  number_of_nodes       = 1

  database_name          = "mydbdev"
  master_username        = "mydbuser"
  create_random_password = false
  master_password        = "Cloudcomputing2024!"

  encrypted     = false
  iam_role_arns = ["arn:aws:iam::359090434390:role/LabRole", "arn:aws:iam::359090434390:role/myRedshiftRole", "arn:aws:iam::359090434390:role/aws-service-role/redshift.amazonaws.com/AWSServiceRoleForRedshift", "arn:aws:iam::359090434390:role/EMR_Notebooks_DefaultRole"]

  enhanced_vpc_routing   = false
  subnet_ids             = ["subnet-0d1541bbd448fd42e"]
  vpc_security_group_ids = [module.dwh_sg.security_group_id]
  subnet_group_name      = "dwh-subnet-group"

  availability_zone_relocation_enabled = false


}


################################################################################
# - Sg
# security group for dwh
################################################################################
module "dwh_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  name        = "${var.project}-dwh-${var.environment}-sg"
  description = "Security Group for tableau"
  vpc_id      = "vpc-0928c23a1009a2529"
  computed_ingress_with_cidr_blocks = [
    {
      description = "Allow connections 80 vpc"
      rule        = "http-80-tcp"
      cidr_blocks = var.vpc_cidr
    },
    {
      description = "Access From Internet and Stage/Prod"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0"
    },
    {
      description = "Access From Internet"
      rule        = "custom-tcp"
      from_port   = "5432"
      to_port     = "5432"
      cidr_blocks = "0.0.0.0"
    }
  ]
}