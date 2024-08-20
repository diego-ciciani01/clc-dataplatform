terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

# provider "assume_role" {

#   region = var.aws_region

#   assume_role {
#     role_arn = var.assume_role_arn
#   }

#   default_tags {
#     tags = local.common_tags
#   }

# }

