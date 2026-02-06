# Identity Aware Proxy Examples

Code examples for the blog post: [Identity Aware Proxy: Zero Trust Access for Internal Applications](https://moabukar.co.uk/blog/identity-aware-proxy-deep-dive)

## Contents

```
identity-aware-proxy/
├── terraform/
│   ├── gcp-iap/           # GCP Identity Aware Proxy
│   └── aws-cognito-alb/   # AWS ALB + Cognito authentication
├── kubernetes/
│   ├── pomerium/          # Pomerium self-hosted IAP
│   └── oauth2-proxy/      # OAuth2-Proxy with NGINX Ingress
└── examples/
    ├── go/                # Go backend with IAP header parsing
    └── node/              # Node.js/Express backend
```

## Quick Start

### GCP IAP

```bash
cd terraform/gcp-iap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

### Pomerium on Kubernetes

```bash
cd kubernetes/pomerium
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml  # Edit first!
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f ingress.yaml
```

### OAuth2-Proxy on Kubernetes

```bash
cd kubernetes/oauth2-proxy
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml  # Edit first!
kubectl apply -f deployment.yaml
kubectl apply -f ingress.yaml
```

## Prerequisites

- Terraform >= 1.0
- kubectl >= 1.28
- Helm >= 3.12
- An OAuth2/OIDC provider (Google, Okta, Azure AD)

## Configuration

All examples require OAuth2 client credentials. Create an OAuth2 client in your IdP:

1. **Google Cloud Console**: APIs & Services > Credentials > Create OAuth Client
2. **Okta**: Applications > Create App Integration > OIDC
3. **Azure AD**: App Registrations > New Registration

Set the redirect URI to match your IAP deployment:
- Pomerium: `https://authenticate.yourdomain.com/oauth2/callback`
- OAuth2-Proxy: `https://oauth2.yourdomain.com/oauth2/callback`
- GCP IAP: Managed by GCP

## Security Notes

1. **Never commit secrets** - Use environment variables or secret management
2. **Verify JWT signatures** - Don't just trust headers in production
3. **Network isolation** - Ensure backends only accept traffic from IAP
4. **Use HTTPS** - Always use TLS for all connections

## License

MIT
