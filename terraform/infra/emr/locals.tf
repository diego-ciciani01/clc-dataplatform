locals {
  common_tags = {
    Environment  = var.environment
    Terraform    = true
    Project      = var.project
    organization = var.organization
  }
}