#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env.local"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing .env.local. Copy .env.example to .env.local and set GOLEMIO_API_TOKEN." >&2
  exit 1
fi

line="$(grep -E '^GOLEMIO_API_TOKEN=' "$ENV_FILE" | head -n 1 || true)"
GOLEMIO_API_TOKEN="${line#GOLEMIO_API_TOKEN=}"

if [[ -z "$GOLEMIO_API_TOKEN" || "$GOLEMIO_API_TOKEN" == "your_token_here" ]]; then
  echo "GOLEMIO_API_TOKEN in .env.local is not set." >&2
  exit 1
fi

flutter run --dart-define="GOLEMIO_API_TOKEN=$GOLEMIO_API_TOKEN"
