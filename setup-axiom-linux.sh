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
  git pull --ff-only || true
fi

if [ ! -f .env ]; then
  echo "Creating .env from template..."
  cp .env.example .env
  if command -v openssl >/dev/null 2>&1; then
    DB_PASSWORD="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 24)"
  else
    DB_PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24)"
  fi
  sed -i.bak "s/^AXIOM_DB_PASSWORD=.*/AXIOM_DB_PASSWORD=${DB_PASSWORD}/" .env && rm -f .env.bak
fi

echo "Pulling images..."
$COMPOSE_CMD pull

echo "Starting AXIOM containers..."
$COMPOSE_CMD up -d axiom-web axiom-db axiom-proxy

LOCAL_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
LOCAL_IP="${LOCAL_IP:-127.0.0.1}"
EXTERNAL_IP="$(curl -fsS https://api.ipify.org 2>/dev/null || echo unavailable)"

echo ""
echo "AXIOM is running"
echo "- Local URL: http://localhost:8080"
echo "- Local IP: ${LOCAL_IP}"
echo "- External IP: ${EXTERNAL_IP}"
echo "- Stop/remove: ./uninstall-axiom-linux.sh"
