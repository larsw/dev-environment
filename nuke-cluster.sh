#!/bin/bash

# Delete the k3d cluster only (no component uninstall scripts).

source "$(dirname "$0")/_shared.sh"

set -euo pipefail

echo "Deleting k3d cluster: ${CLUSTER}"

if ! command -v k3d >/dev/null 2>&1; then
  echo "k3d is not installed"
  exit 1
fi

if k3d cluster list | awk '{print $1}' | grep -qx "${CLUSTER}"; then
  k3d cluster delete "${CLUSTER}"
else
  echo "Cluster '${CLUSTER}' not found"
fi
