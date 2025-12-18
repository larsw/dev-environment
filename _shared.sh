#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "This script must be sourced, not executed."
  exit 1
fi

: "${CLUSTER:=k3s-default}"
: "${NO_SERVERS:=1}"
: "${NO_AGENTS:=2}"
: "${K3S_IMAGE:=rancher/k3s:v1.34.2-k3s1}"
: "${METALLB_VERSION:=v0.15.2}"
: "${CERT_MANAGER_VERSION:=v1.19.1}"
: "${STEP_IMAGE:=smallstep/step-ca:latest}"
: "${COREDNS_NAMESPACE:=kube-system}"
: "${COREDNS_SERVICE:=coredns-kub}"
: "${FALLBACK_DNS:=8.8.8.8 1.1.1.1}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() {
  echo -e "${GREEN}OK${NC} $1"
}

info() {
  echo -e "${YELLOW}INFO${NC} $1"
}

warning() {
  echo -e "${YELLOW}WARN${NC} $1"
}

error() {
  echo -e "${RED}ERR${NC} $1"
}
