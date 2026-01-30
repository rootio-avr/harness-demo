# Delegate Functionality Test Coverage

This document describes the functionality tests we perform for the Harness Delegate container and the coverage we already have.

---

## 1. Test Categories

| Category | Description | Automated | Notes |
|----------|-------------|-----------|--------|
| **Startup** | Container starts and process runs | Yes | `run-delegate.sh` |
| **Health** | HTTP health endpoint responds | Yes | `test-health.sh` |
| **Registration** | Delegate registers with Harness Manager | Indirect | Via health + UI |
| **Pipeline readiness** | Delegate is ready to receive pipeline tasks | Yes | `test-pipeline-readiness.sh` |
| **Pipeline execution** | Pipeline step runs on delegate | Manual | Harness UI |

---

## 2. Tests We Perform (Detailed)

### 2.1 Startup test

**What we test**

- Delegate image is pulled/available.
- Container starts with required environment variables (`ACCOUNT_ID`, `DELEGATE_TOKEN`, `MANAGER_HOST_AND_PORT`, `DELEGATE_NAME`).
- Container stays running (no immediate exit).
- Delegate process starts inside the container (no Java/startup crash).

**How we test**

- `scripts/run-delegate.sh`: runs `docker run` with config from `config.env`, waits `STARTUP_WAIT_SECONDS`, then shows health and last 25 log lines.

**Coverage**

- ✅ Image selection (configurable via `DELEGATE_IMAGE`).
- ✅ Required env vars from config.
- ✅ Port mapping (default 3460).
- ✅ Basic startup; failure visible via logs or non-running container.

**Not covered**

- Different CPU/memory limits.
- Host network mode.
- FIPS mode.

---

### 2.2 Health endpoint test

**What we test**

- HTTP `GET /api/health` on the delegate port (default 3460).
- Response indicates healthy state (e.g. `200` and body with `"data":"healthy"` or `"status":"SUCCESS"`).

**How we test**

- `scripts/run-delegate.sh`: after startup wait, **retries** the health check up to `HEALTH_CHECK_RETRIES` times (default 6), every `HEALTH_CHECK_INTERVAL` seconds (default 15), to allow the delegate time to establish a heartbeat.
- `scripts/test-health.sh`: dedicated script that checks container is running, then calls health URL and shows response and recent logs.
- `scripts/test-pipeline-readiness.sh`: retries the health endpoint the same way before failing the health check.

**Coverage**

- ✅ Health URL correctness (host, port from config).
- ✅ Success response (200 + healthy payload).
- ✅ Container still running and recent logs available.

**Not covered**

- Health over time (e.g. polling for 5 minutes).
- Health during load.
- TLS to health endpoint (we use HTTP to localhost).

---

### 2.3 Registration with Harness Manager

**What we test**

- Delegate connects to Harness Manager (`MANAGER_HOST_AND_PORT`).
- Delegate registers and sends heartbeats.
- Harness UI shows delegate as **Connected** with the configured `DELEGATE_NAME`.

**How we test**

- **Indirect:** Health endpoint returns 200 only after heartbeat is established, so a passing health check implies registration succeeded.
- **Manual:** Harness UI → Delegates → confirm delegate name and status **Connected**.

**Coverage**

- ✅ Correct Manager URL and credentials (token) from config.
- ✅ Delegate name uniqueness (configurable `DELEGATE_NAME`).
- ✅ Connectivity from container to Harness (implied by health).

**Not covered**

- Automated UI checks.
- Multiple delegates with same token.
- Token revocation during test.

---

### 2.4 Pipeline readiness test

**What we test**

- Delegate container is running.
- Health endpoint returns healthy.
- Docker reports container as healthy when applicable.
- Instructions for manual pipeline run are clear.

**How we test**

- `scripts/test-pipeline-readiness.sh`: checks container running, health URL response, Docker status; prints next steps for running a pipeline in Harness UI.

**Coverage**

- ✅ All preconditions for assigning a pipeline to this delegate.
- ✅ Clear “next steps” for manual pipeline test.

**Not covered**

- Actually triggering a pipeline (done manually in UI).
- Verifying which delegate ran the task (manual in UI/logs).

---

### 2.5 Pipeline execution test (manual)

**What we test**

- A Harness pipeline (e.g. Shell Script step) is run with this delegate selected.
- The task is received by the delegate (`SHELL_SCRIPT_TASK_NG` or similar in logs).
- The step completes successfully in the pipeline execution.

**How we test**

- **Manual:** In Harness UI, create or open a pipeline with a Shell Script step, set delegate to `DELEGATE_NAME` (from config), run pipeline, verify success and optionally `docker logs` for task events.

**Coverage**

- ✅ End-to-end: Harness → delegate → task execution.
- ✅ Shell Script step type (and any other step type you run manually).

**Not covered**

- Other step types (Kubernetes, Helm, Terraform, etc.) unless you run them manually.
- Automated assertion of pipeline result from this repo.

---

## 3. Coverage Summary

| Area | Automated | Manual | Notes |
|------|-----------|--------|--------|
| Container start | ✅ | — | `run-delegate.sh` |
| Health endpoint | ✅ | — | `test-health.sh`, also in `run-delegate.sh` |
| Configurable image/name/port | ✅ | — | `config.env` |
| Registration / connectivity | Indirect (health) | ✅ UI | Health implies heartbeat |
| Pipeline readiness | ✅ | — | `test-pipeline-readiness.sh` |
| Pipeline execution | — | ✅ | Run pipeline in UI, assign to this delegate |

---

## 4. Scripts and Config

| Item | Purpose |
|------|--------|
| `config.env` | Copy from `config.env.example`; set `ACCOUNT_ID`, `DELEGATE_TOKEN`, `DELEGATE_IMAGE`, `DELEGATE_CONTAINER_NAME`, `DELEGATE_NAME`. |
| `scripts/common.sh` | Loads config and sets defaults; used by all scripts. |
| `scripts/run-delegate.sh` | Start delegate container; optional health check after wait. |
| `scripts/test-health.sh` | Check container running and health endpoint. |
| `scripts/test-pipeline-readiness.sh` | Check readiness and print pipeline test steps. |
| `run-tests.sh` | Run delegate start + health + pipeline readiness. |

---

## 5. Containers We Test

You can point `DELEGATE_IMAGE` in `config.env` to any delegate image, for example:

- `harness/delegate:25.07.86408` — official image.
- `harness/delegate:25.07.86408-local-binaries` — local build with copied client tools (kubectl, helm, go-template, terraform-config-inspect, etc.).
- `harness/delegate:25.07.86408-original-final` — local build with original delegate JAR and local client tools.

The same functionality tests apply; only the image and optionally `DELEGATE_NAME`/container name change via config.

---

## 6. Gaps and Possible Extensions

- **Automated pipeline run:** Would require Harness API or CLI to trigger a pipeline and poll for result; not implemented.
- **Client tools:** No automated test that runs `kubectl`, `helm`, `go-template`, `terraform-config-inspect` inside the container; can be added as small script steps.
- **Long-running health:** No automated stability test (e.g. health check every 30s for 10 minutes).
- **Multiple images:** No single script that loops over several images; you change `config.env` and re-run.

These can be added later if needed.
