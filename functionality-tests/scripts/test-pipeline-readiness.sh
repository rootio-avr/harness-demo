#!/bin/bash
# Verify delegate is ready for pipeline execution (container running, health OK).
# Does not run a pipeline; that is done in Harness UI. This script checks readiness.
# Usage: ./scripts/test-pipeline-readiness.sh

set -e
source "$(dirname "$0")/common.sh"

echo "=== Delegate Functionality Test: Pipeline Readiness ==="
echo "Delegate name (UI): $DELEGATE_NAME"
echo "Container: $DELEGATE_CONTAINER_NAME"
echo ""

PASS=0
FAIL=0

# 1. Container running
if docker ps --filter "name=$DELEGATE_CONTAINER_NAME" --format "{{.Names}}" | grep -q "^${DELEGATE_CONTAINER_NAME}$"; then
  echo "  [PASS] Delegate container is running"
  PASS=$((PASS + 1))
else
  echo "  [FAIL] Delegate container is not running"
  FAIL=$((FAIL + 1))
fi

# 2. Health endpoint (retry to allow delegate time to establish heartbeat)
HEALTH=""
for i in $(seq 1 "$HEALTH_CHECK_RETRIES"); do
  HEALTH=$(curl -s "$HEALTH_URL" 2>/dev/null || true)
  if echo "$HEALTH" | grep -qE '"data":"healthy"|"status":"SUCCESS"'; then
    echo "  [PASS] Health endpoint returned healthy (attempt $i)"
    PASS=$((PASS + 1))
    break
  fi
  if [ "$i" -lt "$HEALTH_CHECK_RETRIES" ]; then
    echo "  Health not ready (attempt $i/$HEALTH_CHECK_RETRIES), retrying in ${HEALTH_CHECK_INTERVAL}s..."
    sleep "$HEALTH_CHECK_INTERVAL"
  else
    echo "  [FAIL] Health endpoint not healthy after $HEALTH_CHECK_RETRIES attempts (response: ${HEALTH:0:80}...)"
    FAIL=$((FAIL + 1))
  fi
done

# 3. Docker health status (if available)
STATUS=$(docker ps --filter "name=$DELEGATE_CONTAINER_NAME" --format "{{.Status}}" 2>/dev/null || true)
if echo "$STATUS" | grep -q "healthy"; then
  echo "  [PASS] Docker reports container healthy"
  PASS=$((PASS + 1))
else
  echo "  [INFO] Docker status: $STATUS (healthy may appear after heartbeat)"
fi

echo ""
echo "--- Container status ---"
docker ps --filter "name=$DELEGATE_CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true

echo ""
echo "--- Next steps (manual in Harness UI) ---"
echo "1. Harness UI → Delegates: confirm '$DELEGATE_NAME' shows Connected."
echo "2. Create or open a pipeline with a Shell Script step."
echo "3. Set the step/stage to run on delegate: $DELEGATE_NAME"
echo "4. Run the pipeline and verify execution succeeds."
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "Result: $PASS passed, $FAIL failed"
  exit 1
fi
echo "Result: Readiness checks passed ($PASS). Delegate is ready for pipeline assignment."
