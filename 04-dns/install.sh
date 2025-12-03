#!/bin/bash

# Install script for DNS setup

set -e

echo "Installing DNS setup..."

echo "Deploying DNS RBAC and service account..."
kubectl apply -f external-dns-setup.yml

echo "Deploying CoreDNS for .kub domains..."
kubectl apply -f coredns-kub.yml

echo "Waiting for CoreDNS deployment to be ready..."
kubectl rollout status deployment/coredns-kub -n kube-system --timeout=120s

echo "Deploying DNS updater..."
kubectl apply -f dns-updater-k8s.yml

echo "Configuring systemd-resolved (auto-detects CoreDNS LoadBalancer IP)..."
./configure-systemd-resolved.sh

echo "DNS setup installed successfully!"
echo "DNS updater will automatically manage .kub domain records"
echo "Local DNS resolution is configured for .kub domains"
