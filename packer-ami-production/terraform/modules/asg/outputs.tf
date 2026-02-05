# terraform/modules/asg/outputs.tf

output "asg_name" {
  value       = aws_autoscaling_group.app.name
  description = "Name of the Auto Scaling Group"
}

output "asg_arn" {
  value       = aws_autoscaling_group.app.arn
  description = "ARN of the Auto Scaling Group"
}

output "launch_template_id" {
  value       = aws_launch_template.app.id
  description = "ID of the Launch Template"
}

output "launch_template_latest_version" {
  value       = aws_launch_template.app.latest_version
  description = "Latest version of the Launch Template"
}

output "security_group_id" {
  value       = aws_security_group.app.id
  description = "ID of the instance security group"
}

output "iam_role_arn" {
  value       = aws_iam_role.app.arn
  description = "ARN of the instance IAM role"
}
