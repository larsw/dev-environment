# Echo Service

This directory contains a simple echo service for testing the DNS and HTTPS setup.

## Overview

The echo service demonstrates:
- Automatic DNS record creation for `.kub` domains
- HTTPS certificate provisioning using cert-manager
- Ingress configuration with Traefik

## Files

- `echo-service.yml` - Complete echo service deployment with Ingress and TLS

## Deployment

```bash
kubectl apply -f echo-service.yml
```

## Features

### Service Configuration
- **Deployment**: Simple echo server that returns request information
- **Service**: ClusterIP service for internal communication
- **Ingress**: Traefik ingress with TLS termination

### Automatic DNS
- The DNS updater automatically creates an A record for `echo.kub`
- Points to the Traefik LoadBalancer IP (typically `10.10.10.1`)

### HTTPS Certificate
- Uses cert-manager with `step-ca-acme` ClusterIssuer
- Automatically provisions TLS certificate for `echo.kub`
- Forces SSL redirect for all HTTP requests

## Testing

### DNS Resolution
```bash
# Test DNS resolution
nslookup echo.kub
dig echo.kub
```

### HTTP/HTTPS Access
```bash
# Test HTTP (should redirect to HTTPS)
curl -v http://echo.kub/

# Test HTTPS
curl -k https://echo.kub/
```

### Certificate Verification
```bash
# Check certificate
kubectl get certificate -n default
kubectl describe certificate echo-tls-secret -n default
```

## Expected Response

The echo service returns JSON with request information:
```json
{
  "host": {
    "hostname": "echo.kub",
    "ip": "::ffff:10.42.2.5",
    "ips": []
  },
  "http": {
    "method": "GET",
    "baseUrl": "",
    "originalUrl": "/",
    "protocol": "http"
  },
  "request": {
    "params": {"0": "/"},
    "query": {},
    "cookies": {},
    "body": {},
    "headers": {
      "host": "echo.kub",
      "user-agent": "curl/8.5.0",
      "x-forwarded-proto": "https",
      ...
    }
  }
}
```

## Cleanup

```bash
kubectl delete -f echo-service.yml
```
