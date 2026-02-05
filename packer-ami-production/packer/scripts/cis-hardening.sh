#!/bin/bash
# scripts/cis-hardening.sh
# CIS Amazon Linux 2 Benchmark hardening
# Optional - run this for security-sensitive workloads

set -euo pipefail

echo "=== Applying CIS hardening ==="

# 1.1.1 - Disable unused filesystems
for fs in cramfs freevxfs jffs2 hfs hfsplus squashfs udf; do
    echo "install ${fs} /bin/true" >> /etc/modprobe.d/CIS.conf
done

# 1.4.1 - Ensure permissions on bootloader config
chmod 600 /boot/grub2/grub.cfg 2>/dev/null || true

# 2.2.x - Remove unnecessary services
for svc in rpcbind cups avahi-daemon; do
    systemctl disable ${svc} 2>/dev/null || true
    systemctl stop ${svc} 2>/dev/null || true
done

# 3.1.1 - Disable IP forwarding
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.d/99-cis.conf

# 3.2.2 - Disable ICMP redirects
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.d/99-cis.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.d/99-cis.conf

# 4.1.x - Configure auditd
yum install -y audit
systemctl enable auditd

# 5.2.x - SSH hardening (additional)
cat >> /etc/ssh/sshd_config << 'EOF'
Protocol 2
MaxAuthTries 4
IgnoreRhosts yes
HostbasedAuthentication no
PermitEmptyPasswords no
ClientAliveInterval 300
ClientAliveCountMax 0
LoginGraceTime 60
AllowTcpForwarding no
X11Forwarding no
EOF

# 5.4.1 - Password requirements
# (Not needed if using SSM-only access)

# Apply sysctl changes
sysctl -p /etc/sysctl.d/99-cis.conf

echo "=== CIS hardening complete ==="
