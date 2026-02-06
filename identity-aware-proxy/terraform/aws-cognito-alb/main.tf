# AWS ALB with Cognito Authentication
# ====================================
# This provides IAP-like functionality using ALB + Cognito.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

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
  mfa_configuration = var.mfa_enabled ? "ON" : "OFF"

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_enabled ? [1] : []
    content {
      enabled = true
    }
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

  # Schema
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 0
      max_length = 256
    }
  }

  tags = var.tags
}

# User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.domain_prefix}-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# App Client for ALB
resource "aws_cognito_user_pool_client" "alb" {
  name         = "alb-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true

  # OAuth configuration
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  supported_identity_providers = var.enable_federation ? ["Cognito", var.idp_provider_name] : ["COGNITO"]

  # Token validity
  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"
}

# SAML Identity Provider (optional - for Okta/Azure AD federation)
resource "aws_cognito_identity_provider" "saml" {
  count = var.enable_federation ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = var.idp_provider_name
  provider_type = "SAML"

  provider_details = {
    MetadataURL             = var.saml_metadata_url
    IDPSignout              = "true"
    RequestSigningAlgorithm = "rsa-sha256"
  }

  attribute_mapping = {
    email    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    name     = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    username = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
  }
}

# ALB
resource "aws_lb" "main" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

# Target Group
resource "aws_lb_target_group" "app" {
  name     = "${var.alb_name}-tg"
  port     = var.backend_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.tags
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Listener Rule with Cognito Authentication
resource "aws_lb_listener_rule" "authenticated" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  # First action: Authenticate with Cognito
  action {
    type = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.main.arn
      user_pool_client_id = aws_cognito_user_pool_client.alb.id
      user_pool_domain    = aws_cognito_user_pool_domain.main.domain

      on_unauthenticated_request = "authenticate"
      session_timeout            = var.session_timeout
      session_cookie_name        = "AWSELBAuthSessionCookie"
      scope                      = "openid email profile"
    }
    order = 1
  }

  # Second action: Forward to target group
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
    order            = 2
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }
}

# HTTP to HTTPS redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
