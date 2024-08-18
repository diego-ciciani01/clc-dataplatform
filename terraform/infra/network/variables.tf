################################################################################
# Common Variables
################################################################################
variable "aws_region" {
  description = "Region where to deploy the infrastructure"
  type        = string

}

variable "project" {
  type        = string
  description = "Name of the project"
  default     = "clc-dataplatform"
}

variable "organization" {
  description = "Name of the organization"
  type        = string
  default     = "Sapienza"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "assume_role_arn" {
  type        = string
  description = "The ARN of Role to assume during AWS authentication"
  default     = "arn:aws:iam::994304508204:role/EMR_EC2_DefaultRole"
}

################################################################################
# VPC
################################################################################
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "vpc_database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "vpc_create_reshift_subnet_group" {
  description = "Controls if redshit subnet group should be created (n.b. database_subnets must also be set"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the Default VPC"
  type        = bool
  default     = true
}