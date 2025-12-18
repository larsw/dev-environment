# cert-manager with step-ca

Installs cert-manager and configures a step-ca ClusterIssuer.

## Prereqs
- Cluster running
- step-ca running (`../01-ca`)

## Install
```bash
./install.sh
```

## Check
```bash
kubectl get clusterissuer step-ca-acme
kubectl get certificates -A
```

## ACME server
- `https://10.10.0.6:8443/acme/acme/directory`
