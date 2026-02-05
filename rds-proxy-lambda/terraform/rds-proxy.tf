# rds-proxy.tf - RDS Proxy configuration

resource "aws_db_proxy" "main" {
  name                   = "lambda-app-proxy-${var.environment}"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800  # 30 minutes
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy.id]
  vpc_subnet_ids         = aws_subnet.private[*].id

  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = "REQUIRED"  # Require IAM auth from Lambda
    secret_arn                = aws_secretsmanager_secret.db_credentials.arn
  }

  tags = {
    Name        = "lambda-app-proxy"
    Environment = var.environment
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    # How long client can wait for connection from pool
    connection_borrow_timeout = 120

    # Max connections as percentage of RDS max_connections
    max_connections_percent = 100

    # Idle connections to keep (faster response to traffic spikes)
    max_idle_connections_percent = 50

    # Optional: SQL to run when connection is created
    # init_query = "SET timezone='UTC'"
  }
}

resource "aws_db_proxy_target" "main" {
  db_instance_identifier = aws_db_instance.main.identifier
  db_proxy_name          = aws_db_proxy.main.name
  target_group_name      = aws_db_proxy_default_target_group.main.name
}

# IAM role for RDS Proxy to access Secrets Manager
resource "aws_iam_role" "rds_proxy" {
  name = "rds-proxy-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "rds.amazonaws.com"
      }
    }]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "rds_proxy_secrets" {
  name = "rds-proxy-secrets"
  role = aws_iam_role.rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [aws_secretsmanager_secret.db_credentials.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}
