#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/locust/docker-compose.locust.yml"

docker compose -f "$COMPOSE_FILE" up --build
