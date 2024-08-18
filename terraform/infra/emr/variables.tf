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
# EMR
################################################################################
variable "master_instance_type" {
  description = "master node instance type"
  type        = string
  default     = "c1.medium"
}

variable "principal_instance_type" {
  description = "principal node instance type"
  type        = string
  default     = "c4.large"
}

variable "task_instance_type" {
  description = "task node instance type"
  type        = string
  default     = "c4.large"
}

variable "iam_role_arn" {
  description = "the iam role arn to EMR tasks"
  type        = string
  default     = "arn:aws:iam::994304508204:role/EMR_DefaultRole"
}