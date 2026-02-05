#!/bin/bash
# scripts/base-setup.sh
# Base OS setup - installs essential packages and configures security

set -euo pipefail

echo "=== Starting base setup ==="

# Update system packages
sudo yum update -y

# Install essential packages
sudo yum install -y \
    aws-cli \
    jq \
    htop \
    vim \
    curl \
    wget \
    unzip

# Install CloudWatch agent for metrics/logs
sudo yum install -y amazon-cloudwatch-agent

# Install SSM agent (usually pre-installed on Amazon Linux 2)
sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

# Configure time sync (critical for distributed systems)
sudo yum install -y chrony
sudo systemctl enable chronyd

# Security: Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Security: Disable password authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Create application user (non-root)
sudo useradd -m -s /bin/bash appuser

echo "=== Base setup complete ==="
