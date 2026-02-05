#!/bin/bash
# Backup Terraform state
# Usage: ./backup-state.sh [directory]

set -e

DIR="${1:-.}"
BACKUP_FILE="state-backup-$(date +%Y%m%d-%H%M%S).json"

cd "$DIR"

echo "Backing up state from: $DIR"

# Pull and save state
terraform state pull > "$BACKUP_FILE"

# Verify backup is valid JSON
if jq empty "$BACKUP_FILE" 2>/dev/null; then
    echo "✓ State backed up to: $BACKUP_FILE"
    echo "  Size: $(wc -c < "$BACKUP_FILE") bytes"
    echo "  Resources: $(jq '.resources | length' "$BACKUP_FILE")"
else
    echo "✗ Warning: Backup may not be valid JSON"
fi

# Optional: encrypt backup
if command -v gpg &> /dev/null && [ -n "$GPG_RECIPIENT" ]; then
    gpg --encrypt --recipient "$GPG_RECIPIENT" "$BACKUP_FILE"
    rm "$BACKUP_FILE"
    echo "✓ Backup encrypted: ${BACKUP_FILE}.gpg"
fi
