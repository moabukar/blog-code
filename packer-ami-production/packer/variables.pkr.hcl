# variables.pkr.hcl
# Shared variables for Packer templates

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region for AMI builds"
}

variable "app_name" {
  type        = string
  default     = "myapp"
  description = "Application name - used in AMI naming and tags"
}

variable "environment" {
  type        = string
  default     = "all"
  description = "Environment tag - 'all' means AMI can be used in any environment"
}

variable "owner" {
  type        = string
  default     = "platform-team"
  description = "Owner tag for cost allocation"
}
