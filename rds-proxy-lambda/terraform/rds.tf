# rds.tf - RDS PostgreSQL instance

resource "aws_db_subnet_group" "main" {
  name       = "main-${var.environment}"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name        = "main-db-subnet-group"
    Environment = var.environment
  }
}

resource "random_password" "db_password" {
  length  = 32
  special = false  # RDS Proxy works better without special chars
}

resource "aws_db_instance" "main" {
  identifier     = "lambda-app-db-${var.environment}"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = "dbadmin"
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Required for RDS Proxy IAM authentication
  iam_database_authentication_enabled = true

  # Performance Insights (optional but recommended)
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # For demo - set to true in production
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "lambda-app-db"
    Environment = var.environment
  }
}
