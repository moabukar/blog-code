variable "organization_root_id" {
  description = "Root ID of the AWS Organization (e.g., r-xxxx)"
  type        = string
}

variable "production_ou_id" {
  description = "Production OU ID"
  type        = string
  default     = ""
}

variable "sandbox_ou_id" {
  description = "Sandbox OU ID"
  type        = string
  default     = ""
}

variable "approved_regions" {
  description = "List of approved AWS regions"
  type        = list(string)
  default     = ["eu-west-1", "eu-west-2", "us-east-1"]
}

variable "enable_region_restriction" {
  description = "Enable region restriction SCP"
  type        = bool
  default     = true
}

variable "enable_security_guardrails" {
  description = "Enable security guardrails SCP"
  type        = bool
  default     = true
}

variable "enable_cost_controls" {
  description = "Enable cost control SCPs"
  type        = bool
  default     = true
}

variable "expensive_instance_patterns" {
  description = "Instance type patterns to deny"
  type        = list(string)
  default = [
    "*.metal",
    "*.24xlarge",
    "*.16xlarge",
    "*.12xlarge",
    "p*.*",
    "inf*.*",
    "dl*.*"
  ]
}
