#!/bin/bash
# sign-verify.sh - Common Cosign operations

set -e

IMAGE="${1:-}"
if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image>"
    exit 1
fi

# Keyless sign (opens browser for auth)
sign_keyless() {
    echo "=== Signing image (keyless) ==="
    cosign sign --yes "$IMAGE"
}

# Sign with key
sign_with_key() {
    echo "=== Signing image (key-based) ==="
    cosign sign --key cosign.key "$IMAGE"
}

# Verify keyless signature (GitHub Actions)
verify_github() {
    echo "=== Verifying signature (GitHub identity) ==="
    cosign verify \
        --certificate-identity-regexp="https://github.com/myorg/.*" \
        --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
        "$IMAGE"
}

# Verify with public key
verify_with_key() {
    echo "=== Verifying signature (key-based) ==="
    cosign verify --key cosign.pub "$IMAGE"
}

# Generate keypair
generate_keys() {
    echo "=== Generating keypair ==="
    cosign generate-key-pair
    echo "Created: cosign.key (private), cosign.pub (public)"
}

# Attach SBOM
attach_sbom() {
    echo "=== Generating and attaching SBOM ==="
    syft "$IMAGE" -o spdx-json > sbom.spdx.json
    cosign attest --yes \
        --predicate sbom.spdx.json \
        --type spdxjson \
        "$IMAGE"
}

# View signature
view_signature() {
    echo "=== Viewing signature ==="
    cosign triangulate "$IMAGE"
    crane manifest "$(cosign triangulate "$IMAGE")" | jq .
}

# Help
show_help() {
    echo "Commands:"
    echo "  sign-keyless  - Sign with OIDC identity"
    echo "  sign-key      - Sign with private key"
    echo "  verify-github - Verify GitHub Actions signature"
    echo "  verify-key    - Verify with public key"
    echo "  generate-keys - Generate keypair"
    echo "  attach-sbom   - Generate and attach SBOM"
    echo "  view          - View signature"
}

case "${2:-sign-keyless}" in
    sign-keyless)  sign_keyless ;;
    sign-key)      sign_with_key ;;
    verify-github) verify_github ;;
    verify-key)    verify_with_key ;;
    generate-keys) generate_keys ;;
    attach-sbom)   attach_sbom ;;
    view)          view_signature ;;
    *)             show_help ;;
esac
