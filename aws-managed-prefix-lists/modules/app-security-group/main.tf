# modules/app-security-group/main.tf
# Production-ready security group module using prefix lists

variable "name" {
  description = "Security group name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "prefix_list_ids" {
  description = "Prefix lists for ingress access"
  type = object({
    offices     = string
    datacentres = string
    partners    = optional(string)
  })
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "enable_cloudfront" {
  description = "Allow ingress from CloudFront"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

# Get CloudFront prefix list
data "aws_ec2_managed_prefix_list" "cloudfront" {
  count = var.enable_cloudfront ? 1 : 0
  name  = "com.amazonaws.global.cloudfront.origin-facing"
}

# Security group
resource "aws_security_group" "this" {
  name        = var.name
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = var.name
  })
}

# HTTPS from offices
resource "aws_security_group_rule" "https_offices" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [var.prefix_list_ids.offices]
  security_group_id = aws_security_group.this.id
  description       = "HTTPS from corporate offices"
}

# HTTPS from data centres
resource "aws_security_group_rule" "https_datacentres" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [var.prefix_list_ids.datacentres]
  security_group_id = aws_security_group.this.id
  description       = "HTTPS from data centres"
}

# HTTPS from CloudFront (optional)
resource "aws_security_group_rule" "https_cloudfront" {
  count = var.enable_cloudfront ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront[0].id]
  security_group_id = aws_security_group.this.id
  description       = "HTTPS from CloudFront"
}

# App port from partners (optional)
resource "aws_security_group_rule" "app_partners" {
  count = var.prefix_list_ids.partners != null ? 1 : 0

  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  prefix_list_ids   = [var.prefix_list_ids.partners]
  security_group_id = aws_security_group.this.id
  description       = "App port from partners"
}

# Egress - all outbound
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound"
}

# Outputs
output "security_group_id" {
  value       = aws_security_group.this.id
  description = "Security group ID"
}

output "security_group_arn" {
  value       = aws_security_group.this.arn
  description = "Security group ARN"
}
