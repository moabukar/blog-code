# -----------------------------------------------------------------------------
# ClusterSecretStore - AWS Secrets Manager
# -----------------------------------------------------------------------------

resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = data.aws_region.current.name
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = var.eso_namespace
              }
            }
          }
        }
      }
    }
  })

  depends_on = [helm_release.external_secrets]
}

# -----------------------------------------------------------------------------
# ClusterSecretStore - AWS SSM Parameter Store (Optional)
# -----------------------------------------------------------------------------

resource "kubectl_manifest" "cluster_secret_store_ssm" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-parameter-store"
    }
    spec = {
      provider = {
        aws = {
          service = "ParameterStore"
          region  = data.aws_region.current.name
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = var.eso_namespace
              }
            }
          }
        }
      }
    }
  })

  depends_on = [helm_release.external_secrets]
}
