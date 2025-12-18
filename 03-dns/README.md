# DNS for .kub

CoreDNS + a DNS updater that writes the `.kub` zone from cluster state.

## Files
- `coredns-kub.yml`
- `dns-updater-k8s.yml`
- `external-dns-setup.yml`
- `configure-systemd-resolved.sh`
- `uninstall-systemd-resolved.sh`

## Install
```bash
./install.sh
```

## Verify
```bash
kubectl get svc coredns-kub -n kube-system
kubectl logs -n kube-system -l app=dns-updater
```

## Local resolver
```bash
./configure-systemd-resolved.sh
```

## Notes
- Requires MetalLB IP pool from `04-loadbalancer`.
