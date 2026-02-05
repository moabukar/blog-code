#!/bin/bash
# user-data.sh
# Instance-specific configuration run at boot time

set -euo pipefail

# Log startup
echo "Starting instance configuration for ${app_name} in ${environment}"

# Set environment variable for the application
echo "APP_ENV=${environment}" >> /etc/environment

# Start CloudWatch agent with environment-specific config
# Config should be stored in SSM Parameter Store
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c ssm:/cloudwatch-agent/config/${environment}

# Start the application
systemctl start myapp

echo "Instance configuration complete"
