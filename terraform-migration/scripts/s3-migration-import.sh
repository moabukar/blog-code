#!/bin/bash
# s3-migration-import.sh
# Import S3 bucket sub-resources when migrating AWS Provider 3.x to 4.x
# The aws_s3_bucket resource split requires importing existing configurations

set -e

BUCKETS=$(terraform state list | grep "aws_s3_bucket\." | grep -v "aws_s3_bucket_")

for bucket_resource in $BUCKETS; do
  bucket_name=$(terraform state show "$bucket_resource" | grep "bucket " | head -1 | awk -F'"' '{print $2}')
  base_name=$(echo "$bucket_resource" | sed 's/aws_s3_bucket\.//')
  
  echo "Processing: $bucket_name ($base_name)"
  
  # Check if versioning exists
  if aws s3api get-bucket-versioning --bucket "$bucket_name" --query 'Status' --output text | grep -q "Enabled\|Suspended"; then
    echo "  Importing versioning..."
    terraform import "aws_s3_bucket_versioning.${base_name}" "$bucket_name" || true
  fi
  
  # Check if encryption exists
  if aws s3api get-bucket-encryption --bucket "$bucket_name" 2>/dev/null; then
    echo "  Importing encryption..."
    terraform import "aws_s3_bucket_server_side_encryption_configuration.${base_name}" "$bucket_name" || true
  fi
  
  # Check if lifecycle rules exist
  if aws s3api get-bucket-lifecycle-configuration --bucket "$bucket_name" 2>/dev/null; then
    echo "  Importing lifecycle..."
    terraform import "aws_s3_bucket_lifecycle_configuration.${base_name}" "$bucket_name" || true
  fi
  
  # Check if logging exists
  if aws s3api get-bucket-logging --bucket "$bucket_name" --query 'LoggingEnabled' --output text | grep -v "None"; then
    echo "  Importing logging..."
    terraform import "aws_s3_bucket_logging.${base_name}" "$bucket_name" || true
  fi
  
  # Always import public access block (should exist on all buckets)
  echo "  Importing public access block..."
  terraform import "aws_s3_bucket_public_access_block.${base_name}" "$bucket_name" || true
  
done

echo "Done. Run 'terraform plan' to verify."
