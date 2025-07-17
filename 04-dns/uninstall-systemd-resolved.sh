#!/bin/bash

# Script to revert systemd-resolved configuration back to its original state
# This removes the CoreDNS configuration for .kub domains

set -e

echo "Reverting systemd-resolved configuration..."

# Remove the CoreDNS configuration file
if [ -f /etc/systemd/resolved.conf.d/coredns-kub.conf ]; then
    echo "Removing CoreDNS configuration file..."
    sudo rm -f /etc/systemd/resolved.conf.d/coredns-kub.conf
    echo "Configuration file removed."
else
    echo "CoreDNS configuration file not found. Nothing to remove."
fi

# Check if the drop-in directory is empty and remove it if so
if [ -d /etc/systemd/resolved.conf.d ]; then
    if [ -z "$(ls -A /etc/systemd/resolved.conf.d)" ]; then
        echo "Removing empty drop-in directory..."
        sudo rmdir /etc/systemd/resolved.conf.d
    else
        echo "Drop-in directory contains other files, keeping it."
    fi
fi

# Restart systemd-resolved to apply changes
echo "Restarting systemd-resolved..."
sudo systemctl restart systemd-resolved

# Verify configuration
echo "Checking systemd-resolved status..."
sudo systemctl status systemd-resolved --no-pager

echo ""
echo "systemd-resolved configuration reverted successfully!"
echo "The system should now use the default DNS configuration."
echo ""
echo "To verify:"
echo "  resolvectl status"
echo "  resolvectl query example.kub  # Should fail or use fallback DNS"
