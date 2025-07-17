#!/bin/bash

# Install script for MetalLB LoadBalancer

set -e

echo "Installing MetalLB LoadBalancer..."

# Deploy MetalLB
echo "Deploying MetalLB configuration..."
kubectl apply -f metallb-setup.yml

# Wait for MetalLB to be ready
echo "Waiting for MetalLB to be ready..."
kubectl wait --for=condition=ready pod -l app=metallb -n metallb-system --timeout=300s || echo "MetalLB may still be starting"

echo "MetalLB LoadBalancer installed successfully!"
echo "LoadBalancer IP pool: 10.10.10.1-10.10.20.253"
