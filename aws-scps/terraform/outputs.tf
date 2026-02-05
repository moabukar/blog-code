output "scp_ids" {
  description = "IDs of all created SCPs"
  value = {
    deny_leave_org             = aws_organizations_policy.deny_leave_org.id
    deny_root_user             = aws_organizations_policy.deny_root_user.id
    deny_unapproved_regions    = var.enable_region_restriction ? aws_organizations_policy.deny_unapproved_regions[0].id : null
    protect_security_services  = var.enable_security_guardrails ? aws_organizations_policy.protect_security_services[0].id : null
    require_imdsv2             = var.enable_security_guardrails ? aws_organizations_policy.require_imdsv2[0].id : null
    enforce_encryption         = var.enable_security_guardrails ? aws_organizations_policy.enforce_encryption[0].id : null
    restrict_iam               = var.enable_security_guardrails ? aws_organizations_policy.restrict_iam[0].id : null
    deny_expensive_instances   = var.enable_cost_controls ? aws_organizations_policy.deny_expensive_instances[0].id : null
    deny_expensive_services    = var.enable_cost_controls ? aws_organizations_policy.deny_expensive_services[0].id : null
  }
}

output "approved_regions" {
  description = "List of approved regions"
  value       = var.approved_regions
}

output "organization_id" {
  description = "Organization ID"
  value       = data.aws_organizations_organization.current.id
}

output "console_url" {
  description = "URL to view SCPs in AWS Console"
  value       = "https://console.aws.amazon.com/organizations/v2/home/policies/service-control-policy"
}
