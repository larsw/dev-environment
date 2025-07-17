#!/bin/bash

# Script to install cert-manager and configure it with step-ca

set -e

echo "Installing cert-manager..."

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml

# Wait for cert-manager to be ready
echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=120s
kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=120s
kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=120s

echo "cert-manager is ready!"

# Apply the step-ca issuer configuration
echo "Applying step-ca ClusterIssuer..."
kubectl apply -f step-ca-issuer.yaml

echo "Setup complete!"
echo ""
echo "To test certificate issuance, you can apply the test certificate:"
echo "kubectl apply -f step-ca-issuer.yaml"
echo ""
echo "To check the certificate status:"
echo "kubectl get certificate test-cert -o wide"
echo "kubectl describe certificate test-cert"
