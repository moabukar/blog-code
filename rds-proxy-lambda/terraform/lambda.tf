# lambda.tf - Lambda function with RDS Proxy access

resource "aws_lambda_function" "api" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "api-handler-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 256

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DB_PROXY_ENDPOINT = aws_db_proxy.main.endpoint
      DB_NAME           = aws_db_instance.main.db_name
      DB_PORT           = "5432"
      DB_USER           = aws_db_instance.main.username
      AWS_REGION_NAME   = var.region
    }
  }

  # Ensure proxy is available before creating Lambda
  depends_on = [aws_db_proxy_target.main]

  tags = {
    Name        = "api-handler"
    Environment = var.environment
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda.zip"
}

# IAM role for Lambda
resource "aws_iam_role" "lambda" {
  name = "lambda-api-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Environment = var.environment
  }
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access for Lambda
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# RDS Proxy IAM authentication
resource "aws_iam_role_policy" "lambda_rds_proxy" {
  name = "lambda-rds-proxy-connect"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "rds-db:connect"
      Resource = "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_proxy.main.id}/${aws_db_instance.main.username}"
    }]
  })
}
