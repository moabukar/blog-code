variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "domain_prefix" {
  description = "Prefix for Cognito hosted UI domain"
  type        = string
}

variable "mfa_enabled" {
  description = "Enable MFA for the user pool"
  type        = bool
  default     = false
}

variable "callback_urls" {
  description = "List of callback URLs for OAuth"
  type        = list(string)
}

variable "logout_urls" {
  description = "List of logout URLs"
  type        = list(string)
  default     = []
}

# Federation
variable "enable_federation" {
  description = "Enable SAML federation with external IdP"
  type        = bool
  default     = false
}

variable "idp_provider_name" {
  description = "Name of the SAML identity provider"
  type        = string
  default     = "Okta"
}

variable "saml_metadata_url" {
  description = "SAML metadata URL from your IdP"
  type        = string
  default     = ""
}

# ALB
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "alb_security_groups" {
  description = "Security groups for the ALB"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

# Backend
variable "backend_port" {
  description = "Port the backend listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "host_headers" {
  description = "Host headers to match for the listener rule"
  type        = list(string)
}

variable "session_timeout" {
  description = "Session timeout in seconds"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
