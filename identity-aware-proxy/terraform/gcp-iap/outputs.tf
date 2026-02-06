output "iap_client_id" {
  description = "OAuth2 client ID for IAP"
  value       = google_iap_client.default.client_id
}

output "iap_client_secret" {
  description = "OAuth2 client secret for IAP"
  value       = google_iap_client.default.secret
  sensitive   = true
}

output "backend_service_id" {
  description = "Backend service ID"
  value       = google_compute_backend_service.app.id
}

output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = google_compute_global_forwarding_rule.app.ip_address
}

output "iap_brand_name" {
  description = "IAP brand name (for additional clients)"
  value       = google_iap_brand.default.name
}
