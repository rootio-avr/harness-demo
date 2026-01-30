#!/bin/bash
# Common configuration and helpers for delegate functionality tests.
# Source this from other scripts: source "$(dirname "$0")/common.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$TESTS_DIR/config.env"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found: $CONFIG_FILE" >&2
  echo "Copy config.env.example to config.env and set ACCOUNT_ID, DELEGATE_TOKEN, DELEGATE_IMAGE." >&2
  exit 1
fi

# Load configuration (allow overrides from environment)
set -a
source "$CONFIG_FILE"
set +a

# Defaults
: "${DELEGATE_IMAGE:=harness/delegate:25.07.86408}"
: "${DELEGATE_CONTAINER_NAME:=harness-delegate-func-test}"
: "${DELEGATE_NAME:=local-func-test-25-07-86408}"
: "${MANAGER_HOST_AND_PORT:=https://app.harness.io}"
: "${HEALTH_PORT:=3460}"
: "${STARTUP_WAIT_SECONDS:=60}"
# Health check retries: after startup wait, retry health this many times, every HEALTH_CHECK_INTERVAL seconds
: "${HEALTH_CHECK_RETRIES:=6}"
: "${HEALTH_CHECK_INTERVAL:=15}"

[ -z "$ACCOUNT_ID" ] && { echo "Error: ACCOUNT_ID not set in config.env"; exit 1; }
[ -z "$DELEGATE_TOKEN" ] && { echo "Error: DELEGATE_TOKEN not set in config.env"; exit 1; }

HEALTH_URL="http://localhost:${HEALTH_PORT}/api/health"

# Returns 0 if health endpoint returns healthy (200 + "data":"healthy" or "status":"SUCCESS"), 1 otherwise
check_health_healthy() {
  local response
  response=$(curl -s "$HEALTH_URL" 2>/dev/null || true)
  if echo "$response" | grep -qE '"data":"healthy"|"status":"SUCCESS"'; then
    return 0
  fi
  return 1
}
