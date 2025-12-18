#!/bin/bash

# Enhanced setup for step-ca with better k3d integration

set -e

echo "Setting up step-ca ACME server for k3d environment..."

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_DIR="$SCRIPT_DIR/step-ca-config"
STEP_IMAGE="smallstep/step-ca:latest"
PASSWORD_FILE="$CONFIG_DIR/secrets/password"

ensure_dirs() {
    mkdir -p "$CONFIG_DIR/config"
    mkdir -p "$CONFIG_DIR/certs"
    mkdir -p "$CONFIG_DIR/secrets"
}

# Initialize step-ca if not already done
if [ ! -f "$CONFIG_DIR/config/ca.json" ]; then
    echo "Initializing step-ca configuration inside container..."

    ensure_dirs

    CA_PASSWORD="${CA_PASSWORD:-step-ca-local-dev}"
    echo "$CA_PASSWORD" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"

    docker run --rm \
        -v "$CONFIG_DIR:/home/step" \
        -e "STEPPATH=/home/step" \
        "$STEP_IMAGE" \
        sh -c "step ca init \
            --deployment-type standalone \
            --name 'Kub Domain CA' \
            --dns 'step-ca.kub,localhost,127.0.0.1,host.docker.internal' \
            --address ':8443' \
            --provisioner 'jwk' \
            --acme \
            --password-file /home/step/secrets/password"
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

# Test step-ca health using the root CA certificate via the containerized CLI
echo "Testing step-ca health..."
for i in {1..10}; do
    if docker run --rm --network host \
        -v "$CONFIG_DIR:/home/step:ro" \
        -e "STEPPATH=/home/step" \
        "$STEP_IMAGE" \
        sh -c "step ca health --ca-url https://127.0.0.1:8443 --root /home/step/certs/root_ca.crt"; then
        echo "Step-ca is healthy!"
        break
    fi
    echo "Waiting for step-ca... ($i/10)"
    sleep 5
done

# Install root CA certificate in system trust store
echo "Installing root CA certificate in system trust store..."
sudo cp "$CONFIG_DIR/certs/root_ca.crt" /usr/local/share/ca-certificates/step-ca-kub.crt
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
