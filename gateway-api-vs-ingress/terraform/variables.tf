variable "gateway_api_version" {
  description = "Gateway API CRD version to install"
  type        = string
  default     = "v1.2.0"
}

variable "gateway_class_name" {
  description = "Name of the GatewayClass"
  type        = string
  default     = "nginx"
}

variable "gateway_controller" {
  description = "Controller name for GatewayClass"
  type        = string
  default     = "gateway.nginx.org/nginx-gateway-controller"
}

variable "gateway_name" {
  description = "Name of the Gateway"
  type        = string
  default     = "main-gateway"
}

variable "gateway_namespace" {
  description = "Namespace for Gateway resources"
  type        = string
  default     = "infra"
}

variable "gateway_hostname" {
  description = "Hostname pattern for Gateway listeners"
  type        = string
  default     = "*.example.com"
}

variable "tls_secret_name" {
  description = "Name of TLS secret for HTTPS listener"
  type        = string
  default     = "wildcard-tls"
}

variable "allowed_namespaces" {
  description = "Namespace selector for allowed routes"
  type        = map(string)
  default = {
    "gateway-access" = "true"
  }
}
