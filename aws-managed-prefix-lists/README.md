# AWS Managed Prefix Lists with Terraform

Stop hardcoding CIDR blocks. Use prefix lists for reusable, maintainable network security.

📖 **Blog Post:** [AWS Managed Prefix Lists with Terraform](https://moabukar.co.uk/blog/aws-managed-prefix-lists-terraform)

## Contents

```
aws-managed-prefix-lists/
├── examples/
│   ├── prefix-lists.tf                    # Customer-managed prefix lists
│   ├── aws-managed-prefix-lists.tf        # Using AWS-managed prefix lists
│   ├── security-group-with-prefix-lists.tf # Security group examples
│   └── ram-sharing.tf                     # Cross-account sharing via RAM
├── modules/
│   └── app-security-group/
│       └── main.tf                        # Reusable SG module with prefix lists
└── README.md
```

## What Are Prefix Lists?

A prefix list is a named collection of CIDR blocks. Reference it once, use it everywhere.

| Type | Description |
|------|-------------|
| **AWS-Managed** | Maintained by AWS (S3, DynamoDB, CloudFront IPs) |
| **Customer-Managed** | You create and maintain (offices, data centres, partners) |

## Quick Start

### 1. Create Customer-Managed Prefix Lists

```hcl
resource "aws_ec2_managed_prefix_list" "offices" {
  name           = "corporate-offices"
  address_family = "IPv4"
  max_entries    = 20

  entry {
    cidr        = "203.0.113.0/24"
    description = "London HQ"
  }
}
```

### 2. Use in Security Groups

```hcl
resource "aws_security_group_rule" "allow_offices" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [aws_ec2_managed_prefix_list.offices.id]
  security_group_id = aws_security_group.app.id
}
```

### 3. Use AWS-Managed Prefix Lists

```hcl
# CloudFront edge IPs (400+ locations, 1 rule)
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "allow_cloudfront" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.alb.id
}
```

## AWS-Managed Prefix Lists

| Name | Contains |
|------|----------|
| `com.amazonaws.{region}.s3` | S3 gateway endpoint IPs |
| `com.amazonaws.{region}.dynamodb` | DynamoDB endpoint IPs |
| `com.amazonaws.global.cloudfront.origin-facing` | All CloudFront edge IPs |

## Benefits

| Without Prefix Lists | With Prefix Lists |
|----------------------|-------------------|
| 50 CIDRs = 50 SG rules | 50 CIDRs = 1 SG rule |
| Edit SGs when IPs change | Edit prefix list once |
| Duplicated across accounts | Share via RAM |
| Manual CloudFront IP updates | Auto-updated by AWS |

## Module Usage

```hcl
module "app_sg" {
  source = "./modules/app-security-group"

  name   = "my-application"
  vpc_id = aws_vpc.main.id

  prefix_list_ids = {
    offices     = aws_ec2_managed_prefix_list.offices.id
    datacentres = aws_ec2_managed_prefix_list.datacentres.id
    partners    = aws_ec2_managed_prefix_list.partners.id
  }
}
```

## License

MIT
