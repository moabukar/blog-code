# terraform/modules/asg/variables.tf

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "environment" {
  type        = string
  description = "Environment (staging, production)"
}

variable "ami_version" {
  type        = string
  default     = "latest"
  description = "AMI version tag or 'latest'"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type"
}

variable "min_size" {
  type        = number
  default     = 2
  description = "Minimum number of instances"
}

variable "max_size" {
  type        = number
  default     = 10
  description = "Maximum number of instances"
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "Desired number of instances"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ASG"
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "List of target group ARNs for the ASG"
}

variable "alb_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group IDs of the ALB (for ingress rules)"
}
