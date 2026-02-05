# GatewayClass
resource "kubernetes_manifest" "gateway_class" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = var.gateway_class_name
    }
    spec = {
      controllerName = var.gateway_controller
    }
  }

  depends_on = [kubectl_manifest.gateway_api_crds]
}

# Main Gateway
resource "kubernetes_manifest" "main_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.gateway_name
      namespace = var.gateway_namespace
    }
    spec = {
      gatewayClassName = var.gateway_class_name
      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          hostname = var.gateway_hostname
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
        {
          name     = "https"
          protocol = "HTTPS"
          port     = 443
          hostname = var.gateway_hostname
          tls = {
            mode = "Terminate"
            certificateRefs = [{
              name = var.tls_secret_name
              kind = "Secret"
            }]
          }
          allowedRoutes = {
            namespaces = {
              from     = "Selector"
              selector = {
                matchLabels = var.allowed_namespaces
              }
            }
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_namespace.gateway_infra,
    kubernetes_manifest.gateway_class
  ]
}

# Example HTTPRoute
resource "kubernetes_manifest" "example_httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "example-route"
      namespace = "default"
    }
    spec = {
      parentRefs = [{
        name      = var.gateway_name
        namespace = var.gateway_namespace
      }]
      hostnames = ["app.example.com"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [{
          name = "example-service"
          port = 80
        }]
      }]
    }
  }

  depends_on = [kubernetes_manifest.main_gateway]
}

# HTTPRoute with traffic splitting
resource "kubernetes_manifest" "canary_httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "canary-route"
      namespace = "default"
    }
    spec = {
      parentRefs = [{
        name      = var.gateway_name
        namespace = var.gateway_namespace
      }]
      hostnames = ["canary.example.com"]
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
        backendRefs = [
          {
            name   = "app-stable"
            port   = 80
            weight = 90
          },
          {
            name   = "app-canary"
            port   = 80
            weight = 10
          }
        ]
      }]
    }
  }

  depends_on = [kubernetes_manifest.main_gateway]
}
