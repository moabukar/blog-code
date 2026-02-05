# -----------------------------------------------------------------------------
# External Secrets Operator Helm Release
# -----------------------------------------------------------------------------

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = var.eso_namespace
  create_namespace = true
  version          = var.eso_chart_version

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  # Webhook configuration
  set {
    name  = "webhook.create"
    value = "true"
  }

  set {
    name  = "certController.create"
    value = "true"
  }

  depends_on = [aws_iam_role.external_secrets]
}
