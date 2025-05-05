variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  default     = "us-central1"
  description = "GCP region"
}

variable "cluster_name" {
  default     = "mtls-demo"
  description = "Name of your GKE Autopilot cluster"
}
