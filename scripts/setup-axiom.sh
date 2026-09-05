#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

command -v docker >/dev/null 2>&1 || { echo "Docker CLI is required."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required."; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo "OpenSSL is required."; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker daemon is not running."; exit 1; }

AVAILABLE_KB=$(df -Pk "$ROOT_DIR" | awk 'NR==2 {print $4}')
if [ "${AVAILABLE_KB:-0}" -lt 2097152 ]; then
  echo "At least 2GB of free disk space is required."
  exit 1
fi

mkdir -p "$ROOT_DIR/postgres_data" "$ROOT_DIR/logs" "$ROOT_DIR/ssl"

if [ ! -f "$ENV_FILE" ]; then
  DB_PASSWORD=$(openssl rand -base64 24 | tr -d '\n' | tr '/+' 'ab' | cut -c1-24)
  cat > "$ENV_FILE" <<ENVVARS
AXIOM_PORT=8080
AXIOM_ENV=production
AXIOM_LOG_LEVEL=info
POSTGRES_USER=axiom
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=axiom
DATABASE_URL=postgresql://axiom-db:5432/axiom
AXIOM_INTERNAL_URL=http://axiom-web:8080
DOMAIN=localhost
SSL_CERT_PATH=/etc/nginx/ssl/cert.pem
SSL_KEY_PATH=/etc/nginx/ssl/key.pem
ENVVARS
  echo "Created .env with generated credentials."
fi

if [ ! -f "$ROOT_DIR/ssl/cert.pem" ] || [ ! -f "$ROOT_DIR/ssl/key.pem" ]; then
  openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
    -keyout "$ROOT_DIR/ssl/key.pem" \
    -out "$ROOT_DIR/ssl/cert.pem" \
    -subj "/CN=localhost" >/dev/null 2>&1
  echo "Generated local self-signed TLS certificate in ssl/."
fi

cd "$ROOT_DIR"
docker compose up -d --build

echo "Waiting for AXIOM to become healthy..."
for _ in {1..30}; do
  if curl -ksf https://localhost/health >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

curl -ksf https://localhost/health >/dev/null
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "${LOCAL_IP:-}" ] && command -v ipconfig >/dev/null 2>&1; then
  LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || true)
fi
EXTERNAL_IP=$(curl -s --max-time 5 https://api.ipify.org || echo "unavailable")

echo "AXIOM is running."
echo "Local URL: https://localhost"
echo "Local IP: ${LOCAL_IP:-unavailable}"
echo "External IP: $EXTERNAL_IP"

echo "Verification checklist:"
echo "[x] Docker daemon running"
echo "[x] .env configured"
echo "[x] Containers started"
echo "[x] Health check passed"
