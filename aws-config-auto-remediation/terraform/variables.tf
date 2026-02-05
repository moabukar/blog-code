variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "config_bucket_prefix" {
  description = "Prefix for Config S3 bucket name"
  type        = string
  default     = "aws-config-recordings"
}

variable "enable_auto_remediation" {
  description = "Enable automatic remediation for supported rules"
  type        = bool
  default     = true
}

variable "required_tags" {
  description = "Tags that must be present on resources"
  type        = list(string)
  default     = ["Environment", "Owner", "CostCenter"]
}

variable "remediation_retry_attempts" {
  description = "Number of retry attempts for remediation"
  type        = number
  default     = 5
}

variable "remediation_retry_seconds" {
  description = "Seconds between retry attempts"
  type        = number
  default     = 60
}

variable "concurrent_execution_percentage" {
  description = "Percentage of resources to remediate concurrently"
  type        = number
  default     = 25
}

variable "error_percentage" {
  description = "Stop remediation if error rate exceeds this percentage"
  type        = number
  default     = 25
}
