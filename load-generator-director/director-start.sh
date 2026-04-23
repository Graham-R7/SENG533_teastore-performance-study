#!/bin/bash

# =============================================================================
# Runs the LIMBO HTTP Load Generator in director mode for TeaStore performance
# testing. Start the load generator manually on the remote machine first.
#
# USAGE:
#   ./director-start.sh [low|med|high]
#   Workload intensity defaults to "low" if not specified.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR="$SCRIPT_DIR/httploadgenerator.jar"
LUA_SCRIPT="$SCRIPT_DIR/request-scripts/teastore_browse.lua"
RESULTS_DIR="$SCRIPT_DIR/results"

declare -A PROFILES=(
    [low]="$SCRIPT_DIR/workloads/increasingLowIntensity.csv"
    [med]="$SCRIPT_DIR/workloads/increasingMedIntensity.csv"
    [high]="$SCRIPT_DIR/workloads/increasingHighIntensity.csv"
)

LOADGEN_HOST="${LOADGEN_HOST:-192.168.1.100}"
LOADGEN_PORT="${LOADGEN_PORT:-5000}"
WARMUP_SECS="${WARMUP_SECS:-30}"
MAX_THREADS="${MAX_THREADS:-256}"
AUTO_START="${AUTO_START:-0}"

intensity_arg="${1:-}"
intensity="${intensity_arg:-${WORKLOAD_INTENSITY:-low}}"
profile="${PROFILES[$intensity]:-}"

if [[ -z "$profile" ]]; then
    echo "Unknown workload intensity: $intensity" >&2
    echo "Expected one of: low, med, high" >&2
    exit 1
fi

mkdir -p "$RESULTS_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
result_file="$RESULTS_DIR/result_${intensity}_${timestamp}.csv"

echo "  Intensity    : $intensity"
echo "  Load profile : $profile"
echo "  LUA script   : $LUA_SCRIPT"
echo "  Load gen     : $LOADGEN_HOST:$LOADGEN_PORT"
echo "  Warmup (s)   : $WARMUP_SECS"
echo "  Max threads  : $MAX_THREADS"
echo "  Result file  : $result_file"

if [[ "$AUTO_START" == "1" || ! -t 0 ]]; then
    echo "Auto-start enabled; skipping interactive confirmation."
else
    echo "Ensure the load generator is already running on $LOADGEN_HOST:$LOADGEN_PORT"
    echo -n "Press [Enter] to start, or Ctrl-C to abort... "
    read -r
fi

java -jar "$JAR" director \
    --load-profile         "$profile"         \
    --lua-file             "$LUA_SCRIPT"      \
    --load-generator-host  "$LOADGEN_HOST"    \
    --load-generator-port  "$LOADGEN_PORT"    \
    --output               "$result_file"     \
    --max-threads          "$MAX_THREADS"     \
    --warmupduration       "$WARMUP_SECS"

echo "Test complete. Results written to: $result_file"
