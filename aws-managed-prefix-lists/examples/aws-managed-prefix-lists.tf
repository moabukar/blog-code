# aws-managed-prefix-lists.tf
# Examples of using AWS-managed prefix lists

variable "region" {
  default = "eu-west-1"
}

# Get S3 prefix list
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.region}.s3"
}

# Get DynamoDB prefix list
data "aws_prefix_list" "dynamodb" {
  name = "com.amazonaws.${var.region}.dynamodb"
}

# Get CloudFront prefix list (global)
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# Example: Security group allowing S3 egress
resource "aws_security_group_rule" "allow_s3" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.s3.id]
  security_group_id = var.security_group_id
  description       = "Allow HTTPS to S3 via prefix list"
}

# Example: ALB only accepting CloudFront traffic
resource "aws_security_group_rule" "allow_cloudfront" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = var.alb_security_group_id
  description       = "HTTPS from CloudFront only"
}

# Outputs
output "s3_prefix_list_id" {
  value = data.aws_prefix_list.s3.id
}

output "dynamodb_prefix_list_id" {
  value = data.aws_prefix_list.dynamodb.id
}

output "cloudfront_prefix_list_id" {
  value = data.aws_ec2_managed_prefix_list.cloudfront.id
}

output "cloudfront_cidr_count" {
  value       = length(data.aws_ec2_managed_prefix_list.cloudfront.entries)
  description = "Number of CloudFront edge IPs (would need this many SG rules without prefix lists!)"
}

variable "security_group_id" {
  description = "Security group ID for S3 rule"
  type        = string
  default     = ""
}

variable "alb_security_group_id" {
  description = "ALB security group ID for CloudFront rule"
  type        = string
  default     = ""
}
