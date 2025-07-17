#!/bin/bash

# Uninstall script for MetalLB LoadBalancer

set -e

echo "Uninstalling MetalLB LoadBalancer..."

# Remove MetalLB configuration
echo "Removing MetalLB configuration..."
kubectl delete -f metallb-setup.yml --ignore-not-found=true

# Remove MetalLB system components
echo "Removing MetalLB system components..."
kubectl delete namespace metallb-system --ignore-not-found=true

# Remove MetalLB CRDs
echo "Removing MetalLB CRDs..."
kubectl delete crd --ignore-not-found=true \
    addresspools.metallb.io \
    bfdprofiles.metallb.io \
    bgpadvertisements.metallb.io \
    bgppeers.metallb.io \
    communities.metallb.io \
    ipaddresspools.metallb.io \
    l2advertisements.metallb.io || echo "Some CRDs may not exist"

echo "MetalLB LoadBalancer uninstalled successfully!"
