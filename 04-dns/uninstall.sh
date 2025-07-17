#!/bin/bash

# Uninstall script for DNS setup

set -e

echo "Uninstalling DNS setup..."

# Remove DNS updater deployment
echo "Removing DNS updater deployment..."
kubectl delete -f dns-updater-k8s.yml --ignore-not-found=true

# Remove RBAC and service account
echo "Removing DNS RBAC and service account..."
kubectl delete -f external-dns-setup.yml --ignore-not-found=true

# Remove CoreDNS ConfigMap
echo "Removing CoreDNS ConfigMap..."
kubectl delete configmap coredns-config -n kube-system --ignore-not-found=true

# Revert systemd-resolved configuration
echo "Reverting systemd-resolved configuration..."
./uninstall-systemd-resolved.sh

echo "DNS setup uninstalled successfully!"
echo "Local DNS resolution has been reverted"
