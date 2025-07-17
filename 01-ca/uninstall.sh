#!/bin/bash

# Uninstall script for Step-CA ACME server

set -e

echo "Uninstalling Step-CA ACME server..."

# Stop and remove Docker containers
if [ -f docker-compose.yml ]; then
    echo "Stopping Step-CA containers..."
    docker-compose down -v
    echo "Step-CA containers stopped and removed"
else
    echo "No docker-compose.yml found"
fi

# Remove any Step-CA related containers that might be running
echo "Cleaning up any remaining Step-CA containers..."
docker ps -a | grep step-ca | awk '{print $1}' | xargs -r docker rm -f || true

echo "Step-CA uninstalled successfully!"
echo "Note: Step-CA configuration files in step-ca-config/ are preserved"
