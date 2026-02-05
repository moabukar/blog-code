# Attach base SCPs to root
resource "aws_organizations_policy_attachment" "deny_leave_org_root" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = var.organization_root_id
}

resource "aws_organizations_policy_attachment" "deny_root_user_root" {
  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = var.organization_root_id
}

resource "aws_organizations_policy_attachment" "deny_unapproved_regions_root" {
  count     = var.enable_region_restriction ? 1 : 0
  policy_id = aws_organizations_policy.deny_unapproved_regions[0].id
  target_id = var.organization_root_id
}

# Attach security SCPs to production OU (if provided)
resource "aws_organizations_policy_attachment" "protect_security_services_prod" {
  count     = var.enable_security_guardrails && var.production_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.protect_security_services[0].id
  target_id = var.production_ou_id
}

resource "aws_organizations_policy_attachment" "require_imdsv2_prod" {
  count     = var.enable_security_guardrails && var.production_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.require_imdsv2[0].id
  target_id = var.production_ou_id
}

resource "aws_organizations_policy_attachment" "enforce_encryption_prod" {
  count     = var.enable_security_guardrails && var.production_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.enforce_encryption[0].id
  target_id = var.production_ou_id
}

# Attach cost control SCPs to sandbox OU (if provided)
resource "aws_organizations_policy_attachment" "deny_expensive_instances_sandbox" {
  count     = var.enable_cost_controls && var.sandbox_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.deny_expensive_instances[0].id
  target_id = var.sandbox_ou_id
}

resource "aws_organizations_policy_attachment" "deny_expensive_services_sandbox" {
  count     = var.enable_cost_controls && var.sandbox_ou_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.deny_expensive_services[0].id
  target_id = var.sandbox_ou_id
}
