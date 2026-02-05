#!/bin/bash
# Attach SBOM and attestations to container image

set -euo pipefail

IMAGE="${1:-}"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image>"
    echo "Example: $0 ghcr.io/myorg/myapp:v1.0.0"
    exit 1
fi

echo "=== Generating and Attaching SBOM ==="
echo "Image: $IMAGE"

# Check if syft is installed
if ! command -v syft &> /dev/null; then
    echo "Installing Syft..."
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
fi

# Generate SBOM
echo ""
echo "Generating SBOM..."
syft "$IMAGE" -o spdx-json > sbom.spdx.json

echo "SBOM generated: sbom.spdx.json"

# Attach as attestation
echo ""
echo "Attaching SBOM as attestation..."
cosign attest --yes \
  --predicate sbom.spdx.json \
  --type spdxjson \
  "$IMAGE"

echo ""
echo "=== Verify SBOM Attestation ==="
echo "Run:"
echo "  cosign verify-attestation \\"
echo "    --type spdxjson \\"
echo "    --certificate-identity-regexp='https://github.com/.*' \\"
echo "    --certificate-oidc-issuer=https://token.actions.githubusercontent.com \\"
echo "    $IMAGE"

# Cleanup
rm -f sbom.spdx.json
