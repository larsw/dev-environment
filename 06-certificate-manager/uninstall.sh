#!/bin/bash

# Uninstall script for cert-manager

set -e

echo "Uninstalling cert-manager..."

# Remove Step-CA ClusterIssuer (and supporting ACME solver config)
echo "Removing Step-CA ClusterIssuer..."
kubectl delete -f cert-manager-step-ca.yml --ignore-not-found=true

# Remove Step-CA service
echo "Removing Step-CA service..."
kubectl delete -f step-ca-service.yaml --ignore-not-found=true

# Remove CoreDNS custom configuration
echo "Removing CoreDNS custom configuration..."
kubectl delete -f coredns-custom.yaml --ignore-not-found=true

# Remove cert-manager components (namespace and CRDs)
echo "Removing cert-manager namespace..."
kubectl delete namespace cert-manager --ignore-not-found=true

echo "Removing cert-manager CRDs..."
kubectl delete crd --ignore-not-found=true \
    certificaterequests.cert-manager.io \
    certificates.cert-manager.io \
    challenges.acme.cert-manager.io \
    clusterissuers.cert-manager.io \
    issuers.cert-manager.io \
    orders.acme.cert-manager.io || echo "Some CRDs may not exist"

echo "cert-manager uninstalled successfully!"
