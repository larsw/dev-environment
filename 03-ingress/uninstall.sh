#!/bin/bash

# Uninstall script for Traefik ingress controller

set -e

echo "Uninstalling Traefik ingress controller..."

# Remove Traefik Helm release
echo "Removing Traefik Helm release..."
helm uninstall traefik -n kube-system || echo "Traefik Helm release may not exist"

# Remove any Traefik-related resources
echo "Cleaning up Traefik resources..."
kubectl delete crd --ignore-not-found=true \
    ingressroutes.traefik.containo.us \
    ingressroutetcps.traefik.containo.us \
    ingressrouteudps.traefik.containo.us \
    middlewares.traefik.containo.us \
    middlewaretcps.traefik.containo.us \
    serverstransports.traefik.containo.us \
    tlsoptions.traefik.containo.us \
    tlsstores.traefik.containo.us \
    traefikservices.traefik.containo.us || echo "Some CRDs may not exist"

# Remove Traefik namespace if it exists
kubectl delete namespace traefik --ignore-not-found=true

echo "Traefik ingress controller uninstalled successfully!"
