output "iam_role_arn" {
  description = "IAM role ARN for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "iam_role_name" {
  description = "IAM role name for External Secrets Operator"
  value       = aws_iam_role.external_secrets.name
}

output "namespace" {
  description = "Namespace where ESO is installed"
  value       = var.eso_namespace
}

output "cluster_secret_store_name" {
  description = "ClusterSecretStore name for Secrets Manager"
  value       = "aws-secrets-manager"
}

output "cluster_secret_store_ssm_name" {
  description = "ClusterSecretStore name for Parameter Store"
  value       = "aws-parameter-store"
}
