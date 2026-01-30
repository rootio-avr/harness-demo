#!/bin/bash
# Test delegate health endpoint and container status.
# Usage: ./scripts/test-health.sh

set -e
source "$(dirname "$0")/common.sh"

echo "=== Delegate Functionality Test: Health Check ==="
echo "Container: $DELEGATE_CONTAINER_NAME"
echo "Health URL: $HEALTH_URL"
echo ""

# Check container exists and is running
if ! docker ps --filter "name=$DELEGATE_CONTAINER_NAME" --format "{{.Names}}" | grep -q "^${DELEGATE_CONTAINER_NAME}$"; then
  echo "Error: Container '$DELEGATE_CONTAINER_NAME' is not running."
  echo "Start it with: $TESTS_DIR/scripts/run-delegate.sh"
  exit 1
fi

echo "--- Container status ---"
docker ps --filter "name=$DELEGATE_CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "--- Health endpoint ---"
RESPONSE=$(curl -s "$HEALTH_URL" || true)
if echo "$RESPONSE" | grep -q '"data":"healthy"'; then
  echo "OK: Delegate is healthy"
  echo "$RESPONSE" | head -1
elif echo "$RESPONSE" | grep -q '"status":"SUCCESS"'; then
  echo "OK: Delegate responded (SUCCESS)"
  echo "$RESPONSE" | head -1
else
  echo "Response: $RESPONSE"
  echo "Delegate may still be starting (heartbeat not yet established)."
fi

echo ""
echo "--- Recent logs (last 15 lines) ---"
docker logs "$DELEGATE_CONTAINER_NAME" --tail 15
