#!/bin/bash

# Validation script for k3d-metallb-environment setup
# This script verifies that all components are working correctly

set -e

echo "=== K3D MetalLB Environment Validation ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if k3d cluster is running
echo "1. Checking k3d cluster..."
if kubectl cluster-info &>/dev/null; then
    success "k3d cluster is running"
else
    error "k3d cluster is not running"
    exit 1
fi

# Check MetalLB
echo "2. Checking MetalLB..."
if kubectl get pods -n metallb-system &>/dev/null; then
    success "MetalLB is deployed"
else
    error "MetalLB is not deployed"
fi

# Check DNS updater
echo "3. Checking DNS updater..."
if kubectl get pods -n kube-system -l app=dns-updater | grep -q "Running"; then
    success "DNS updater is running"
else
    error "DNS updater is not running"
fi

# Check CoreDNS for .kub domains
echo "4. Checking CoreDNS for .kub domains..."
if kubectl get service coredns-kub -n kube-system &>/dev/null; then
    success "CoreDNS for .kub domains is deployed"
else
    error "CoreDNS for .kub domains is not deployed"
fi

# Check Istio ingress controller
echo "5. Checking Istio ingress gateway..."
if kubectl get pods -n istio-system -l istio=ingressgateway | grep -q "Running"; then
    success "Istio ingress gateway is running"
else
    error "Istio ingress gateway is not running"
fi

# Check cert-manager
echo "6. Checking cert-manager..."
if kubectl get pods -n cert-manager | grep -q "Running"; then
    success "cert-manager is running"
else
    error "cert-manager is not running"
fi

# Check step-ca ClusterIssuer
echo "7. Checking step-ca ClusterIssuer..."
if kubectl get clusterissuer step-ca-acme &>/dev/null; then
    success "step-ca ClusterIssuer is configured"
else
    error "step-ca ClusterIssuer is not configured"
fi

# Test DNS resolution
echo "8. Testing DNS resolution..."
COREDNS_IP=$(kubectl get svc coredns-kub -n kube-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
if [ -z "$COREDNS_IP" ]; then
    warning "CoreDNS LoadBalancer IP not available yet (is MetalLB running?)"
elif dig +short @"$COREDNS_IP" echo.kub | grep -Eq '([0-9]{1,3}\.){3}[0-9]{1,3}'; then
    success "DNS resolution for echo.kub works"
else
    error "DNS resolution for echo.kub failed"
fi

# Test local DNS resolution
echo "9. Testing local DNS resolution..."
if nslookup echo.kub | grep -Eq 'Address: ([0-9]{1,3}\.){3}[0-9]{1,3}'; then
    success "Local DNS resolution for echo.kub works"
else
    warning "Local DNS resolution for echo.kub failed (systemd-resolved may not be configured)"
fi

# Test echo service
echo "10. Testing echo service..."
if kubectl get service echo &>/dev/null; then
    success "Echo service is deployed"
else
    error "Echo service is not deployed"
fi

# Test HTTPS connectivity
echo "11. Testing HTTPS connectivity..."
if curl -k -s https://echo.kub/ | grep -q "echo.kub"; then
    success "HTTPS connectivity to echo.kub works"
else
    error "HTTPS connectivity to echo.kub failed"
fi

# Check certificate
echo "12. Checking TLS certificate..."
if kubectl get certificate echo-cert -n istio-system &>/dev/null; then
    CERT_STATUS=$(kubectl get certificate echo-cert -n istio-system -o jsonpath='{.status.conditions[0].status}')
    if [ "$CERT_STATUS" = "True" ]; then
        success "TLS certificate for echo.kub is ready"
    else
        warning "TLS certificate for echo.kub is not ready yet"
    fi
else
    error "TLS certificate for echo.kub not found"
fi

echo
echo "=== Validation Complete ==="
echo "If all checks passed, your k3d-metallb-environment is ready!"
echo
echo "Test commands:"
echo "- DNS: dig echo.kub"
echo "- HTTP: curl http://echo.kub/ (should redirect to HTTPS)"
echo "- HTTPS: curl -k https://echo.kub/"
echo "- Local DNS: nslookup echo.kub"
