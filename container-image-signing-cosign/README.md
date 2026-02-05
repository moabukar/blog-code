# Container Image Signing with Cosign

Sign and verify container images without managing keys.

📖 **Blog Post:** [Container Image Signing with Cosign](https://moabukar.co.uk/blog/container-image-signing-cosign)

## Contents

```
container-image-signing-cosign/
├── .github/workflows/
│   └── build-sign.yml        # GitHub Actions workflow
├── kubernetes/
│   └── policy.yml            # Kyverno/Sigstore policies
├── scripts/
│   └── sign-verify.sh        # Common operations
└── README.md
```

## Quick Start

```bash
# Install Cosign
brew install cosign  # macOS
# or
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
chmod +x cosign-linux-amd64 && sudo mv cosign-linux-amd64 /usr/local/bin/cosign

# Sign image (keyless - opens browser)
cosign sign --yes ghcr.io/myorg/myapp:v1.0.0

# Verify signature
cosign verify \
  --certificate-identity-regexp="https://github.com/myorg/.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/myorg/myapp:v1.0.0
```

## Key-Based Signing

```bash
# Generate keypair
cosign generate-key-pair

# Sign
cosign sign --key cosign.key ghcr.io/myorg/myapp:v1.0.0

# Verify
cosign verify --key cosign.pub ghcr.io/myorg/myapp:v1.0.0
```

## KMS Support

```bash
# AWS KMS
cosign generate-key-pair --kms awskms:///alias/cosign-key
cosign sign --key awskms:///alias/cosign-key image:tag

# GCP KMS
cosign generate-key-pair --kms gcpkms://projects/PROJECT/locations/LOCATION/keyRings/RING/cryptoKeys/KEY

# Azure Key Vault
cosign generate-key-pair --kms azurekms://VAULT_NAME/KEY_NAME
```

## Kubernetes Enforcement

Apply the Kyverno policy:

```bash
kubectl apply -f kubernetes/policy.yml
```

Now only signed images can be deployed.

## License

MIT
