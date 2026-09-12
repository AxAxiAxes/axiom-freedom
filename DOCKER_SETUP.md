# AXIOM Docker Setup

## Quick start (local)

```bash
./scripts/setup-axiom.sh
# Windows PowerShell: ./scripts/setup-axiom.ps1
```

Then open: `https://localhost` (health endpoint: `https://localhost/health`).
The setup scripts auto-create `.env` with a generated DB password when it is missing.

## Prerequisites
- Docker Desktop or Docker Engine + Compose v2
- OpenSSL available on Linux/macOS (Windows script generates cert via container)
- At least 2GB free disk

## Environment setup
1. Copy `.env.example` to `.env` only if you want to predefine values.
2. Set secure values for `POSTGRES_PASSWORD`.
3. Optionally set `DOMAIN` for your hostname.

## Running services
```bash
docker compose up -d --build
docker compose ps
docker compose logs -f axiom-web
```

## Access
- Proxy: `https://localhost` (ports `80/443`)
- Web container internal port: `8080`
- Postgres internal port: `5432`

## Common commands
```bash
docker compose ps
docker compose logs -f axiom-proxy
docker compose restart axiom-web
docker compose stop
docker compose down
```

## Troubleshooting
- Check health: `curl -ks https://localhost/health`
- Check cert files exist: `ssl/cert.pem`, `ssl/key.pem`
- Rebuild stack: `docker compose down -v && rm -rf postgres_data logs ssl && docker compose up -d --build`

## Production notes
- Replace self-signed certs in `ssl/` with real TLS cert/key.
- Set strong database credentials in `.env`.
- Optionally prebuild/pull images via `.github/workflows/docker-build-push.yml`.

## Scaling considerations
- Run multiple `axiom-web` replicas behind proxy in orchestrators (Swarm/Kubernetes).
- Move Postgres to managed service for HA and backups.
- Centralize logs and metrics for multi-node deployments.
