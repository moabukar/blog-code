output "config_bucket_name" {
  description = "S3 bucket for Config recordings"
  value       = aws_s3_bucket.config.id
}

output "config_role_arn" {
  description = "IAM role ARN for Config service"
  value       = aws_iam_role.config.arn
}

output "remediation_role_arn" {
  description = "IAM role ARN for remediation actions"
  value       = aws_iam_role.config_remediation.arn
}

output "managed_rules" {
  description = "List of managed Config rules"
  value = [
    aws_config_config_rule.s3_encryption.name,
    aws_config_config_rule.s3_public_read.name,
    aws_config_config_rule.s3_public_write.name,
    aws_config_config_rule.s3_versioning.name,
    aws_config_config_rule.ebs_encryption.name,
    aws_config_config_rule.rds_encryption.name,
    aws_config_config_rule.rds_public_access.name,
    aws_config_config_rule.ec2_imdsv2.name,
    aws_config_config_rule.required_tags.name,
    aws_config_config_rule.cloudtrail_enabled.name,
    aws_config_config_rule.vpc_flow_logs.name,
    aws_config_config_rule.sg_ssh_restricted.name,
    aws_config_config_rule.root_mfa.name,
  ]
}

output "custom_rules" {
  description = "List of custom Config rules"
  value = [
    aws_config_config_rule.ec2_instance_types.name,
    aws_config_config_rule.s3_logging_required.name,
    aws_config_config_rule.no_public_subnets.name,
  ]
}

output "ssm_documents" {
  description = "Custom SSM automation documents"
  value = [
    aws_ssm_document.enable_s3_versioning.name,
    aws_ssm_document.enable_imdsv2.name,
    aws_ssm_document.tag_non_compliant.name,
    aws_ssm_document.stop_ec2_instance.name,
  ]
}

output "compliance_dashboard_url" {
  description = "URL to AWS Config compliance dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/config/home?region=${data.aws_region.current.name}#/dashboard"
}
