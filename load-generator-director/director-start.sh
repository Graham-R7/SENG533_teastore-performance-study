# =============================================================================
# Runs the LIMBO HTTP Load Generator in director mode for TeaStore performance
# testing. Start the load generator manually on the remote machine first.

# USAGE:
#   ./director-start.sh [low|med|high]
#   Workload intensity defaults to "low" if not specified.
# =============================================================================

set -euo pipefail

LOADGEN_HOST="<IP_ADDRESS>"  # Update this to the actual IP address of the load generator
LOADGEN_PORT=4444                  

WARMUP_SECS=30                     
MAX_THREADS=256                    

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR="$SCRIPT_DIR/httploadgenerator.jar"
LUA_SCRIPT="$SCRIPT_DIR/request-scripts/teastore_browse.lua"
RESULTS_DIR="$SCRIPT_DIR/results"

declare -A PROFILES=(
    [low]="$SCRIPT_DIR/workloads/increasingLowIntensity.csv"
    [med]="$SCRIPT_DIR/workloads/increasingMedIntensity.csv"
    [high]="$SCRIPT_DIR/workloads/increasingHighIntensity.csv"
)

intensity="${1:-low}"
profile="${PROFILES[$intensity]:-}"

mkdir -p "$RESULTS_DIR"

timestamp="$(date +%Y%m%d_%H%M%S)"
result_file="$RESULTS_DIR/result_${intensity}_${timestamp}.csv"

echo "  Intensity    : $intensity"
echo "  Load profile : $profile"
echo "  LUA script   : $LUA_SCRIPT"
echo "  Load gen     : $LOADGEN_HOST:$LOADGEN_PORT"
echo "  Result file  : $result_file"
echo "Ensure the load generator is already running on $LOADGEN_HOST:$LOADGEN_PORT"
echo -n "Press [Enter] to start, or Ctrl-C to abort... "
read -r

java -jar "$JAR" director \
    --load-profile         "$profile"         \
    --lua-file             "$LUA_SCRIPT"      \
    --load-generator-host  "$LOADGEN_HOST"    \
    --load-generator-port  "$LOADGEN_PORT"    \
    --output               "$result_file"     \
    --max-threads          "$MAX_THREADS"     \
    --warmupduration       "$WARMUP_SECS"

echo "Test complete. Results written to: $result_file"