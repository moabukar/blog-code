#!/bin/bash
# Full multi-domain migration script
# Migrates resources from a monolithic state to multiple domain-specific states

set -e

DOMAINS="networking security iam dns rds eks storage lambda monitoring"
OLD_STATE="./legacy"
BACKUP_DIR="./backups/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

echo "=== Full State Migration ==="
echo "Domains: $DOMAINS"
echo "Old state: $OLD_STATE"
echo "Backup dir: $BACKUP_DIR"
echo ""

# Confirm before proceeding
read -p "This will migrate all domains. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Backup everything first
echo "=== Creating backups ==="
cd "$OLD_STATE"
terraform state pull > "$BACKUP_DIR/legacy.json"
echo "Backed up: legacy"
cd ..

for domain in $DOMAINS; do
  if [ -d "$domain" ]; then
    cd "$domain"
    terraform state pull > "$BACKUP_DIR/${domain}.json" 2>/dev/null || echo "$domain is new (no existing state)"
    cd ..
  fi
done

echo "All backups saved to: $BACKUP_DIR"

# Migrate each domain
for domain in $DOMAINS; do
  echo ""
  echo "=== Migrating: $domain ==="
  
  if [ -f "migrations/${domain}.sh" ]; then
    bash "migrations/${domain}.sh"
    
    # Verify
    cd "$domain"
    if ! terraform plan -detailed-exitcode; then
      echo "ERROR: $domain verification failed!"
      echo "Check the plan output and fix any issues."
      exit 1
    fi
    echo "✓ $domain verified"
    cd ..
  else
    echo "No migration script for $domain (migrations/${domain}.sh), skipping"
  fi
done

echo ""
echo "=== All migrations complete ==="
echo ""
echo "Next steps:"
echo "1. Review all terraform plans in each domain"
echo "2. Update CI/CD pipelines for new structure"
echo "3. Update documentation"
echo "4. Keep backups in $BACKUP_DIR until confident"
