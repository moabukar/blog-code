variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for interface endpoints"
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route table IDs for gateway endpoints"
  type        = list(string)
}

variable "enable_s3_endpoint" {
  description = "Enable S3 gateway endpoint (FREE)"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB gateway endpoint (FREE)"
  type        = bool
  default     = true
}

variable "interface_endpoints" {
  description = "List of interface endpoints to create"
  type        = list(string)
  default = [
    "secretsmanager",
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs",
    "ecr.api",
    "ecr.dkr",
    "kms",
    "sts"
  ]
}

variable "enable_endpoint_policies" {
  description = "Enable restrictive endpoint policies"
  type        = bool
  default     = false
}

variable "allowed_s3_buckets" {
  description = "S3 buckets allowed through endpoint policy"
  type        = list(string)
  default     = []
}
