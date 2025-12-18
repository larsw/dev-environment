#!/bin/bash

# Complete uninstallation script for k3d-metallb-environment

source "$(dirname "$0")/_shared.sh"

set -e

echo "=== K3D MetalLB Environment - Complete Uninstallation ==="
echo

# Function to run uninstallation step
run_uninstall() {
    local dir=$1
    local name=$2
    
    info "Uninstalling $name..."
    if cd "$dir" && ./uninstall.sh; then
        success "$name uninstalled successfully"
        cd ..
    else
        error "Failed to uninstall $name (continuing anyway)"
    fi
    echo
}

# Confirmation prompt
echo "This will completely remove the k3d-metallb-environment setup."
echo "Are you sure you want to continue? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi
echo

# Uninstallation steps in reverse order
run_uninstall "09-ontop" "Ontop endpoint for LEGO DB"
run_uninstall "08-postgres" "Postgres with pgAdmin"
run_uninstall "07-echo" "Echo service"
run_uninstall "06-certificate-manager" "cert-manager"
run_uninstall "05-ingress" "Istio ingress gateway"
run_uninstall "04-loadbalancer" "MetalLB LoadBalancer"
run_uninstall "03-dns" "DNS management"
run_uninstall "02-cluster" "k3d cluster"
run_uninstall "01-ca" "Step-CA ACME server"

echo "=== Uninstallation Complete ==="
echo
success "All components uninstalled successfully!"
echo
echo "Cleanup notes:"
echo "- Docker images may still be present (use: docker system prune)"
echo "- Configuration files in directories are preserved"
echo "- You may need to manually remove any remaining Docker volumes"
