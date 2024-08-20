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
  default     = "sapienza"
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
# Redshift
################################################################################
variable "redshift_node_type" {
  type        = string
  description = "The node type to be provisioned for the cluster"
  default     = "dc2.large"

}

################################################################################
# VPC
################################################################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}