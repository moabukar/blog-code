output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.backstage.dns_name
}

output "backstage_url" {
  description = "Backstage URL"
  value       = "https://${var.domain_name}"
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.backstage.id
}

output "cognito_domain" {
  description = "Cognito domain"
  value       = "https://${aws_cognito_user_pool_domain.backstage.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.backstage.repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.backstage.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.backstage.name
}
