#!/bin/bash
# backup-snapshot.sh - Create snapshot before migration

ES_HOST="${ES_HOST:-localhost:9200}"
REPO_NAME="${REPO_NAME:-migration_backup}"
SNAPSHOT_NAME="pre-migration-$(date +%Y%m%d-%H%M%S)"

echo "=== Creating Snapshot Repository ==="
curl -X PUT "$ES_HOST/_snapshot/$REPO_NAME" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/mnt/backups/es-migration"
  }
}'

echo -e "\n\n=== Creating Snapshot: $SNAPSHOT_NAME ==="
curl -X PUT "$ES_HOST/_snapshot/$REPO_NAME/$SNAPSHOT_NAME?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": "*",
  "include_global_state": true
}'

echo -e "\n\n=== Verifying Snapshot ==="
curl -s "$ES_HOST/_snapshot/$REPO_NAME/$SNAPSHOT_NAME" | jq .

echo -e "\n=== Snapshot Complete ==="
echo "Snapshot: $REPO_NAME/$SNAPSHOT_NAME"
