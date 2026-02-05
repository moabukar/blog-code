#!/bin/bash
# scripts/rollback.sh
# Emergency rollback script - use when you need to rollback without Terraform

set -euo pipefail

# Configuration - update these for your environment
PREVIOUS_AMI="${1:-}"
ASG_NAME="${2:-myapp-production}"
LAUNCH_TEMPLATE_NAME="${3:-myapp-production}"

if [ -z "${PREVIOUS_AMI}" ]; then
    echo "Usage: $0 <ami-id> [asg-name] [launch-template-name]"
    echo ""
    echo "Example: $0 ami-0abc123def456 myapp-production myapp-production"
    echo ""
    echo "Recent AMIs:"
    aws ec2 describe-images \
        --owners self \
        --filters "Name=tag:Application,Values=myapp" \
        --query 'sort_by(Images, &CreationDate)[-5:].[ImageId,CreationDate,Name]' \
        --output table
    exit 1
fi

echo "=== Starting rollback ==="
echo "ASG: ${ASG_NAME}"
echo "Target AMI: ${PREVIOUS_AMI}"
echo ""

# Verify AMI exists
echo "Verifying AMI..."
aws ec2 describe-images --image-ids "${PREVIOUS_AMI}" --query 'Images[0].Name' --output text

# Create new launch template version with old AMI
echo "Creating new launch template version..."
NEW_VERSION=$(aws ec2 create-launch-template-version \
    --launch-template-name "${LAUNCH_TEMPLATE_NAME}" \
    --source-version '$Latest' \
    --launch-template-data "{\"ImageId\":\"${PREVIOUS_AMI}\"}" \
    --query 'LaunchTemplateVersion.VersionNumber' \
    --output text)

echo "Created launch template version: ${NEW_VERSION}"

# Start instance refresh
echo "Starting instance refresh..."
aws autoscaling start-instance-refresh \
    --auto-scaling-group-name "${ASG_NAME}" \
    --preferences '{
        "MinHealthyPercentage": 75,
        "InstanceWarmup": 120
    }'

echo ""
echo "=== Rollback initiated ==="
echo ""
echo "Monitor progress with:"
echo "  aws autoscaling describe-instance-refreshes --auto-scaling-group-name ${ASG_NAME}"
echo ""
echo "Cancel if needed with:"
echo "  aws autoscaling cancel-instance-refresh --auto-scaling-group-name ${ASG_NAME}"
