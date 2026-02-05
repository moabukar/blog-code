# Building Production AMIs with Packer

Complete infrastructure code for building immutable AMIs with Packer, deploying with Terraform, and managing the full lifecycle.

## Blog Post

📖 **[Read the full blog post](https://moabukar.co.uk/blog/packer-ami-production)**

## What's Included

```
packer-ami-production/
├── packer/
│   ├── app-ami.pkr.hcl           # Main Packer template
│   ├── variables.pkr.hcl         # Shared variables
│   └── scripts/
│       ├── base-setup.sh         # OS hardening, base packages
│       ├── app-install.sh        # Application installation
│       ├── cleanup.sh            # Pre-AMI cleanup
│       └── cis-hardening.sh      # CIS benchmark hardening
├── terraform/
│   ├── modules/
│   │   └── asg/                  # Auto Scaling Group module
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── user-data.sh
│   └── environments/
│       ├── staging/
│       │   └── main.tf
│       └── production/
│           └── main.tf
├── .github/
│   └── workflows/
│       └── packer-build.yml      # CI pipeline for AMI builds
├── scripts/
│   ├── rollback.sh               # Manual rollback script
│   └── cleanup-old-amis.sh       # AMI cleanup script
└── lambda/
    └── cleanup_amis.py           # Lambda for scheduled cleanup
```

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Packer | >= 1.9.0 | AMI builds |
| Terraform | >= 1.5.0 | Infrastructure deployment |
| AWS CLI | >= 2.0 | Authentication |

## Quick Start

### 1. Configure AWS credentials

```bash
aws configure
# Or use environment variables / IAM role
```

### 2. Build an AMI

```bash
cd packer

# Initialize Packer plugins
packer init .

# Validate template
packer validate \
  -var="app_version=v1.0.0" \
  -var="vpc_id=vpc-xxx" \
  -var="subnet_id=subnet-xxx" \
  app-ami.pkr.hcl

# Build AMI
packer build \
  -var="app_version=v1.0.0" \
  -var="vpc_id=vpc-xxx" \
  -var="subnet_id=subnet-xxx" \
  app-ami.pkr.hcl
```

### 3. Deploy with Terraform

```bash
cd terraform/environments/staging

terraform init
terraform plan
terraform apply
```

## Key Concepts

### Immutable Infrastructure

Every deployment creates a new AMI. No configuration drift, instant rollbacks, full audit trail.

### Rolling Updates

ASG instance refresh handles zero-downtime deployments:
- Keeps 75% of instances healthy during update
- Automatic health check validation
- Configurable warmup period

### Rollback Strategies

1. **Terraform rollback** - Change `ami_version` and apply
2. **Manual ASG update** - Use `scripts/rollback.sh`
3. **Blue-green** - Switch ALB target groups

### Security

- No SSH keys baked into AMIs
- IMDSv2 enforced
- Encrypted root volumes
- CIS benchmark hardening available
- Secrets fetched at runtime (Secrets Manager / SSM)

## CI/CD Flow

```
Code Push → Packer Build → AMI Created → SSM Parameter Updated → Terraform Apply → ASG Rolling Update
```

## License

MIT
