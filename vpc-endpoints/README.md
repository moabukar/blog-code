# AWS VPC Endpoints

Companion code for the blog post: [AWS VPC Endpoints - Keep Your Traffic Off the Internet](https://moabukar.co.uk/blog/aws-vpc-endpoints-deep-dive)

## Contents

```
.
└── terraform/
    ├── main.tf              # Provider and data sources
    ├── variables.tf         # Configuration variables
    ├── gateway-endpoints.tf # S3 and DynamoDB (FREE)
    ├── interface-endpoints.tf # PrivateLink endpoints
    ├── security-groups.tf   # Endpoint security groups
    ├── endpoint-policies.tf # Restrictive endpoint policies
    └── outputs.tf           # Endpoint IDs and DNS names
```

## Quick Start

```bash
cd terraform

# Set your VPC details
export TF_VAR_vpc_id="vpc-xxx"
export TF_VAR_private_subnet_ids='["subnet-xxx", "subnet-yyy"]'
export TF_VAR_route_table_ids='["rtb-xxx", "rtb-yyy"]'

terraform init
terraform plan
terraform apply
```

## Endpoints Included

### Gateway Endpoints (FREE)

| Service | Cost | Notes |
|---------|------|-------|
| S3 | Free | Always use - no reason not to |
| DynamoDB | Free | Always use - no reason not to |

### Interface Endpoints (~$7.50/month/AZ each)

| Service | Required For |
|---------|--------------|
| secretsmanager | Secrets access from Lambda/ECS |
| ssm | Parameter Store, Session Manager |
| ssmmessages | Session Manager |
| ec2messages | Session Manager |
| logs | CloudWatch Logs |
| ecr.api | ECR authentication |
| ecr.dkr | Docker image pulls |
| kms | Encryption operations |
| sts | AssumeRole |

## Cost Estimate

For 2 AZs with 9 interface endpoints:
- Hourly: 9 × 2 × $0.01 × 730 = ~$131/month
- Plus $0.01/GB data processed

## Testing

```bash
# Verify S3 endpoint works
aws s3 ls --region eu-west-1

# Check endpoint DNS resolution
nslookup secretsmanager.eu-west-1.amazonaws.com

# List endpoint ENIs
aws ec2 describe-network-interfaces \
  --filters "Name=interface-type,Values=vpc_endpoint"
```

## License

MIT
