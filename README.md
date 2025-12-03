# Local K3D-based Development Environment

This repository contains a complete setup for a k3d cluster with MetalLB LoadBalancer, automatic DNS management for `.kub` domains, and HTTPS certificate provisioning.

## Overview

The environment provides:
- **k3d cluster** with MetalLB LoadBalancer
- **Automatic DNS management** for `.kub` domains
- **HTTPS certificate provisioning** using cert-manager and Step-CA
- **Local DNS resolution** via systemd-resolved configuration

## Directory Structure

```
k3d-metallb-environment/
├── 01-ca/                         # Step-CA ACME server setup
│   ├── docker-compose.yml         # Step-CA container configuration
│   ├── setup-step-ca.sh          # Complete Step-CA setup script
│   ├── step-ca-config/           # Step-CA configuration files
│   └── README.md                 # Step-CA documentation
├── 02-cluster/                    # K3d cluster setup
│   └── create-cluster.sh         # Create cluster
├── 03-ingress/                   # Traefik ingress controller
│   ├── values.yml               # Traefik configuration
│   ├── setup-traefik.sh         # Traefik setup script
│   └── setup-dashboard-auth.sh  # Dashboard authentication setup
├── 04-dns/                       # DNS setup (CoreDNS + DNS updater)
│   ├── dns-updater-k8s.yml      # DNS updater deployment
│   ├── external-dns-setup.yml   # RBAC and service account
│   ├── configure-systemd-resolved.sh # Configure systemd-resolved
│   ├── uninstall-systemd-resolved.sh # Revert systemd-resolved
│   └── README.md                 # DNS setup documentation
├── 05-loadbalancer/              # MetalLB LoadBalancer setup
│   └── metallb-setup.yml        # MetalLB IP pool and L2 advertisement
├── 06-cert-manager/              # cert-manager configuration
│   ├── cert-manager-step-ca.yml  # ClusterIssuer for step-ca ACME
│   ├── coredns-custom.yaml      # CoreDNS custom configuration
│   ├── install.sh               # cert-manager setup script
│   ├── step-ca-issuer.yaml      # Example test certificate
│   ├── step-ca-service.yaml     # Step-CA service configuration
│   ├── test-cert-new.yaml       # Test certificate
│   └── README.md                # cert-manager documentation
├── 07-echo/                      # Echo service example
│   ├── echo-service.yml         # Echo service with Ingress and TLS
│   └── README.md                # Echo service documentation
├── install-all.sh                # Complete environment installation
├── uninstall-all.sh              # Complete environment uninstallation
├── validate-setup.sh             # Setup validation script
└── README.md                    # This file
```

## Quick Start

## Quick Start

Run the complete installation:
```bash
./install-all.sh
```

Or install components individually:

### 1. Start Step-CA ACME Server
```bash
cd 01-ca
./install.sh
```

### 2. Create k3d Cluster
```bash
cd 02-cluster
./install.sh
```

### 3. Setup MetalLB LoadBalancer
```bash
cd 05-loadbalancer
./install.sh
```

### 4. Setup Traefik Ingress
```bash
cd 03-ingress
./install.sh
```

### 5. Setup DNS Management
```bash
cd 04-dns
./install.sh
```

### 6. Setup cert-manager
```bash
cd 06-cert-manager
./install.sh
```

### 7. Deploy Echo Service
```bash
cd 07-echo
./install.sh
```

## Key Features

### Automatic DNS Management
- **DNS Updater**: Automatically creates DNS records for LoadBalancer services and Ingresses
- **Zone File Generation**: Creates proper DNS zone files with correct SOA records
- **Serial Number Management**: Uses 10-digit serial numbers in YYYYMMDDSS format
- **Dynamic Updates**: Monitors services every 30 seconds and updates DNS records

### LoadBalancer Configuration
- **MetalLB**: Provides LoadBalancer IPs (10.10.10.1-10.10.20.253)
- **CoreDNS**: In-cluster DNS server exposed via a MetalLB LoadBalancer for .kub domains (IP is auto-discovered)
- **Traefik**: Ingress controller with a MetalLB-assigned LoadBalancer IP

### HTTPS Certificate Management
- **Step-CA**: Local ACME server for certificate authority
- **cert-manager**: Automatic certificate provisioning and renewal
- **TLS Ingress**: Automatic HTTPS for all .kub domains

### Local DNS Resolution
- **systemd-resolved**: Configured to use in-cluster CoreDNS for .kub domains
- **Fallback DNS**: All other queries forwarded to system DNS

## Usage

### Automatic DNS Records
Services and Ingresses automatically get DNS records:

**For LoadBalancer Services:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    external-dns.alpha.kubernetes.io/hostname: my-service.kub
spec:
  type: LoadBalancer
  # ... rest of service spec
```

**For Ingresses:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    cert-manager.io/cluster-issuer: step-ca-acme
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - my-service.kub
    secretName: my-service-tls
  rules:
  - host: my-service.kub
    # ... rest of ingress spec
```

### Testing
```bash
# Test DNS resolution
nslookup echo.kub
dig echo.kub

# Test HTTPS service
curl -k https://echo.kub/
```

## Troubleshooting

### Check DNS Updater
```bash
kubectl logs -l app=dns-updater -n kube-system
```

### Check CoreDNS
```bash
kubectl logs -l app=coredns-kub -n kube-system
```

### Check Certificates
```bash
kubectl get certificates -A
kubectl describe certificate echo-tls-secret -n default
```

## Cleanup

## Cleanup

### Complete Uninstallation
```bash
./uninstall-all.sh
```

### Individual Component Uninstallation
```bash
# Remove components in reverse order
cd 07-echo && ./uninstall.sh
cd 06-cert-manager && ./uninstall.sh
cd 05-loadbalancer && ./uninstall.sh
cd 04-dns && ./uninstall.sh
cd 03-ingress && ./uninstall.sh
cd 02-cluster && ./uninstall.sh
cd 01-ca && ./uninstall.sh
```

## Architecture

```
[Local Machine] → [systemd-resolved] → [CoreDNS LoadBalancer (MetalLB IP)] → [CoreDNS Pod]
                                                                                    ↓
                                                                           [DNS Updater Pod]
                                                                                    ↓
                                                                           [ConfigMap: coredns-config]
                                                                                    ↓
                                                                           [LoadBalancer Services]
                                                                           [Ingresses]
```

The DNS updater automatically monitors LoadBalancer services and Ingresses, generates proper DNS zone files, and updates the CoreDNS configuration to serve .kub domains.
