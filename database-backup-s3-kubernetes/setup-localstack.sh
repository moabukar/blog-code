#!/bin/bash
# Setup LocalStack S3 bucket and lifecycle policy

set -euo pipefail

echo "Setting up LocalStack S3..."

# Wait for LocalStack
echo "Waiting for LocalStack to be ready..."
for i in {1..30}; do
  if curl -s http://localhost:4566/health > /dev/null 2>&1; then
    echo "LocalStack is ready!"
    break
  fi
  echo "Attempt $i: Waiting for LocalStack..."
  sleep 2
done

# Configure credentials (fake for LocalStack)
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Create bucket
echo "Creating S3 bucket..."
awslocal s3 mb s3://rds-db-backups-co-create 2>/dev/null || echo "Bucket already exists"

# Add lifecycle policy (move to Glacier after 30 days, delete after 365)
cat > lifecycle-policy.json << EOF
{
  "Rules": [
    {
      "ID": "move-to-glacier",
      "Status": "Enabled",
      "Filter": { "Prefix": "" },
      "Transitions": [
        { "Days": 30, "StorageClass": "GLACIER" }
      ],
      "Expiration": { "Days": 365 }
    }
  ]
}
EOF

echo "Setting lifecycle policy..."
awslocal s3api put-bucket-lifecycle-configuration \
  --bucket rds-db-backups-co-create \
  --lifecycle-configuration file://lifecycle-policy.json

echo "Verifying setup..."
awslocal s3 ls

echo "LocalStack S3 setup complete!"
