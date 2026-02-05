# -----------------------------------------------------------------------------
# IAM Role for External Secrets Operator (IRSA)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "external_secrets" {
  name = "${var.cluster_name}-external-secrets"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.cluster_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.cluster_oidc_provider_url}:sub" = "system:serviceaccount:${var.eso_namespace}:external-secrets"
          "${var.cluster_oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name      = "${var.cluster_name}-external-secrets"
    ManagedBy = "terraform"
  }
}

# -----------------------------------------------------------------------------
# IAM Policy - Secrets Manager Read Access
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "external_secrets_sm" {
  name = "secrets-manager-access"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      },
      {
        Sid    = "GetSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.secrets_path_prefix}"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# IAM Policy - SSM Parameter Store Read Access (Optional)
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "external_secrets_ssm" {
  name = "ssm-parameter-store-access"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GetParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.secrets_path_prefix}"
        ]
      }
    ]
  })
}
