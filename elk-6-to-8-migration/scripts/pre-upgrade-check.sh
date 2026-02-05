#!/bin/bash
# pre-upgrade-check.sh - Check cluster readiness before ELK upgrade

ES_HOST="${ES_HOST:-localhost:9200}"

echo "=== ELK Pre-Upgrade Check ==="

# Get cluster health
echo -e "\n=== Cluster Health ==="
curl -s "$ES_HOST/_cluster/health?pretty"

# List indices with creation version
echo -e "\n=== Indices ==="
curl -s "$ES_HOST/_cat/indices?v&h=index,creation.date.string,pri,rep,docs.count,store.size"

# Check for 5.x indices (can't be read by ES 7.x)
echo -e "\n=== Checking for 5.x indices ==="
curl -s "$ES_HOST/_settings" | jq -r '
  to_entries[] | 
  select(.value.settings.index.version.created | startswith("5") or startswith("2") or startswith("1")) | 
  .key' || echo "None found (or jq not installed)"

# Get current version
echo -e "\n=== Current Version ==="
curl -s "$ES_HOST/"

echo -e "\n=== Pre-Upgrade Check Complete ==="
