#!/bin/bash

# Remove Postgres and pgAdmin resources

set -e

echo "Uninstalling Postgres and pgAdmin..."
kubectl delete -f postgres.yml --ignore-not-found

echo "Uninstall complete."
