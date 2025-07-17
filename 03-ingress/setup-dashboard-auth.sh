#!/bin/bash

# Script to create basic authentication for Traefik dashboard

set -e

NAMESPACE="kube-system"
USERNAME="admin"

echo "Setting up Traefik dashboard authentication..."

# Prompt for password
read -s -p "Enter password for dashboard user '$USERNAME': " PASSWORD
echo

# Generate bcrypt hash of the password
# Using htpasswd from apache2-utils package
if ! command -v htpasswd &> /dev/null; then
    echo "htpasswd is required but not installed."
    echo "Please install it with: sudo apt-get install apache2-utils"
    exit 1
fi

# Create htpasswd entry
AUTH_STRING="$USERNAME:$(htpasswd -nbB $USERNAME $PASSWORD | cut -d: -f2)"

# Create Kubernetes secret
kubectl create secret generic dashboard-auth-secret \
    --from-literal=users="$AUTH_STRING" \
    --namespace=$NAMESPACE \
    --dry-run=client -o yaml | kubectl apply -f -

# Create middleware for basic auth
cat <<EOF | kubectl apply -f -
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: dashboard-auth
  namespace: $NAMESPACE
spec:
  basicAuth:
    secret: dashboard-auth-secret
EOF

echo "Authentication setup complete!"
echo "Dashboard will be accessible at: http://dashboard.kub"
echo "Username: $USERNAME"
echo "Password: (the one you just entered)"
