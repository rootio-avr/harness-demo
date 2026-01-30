#!/bin/bash
# Run delegate functionality test suite.
# 1. Starts delegate container (from config.env)
# 2. Waits and runs health check
# 3. Runs pipeline readiness check
#
# Prerequisite: Copy config.env.example to config.env and set ACCOUNT_ID, DELEGATE_TOKEN, DELEGATE_IMAGE.
# Usage: ./run-tests.sh

set -e
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$TESTS_DIR"

echo "=== Delegate Functionality Test Suite ==="
echo ""

"$TESTS_DIR/scripts/run-delegate.sh"

echo ""
echo "=== Running health check ==="
"$TESTS_DIR/scripts/test-health.sh"

echo ""
echo "=== Running pipeline readiness check ==="
"$TESTS_DIR/scripts/test-pipeline-readiness.sh"

echo ""
echo "=== Test suite complete ==="
