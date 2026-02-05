#!/bin/bash
# scripts/cleanup.sh
# Pre-AMI cleanup - removes sensitive data before creating the AMI

set -euo pipefail

echo "=== Starting pre-AMI cleanup ==="

# Remove SSH host keys (regenerated on first boot)
sudo rm -f /etc/ssh/ssh_host_*

# Remove temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clean yum cache
sudo yum clean all
sudo rm -rf /var/cache/yum

# Remove shell history
sudo rm -f /root/.bash_history
rm -f ~/.bash_history
history -c

# Remove cloud-init artifacts (forces re-run on new instance)
sudo rm -rf /var/lib/cloud/instances/*

# Remove machine ID (regenerated on boot)
sudo truncate -s 0 /etc/machine-id

# Zero out free space for smaller AMI (optional, adds build time)
# sudo dd if=/dev/zero of=/EMPTY bs=1M || true
# sudo rm -f /EMPTY

# Sync filesystem
sync

echo "=== Cleanup complete ==="
