# Ontop endpoint for LEGO database

Runs Ontop against the Postgres LEGO sample DB (from `08-postgres`) and exposes it via HTTPS at `https://ontop.kub/`.

## What it includes
- Ontop endpoint (`ontop/ontop:latest`) serving on port 8080 behind Traefik Ingress with TLS (cert-manager `step-ca-acme`) and HTTP→HTTPS redirect middleware.
- OBDA mapping for the LEGO schema with prefix `lego: <https://lego.com/#>`.
- PostgreSQL JDBC driver fetched in an init container.
- Secrets for DB credentials; defaults match the `08-postgres` deployment.

## Deploy
```bash
cd 09-ontop
./install.sh
```
Wait for:
```bash
kubectl get pods -l app=ontop
```

## Access
- URL: `https://ontop.kub/`
- SPARQL endpoint (default Ontop endpoint): `https://ontop.kub/sparql`

## Configuration
- DB connection points at `postgres.default.svc.cluster.local:5432/lego`.
- Update credentials by editing `ontop.yml` or patching `ontop-db-secret`.
- OBDA mapping lives in ConfigMap `ontop-mapping` (`mapping.obda`); ontology placeholder at `ontology.owl`.

## Cleanup
```bash
cd 09-ontop
./uninstall.sh
```
