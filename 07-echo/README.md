# Echo service

Deploys an echo server behind an Istio Gateway and issues a cert via cert-manager.

## Install
```bash
./install.sh
```

## Check
```bash
kubectl get deployment echo
kubectl get certificate echo-cert -n istio-system
curl -k https://echo.kub/
```
