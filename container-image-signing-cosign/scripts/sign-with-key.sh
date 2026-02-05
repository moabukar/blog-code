#!/bin/bash
# Key-based signing with Cosign
# Use when offline signing is needed or OIDC isn't available

set -euo pipefail

IMAGE="${1:-}"
KEY_FILE="${2:-cosign.key}"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image> [key-file]"
    echo "Example: $0 ghcr.io/myorg/myapp:v1.0.0 cosign.key"
    exit 1
fi

# Generate keys if they don't exist
if [ ! -f "$KEY_FILE" ]; then
    echo "=== Generating Key Pair ==="
    echo "This will create cosign.key (private) and cosign.pub (public)"
    cosign generate-key-pair
fi

echo ""
echo "=== Signing Image ==="
echo "Image: $IMAGE"
echo "Key: $KEY_FILE"

cosign sign --key "$KEY_FILE" "$IMAGE"

echo ""
echo "=== Signature Details ==="
cosign tree "$IMAGE"

echo ""
echo "=== Verify with public key ==="
echo "Run: cosign verify --key cosign.pub $IMAGE"
