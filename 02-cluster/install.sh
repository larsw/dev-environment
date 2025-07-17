#!/bin/bash

# Check if k3d-default-net network exists
if ! docker network ls --format "{{.Name}}" | grep -q "^k3d-default-net$"; then
    echo "Creating k3d-default-net network..."
    docker network create \
      --driver=bridge \
      --subnet=10.10.0.0/16 \
      --ip-range=10.10.0.0/20 \
      --gateway=10.10.0.1 \
      k3d-default-net
else
    echo "k3d-default-net network already exists, skipping creation..."
fi

# create cluster
k3d cluster create \
	--k3s-arg "--disable=traefik@server:*" \
	--k3s-arg "--disable=servicelb@server:*" \
	--no-lb \
	--gpus all \
	--servers 1 \
	--agents 2 \
	--registry-create registry:5000 \
	--network k3d-default-net

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=300s

# Install cert-manager
echo "Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml

# Wait for cert-manager to be ready
echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s
kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=300s
kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=300s

# Apply cert-manager configuration for step-ca
echo "Configuring cert-manager for step-ca..."
kubectl apply -f cert-manager-step-ca.yml

echo "Cluster setup complete with cert-manager!"
echo ""
echo "Next steps:"
echo "1. Make sure step-ca is running: cd ../00-ca && ./setup-step-ca.sh"
echo "2. Test cert-manager: kubectl get clusterissuer"

