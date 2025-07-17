# cert-manager with step-ca Integration

This directory contains the configuration to integrate cert-manager with the step-ca ACME server for automatic certificate issuance in the k3d cluster.

## Prerequisites

- k3d cluster running
- step-ca server running (see `../00-ca/README.md`)
- kubectl configured to access the k3d cluster

## Setup

1. **Install cert-manager and configure step-ca integration:**
   ```bash
   ./setup-cert-manager.sh
   ```

2. **Verify the setup:**
   ```bash
   kubectl get clusterissuer step-ca-acme
   kubectl get certificate test-cert -o wide
   ```

## Configuration Files

### `step-ca-issuer.yaml`
- **ClusterIssuer**: Configures cert-manager to use step-ca as the ACME server
- **Certificate**: Example certificate for testing

### `setup-cert-manager.sh`
- Installation script for cert-manager
- Applies the step-ca configuration

## Testing Certificate Issuance

The configuration includes a test certificate that will be automatically issued for:
- `test.kub`
- `api.kub`

To check the certificate status:
```bash
kubectl get certificate test-cert -o wide
kubectl describe certificate test-cert
kubectl get secret test-cert-tls -o yaml
```

## Creating Additional Certificates

To create certificates for your applications, use the following template:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-app-cert
  namespace: default
spec:
  secretName: my-app-cert-tls
  issuerRef:
    name: step-ca-acme
    kind: ClusterIssuer
  dnsNames:
  - my-app.kub
  - www.my-app.kub
```

## Troubleshooting

### Certificate Not Issuing

1. **Check the ClusterIssuer status:**
   ```bash
   kubectl describe clusterissuer step-ca-acme
   ```

2. **Check certificate events:**
   ```bash
   kubectl describe certificate test-cert
   ```

3. **Check cert-manager logs:**
   ```bash
   kubectl logs -n cert-manager -l app=cert-manager
   ```

4. **Verify step-ca is accessible:**
   ```bash
   curl -k https://host.docker.internal:8443/health
   curl -k https://host.docker.internal:8443/acme/acme-1/directory
   ```

### Common Issues

- **step-ca not accessible**: Ensure the step-ca container is running and accessible at `host.docker.internal:8443`
- **CA certificate trust issues**: The root CA certificate is included in the `caBundle` field
- **ACME challenges failing**: Check that the ingress controller (Traefik) is properly configured
- **DNS resolution**: Ensure `.kub` domains resolve properly in your environment

## Integration with Applications

Once certificates are issued, they can be used in Kubernetes resources:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
spec:
  tls:
  - hosts:
    - my-app.kub
    secretName: my-app-cert-tls
  rules:
  - host: my-app.kub
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```

## step-ca ACME Server Details

- **Server URL**: `https://host.docker.internal:8443/acme/acme-1/directory`
- **Provisioner**: `acme-1`
- **Challenge Types**: HTTP-01 via Traefik ingress
- **Certificate Lifetime**: Configured in step-ca (default: 24 hours)
- **Root CA**: Included in the ClusterIssuer configuration
