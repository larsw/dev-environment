#!/bin/bash

# Install Ontop endpoint configured for the LEGO Postgres database

set -e

echo "Installing Ontop..."
kubectl apply -f ontop.yml

echo "Waiting for Ontop to be ready..."
kubectl wait --for=condition=available deployment/ontop --timeout=300s || echo "Ontop may still be starting"

echo "Ontop installed."
echo "Endpoint available at: https://ontop.kub"
