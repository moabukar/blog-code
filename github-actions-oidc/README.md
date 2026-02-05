# GitHub Actions OIDC with AWS

Authenticate GitHub Actions to AWS without storing secrets.

📖 **Blog Post:** [GitHub Actions OIDC - Ditch the AWS Access Keys](https://moabukar.co.uk/blog/github-actions-oidc)

## Contents

```
github-actions-oidc/
├── terraform/
│   └── main.tf                    # OIDC provider + IAM role
├── .github/workflows/
│   └── deploy.yml                 # Example workflow
└── README.md
```

## How It Works

```
GitHub Actions → Request JWT → GitHub OIDC Provider
                                      │
                                      ▼
                              AssumeRoleWithWebIdentity
                                      │
                                      ▼
                              AWS IAM Role → Temp Credentials
```

No secrets stored. Credentials valid for 1 hour max.

## Setup

### 1. Deploy Terraform

```bash
cd terraform
terraform init
terraform apply \
  -var="github_org=myorg" \
  -var="github_repo=myrepo"
```

### 2. Update Workflow

Replace the role ARN in `.github/workflows/deploy.yml`:

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT:role/github-actions-myrepo
    aws-region: eu-west-1
```

### 3. Add Permissions

```yaml
permissions:
  id-token: write   # Required for OIDC!
  contents: read
```

## Token Claims

Control access with IAM conditions on the `sub` claim:

| Scope | Condition Value |
|-------|-----------------|
| Any branch | `repo:org/repo:*` |
| Specific branch | `repo:org/repo:ref:refs/heads/main` |
| Pull requests | `repo:org/repo:pull_request` |
| Tags | `repo:org/repo:ref:refs/tags/*` |
| Environment | `repo:org/repo:environment:production` |

## Security Tips

1. Always scope to specific repos/branches
2. Use least-privilege IAM policies
3. Enable CloudTrail for audit logs
4. Use environments for production deployments

## License

MIT
