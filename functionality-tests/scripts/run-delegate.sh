#!/bin/bash
# Start the delegate container for functionality testing.
# Uses config from functionality-tests/config.env.
# Usage: ./scripts/run-delegate.sh

set -e
source "$(dirname "$0")/common.sh"

echo "=== Delegate Functionality Test: Start Delegate ==="
echo "Image: $DELEGATE_IMAGE"
echo "Container: $DELEGATE_CONTAINER_NAME"
echo "Delegate name (UI): $DELEGATE_NAME"
echo ""

# Remove existing container if present
docker rm -f "$DELEGATE_CONTAINER_NAME" 2>/dev/null || true

echo "Starting delegate container..."
docker run -d \
  --name "$DELEGATE_CONTAINER_NAME" \
  --cpus=1 \
  --memory=2g \
  -e ACCOUNT_ID="$ACCOUNT_ID" \
  -e DELEGATE_TOKEN="$DELEGATE_TOKEN" \
  -e MANAGER_HOST_AND_PORT="${MANAGER_HOST_AND_PORT}" \
  -e DELEGATE_NAME="$DELEGATE_NAME" \
  -e NEXT_GEN="true" \
  -e DELEGATE_TYPE="DOCKER" \
  ${PRECHECK_CONN:+ -e PRECHECK_CONN="$PRECHECK_CONN"} \
  -p "${HEALTH_PORT}:3460" \
  "$DELEGATE_IMAGE"

echo "Waiting ${STARTUP_WAIT_SECONDS}s for delegate to start..."
sleep "$STARTUP_WAIT_SECONDS"

echo ""
echo "--- Health check ($HEALTH_URL) ---"
HEALTH_OK=false
for i in $(seq 1 "$HEALTH_CHECK_RETRIES"); do
  if check_health_healthy; then
    echo "OK: Health endpoint returned healthy (attempt $i)"
    HEALTH_OK=true
    break
  fi
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" || true)
  echo "Attempt $i/$HEALTH_CHECK_RETRIES: HTTP $HTTP_CODE (retrying in ${HEALTH_CHECK_INTERVAL}s...)"
  [ "$i" -lt "$HEALTH_CHECK_RETRIES" ] && sleep "$HEALTH_CHECK_INTERVAL"
done
if [ "$HEALTH_OK" != "true" ]; then
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" || true)
  echo "Unexpected: HTTP $HTTP_CODE after $HEALTH_CHECK_RETRIES attempts (delegate may still be starting; run test-health.sh again later)"
fi

echo ""
echo "--- Last 25 lines of container log ---"
docker logs "$DELEGATE_CONTAINER_NAME" --tail 25

echo ""
echo "Next: In Harness UI → Delegates, confirm '$DELEGATE_NAME' shows Connected."
echo "Run health test again: $TESTS_DIR/scripts/test-health.sh"
echo "Stop: docker stop $DELEGATE_CONTAINER_NAME"
