# AWS Config Rules with Auto Remediation

Companion code for the blog post: [AWS Config Rules with Auto Remediation](https://moabukar.co.uk/blog/aws-config-rules-auto-remediation)

## Contents

```
.
├── terraform/
│   ├── main.tf              # Provider and Config setup
│   ├── variables.tf         # Configuration variables
│   ├── config-recorder.tf   # Config Recorder and Delivery Channel
│   ├── iam.tf               # IAM roles for Config and remediation
│   ├── managed-rules.tf     # AWS managed Config rules
│   ├── custom-rules.tf      # Custom Guard policy rules
│   ├── remediation.tf       # Auto remediation configurations
│   ├── ssm-documents.tf     # Custom SSM Automation documents
│   └── outputs.tf           # Useful outputs
└── guard-policies/
    └── security-baseline.guard  # Guard policy examples
```

## Quick Start

```bash
cd terraform

# Initialize
terraform init

# Review plan
terraform plan

# Apply (starts Config recording and rules)
terraform apply
```

## Prerequisites

- AWS Config not already enabled in the region
- S3 bucket permissions for Config delivery
- IAM permissions to create roles and policies

## Managed Rules Included

| Rule | Description | Auto Remediation |
|------|-------------|------------------|
| S3 Encryption | Checks bucket encryption | Yes - enables AES256 |
| S3 Public Access | Checks for public buckets | Yes - blocks public access |
| S3 Versioning | Checks versioning enabled | Yes - enables versioning |
| EBS Encryption | Checks volume encryption | No - alert only |
| RDS Encryption | Checks RDS encryption | No - alert only |
| Required Tags | Checks for mandatory tags | No - alert only |
| IAM Password Policy | Checks password requirements | No - alert only |

## Custom Guard Policies

The `guard-policies/` directory contains example Guard policies:

- EC2 approved instance types
- RDS approved engine versions
- S3 logging requirements

## Testing Remediation

Create a non-compliant resource to test:

```bash
# Create unencrypted S3 bucket
aws s3api create-bucket --bucket test-unencrypted-$(date +%s) --region us-east-1

# Wait for Config to detect and remediate
aws configservice get-compliance-details-by-config-rule \
  --config-rule-name s3-bucket-server-side-encryption-enabled
```

## Cost Estimate

For ~1000 resources with 10 rules:
- Config recording: ~$30/month
- Rule evaluations: ~$10/month
- SSM Automation: Free tier covers most use cases

## License

MIT
