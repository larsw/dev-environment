#!/bin/bash

# Complete installation script for k3d-metallb-environment

set -e

echo "=== K3D MetalLB Environment - Complete Installation ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() {
    echo -e "${GREEN}✓${NC} $1"
}

info() {
    echo -e "${YELLOW}→${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to run installation step
run_install() {
    local dir=$1
    local name=$2
    
    info "Installing $name..."
    if cd "$dir" && ./install.sh; then
        success "$name installed successfully"
        cd ..
    else
        error "Failed to install $name"
        exit 1
    fi
    echo
}

# Check prerequisites
echo "Checking prerequisites..."
command -v docker >/dev/null 2>&1 || { error "Docker is required but not installed"; exit 1; }
command -v k3d >/dev/null 2>&1 || { error "k3d is required but not installed"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { error "kubectl is required but not installed"; exit 1; }
command -v helm >/dev/null 2>&1 || { error "Helm is required but not installed"; exit 1; }
success "All prerequisites found"
echo

# Installation steps in order
run_install "01-ca" "Step-CA ACME server"
run_install "02-cluster" "k3d cluster"
run_install "03-ingress" "Traefik ingress controller"
run_install "04-dns" "DNS management"
run_install "05-loadbalancer" "MetalLB LoadBalancer"
run_install "06-cert-manager" "cert-manager"
run_install "07-echo" "Echo service"

echo "=== Installation Complete ==="
echo
success "All components installed successfully!"
echo
echo "Running validation..."
if ./validate-setup.sh; then
    echo
    success "Environment is ready!"
    echo
    echo "Test your setup:"
    echo "- DNS: dig echo.kub"
    echo "- HTTPS: curl -k https://echo.kub/"
    echo "- Local DNS: nslookup echo.kub"
else
    echo
    error "Validation failed - please check the logs above"
    exit 1
fi
