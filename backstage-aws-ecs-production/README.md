# Backstage on AWS ECS - Production Deployment

Deploy Spotify's Backstage developer portal on AWS ECS Fargate with RDS and Cognito.

📖 **Blog Post:** [Backstage on AWS ECS - Production-Ready Deployment](https://moabukar.co.uk/blog/backstage-aws-ecs-production)

## Overview

Production-ready Backstage deployment on AWS with:
- ECS Fargate (serverless containers)
- PostgreSQL RDS (database)
- Cognito (authentication)
- ALB with HTTPS (load balancing)
- Secrets Manager (credential management)

## Architecture

```
Users ──► ALB ──► ECS Fargate (Backstage)
                      │           │
                      ▼           ▼
                   Cognito    RDS PostgreSQL
```

## Files

```
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── rds.tf
│   ├── ecs.tf
│   ├── alb.tf
│   ├── cognito.tf
│   ├── ecr.tf
│   ├── iam.tf
│   └── cloudwatch.tf
├── backstage/
│   ├── Dockerfile
│   └── app-config.production.yaml
└── .github/
    └── workflows/
        └── deploy.yml
```

## Prerequisites

- Terraform >= 1.5
- AWS CLI >= 2.0
- Docker >= 24
- Node.js >= 18

## Quick Start

```bash
# Initialize and apply Terraform
cd terraform
terraform init
terraform plan -var-file=production.tfvars
terraform apply -var-file=production.tfvars

# Build and push Docker image
cd ../backstage
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.eu-west-1.amazonaws.com
docker build -t backstage .
docker tag backstage:latest <account>.dkr.ecr.eu-west-1.amazonaws.com/backstage/backstage:latest
docker push <account>.dkr.ecr.eu-west-1.amazonaws.com/backstage/backstage:latest

# Force new deployment
aws ecs update-service --cluster backstage-cluster --service backstage --force-new-deployment
```

## Cost Estimate

| Environment | Monthly Cost |
|-------------|-------------|
| Development | ~$115/month |
| Production  | ~$412/month |

## References

- [Backstage Documentation](https://backstage.io/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide)
