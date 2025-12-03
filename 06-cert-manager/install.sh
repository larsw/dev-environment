#!/bin/bash

# Script to install cert-manager and configure it with step-ca

set -e

CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.19.1}"

echo "Installing cert-manager..."

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.yaml

# Wait for cert-manager to be ready
echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=120s
kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=120s
kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=120s

echo "cert-manager is ready!"

# Expose step-ca inside the cluster (uses 10.10.0.6 endpoint)
echo "Applying step-ca Service/Endpoints for in-cluster ACME reachability..."
kubectl apply -f step-ca-service.yaml

# Apply the step-ca ClusterIssuer
echo "Applying step-ca ClusterIssuer..."
kubectl apply -f cert-manager-step-ca.yml

echo "Setup complete!"
echo ""
echo "To check the certificate status:"
echo "kubectl get certificate test-cert -o wide"
echo "kubectl describe certificate test-cert"
