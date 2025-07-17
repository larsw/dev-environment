#!/bin/bash

# Complete Traefik setup with dashboard authentication

set -e

echo "Setting up Traefik with authenticated dashboard..."

# Step 1: Install/upgrade Traefik first to get CRDs
echo "Installing Traefik with dashboard configuration..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade --install traefik traefik/traefik \
    --namespace kube-system \
    --values values.yml \
    --set service.type=LoadBalancer

# Step 2: Wait for Traefik to be ready
echo "Waiting for Traefik to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=traefik -n kube-system --timeout=300s

# Step 3: Setup authentication (now that CRDs exist)
echo "Setting up dashboard authentication..."
./setup-dashboard-auth.sh

# Step 4: Get the LoadBalancer IP
echo "Getting Traefik LoadBalancer IP..."
kubectl get svc -n kube-system traefik

echo ""
echo "Setup complete!"
echo "Dashboard should be accessible at: http://dashboard.kub"
echo "Note: Make sure your DNS setup is running for .kub domains"
echo ""
echo "To check status:"
echo "  kubectl get svc -n kube-system traefik"
echo "  kubectl get ingressroute -n kube-system"
