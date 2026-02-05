terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}

# Assumes kubeconfig is configured
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

# Create namespace for Gateway infrastructure
resource "kubernetes_namespace" "gateway_infra" {
  metadata {
    name = var.gateway_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Install Gateway API CRDs
# Note: In production, you might use Helm or apply CRDs separately
resource "kubectl_manifest" "gateway_api_crds" {
  yaml_body = <<-YAML
    # This is a placeholder - in production, apply the full CRD manifest
    # kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_version}/standard-install.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: gateway-api-version
      namespace: ${var.gateway_namespace}
    data:
      version: "${var.gateway_api_version}"
  YAML

  depends_on = [kubernetes_namespace.gateway_infra]
}
