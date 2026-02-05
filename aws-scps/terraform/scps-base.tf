# Base SCP: Deny leaving organization
resource "aws_organizations_policy" "deny_leave_org" {
  name        = "deny-leave-organization"
  description = "Prevent accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })
}

# Base SCP: Deny root user actions
resource "aws_organizations_policy" "deny_root_user" {
  name        = "deny-root-user-actions"
  description = "Deny most actions for root user in member accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

# Base SCP: Deny unapproved regions
resource "aws_organizations_policy" "deny_unapproved_regions" {
  count = var.enable_region_restriction ? 1 : 0

  name        = "deny-unapproved-regions"
  description = "Deny actions outside approved regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnapprovedRegions"
        Effect = "Deny"
        NotAction = [
          # Global services that must be accessible
          "a4b:*",
          "access-analyzer:*",
          "account:*",
          "acm:*",
          "aws-portal:*",
          "budgets:*",
          "ce:*",
          "chime:*",
          "cloudfront:*",
          "config:*",
          "cur:*",
          "globalaccelerator:*",
          "health:*",
          "iam:*",
          "importexport:*",
          "mobileanalytics:*",
          "organizations:*",
          "pricing:*",
          "route53:*",
          "route53domains:*",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "shield:*",
          "sts:*",
          "support:*",
          "trustedadvisor:*",
          "waf:*",
          "wafv2:*",
          "wellarchitected:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.approved_regions
          }
        }
      }
    ]
  })
}
