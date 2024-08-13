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
# Datalake Variables
################################################################################
variable "days_after_transition_to_ia" {
  type        = map(number)
  description = "Number of days after which objects should transition to IA class"
  default = {
    "bronze" : 30,
    "silver" : 60
  }
}