#!/bin/bash
# scripts/cleanup-old-amis.sh
# Clean up old AMIs, keeping the most recent N
# Run weekly via cron or scheduled Lambda

set -euo pipefail

APP_NAME="${1:-myapp}"
KEEP_COUNT="${2:-5}"

echo "=== Cleaning up old AMIs for ${APP_NAME} ==="
echo "Keeping last ${KEEP_COUNT} AMIs"
echo ""

# Get all AMIs sorted by creation date
AMIS=$(aws ec2 describe-images \
    --owners self \
    --filters "Name=tag:Application,Values=${APP_NAME}" \
    --query 'sort_by(Images, &CreationDate)[*].[ImageId,CreationDate,Name]' \
    --output text)

if [ -z "${AMIS}" ]; then
    echo "No AMIs found for ${APP_NAME}"
    exit 0
fi

TOTAL=$(echo "${AMIS}" | wc -l)
DELETE_COUNT=$((TOTAL - KEEP_COUNT))

echo "Found ${TOTAL} AMIs"

if [ ${DELETE_COUNT} -le 0 ]; then
    echo "Only ${TOTAL} AMIs exist, keeping all"
    exit 0
fi

echo "Will delete ${DELETE_COUNT} oldest AMIs"
echo ""

# Get AMIs to delete (oldest first)
TO_DELETE=$(echo "${AMIS}" | head -n ${DELETE_COUNT})

echo "AMIs to delete:"
echo "${TO_DELETE}"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

echo "${TO_DELETE}" | while read -r ami_id created_at ami_name; do
    echo "Deleting: ${ami_id} (${ami_name}, created ${created_at})"
    
    # Get associated snapshots
    SNAPSHOTS=$(aws ec2 describe-images \
        --image-ids "${ami_id}" \
        --query 'Images[0].BlockDeviceMappings[*].Ebs.SnapshotId' \
        --output text)
    
    # Deregister AMI
    aws ec2 deregister-image --image-id "${ami_id}"
    
    # Delete snapshots
    for snapshot in ${SNAPSHOTS}; do
        if [ "${snapshot}" != "None" ]; then
            echo "  Deleting snapshot: ${snapshot}"
            aws ec2 delete-snapshot --snapshot-id "${snapshot}"
        fi
    done
done

echo ""
echo "=== Cleanup complete ==="
