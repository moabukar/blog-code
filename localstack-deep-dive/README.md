# LocalStack Deep Dive - AWS on Your Laptop

Run AWS services locally for faster development and testing.

📖 **Blog Post:** [LocalStack Deep Dive](https://moabukar.co.uk/blog/localstack-deep-dive)

## Overview

LocalStack emulates 80+ AWS services locally. S3, Lambda, DynamoDB, SQS - running on your laptop. Changes take seconds, not minutes. Tests run without hitting real AWS.

## Files

```
.
├── docker-compose.yml          # LocalStack setup
├── init-aws.sh                 # Initialization script
├── terraform/
│   └── main.tf                 # Terraform with LocalStack
├── tests/
│   ├── conftest.py             # pytest fixtures
│   └── test_s3_operations.py   # Example tests
└── .github/
    └── workflows/
        └── test.yml            # CI with LocalStack
```

## Quick Start

```bash
# Start LocalStack
docker-compose up -d

# Configure AWS CLI
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Use awslocal wrapper (no endpoint needed)
pip install awscli-local
awslocal s3 mb s3://my-bucket
awslocal dynamodb list-tables
```

## Services Included (Free Tier)

| Service | Coverage |
|---------|----------|
| S3 | Full |
| DynamoDB | Full |
| Lambda | Full |
| SQS | Full |
| SNS | Full |
| Secrets Manager | Full |
| CloudWatch Logs | Full |
| API Gateway | Full |

## Quick Reference

```bash
# Start
docker-compose up -d

# AWS CLI with endpoint
aws --endpoint-url=http://localhost:4566 s3 ls

# Or use awslocal
awslocal s3 ls

# Check health
curl localhost:4566/_localstack/health

# Reset (delete all data)
docker-compose down -v && docker-compose up -d
```

## References

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [awscli-local](https://github.com/localstack/awscli-local)
