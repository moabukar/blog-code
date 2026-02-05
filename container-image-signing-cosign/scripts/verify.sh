#!/bin/bash
# Verify container image signatures

set -euo pipefail

IMAGE="${1:-}"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image>"
    echo "Example: $0 ghcr.io/myorg/myapp:v1.0.0"
    exit 1
fi

echo "=== Inspecting Image Signatures ==="
echo "Image: $IMAGE"
echo ""

# Show signature tree
echo "--- Signature Tree ---"
cosign tree "$IMAGE" 2>/dev/null || echo "No signatures found"

echo ""
echo "--- Verification Examples ---"

# Example: Verify with Google identity
echo ""
echo "Verify with Google identity:"
echo "  cosign verify \\"
echo "    --certificate-identity=user@gmail.com \\"
echo "    --certificate-oidc-issuer=https://accounts.google.com \\"
echo "    $IMAGE"

# Example: Verify with GitHub Actions identity
echo ""
echo "Verify with GitHub Actions:"
echo "  cosign verify \\"
echo "    --certificate-identity-regexp='https://github.com/OWNER/REPO/.*' \\"
echo "    --certificate-oidc-issuer=https://token.actions.githubusercontent.com \\"
echo "    $IMAGE"

# Example: Verify with public key
echo ""
echo "Verify with public key:"
echo "  cosign verify --key cosign.pub $IMAGE"

# Try to download signature details
echo ""
echo "--- Attempting to Download Signature ---"
cosign download signature "$IMAGE" 2>/dev/null | head -20 || echo "Could not download signature"
