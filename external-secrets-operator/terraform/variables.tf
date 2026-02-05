variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "EKS cluster OIDC provider ARN"
  type        = string
}

variable "cluster_oidc_provider_url" {
  description = "EKS cluster OIDC provider URL (without https://)"
  type        = string
}

variable "secrets_path_prefix" {
  description = "Secrets Manager path prefix to allow access to"
  type        = string
  default     = "app/*"
}

variable "eso_namespace" {
  description = "Namespace for External Secrets Operator"
  type        = string
  default     = "external-secrets"
}

variable "eso_chart_version" {
  description = "External Secrets Operator Helm chart version"
  type        = string
  default     = "0.9.11"
}
