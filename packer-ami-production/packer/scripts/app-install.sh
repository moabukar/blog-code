#!/bin/bash
# scripts/app-install.sh
# Application installation script

set -euo pipefail

echo "=== Installing application version ${APP_VERSION} ==="

# Download application artifact from S3
# Using versioned path ensures reproducibility
aws s3 cp "s3://mycompany-artifacts/myapp/${APP_VERSION}/myapp.tar.gz" /tmp/myapp.tar.gz

# Verify checksum (uploaded alongside artifact)
aws s3 cp "s3://mycompany-artifacts/myapp/${APP_VERSION}/myapp.tar.gz.sha256" /tmp/
cd /tmp && sha256sum -c myapp.tar.gz.sha256

# Extract and install
sudo mkdir -p /opt/myapp
sudo tar -xzf /tmp/myapp.tar.gz -C /opt/myapp
sudo chown -R appuser:appuser /opt/myapp

# Install systemd service
sudo cat > /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=MyApp Service
After=network.target

[Service]
Type=simple
User=appuser
Group=appuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp
Restart=always
RestartSec=5
Environment=APP_ENV=production

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/myapp/data /var/log/myapp

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable myapp

# Create log directory
sudo mkdir -p /var/log/myapp
sudo chown appuser:appuser /var/log/myapp

# Store version for debugging
echo "${APP_VERSION}" | sudo tee /opt/myapp/VERSION

echo "=== Application installation complete ==="
