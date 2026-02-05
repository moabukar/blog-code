variable "project_name" {
  description = "Project name"
  type        = string
  default     = "backstage"
}

variable "environment" {
  description = "Environment (development, staging, production)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Domain name for Backstage"
  type        = string
}

variable "route53_zone_name" {
  description = "Route53 zone name"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "backstage"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "backstage"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage (GB)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "RDS max allocated storage (GB)"
  type        = number
  default     = 100
}

variable "ecs_cpu" {
  description = "ECS task CPU units"
  type        = number
  default     = 1024
}

variable "ecs_memory" {
  description = "ECS task memory (MB)"
  type        = number
  default     = 2048
}

variable "ecs_desired_count" {
  description = "ECS desired task count"
  type        = number
  default     = 2
}

variable "ecs_min_count" {
  description = "ECS minimum task count"
  type        = number
  default     = 1
}

variable "ecs_max_count" {
  description = "ECS maximum task count"
  type        = number
  default     = 10
}

variable "backstage_port" {
  description = "Backstage container port"
  type        = number
  default     = 7007
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
