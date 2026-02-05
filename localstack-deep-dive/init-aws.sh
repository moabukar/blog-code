#!/bin/bash
# LocalStack initialization script
# This runs automatically when LocalStack starts

set -e

echo "Initializing LocalStack resources..."

# Create S3 bucket
awslocal s3 mb s3://app-bucket
awslocal s3 mb s3://data-bucket

# Create DynamoDB table
awslocal dynamodb create-table \
  --table-name Users \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Create SQS queue
awslocal sqs create-queue --queue-name app-queue
awslocal sqs create-queue --queue-name dead-letter-queue

# Create SNS topic
awslocal sns create-topic --name app-notifications

# Subscribe SQS to SNS
awslocal sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:app-notifications \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:us-east-1:000000000000:app-queue

# Create secret
awslocal secretsmanager create-secret \
  --name app/database \
  --secret-string '{"username":"admin","password":"secret123"}'

echo "LocalStack initialization complete!"
echo ""
echo "Resources created:"
echo "  - S3: app-bucket, data-bucket"
echo "  - DynamoDB: Users"
echo "  - SQS: app-queue, dead-letter-queue"
echo "  - SNS: app-notifications (subscribed to app-queue)"
echo "  - Secret: app/database"
