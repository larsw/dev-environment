#!/bin/bash

# Install script for MetalLB LoadBalancer

source "$(dirname "$0")/../_shared.sh"

set -e

echo "Installing MetalLB LoadBalancer..."

METALLB_MANIFEST="https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml"

# Install MetalLB (CRDs + controllers) if not present
if ! kubectl get namespace metallb-system >/dev/null 2>&1; then
    echo "Installing MetalLB components (${METALLB_VERSION})..."
    kubectl apply -f "${METALLB_MANIFEST}"
    echo "Waiting for MetalLB pods to be ready..."
    kubectl wait --for=condition=ready pod -l app=metallb -n metallb-system --timeout=300s || {
        echo "MetalLB pods not ready yet; continuing to apply IPAddressPool/L2Advertisement."
    }
else
    echo "MetalLB components already installed, skipping controller install..."
fi

# Deploy MetalLB
echo "Deploying MetalLB configuration..."
kubectl apply -f metallb-setup.yml

# Wait for MetalLB to be ready
echo "Waiting for MetalLB to be ready..."
kubectl wait --for=condition=ready pod -l app=metallb -n metallb-system --timeout=300s || echo "MetalLB may still be starting"

echo "MetalLB LoadBalancer installed successfully!"
echo "LoadBalancer IP pool: 10.10.10.1-10.10.20.253"
