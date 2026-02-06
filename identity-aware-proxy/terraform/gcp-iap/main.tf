# GCP Identity Aware Proxy Configuration
# =======================================
# This configuration sets up IAP for a backend service on GCP.

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "iap" {
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# OAuth consent screen (brand)
resource "google_iap_brand" "default" {
  support_email     = var.support_email
  application_title = var.application_title
  project           = var.project_id

  depends_on = [google_project_service.iap]
}

# OAuth client for IAP
resource "google_iap_client" "default" {
  display_name = "IAP Client - ${var.application_title}"
  brand        = google_iap_brand.default.name
}

# Health check for backend
resource "google_compute_health_check" "app" {
  name               = "${var.app_name}-health-check"
  check_interval_sec = 10
  timeout_sec        = 5

  http_health_check {
    port         = var.backend_port
    request_path = var.health_check_path
  }
}

# Backend service with IAP enabled
resource "google_compute_backend_service" "app" {
  name        = "${var.app_name}-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  health_checks = [google_compute_health_check.app.id]

  # Enable IAP
  iap {
    oauth2_client_id     = google_iap_client.default.client_id
    oauth2_client_secret = google_iap_client.default.secret
  }

  # Backend configuration - adjust based on your setup
  dynamic "backend" {
    for_each = var.backend_groups
    content {
      group           = backend.value
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1.0
    }
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  depends_on = [google_project_service.compute]
}

# IAP access for specific users
resource "google_iap_web_backend_service_iam_member" "users" {
  for_each = toset(var.allowed_users)

  project             = var.project_id
  web_backend_service = google_compute_backend_service.app.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = "user:${each.value}"
}

# IAP access for groups
resource "google_iap_web_backend_service_iam_member" "groups" {
  for_each = toset(var.allowed_groups)

  project             = var.project_id
  web_backend_service = google_compute_backend_service.app.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = "group:${each.value}"
}

# IAP access for entire domain (optional)
resource "google_iap_web_backend_service_iam_member" "domain" {
  count = var.allowed_domain != "" ? 1 : 0

  project             = var.project_id
  web_backend_service = google_compute_backend_service.app.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = "domain:${var.allowed_domain}"
}

# URL Map (for HTTPS Load Balancer)
resource "google_compute_url_map" "app" {
  name            = "${var.app_name}-url-map"
  default_service = google_compute_backend_service.app.id
}

# HTTPS Proxy
resource "google_compute_target_https_proxy" "app" {
  name             = "${var.app_name}-https-proxy"
  url_map          = google_compute_url_map.app.id
  ssl_certificates = var.ssl_certificate_ids
}

# Global Forwarding Rule (external IP)
resource "google_compute_global_forwarding_rule" "app" {
  name       = "${var.app_name}-forwarding-rule"
  target     = google_compute_target_https_proxy.app.id
  port_range = "443"
  ip_address = var.static_ip_address
}
