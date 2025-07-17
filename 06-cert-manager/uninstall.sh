#!/bin/bash

# Uninstall script for cert-manager

set -e

echo "Uninstalling cert-manager..."

# Remove Step-CA ClusterIssuer
echo "Removing Step-CA ClusterIssuer..."
kubectl delete -f step-ca-issuer.yaml --ignore-not-found=true

# Remove Step-CA service
echo "Removing Step-CA service..."
kubectl delete -f step-ca-service.yaml --ignore-not-found=true

# Remove CoreDNS custom configuration
echo "Removing CoreDNS custom configuration..."
kubectl delete -f coredns-custom.yaml --ignore-not-found=true

# Remove test certificate
echo "Removing test certificate..."
kubectl delete -f test-cert-new.yaml --ignore-not-found=true

# Remove cert-manager Helm release
echo "Removing cert-manager Helm release..."
helm uninstall cert-manager -n cert-manager || echo "cert-manager Helm release may not exist"

# Remove cert-manager namespace
echo "Removing cert-manager namespace..."
kubectl delete namespace cert-manager --ignore-not-found=true

# Remove cert-manager CRDs
echo "Removing cert-manager CRDs..."
kubectl delete crd --ignore-not-found=true \
    certificaterequests.cert-manager.io \
    certificates.cert-manager.io \
    challenges.acme.cert-manager.io \
    clusterissuers.cert-manager.io \
    issuers.cert-manager.io \
    orders.acme.cert-manager.io || echo "Some CRDs may not exist"

echo "cert-manager uninstalled successfully!"
