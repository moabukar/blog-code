# External Secrets Operator with AWS Secrets Manager

Companion code for: [External Secrets Operator with AWS Secrets Manager](https://moabukar.co.uk/blog/external-secrets-operator-aws)

## Quick Start

```bash
# Install ESO
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace

# Apply SecretStore
kubectl apply -f manifests/secret-store.yaml

# Apply ExternalSecret
kubectl apply -f manifests/external-secret.yaml
```

## Contents

- `terraform/` - IAM roles and Helm release
- `manifests/` - Kubernetes manifests for SecretStore and ExternalSecret

## License

MIT
