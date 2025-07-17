#!/bin/bash

# Uninstall script for echo service

set -e

echo "Uninstalling echo service..."

# Remove echo service
echo "Removing echo service..."
kubectl delete -f echo-service.yml --ignore-not-found=true

# Remove any TLS secrets that might have been created
echo "Removing TLS secrets..."
kubectl delete secret echo-tls-secret --ignore-not-found=true

echo "Echo service uninstalled successfully!"
echo "DNS record will be automatically removed by DNS updater"
