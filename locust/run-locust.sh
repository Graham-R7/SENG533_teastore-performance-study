#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="${TEASTORE_HOST:-http://localhost:8080}"

python3 -m locust \
  -f "$ROOT_DIR/locust/locustfile.py" \
  --host "$HOST"
