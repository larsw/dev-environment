# DNS Setup for .kub Domains

This directory contains the DNS configuration for automatic `.kub` domain management in the k3d cluster.

## Overview

The DNS setup consists of:
1. **DNS Updater**: Automatically creates/updates DNS records for LoadBalancer services and Ingresses
2. **In-cluster CoreDNS**: Serves `.kub` domains using dynamically generated zone files
3. **Local DNS Configuration**: Configures systemd-resolved to use the in-cluster CoreDNS for `.kub` domains

## Files

### Core Components
- `dns-updater-k8s.yml` - DNS updater deployment that automatically manages `.kub` DNS records
- `external-dns-setup.yml` - RBAC permissions and service account for the DNS updater

### Local DNS Configuration
- `configure-systemd-resolved.sh` - Configures local systemd-resolved to use in-cluster CoreDNS for `.kub` domains
- `uninstall-systemd-resolved.sh` - Removes local DNS configuration

## Setup Instructions

### 1. Deploy DNS Components

```bash
# Deploy RBAC and service account
kubectl apply -f external-dns-setup.yml

# Deploy DNS updater
kubectl apply -f dns-updater-k8s.yml
```

### 2. Configure Local DNS Resolution

```bash
# Configure systemd-resolved to use in-cluster CoreDNS for .kub domains
./configure-systemd-resolved.sh
```

### 3. Verify Setup

```bash
# Check DNS updater is running
kubectl get pods -n kube-system -l app=dns-updater

# Check DNS resolution works
dig @10.10.10.254 echo.kub
nslookup echo.kub
```

## How It Works

### DNS Updater
- Monitors LoadBalancer services and Ingresses every 30 seconds
- Automatically generates DNS zone files with proper SOA records
- Uses 10-digit serial numbers in YYYYMMDDSS format
- Updates the `coredns-config` ConfigMap with new DNS records
- Restarts CoreDNS when changes are detected

### Automatic DNS Record Creation
- **LoadBalancer Services**: Creates A records pointing to the LoadBalancer IP
- **Ingresses**: Creates A records for ingress hostnames pointing to Traefik LoadBalancer IP
- **Serial Numbers**: Uses proper 10-digit format (YYYYMMDDSS) for zone file serial numbers

### Zone File Format
```
$ORIGIN kub.
@   3600 IN SOA ns1.kub. admin.kub. (
        2025071714 ; serial (YYYYMMDDSS format)
        7200       ; refresh (2 hours)
        3600       ; retry (1 hour)
        1209600    ; expire (2 weeks)
        3600       ; minimum (1 hour)
        )

; Nameserver record
@       IN NS   ns1.kub.
ns1     IN A    127.0.0.1

; Service records (auto-generated)
echo    30 IN A 10.10.10.2
api     30 IN A 10.10.10.3
```

## LoadBalancer Configuration

The DNS updater expects:
- CoreDNS LoadBalancer service at `10.10.10.254`
- Traefik LoadBalancer service for Ingress records
- MetalLB configured with appropriate IP ranges

## Troubleshooting

### Check DNS Updater Logs
```bash
kubectl logs -l app=dns-updater -n kube-system
```

### Check CoreDNS Logs
```bash
kubectl logs -l app=coredns-kub -n kube-system
```

### Check DNS Resolution
```bash
# Test direct DNS query
dig @10.10.10.254 echo.kub

# Test local resolution
nslookup echo.kub
```

### Check ConfigMap Content
```bash
kubectl get configmap coredns-config -n kube-system -o yaml
```

## Cleanup

To remove local DNS configuration:
```bash
./uninstall-systemd-resolved.sh
```

To remove DNS components:
```bash
kubectl delete -f dns-updater-k8s.yml
kubectl delete -f external-dns-setup.yml
```
