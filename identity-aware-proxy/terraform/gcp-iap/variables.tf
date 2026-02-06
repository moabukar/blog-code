variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west2"
}

variable "app_name" {
  description = "Application name (used for resource naming)"
  type        = string
}

variable "support_email" {
  description = "Support email for OAuth consent screen"
  type        = string
}

variable "application_title" {
  description = "Application title shown on OAuth consent screen"
  type        = string
  default     = "Internal Applications"
}

variable "backend_port" {
  description = "Port the backend service listens on"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/health"
}

variable "backend_groups" {
  description = "List of instance group URLs for the backend"
  type        = list(string)
}

variable "allowed_users" {
  description = "List of user emails allowed to access the application"
  type        = list(string)
  default     = []
}

variable "allowed_groups" {
  description = "List of Google Groups allowed to access the application"
  type        = list(string)
  default     = []
}

variable "allowed_domain" {
  description = "Domain to allow access (e.g., 'company.com'). Leave empty to disable."
  type        = string
  default     = ""
}

variable "ssl_certificate_ids" {
  description = "List of SSL certificate resource IDs"
  type        = list(string)
}

variable "static_ip_address" {
  description = "Static IP address for the load balancer"
  type        = string
}
