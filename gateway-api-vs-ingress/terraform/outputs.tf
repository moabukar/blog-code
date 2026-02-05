output "gateway_namespace" {
  description = "Namespace where Gateway resources are deployed"
  value       = kubernetes_namespace.gateway_infra.metadata[0].name
}

output "gateway_class_name" {
  description = "Name of the GatewayClass"
  value       = var.gateway_class_name
}

output "gateway_name" {
  description = "Name of the Gateway"
  value       = var.gateway_name
}

output "gateway_hostname" {
  description = "Hostname pattern configured on Gateway"
  value       = var.gateway_hostname
}

output "kubectl_get_gateway" {
  description = "Command to check Gateway status"
  value       = "kubectl get gateway ${var.gateway_name} -n ${var.gateway_namespace} -o yaml"
}

output "kubectl_get_routes" {
  description = "Command to list all HTTPRoutes"
  value       = "kubectl get httproute -A -o wide"
}
