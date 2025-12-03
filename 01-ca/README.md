# Step-ca ACME Server Setup

This directory contains the setup for a local step-ca Certificate Authority that serves as an ACME server for `.kub` domains.

## Overview

Step-ca is a private Certificate Authority that provides ACME (Automated Certificate Management Environment) protocol support. This setup creates a local CA specifically for managing certificates for services in the `.kub` domain within your k3d environment.

## Files

- **`docker-compose.yml`** - Docker Compose configuration for step-ca container
- **`setup-step-ca.sh`** - Complete setup script that installs step CLI and configures step-ca
- **`step-ca-config/`** - Step-ca configuration directory (created during setup)

## Quick Start

```bash
cd 00-ca
./setup-step-ca.sh
```

## What the Setup Does

1. **Installs step CLI** using the official Smallstep APT repository
2. **Initializes step-ca configuration** for `.kub` domains
3. **Starts step-ca container** on port 8443
4. **Enables ACME provisioner** for automated certificate management
5. **Installs root CA certificate** in system trust store
6. **Tests connectivity** and health checks

## Configuration Details

### Docker Container
- **Image**: `smallstep/step-ca:latest`
- **Port**: 8443 (external) → 9000 (internal)
- **Network**: Isolated Docker network
- **Health Check**: Built-in step ca health command
- **Initialization**: Manual initialization via setup script (not Docker auto-init)
- **Volume**: `./step-ca-config` mounted to `/home/step` in container

### ACME Server
- **URL**: `https://localhost:8443/acme/acme/directory`
- **Protocol**: ACME v2 (RFC 8555)
- **Domains**: Configured for `.kub` domains
- **Authentication**: No authentication required for ACME (standard behavior)

## Integration with k3d

The step-ca server is configured to work with the k3d environment:

1. **DNS Names**: Includes `step-ca.kub`, `localhost`, and `127.0.0.1`
2. **Docker Network**: Accessible from k3d containers via `host.docker.internal:8443`
3. **Cert-manager**: Configured as ClusterIssuer in `06-cert-manager/cert-manager-step-ca.yml`
4. **System Trust**: Root CA installed in system trust store

## Usage

### Test ACME Directory
```bash
curl -k https://localhost:8443/acme/acme/directory
```

### Check Container Status
```bash
docker-compose ps
docker-compose logs step-ca
```

### Test Step-ca Health
```bash
step ca health --ca-url https://localhost:8443 --root ./step-ca-config/certs/root_ca.crt
```

### Get Root CA Certificate
```bash
step ca root ./step-ca-config/certs/root_ca.crt --ca-url https://localhost:8443 --insecure
```

## Certificate Management

Once integrated with cert-manager in your k3d cluster, certificates will be automatically:

1. **Requested** by cert-manager when services need TLS
2. **Validated** via HTTP-01 challenge through Traefik ingress
3. **Issued** by step-ca for `.kub` domains
4. **Renewed** automatically before expiration
5. **Stored** as Kubernetes secrets

## Security Considerations

- **Local Development Only**: This setup is intended for local development environments
- **Self-signed Root**: The root CA is self-signed and installed in system trust store
- **No Remote Management**: Remote management is disabled for security
- **ACME Authentication**: Uses standard ACME challenge authentication
- **TLS Verification**: Cert-manager configured to skip TLS verification for localhost

## Troubleshooting

### Container won't start
```bash
docker-compose logs step-ca
```

### ACME directory not accessible
```bash
# Check if step-ca is healthy
step ca health --ca-url https://localhost:8443 --root ./step-ca-config/certs/root_ca.crt

# Check container networking
docker-compose exec step-ca netstat -tlnp
```

### Certificate validation fails
```bash
# Check if root CA is installed
ls -la /usr/local/share/ca-certificates/step-ca-kub.crt

# Update CA certificates
sudo update-ca-certificates
```

### Step CLI not found
```bash
# Reinstall step CLI
sudo apt-get update && sudo apt-get install step-cli
```

## Advanced Configuration

### Custom Configuration
Edit `step-ca-config/config/ca.json` after initialization to customize:
- Certificate validity periods
- Key algorithms
- Additional provisioners
- DNS names

### Backup and Restore
Important files to backup:
- `step-ca-config/` - Complete configuration
- `step-ca-data/` - Certificate database
- Root CA certificate for system trust

## Next Steps

After setting up step-ca, continue with:
1. **02-cluster** - Create k3d cluster with cert-manager
2. **05-loadbalancer** - Setup MetalLB for LoadBalancer services
3. **03-ingress** - Setup Traefik with TLS certificates
4. **04-dns** - Configure DNS for `.kub` domains
