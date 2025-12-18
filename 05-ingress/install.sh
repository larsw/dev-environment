#!/bin/bash

# Install Istio with an external LoadBalancer ingress gateway (MetalLB) and base Gateway resources

set -e

export PATH="$HOME/.local/bin:$PATH"

echo "Installing Istio ingress with Gateway API support..."

# Install Gateway API CRDs if they are missing (required for Istio Gateway/HTTPRoute objects)
if ! kubectl get crd gateways.gateway.networking.k8s.io >/dev/null 2>&1; then
    echo "Installing Gateway API CRDs..."
    kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
else
    echo "Gateway API CRDs already present, skipping install..."
fi

# Install Istio control plane and ingress gateway
echo "Running istioctl install..."
istioctl install -y -f istio-operator.yaml

echo "Waiting for Istio control plane to be ready..."
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=300s

echo "Waiting for Istio ingress gateway to be ready..."
kubectl wait --for=condition=ready pod -l istio=ingressgateway -n istio-system --timeout=300s

# Apply shared Gateway and HTTP redirect route
echo "Configuring Istio Gateway for .kub domains..."
kubectl apply -f gateway.yml
kubectl apply -f http-redirect-route.yml
kubectl apply -f ingressclass-istio.yaml

echo "Istio ingress setup complete!"
echo ""
echo "Gateway service:"
kubectl get svc istio-ingressgateway -n istio-system
echo ""
echo "Next:"
echo "- Cert-manager will issue certificates for echo.kub / pgadmin.kub / ontop.kub (step 06)."
echo "- HTTPRoutes per service are applied with each workload manifest."
