# Step-ca ACME Server

Local step-ca for `.kub` certificates.

## Files
- `docker-compose.yml`
- `setup-step-ca.sh`
- `step-ca-config/`

## Setup
```bash
./setup-step-ca.sh
```

## Endpoints
- ACME directory: `https://localhost:8443/acme/acme/directory`
- Health: `https://localhost:8443/health`

## Notes
- Root CA is installed into system trust by the setup script.
- Cluster integration uses `06-certificate-manager/cert-manager-step-ca.yml`.
