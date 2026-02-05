#!/bin/bash
# upgrade-0.12.sh - Upgrade from Terraform 0.11 to 0.12

set -e

echo "=== Terraform 0.11 to 0.12 Upgrade ==="

# Verify we're on 0.11
TF_VERSION=$(terraform version | head -1)
echo "Current version: $TF_VERSION"

# Backup state
echo "=== Backing up state ==="
terraform state pull > "state-backup-$(date +%Y%m%d-%H%M%S).json"

# Verify 0.11 state is clean
echo "=== Verifying current state ==="
terraform plan -detailed-exitcode
if [ $? -eq 2 ]; then
    echo "ERROR: Plan shows changes. Fix drift before upgrading."
    exit 1
fi

# Run the upgrade tool
echo "=== Running 0.12upgrade ==="
terraform-0.12 0.12upgrade

# Review changes
echo "=== Review the changes ==="
git diff

# Reinitialize
echo "=== Reinitializing ==="
terraform-0.12 init

# Verify no changes
echo "=== Verifying upgrade ==="
terraform-0.12 plan -detailed-exitcode
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: No changes detected"
elif [ $? -eq 2 ]; then
    echo "❌ ERROR: Plan shows changes after upgrade!"
    echo "Review the plan output and fix any issues."
    exit 1
fi

echo "=== Upgrade complete ==="
echo "Commit your changes and proceed to 0.13"
