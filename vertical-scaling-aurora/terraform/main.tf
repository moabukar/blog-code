# main.tf - Aurora Vertical Autoscaling Infrastructure

variable "cluster_identifier" {
  description = "Aurora cluster identifier"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "cpu_threshold_high" {
  description = "CPU threshold to trigger scale up"
  type        = number
  default     = 80
}

variable "cpu_threshold_low" {
  description = "CPU threshold to trigger scale down"
  type        = number
  default     = 20
}

data "aws_caller_identity" "current" {}

# SNS Topic for Alarms
resource "aws_sns_topic" "aurora_autoscale" {
  name = "aurora-autoscale-${var.environment}"
}

# CloudWatch Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "aurora-${var.cluster_identifier}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_threshold_high
  alarm_description   = "Aurora CPU high - trigger scale up"

  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }

  alarm_actions = [aws_sns_topic.aurora_autoscale.arn]
}

# Lambda Function
resource "aws_lambda_function" "alarm_handler" {
  filename         = "${path.module}/../lambda/alarm_handler.zip"
  function_name    = "aurora-autoscale-alarm-${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "alarm_handler.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60

  environment {
    variables = {
      CLUSTER_IDENTIFIER = var.cluster_identifier
    }
  }
}

# SNS -> Lambda subscription
resource "aws_sns_topic_subscription" "alarm_to_lambda" {
  topic_arn = aws_sns_topic.aurora_autoscale.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alarm_handler.arn
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alarm_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.aurora_autoscale.arn
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "aurora-autoscale-lambda-${var.environment}"

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
}

resource "aws_iam_role_policy" "lambda" {
  name = "aurora-autoscale-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:ModifyDBInstance",
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource"
        ]
        Resource = [
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:cluster:${var.cluster_identifier}",
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:db:${var.cluster_identifier}-*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}
