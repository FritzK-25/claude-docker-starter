#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo "No .env file found. Run ./setup.sh first."
  exit 1
fi

if [[ "$(docker inspect -f '{{.State.Running}}' claude-code 2>/dev/null || true)" != "true" ]]; then
  echo "Starting container..."
  docker compose up -d
fi

echo "Checking for Claude Code updates..."
docker exec claude-code claude update || true

echo
exec docker exec -it claude-code claude
