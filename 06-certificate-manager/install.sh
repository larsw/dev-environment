#!/bin/bash

# Script to install cert-manager and configure it with step-ca

source "$(dirname "$0")/../_shared.sh"

set -e

echo "Installing cert-manager..."

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.yaml

# Enable Gateway API HTTP-01 solver support
echo "Enabling cert-manager Gateway API feature gate..."
kubectl patch deployment cert-manager -n cert-manager --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--feature-gates=ExperimentalGatewayAPISupport=true"}]'
kubectl patch deployment cert-manager -n cert-manager --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api=true"}]'

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
echo "To check certificate status (app manifests create the certs):"
echo "kubectl get certificates -A"
echo "kubectl describe certificate echo-cert -n istio-system"
