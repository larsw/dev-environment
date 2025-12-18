#!/bin/bash

# Script to configure systemd-resolved to use CoreDNS for .kub domains

set -e

COREDNS_NAMESPACE="${COREDNS_NAMESPACE:-kube-system}"
COREDNS_SERVICE="${COREDNS_SERVICE:-coredns-kub}"
FALLBACK_DNS="${FALLBACK_DNS:-8.8.8.8 1.1.1.1}"
LOOKUP_TIMEOUT="${LOOKUP_TIMEOUT:-120}"

echo "Configuring systemd-resolved for .kub domains..."
echo "Looking up LoadBalancer IP for ${COREDNS_SERVICE}.${COREDNS_NAMESPACE}..."

start_time=$(date +%s)
COREDNS_IP=""

while true; do
    COREDNS_IP=$(kubectl get svc "${COREDNS_SERVICE}" -n "${COREDNS_NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    if [ -n "${COREDNS_IP}" ]; then
        echo "Found CoreDNS IP: ${COREDNS_IP}"
        break
    fi

    now=$(date +%s)
    if [ $((now - start_time)) -ge "${LOOKUP_TIMEOUT}" ]; then
        echo "Timed out waiting for LoadBalancer IP for ${COREDNS_SERVICE}.${COREDNS_NAMESPACE}. Is MetalLB running?"
        exit 1
    fi

    echo "LoadBalancer IP not ready yet, retrying..."
    sleep 2
done

# Create systemd-resolved drop-in directory
sudo mkdir -p /etc/systemd/resolved.conf.d

# Create configuration for .kub domain
sudo tee /etc/systemd/resolved.conf.d/coredns-kub.conf > /dev/null << EOF
[Resolve]
# Use CoreDNS for .kub domains (in-cluster CoreDNS)
DNS=${COREDNS_IP}
Domains=~kub
# Disable DNSSEC for .kub domains (CoreDNS doesn't sign them)
DNSSEC=no
# Fallback to system DNS
FallbackDNS=${FALLBACK_DNS}
EOF

echo "Wrote systemd-resolved config pointing .kub to ${COREDNS_IP}"

# Restart systemd-resolved
echo "Restarting systemd-resolved..."
sudo systemctl restart systemd-resolved

# Verify configuration
echo "Checking systemd-resolved status..."
sudo systemctl status systemd-resolved --no-pager

echo "Configuration complete!"
echo "Testing with: resolvectl query example.kub"
resolvectl query example.kub || true
