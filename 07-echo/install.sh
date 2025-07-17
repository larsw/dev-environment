#!/bin/bash

# Install script for echo service

set -e

echo "Installing echo service..."

# Deploy echo service
echo "Deploying echo service..."
kubectl apply -f echo-service.yml

# Wait for deployment to be ready
echo "Waiting for echo service to be ready..."
kubectl wait --for=condition=available deployment/echo --timeout=300s || echo "Echo service may still be starting"

echo "Echo service installed successfully!"
echo "Service will be available at: https://echo.kub"
echo "DNS record will be automatically created by DNS updater"
