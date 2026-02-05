#!/bin/bash
# upgrade-0.13.sh - Upgrade from Terraform 0.12 to 0.13

set -e

echo "=== Terraform 0.12 to 0.13 Upgrade ==="

# Backup state
echo "=== Backing up state ==="
terraform state pull > "state-backup-$(date +%Y%m%d-%H%M%S).json"

# Verify 0.12 state is clean
echo "=== Verifying current state ==="
terraform plan -detailed-exitcode
if [ $? -eq 2 ]; then
    echo "ERROR: Plan shows changes. Fix drift before upgrading."
    exit 1
fi

# Run the upgrade command
echo "=== Running 0.13upgrade ==="
terraform-0.13 0.13upgrade

echo "=== Add required_providers block if not present ==="
cat << 'EOF'

# Add this to versions.tf:
terraform {
  required_version = ">= 0.13"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
EOF

# Reinitialize
echo "=== Reinitializing ==="
terraform-0.13 init -upgrade

# Verify no changes
echo "=== Verifying upgrade ==="
terraform-0.13 plan -detailed-exitcode
if [ $? -eq 0 ]; then
    echo "✅ SUCCESS: No changes detected"
elif [ $? -eq 2 ]; then
    echo "❌ ERROR: Plan shows changes after upgrade!"
    exit 1
fi

echo "=== Upgrade complete ==="
