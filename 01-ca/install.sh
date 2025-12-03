#!/bin/bash

# Enhanced setup for step-ca with better k3d integration

set -e

echo "Setting up step-ca ACME server for k3d environment..."

# Check if step CLI is installed
if ! command -v step &> /dev/null; then
    echo "Installing step CLI..."
    sudo apt-get update && sudo apt-get install -y --no-install-recommends curl vim gpg ca-certificates
    curl -fsSL https://packages.smallstep.com/keys/apt/repo-signing-key.gpg -o /tmp/smallstep.asc
    sudo mv /tmp/smallstep.asc /etc/apt/trusted.gpg.d/smallstep.asc
    echo 'deb [signed-by=/etc/apt/trusted.gpg.d/smallstep.asc] https://packages.smallstep.com/stable/debian debs main' \
        | sudo tee /etc/apt/sources.list.d/smallstep.list
    sudo apt-get update && sudo apt-get -y install step-cli
fi

# Initialize step-ca if not already done
if [ ! -f "./step-ca-config/config/ca.json" ]; then
    echo "Initializing step-ca configuration..."
    
    # Create necessary directories
    mkdir -p ./step-ca-config/config
    mkdir -p ./step-ca-config/certs
    mkdir -p ./step-ca-config/secrets
    
    # Set a default password for local development
    CA_PASSWORD="step-ca-local-dev"
    
    # Save the password to the secrets directory
    echo "$CA_PASSWORD" > ./step-ca-config/secrets/password
    chmod 600 ./step-ca-config/secrets/password
    
    # Initialize step-ca with password
    STEPPATH=./step-ca-config step ca init \
        --deployment-type standalone \
        --name "Kub Domain CA" \
        --dns "step-ca.kub,localhost,127.0.0.1,host.docker.internal" \
        --address ":9000" \
        --provisioner "acme" \
        --acme \
        --password-file ./step-ca-config/secrets/password
    
    # Note: ACME provisioner is already created by --acme flag above
fi

# Start step-ca container
echo "Starting step-ca container..."
docker compose up -d step-ca

# If the k3d network exists, attach step-ca so the cluster can reach it directly
if docker network ls --format '{{.Name}}' | grep -q '^k3d-default-net$'; then
    echo "Connecting step-ca container to k3d-default-net (10.10.0.6)..."
    if ! docker network inspect k3d-default-net --format '{{range .Containers}}{{.Name}}{{end}}' | grep -q 'step-ca-kub'; then
        docker network connect --ip 10.10.0.6 k3d-default-net step-ca-kub
    else
        echo "step-ca container already connected to k3d-default-net"
    fi
else
    echo "k3d-default-net not found; cluster access to step-ca will be configured after the network exists."
fi

# Wait for step-ca to be ready
echo "Waiting for step-ca to be ready..."
sleep 10

# Test step-ca health using the locally generated root CA certificate
echo "Testing step-ca health..."
for i in {1..10}; do
    if step ca health --ca-url https://localhost:8443 --root ./step-ca-config/certs/root_ca.crt; then
        echo "Step-ca is healthy!"
        break
    fi
    echo "Waiting for step-ca... ($i/10)"
    sleep 5
done

# Install root CA certificate in system trust store
echo "Installing root CA certificate in system trust store..."
sudo cp ./step-ca-config/certs/root_ca.crt /usr/local/share/ca-certificates/step-ca-kub.crt
sudo update-ca-certificates

echo ""
echo "Step-ca setup complete!"
echo ""
echo "ACME server is available at: https://localhost:8443/acme/acme/directory"
echo "Root CA certificate installed in system trust store"
echo ""
echo "To test ACME directory:"
echo "  curl -k https://localhost:8443/acme/acme/directory"
echo ""
echo "Container logs:"
echo "  docker compose logs step-ca"
