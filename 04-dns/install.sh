#!/bin/bash

# Install script for DNS setup

set -e

echo "Installing DNS setup..."

# Deploy RBAC and service account
echo "Deploying DNS RBAC and service account..."
kubectl apply -f external-dns-setup.yml

# Deploy DNS updater
echo "Deploying DNS updater..."
kubectl apply -f dns-updater-k8s.yml

# Configure systemd-resolved for local DNS resolution
echo "Configuring systemd-resolved..."
./configure-systemd-resolved.sh

echo "DNS setup installed successfully!"
echo "DNS updater will automatically manage .kub domain records"
echo "Local DNS resolution is configured for .kub domains"
