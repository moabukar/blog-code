#!/bin/bash
# Migrate resources from old state to new state
# Usage: ./state-migration.sh

set -e

OLD_DIR="${OLD_DIR:-./legacy}"
NEW_DIR="${NEW_DIR:-./networking}"

# Resources to move (format: "resource_address|import_id")
# Customize this array for your migration
RESOURCES=(
  "aws_vpc.main|vpc-0abc123def456"
  "aws_subnet.private[0]|subnet-0abc123"
  "aws_subnet.private[1]|subnet-0def456"
  "aws_subnet.public[0]|subnet-0ghi789"
  "aws_subnet.public[1]|subnet-0jkl012"
)

echo "=== State Migration Script ==="
echo "Source: $OLD_DIR"
echo "Target: $NEW_DIR"
echo "Resources to migrate: ${#RESOURCES[@]}"
echo ""

# Confirm before proceeding
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo "=== Backing up states ==="
cd "$OLD_DIR"
terraform state pull > "../backup-old-$(date +%Y%m%d-%H%M%S).json"
echo "Old state backed up"
cd ..

cd "$NEW_DIR"
terraform init
terraform state pull > "../backup-new-$(date +%Y%m%d-%H%M%S).json" 2>/dev/null || echo "New state is empty (expected)"
echo "New state backed up"
cd ..

echo "=== Importing into new state ==="
cd "$NEW_DIR"
for resource in "${RESOURCES[@]}"; do
  addr="${resource%%|*}"
  id="${resource##*|}"
  echo "Importing: $addr ($id)"
  terraform import "$addr" "$id" || { echo "FAILED: $addr"; exit 1; }
done

echo "=== Verifying new state ==="
terraform plan -detailed-exitcode
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ New state verified - no changes"
elif [ $EXIT_CODE -eq 2 ]; then
  echo "✗ ERROR: Plan shows changes! Aborting."
  echo "Review the plan output above and fix any discrepancies."
  exit 1
fi
cd ..

echo "=== Removing from old state ==="
cd "$OLD_DIR"
for resource in "${RESOURCES[@]}"; do
  addr="${resource%%|*}"
  echo "Removing: $addr"
  terraform state rm "$addr" || { echo "FAILED to remove: $addr"; exit 1; }
done

echo "=== Verifying old state ==="
terraform plan -detailed-exitcode
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo "✓ Old state verified - no changes"
elif [ $EXIT_CODE -eq 2 ]; then
  echo "✗ ERROR: Plan shows changes! Check manually."
  exit 1
fi
cd ..

echo ""
echo "=== Migration complete ==="
echo "Backups saved in current directory"
echo "Verify everything works before deleting backups"
