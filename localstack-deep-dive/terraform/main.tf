# Terraform configuration for LocalStack
# Run: terraform init && terraform apply

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3             = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    iam            = "http://localhost:4566"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket"
}

resource "aws_s3_bucket_versioning" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "app_table" {
  name         = "AppData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "timestamp"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name            = "TimestampIndex"
    hash_key        = "timestamp"
    projection_type = "ALL"
  }
}

# SQS Queue
resource "aws_sqs_queue" "app_queue" {
  name                       = "app-processing-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue" "dlq" {
  name = "app-processing-dlq"
}

# SNS Topic
resource "aws_sns_topic" "notifications" {
  name = "app-notifications"
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.app_queue.arn
}

# Secrets Manager
resource "aws_secretsmanager_secret" "app_secret" {
  name = "app/api-key"
}

resource "aws_secretsmanager_secret_version" "app_secret" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    api_key = "sk-test-12345"
    region  = "us-east-1"
  })
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.app_table.name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.app_queue.url
}

output "sns_topic_arn" {
  value = aws_sns_topic.notifications.arn
}
