# Postgres + pgAdmin

Postgres with a seeded database and pgAdmin exposed via Gateway API.

## Install
```bash
./install.sh
```

## Access
- Host: `pgadmin.kub`
- Credentials are in `pgadmin-secret` (`PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`).

## Check
```bash
kubectl get deployment postgres
kubectl get deployment pgadmin
kubectl get certificate pgadmin-cert -n istio-system
```
