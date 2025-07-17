#!/bin/bash

# Uninstall script for k3d cluster

set -e

echo "Uninstalling k3d cluster..."

# Delete the k3d cluster
echo "Deleting k3d cluster..."
k3d cluster delete k3d-metallb-cluster || echo "Cluster may not exist or already deleted"

# Clean up any remaining k3d resources
echo "Cleaning up k3d resources..."
k3d cluster list | grep k3d-metallb-cluster || echo "No k3d-metallb-cluster found"

echo "k3d cluster uninstalled successfully!"
echo "Note: Docker images and k3d registry may still be present"
