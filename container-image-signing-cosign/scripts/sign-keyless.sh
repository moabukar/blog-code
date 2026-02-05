#!/bin/bash
# Keyless signing with Cosign
# Uses OIDC identity (GitHub, Google, Microsoft) instead of managing keys

set -euo pipefail

IMAGE="${1:-}"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image>"
    echo "Example: $0 ghcr.io/myorg/myapp:v1.0.0"
    exit 1
fi

echo "=== Keyless Image Signing ==="
echo "Image: $IMAGE"
echo ""
echo "This will open a browser for OIDC authentication."
echo ""

# Sign with keyless (opens browser for auth)
cosign sign --yes "$IMAGE"

echo ""
echo "=== Signature Details ==="
cosign tree "$IMAGE"

echo ""
echo "=== Verify the signature ==="
echo "Run:"
echo "  cosign verify \\"
echo "    --certificate-identity=YOUR_EMAIL \\"
echo "    --certificate-oidc-issuer=https://accounts.google.com \\"
echo "    $IMAGE"
