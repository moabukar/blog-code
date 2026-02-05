# LocalStack Deep Dive - AWS on Your Laptop

Run AWS services locally for faster development and testing.

📖 **Blog Post:** [LocalStack Deep Dive - AWS on Your Laptop](https://moabukar.co.uk/blog/localstack-deep-dive)

## Contents

```
localstack-deep-dive/
├── docker-compose.yml        # LocalStack setup
├── python/
│   ├── s3_example.py         # S3 operations
│   └── lambda_example.py     # Lambda operations
├── terraform/
│   └── main.tf               # Terraform with LocalStack
└── README.md
```

## Quick Start

```bash
# Start LocalStack
docker-compose up -d

# Configure AWS CLI
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Test S3
aws s3 mb s3://my-bucket
aws s3 cp myfile.txt s3://my-bucket/
aws s3 ls s3://my-bucket/
```

## Python Examples

```bash
cd python
pip install boto3
python s3_example.py
python lambda_example.py
```

## Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Supported Services (Free Tier)

- S3 (Object Storage)
- Lambda (Serverless Functions)
- DynamoDB (NoSQL Database)
- SQS (Message Queue)
- SNS (Notifications)
- CloudWatch (Logs)
- IAM (Identity)
- Secrets Manager
- And more...

## License

MIT
