# Security SCP: Protect security services
resource "aws_organizations_policy" "protect_security_services" {
  count = var.enable_security_guardrails ? 1 : 0

  name        = "protect-security-services"
  description = "Prevent disabling GuardDuty, SecurityHub, CloudTrail, Config"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectGuardDuty"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DeleteMembers",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateFromAdministratorAccount",
          "guardduty:DisassociateMembers",
          "guardduty:StopMonitoringMembers"
        ]
        Resource = "*"
      },
      {
        Sid    = "ProtectSecurityHub"
        Effect = "Deny"
        Action = [
          "securityhub:DeleteMembers",
          "securityhub:DisableSecurityHub",
          "securityhub:DisassociateFromMasterAccount",
          "securityhub:DisassociateFromAdministratorAccount",
          "securityhub:DisassociateMembers"
        ]
        Resource = "*"
      },
      {
        Sid    = "ProtectCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging"
        ]
        Resource = "*"
      },
      {
        Sid    = "ProtectConfig"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
      }
    ]
  })
}

# Security SCP: Require IMDSv2
resource "aws_organizations_policy" "require_imdsv2" {
  count = var.enable_security_guardrails ? 1 : 0

  name        = "require-ec2-imdsv2"
  description = "Require IMDSv2 for all EC2 instances"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "RequireIMDSv2"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringNotEquals = {
            "ec2:MetadataHttpTokens" = "required"
          }
        }
      }
    ]
  })
}

# Security SCP: Enforce encryption
resource "aws_organizations_policy" "enforce_encryption" {
  count = var.enable_security_guardrails ? 1 : 0

  name        = "enforce-encryption"
  description = "Enforce encryption for EBS volumes"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyUnencryptedEBSVolumes"
        Effect   = "Deny"
        Action   = "ec2:CreateVolume"
        Resource = "*"
        Condition = {
          Bool = {
            "ec2:Encrypted" = "false"
          }
        }
      }
    ]
  })
}

# Security SCP: Restrict IAM
resource "aws_organizations_policy" "restrict_iam" {
  count = var.enable_security_guardrails ? 1 : 0

  name        = "restrict-iam-actions"
  description = "Prevent creating IAM users (use federated access)"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyIAMUserCreation"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:CreateAccessKey"
        ]
        Resource = "*"
      }
    ]
  })
}
