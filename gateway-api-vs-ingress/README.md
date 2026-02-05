# Gateway API vs Ingress - Code Examples

Companion code for the blog post: [Kubernetes Gateway API vs Ingress - When to Migrate and How](https://moabukar.co.uk/blog/gateway-api-vs-ingress)

## Contents

```
.
├── manifests/
│   ├── ingress/           # Traditional Ingress examples
│   │   ├── simple-ingress.yaml
│   │   ├── canary-annotations.yaml
│   │   └── tls-ingress.yaml
│   └── gateway-api/       # Gateway API equivalents
│       ├── 00-install-crds.sh
│       ├── 01-gateway-class.yaml
│       ├── 02-gateway.yaml
│       ├── 03-httproute-basic.yaml
│       ├── 04-httproute-traffic-split.yaml
│       ├── 05-httproute-header-routing.yaml
│       ├── 06-httproute-cross-namespace.yaml
│       ├── 07-reference-grant.yaml
│       └── 08-httproute-rewrites.yaml
└── terraform/             # IaC deployment
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── gateway.tf
```

## Quick Start

### Install Gateway API CRDs

```bash
# Standard channel (stable resources only)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

# Or with experimental resources
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml
```

### Deploy Examples

```bash
# Apply GatewayClass (controller-specific)
kubectl apply -f manifests/gateway-api/01-gateway-class.yaml

# Create Gateway
kubectl apply -f manifests/gateway-api/02-gateway.yaml

# Deploy HTTPRoute
kubectl apply -f manifests/gateway-api/03-httproute-basic.yaml
```

### Verify

```bash
# Check Gateway status
kubectl get gateway -A

# Check HTTPRoute status
kubectl get httproute -A -o wide

# Describe for troubleshooting
kubectl describe httproute <name>
```

## Migration Checklist

- [ ] Verify your ingress controller supports Gateway API
- [ ] Install Gateway API CRDs
- [ ] Deploy GatewayClass for your controller
- [ ] Create Gateway with appropriate listeners
- [ ] Convert Ingress resources to HTTPRoutes
- [ ] Test with subset of traffic
- [ ] Switch production DNS
- [ ] Remove old Ingress resources

## Controller Support

| Controller | Gateway API Status |
|------------|-------------------|
| NGINX Gateway Fabric | GA |
| Istio | GA |
| Envoy Gateway | GA |
| Traefik | GA |
| Contour | GA |
| Kong | GA |
| Cilium | GA |
| AWS ALB Controller | Partial |

## License

MIT
