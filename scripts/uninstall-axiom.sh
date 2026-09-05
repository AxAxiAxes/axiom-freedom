#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

docker compose down -v --remove-orphans
if ! rm -rf "$ROOT_DIR/postgres_data" "$ROOT_DIR/logs" "$ROOT_DIR/ssl" 2>/dev/null; then
  docker run --rm -v "$ROOT_DIR:/workspace" alpine sh -c "rm -rf /workspace/postgres_data /workspace/logs /workspace/ssl" >/dev/null
fi
echo "AXIOM containers and local persistent data removed."
