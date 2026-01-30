# Test Results Reference

This document summarizes past functionality test results for reference. Current tests are run via `run-tests.sh` and the scripts in `scripts/`.

---

## Images Tested

| Image | Result | Notes |
|-------|--------|--------|
| harness/delegate:25.07.86408 | PASS | Official image; health 200, delegate Connected, pipeline executed. |
| harness/delegate:25.07.86408-original-final | PASS | Original JAR + local client tools; health 200, delegate Connected. |
| harness/delegate:25.07.86408-local-binaries | PASS | Local binaries (go-template, terraform-config-inspect, kubectl, helm, etc.); health 200, delegate Connected. |
| harness/delegate:25.07.86408-netty-only (patched) | FAIL | NoSuchMethodError (protobuf); container exits. |
| harness/delegate:25.07.86408-patched (all patches) | FAIL | Same protobuf error. |

---

## Checks Performed (Summary)

- **Container start:** Container runs with ACCOUNT_ID, DELEGATE_TOKEN, DELEGATE_NAME.
- **Health:** `GET /api/health` returns 200 and healthy payload after heartbeat (typically 60–120s).
- **Harness UI:** Delegate shows **Connected** with correct name.
- **Pipeline execution (manual):** Shell Script step run on delegate; task type SHELL_SCRIPT_TASK_NG in logs; pipeline status SUCCESS.

---

## Reference Documents (Parent Project)

Detailed results from earlier runs are in the parent project:

- **FUNCTIONAL_TEST_RESULTS.md** — First functional test run (official image).
- **PIPELINE_EXECUTION_RESULTS.md** — Pipeline execution with Shell Script step on delegate.
- **ORIGINAL_JAR_FUNCTIONAL_TEST_RESULTS.md** — Test with original JAR image.
- **LOCAL_BINARIES_TEST_RESULTS.md** — Test with local binaries image.
- **DELEGATE_AND_PIPELINE_VERIFICATION.md** — Verification of delegate + pipeline with shared key.

Use **config.env** in this sub-project to choose which image to test and run `run-tests.sh` for the current test suite.
