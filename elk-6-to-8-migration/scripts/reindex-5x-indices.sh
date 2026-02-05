#!/bin/bash
# reindex-5x-indices.sh - Reindex 5.x indices before upgrading to 7.x

ES_HOST="${ES_HOST:-localhost:9200}"

echo "=== Reindexing 5.x Indices ==="

# Find 5.x indices
INDICES=$(curl -s "$ES_HOST/_settings" | jq -r '
  to_entries[] | 
  select(.value.settings.index.version.created | startswith("5") or startswith("2") or startswith("1")) | 
  .key')

if [ -z "$INDICES" ]; then
  echo "No 5.x indices found. Nothing to reindex."
  exit 0
fi

for INDEX in $INDICES; do
  NEW_INDEX="${INDEX}-reindexed"
  
  echo "Reindexing $INDEX -> $NEW_INDEX"
  
  # Reindex
  curl -X POST "$ES_HOST/_reindex" -H 'Content-Type: application/json' -d"
  {
    \"source\": {\"index\": \"$INDEX\"},
    \"dest\": {\"index\": \"$NEW_INDEX\"}
  }"
  
  echo -e "\n"
done

echo "=== Reindex Complete ==="
echo "Review the new indices, then delete old ones and create aliases if needed."
