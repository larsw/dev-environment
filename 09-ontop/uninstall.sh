#!/bin/bash

# Remove Ontop resources

set -e

echo "Uninstalling Ontop..."
kubectl delete -f ontop.yml --ignore-not-found

echo "Uninstall complete."
