#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required. Install Docker Desktop or Docker Engine first."
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "Docker Compose is required."
  exit 1
fi

if [ -d .git ]; then
  echo "Pulling latest code..."
  git pull --ff-only
fi

if [ ! -f .env ]; then
  echo "Creating .env from template..."
  cp .env.example .env
  if command -v openssl >/dev/null 2>&1; then
    DB_PASSWORD="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 24)"
  else
    DB_PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24)"
  fi
  awk -v pw="$DB_PASSWORD" '
    /^AXIOM_DB_PASSWORD=/ { print "AXIOM_DB_PASSWORD=" pw; next }
    { print }
  ' .env > .env.tmp && mv .env.tmp .env
fi

echo "Pulling images..."
$COMPOSE_CMD pull

echo "Starting AXIOM containers..."
$COMPOSE_CMD up -d axiom-web axiom-db axiom-proxy

PROXY_PORT="$(grep -E '^AXIOM_PROXY_PORT=' .env 2>/dev/null | tail -1 | cut -d= -f2)"
PROXY_PORT="${PROXY_PORT:-8080}"
LOCAL_IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
if [ -z "${LOCAL_IP}" ] && command -v ipconfig >/dev/null 2>&1; then
  LOCAL_IP="$(ipconfig getifaddr en0 2>/dev/null || true)"
fi
if [ -z "${LOCAL_IP}" ] && command -v ip >/dev/null 2>&1; then
  LOCAL_IP="$(ip route get 1 2>/dev/null | awk '{print $7; exit}')"
fi
LOCAL_IP="${LOCAL_IP:-127.0.0.1}"
EXTERNAL_IP="$(curl -fsS https://api.ipify.org 2>/dev/null || echo unavailable)"

echo ""
echo "AXIOM is running"
echo "- Local URL: http://localhost:${PROXY_PORT}"
echo "- Local IP: ${LOCAL_IP}"
echo "- External IP: ${EXTERNAL_IP}"
echo "- Stop/remove: ./uninstall-axiom-linux.sh"
