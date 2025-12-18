# Ontop

Ontop service exposed via Gateway API with cert-manager TLS.

## Install
```bash
./install.sh
```

## Check
```bash
kubectl get deployment ontop
kubectl get certificate ontop-cert -n istio-system
```
