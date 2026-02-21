#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo
echo "============================================================"
echo " Claude Code in Docker — First-Time Setup"
echo "============================================================"
echo
echo "This will:"
echo "  1. Check Docker is installed and running"
echo "  2. Prompt for your Anthropic API key (if .env is missing)"
echo "  3. Build the Claude Code container"
echo "  4. Start it and optionally launch Claude Code"
echo

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is not running or not installed."
  echo "Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
  exit 1
fi

echo "[1/4] Docker is running."

echo "[2/4] Checking API key setup..."
if [[ ! -f .env ]]; then
  if [[ -f .env.example ]]; then
    cp .env.example .env
  else
    echo "ANTHROPIC_API_KEY=your-api-key-here" > .env
  fi

  echo "Enter your Anthropic API key (input hidden):"
  read -r -s APIKEY
  echo

  if [[ -z "${APIKEY}" ]]; then
    echo "ERROR: No API key entered. Aborting."
    rm -f .env
    exit 1
  fi

  printf 'ANTHROPIC_API_KEY=%s\n' "$APIKEY" > .env
  echo "Saved key to .env"
else
  echo "Found existing .env file."
fi

echo "[3/4] Building container image..."
docker compose build

echo "[4/4] Starting container..."
docker compose up -d

echo
echo "============================================================"
echo " Setup complete!"
echo "============================================================"
echo "Workspace: $(pwd)/workspace"
echo "Launch Claude any time with: ./claude.sh"
echo

read -r -p "Launch Claude Code now? (y/N): " launch
if [[ "${launch,,}" == "y" ]]; then
  exec ./claude.sh
fi
