#!/bin/bash

# Script to configure systemd-resolved to use CoreDNS for .kub domains

set -e

echo "Configuring systemd-resolved for .kub domains..."

# Create systemd-resolved drop-in directory
sudo mkdir -p /etc/systemd/resolved.conf.d

# Create configuration for .kub domain
sudo tee /etc/systemd/resolved.conf.d/coredns-kub.conf > /dev/null << 'EOF'
[Resolve]
# Use CoreDNS for .kub domains (in-cluster CoreDNS)
DNS=10.10.10.254
Domains=~kub
# Disable DNSSEC for .kub domains (CoreDNS doesn't sign them)
DNSSEC=no
# Fallback to system DNS
FallbackDNS=192.168.86.1 8.8.8.8 8.8.4.4
EOF

# Restart systemd-resolved
echo "Restarting systemd-resolved..."
sudo systemctl restart systemd-resolved

# Verify configuration
echo "Checking systemd-resolved status..."
sudo systemctl status systemd-resolved --no-pager

echo "Configuration complete!"
echo "Testing with: resolvectl query example.kub"
resolvectl query example.kub
