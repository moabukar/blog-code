# AWS Service Control Policies (SCPs)

Companion code for the blog post: [AWS Service Control Policies (SCPs) - Guardrails for Your Organization](https://moabukar.co.uk/blog/aws-service-control-policies)

## Contents

```
.
├── terraform/
│   ├── main.tf              # Provider configuration
│   ├── variables.tf         # Configuration variables
│   ├── scps-base.tf         # Base SCPs (region, leave org)
│   ├── scps-security.tf     # Security guardrails
│   ├── scps-cost.tf         # Cost control SCPs
│   ├── attachments.tf       # Policy attachments
│   └── outputs.tf           # Useful outputs
└── policies/
    ├── deny-regions.json
    ├── deny-leave-org.json
    ├── protect-security-services.json
    ├── require-imdsv2.json
    └── deny-expensive-instances.json
```

## Quick Start

```bash
cd terraform

# Set your organization details
export TF_VAR_organization_root_id="r-xxxx"
export TF_VAR_production_ou_id="ou-xxxx-xxxxxxxx"
export TF_VAR_sandbox_ou_id="ou-xxxx-xxxxxxxx"

# Initialize and apply
terraform init
terraform plan
terraform apply
```

## SCPs Included

| SCP | Target | Description |
|-----|--------|-------------|
| deny-leave-organization | Root | Prevent accounts from leaving org |
| deny-unapproved-regions | Root | Restrict to approved regions only |
| protect-security-services | Production OU | Prevent disabling GuardDuty, SecurityHub, CloudTrail |
| require-imdsv2 | Production OU | Require IMDSv2 for EC2 instances |
| deny-expensive-instances | Sandbox OU | Block large/GPU instance types |
| deny-root-user | Root | Prevent root user actions |

## Testing

1. Create a test OU: `aws organizations create-organizational-unit --parent-id r-xxxx --name scp-testing`
2. Attach SCP to test OU only
3. Move a test account to the OU
4. Verify actions are denied as expected
5. Check CloudTrail for denial reasons

## Important Notes

- SCPs don't affect the management account
- Service-linked roles are exempt from SCPs
- Always include global services in region restrictions
- Test thoroughly before attaching to production

## License

MIT
