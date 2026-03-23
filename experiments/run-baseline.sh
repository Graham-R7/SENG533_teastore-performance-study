#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$ROOT_DIR/workload/baseline.arrival"
SCRIPT="$ROOT_DIR/workload/browsing.lua"
OUT_DIR="$ROOT_DIR/results/raw"
OUT="$OUT_DIR/baseline.csv"

echo "Running baseline..."

missing=0

if [ ! -f "$SCRIPT" ]; then
  echo "Error: workload script not found at $SCRIPT" >&2
  missing=1
fi

if ! command -v load-generator >/dev/null 2>&1; then
  echo "Error: 'load-generator' is not installed or not in PATH." >&2
  missing=1
fi

if [ "$missing" -ne 0 ]; then
  exit 1
fi

mkdir -p "$OUT_DIR"

load-generator \
  --arrival-rate $PROFILE \
  --script $SCRIPT \
  --output $OUT
