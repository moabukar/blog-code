# security-groups.tf - Security groups for Lambda, RDS Proxy, and RDS

# Lambda security group
resource "aws_security_group" "lambda" {
  name        = "lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "lambda-sg"
    Environment = var.environment
  }
}

# RDS Proxy security group
resource "aws_security_group" "rds_proxy" {
  name        = "rds-proxy-sg"
  description = "Security group for RDS Proxy"
  vpc_id      = aws_vpc.main.id

  # Allow inbound from Lambda
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
    description     = "PostgreSQL from Lambda"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "rds-proxy-sg"
    Environment = var.environment
  }
}

# RDS security group
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  # Allow inbound from RDS Proxy only
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_proxy.id]
    description     = "PostgreSQL from RDS Proxy"
  }

  tags = {
    Name        = "rds-sg"
    Environment = var.environment
  }
}
