#!/bin/bash

# Install Postgres with sample data and pgAdmin exposure

set -e

echo "Installing Postgres and pgAdmin..."
kubectl apply -f postgres.yml

echo "Waiting for Postgres to be ready..."
kubectl wait --for=condition=available deployment/postgres --timeout=300s || echo "Postgres may still be starting"

echo "Waiting for pgAdmin to be ready..."
kubectl wait --for=condition=available deployment/pgadmin --timeout=300s || echo "pgAdmin may still be starting"

echo "Postgres and pgAdmin installed."
echo "pgAdmin will be available at: https://pgadmin.kub"
echo "Default credentials are in pgadmin-secret; update them before production use."
