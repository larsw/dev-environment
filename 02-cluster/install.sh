#!/bin/bash

CLUSTER=${CLUSTER:-k3s-default}

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

NO_SERVERS=${NO_SERVERS:-1}
NO_AGENTS=${NO_AGENTS:-2}
K3S_IMAGE=${K3S_IMAGE:-"rancher/k3s:v1.34.2-k3s1"}

# create cluster
k3d cluster create \
	--k3s-arg "--disable=traefik@server:*" \
	--k3s-arg "--disable=servicelb@server:*" \
	--no-lb \
	--gpus all \
	--servers $NO_SERVERS \
	--agents $NO_AGENTS \
	--registry-create registry:5000 \
	--network k3d-default-net \
        --image $K3S_IMAGE \
        $CLUSTER

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=300s

echo "Cluster setup complete!"
echo ""
echo "Next steps:"
echo "1. Make sure step-ca is running: cd ../01-ca && ./setup-step-ca.sh"
echo "2. Continue with DNS, MetalLB, ingress, then cert-manager (06-certificate-manager)"
