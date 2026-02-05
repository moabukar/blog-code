output "s3_endpoint_id" {
  description = "S3 Gateway Endpoint ID"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "dynamodb_endpoint_id" {
  description = "DynamoDB Gateway Endpoint ID"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "interface_endpoint_ids" {
  description = "Interface Endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "interface_endpoint_dns_names" {
  description = "Interface Endpoint DNS Names"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.dns_entry[0].dns_name }
}

output "security_group_id" {
  description = "VPC Endpoints Security Group ID"
  value       = aws_security_group.vpc_endpoints.id
}

output "monthly_cost_estimate" {
  description = "Estimated monthly cost for interface endpoints"
  value       = format("$%.2f/month (excluding data processing)", length(var.interface_endpoints) * length(var.private_subnet_ids) * 0.01 * 730)
}
