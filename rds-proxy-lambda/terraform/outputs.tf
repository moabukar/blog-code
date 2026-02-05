# outputs.tf - Useful outputs

output "rds_proxy_endpoint" {
  value       = aws_db_proxy.main.endpoint
  description = "RDS Proxy endpoint - use this in Lambda instead of RDS endpoint"
}

output "rds_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "Direct RDS endpoint (for admin access, not Lambda)"
}

output "lambda_function_name" {
  value       = aws_lambda_function.api.function_name
  description = "Lambda function name"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.api.arn
  description = "Lambda function ARN"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "db_credentials_secret_arn" {
  value       = aws_secretsmanager_secret.db_credentials.arn
  description = "Secrets Manager ARN for DB credentials"
}
