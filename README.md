# Development Environment

K3d-based cluster with MetalLB, DNS for `.kub`, Istio Gateway API ingress, and cert-manager using step-ca.

## Components (order)
1. `01-ca`
2. `02-cluster`
3. `03-dns`
4. `04-loadbalancer`
5. `05-ingress`
6. `06-certificate-manager`
7. `07-echo`
8. `08-postgres`
9. `09-ontop`

## Install all
```bash
./install-all.sh
```

## Install individually
```bash
cd 01-ca && ./install.sh
cd 02-cluster && ./install.sh
cd 03-dns && ./install.sh
cd 04-loadbalancer && ./install.sh
cd 05-ingress && ./install.sh
cd 06-certificate-manager && ./install.sh
cd 07-echo && ./install.sh
cd 08-postgres && ./install.sh
cd 09-ontop && ./install.sh
```

## Validate
```bash
./validate-setup.sh
```

## Uninstall all
```bash
./uninstall-all.sh
```

## Uninstall individually (reverse order)
```bash
cd 09-ontop && ./uninstall.sh
cd 08-postgres && ./uninstall.sh
cd 07-echo && ./uninstall.sh
cd 06-certificate-manager && ./uninstall.sh
cd 05-ingress && ./uninstall.sh
cd 04-loadbalancer && ./uninstall.sh
cd 03-dns && ./uninstall.sh
cd 02-cluster && ./uninstall.sh
cd 01-ca && ./uninstall.sh
```

## Checks
```bash
nslookup echo.kub
curl -k https://echo.kub/
```
