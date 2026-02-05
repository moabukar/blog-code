# Cost Control SCP: Deny expensive instance types
resource "aws_organizations_policy" "deny_expensive_instances" {
  count = var.enable_cost_controls ? 1 : 0

  name        = "deny-expensive-instance-types"
  description = "Deny launching expensive EC2 instance types"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyExpensiveInstances"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          "ForAnyValue:StringLike" = {
            "ec2:InstanceType" = var.expensive_instance_patterns
          }
        }
      }
    ]
  })
}

# Cost Control SCP: Deny expensive services (for sandbox)
resource "aws_organizations_policy" "deny_expensive_services" {
  count = var.enable_cost_controls ? 1 : 0

  name        = "deny-expensive-services"
  description = "Deny expensive services in sandbox accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyExpensiveServices"
        Effect = "Deny"
        Action = [
          "redshift:CreateCluster",
          "emr:RunJobFlow",
          "sagemaker:CreateNotebookInstance",
          "sagemaker:CreateTrainingJob",
          "sagemaker:CreateEndpoint"
        ]
        Resource = "*"
      }
    ]
  })
}
