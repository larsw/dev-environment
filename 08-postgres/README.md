# Postgres + pgAdmin

Single-node Postgres with the LEGO sample database preloaded and pgAdmin exposed over HTTPS at `https://pgadmin.kub/`.

## What this does
- Deploys Postgres 15 with PVC-backed storage and preloads `lego.sql` from Neon sample DBs into a `lego` database on first start.
- Deploys pgAdmin 4 and stores its state on a PVC.
- Preconfigures pgAdmin with a server entry pointing at the in-cluster Postgres (`postgres.default.svc.cluster.local:5432`, DB `lego`, user `postgres`).
- Exposes pgAdmin via Traefik Ingress with TLS (cert-manager `step-ca-acme`) and the HTTP→HTTPS redirect middleware.
- Creates DNS annotation for `pgadmin.kub`.

## Files
- `postgres.yml` — Secrets, PVCs, Deployments, Services, Ingress, and middleware.
- `install.sh` / `uninstall.sh` — Apply or remove everything.

## Deploy
```bash
cd 08-postgres
./install.sh
```
Wait for:
```bash
kubectl get pods -l app=postgres
kubectl get pods -l app=pgadmin
```

## Access pgAdmin
- URL: `https://pgadmin.kub/`
- Credentials: stored in secret `pgadmin-secret` (`PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`).

### Connect pgAdmin to Postgres
Use these defaults (change if you updated the secrets):
- Host: `postgres.default.svc.cluster.local`
- Port: `5432`
- Username: value of `POSTGRES_USER` in `postgres-secret` (default: `postgres`)
- Password: value of `POSTGRES_PASSWORD` in `postgres-secret`
- Database: `lego` (preloaded from the sample dump)

## Customize secrets
Update `stringData` in `postgres.yml` before installing, or patch after deploy:
```bash
kubectl patch secret postgres-secret -n default --type merge -p '{
  "stringData": { "POSTGRES_USER": "youruser", "POSTGRES_PASSWORD": "changeme" }
}'
kubectl patch secret pgadmin-secret -n default --type merge -p '{
  "stringData": { "PGADMIN_DEFAULT_EMAIL": "you@example.com", "PGADMIN_DEFAULT_PASSWORD": "changeme" }
}'
```

## Cleanup
```bash
cd 08-postgres
./uninstall.sh
```
