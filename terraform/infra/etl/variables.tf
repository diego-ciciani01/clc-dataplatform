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

variable "lab_role" {
  type        = string
  description = "The ARN of Role to assume during AWS authentication"
  default     = "arn:aws:iam::994304508204:role/LabRole"
}

################################################################################
# Glue 
################################################################################

