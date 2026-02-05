resource "aws_cognito_user_pool" "backstage" {
  name = "${var.project_name}-users"

  # Password policy
  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # MFA configuration
  mfa_configuration = var.environment == "production" ? "ON" : "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Schema attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Auto-verified attributes
  auto_verified_attributes = ["email"]

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cognito_user_pool_domain" "backstage" {
  domain       = "${var.project_name}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.backstage.id
}

resource "aws_cognito_user_pool_client" "backstage" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.backstage.id

  generate_secret = true

  # OAuth configuration
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = [
    "https://${var.domain_name}/api/auth/aws-alb-oidc/handler/frame",
    "https://${var.domain_name}/api/auth/cognito/handler/frame"
  ]

  logout_urls = [
    "https://${var.domain_name}"
  ]

  supported_identity_providers = ["COGNITO"]

  # Token validity
  access_token_validity  = 1   # hours
  id_token_validity      = 1   # hours
  refresh_token_validity = 30  # days

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

# Store client secret in Secrets Manager
resource "aws_secretsmanager_secret" "cognito_client_secret" {
  name                    = "${var.project_name}/cognito-client-secret"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "cognito_client_secret" {
  secret_id = aws_secretsmanager_secret.cognito_client_secret.id
  secret_string = jsonencode({
    client_id     = aws_cognito_user_pool_client.backstage.id
    client_secret = aws_cognito_user_pool_client.backstage.client_secret
    user_pool_id  = aws_cognito_user_pool.backstage.id
    domain        = aws_cognito_user_pool_domain.backstage.domain
    region        = var.aws_region
  })
}

# Create admin group
resource "aws_cognito_user_group" "admins" {
  name         = "admins"
  user_pool_id = aws_cognito_user_pool.backstage.id
  description  = "Backstage administrators"
}

resource "aws_cognito_user_group" "developers" {
  name         = "developers"
  user_pool_id = aws_cognito_user_pool.backstage.id
  description  = "Backstage developers"
}
