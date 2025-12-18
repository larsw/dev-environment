#!/bin/bash

# Uninstall script for Istio ingress gateway

set -e

export PATH="$HOME/.local/bin:$PATH"

echo "Uninstalling Istio ingress gateway..."

# Remove Gateway resources
kubectl delete -f http-redirect-route.yml --ignore-not-found
kubectl delete -f gateway.yml --ignore-not-found
kubectl delete -f ingressclass-istio.yaml --ignore-not-found

# Uninstall Istio control plane and clean up namespaces
if command -v istioctl >/dev/null 2>&1; then
    istioctl uninstall -y --purge || echo "Istio may already be removed"
else
    echo "istioctl not found in PATH, skipping control plane removal"
fi

kubectl delete namespace istio-system --ignore-not-found=true

echo "Istio ingress gateway uninstalled successfully!"
