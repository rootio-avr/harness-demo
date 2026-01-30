# Functional Test Plan: Harness Delegate

This document explains what the Harness Delegate container does and how we functionally test it in this sub-project.

---

## 1. What is the Harness Delegate Container?

The **Harness Delegate** is a worker service that:

- **Connects** to Harness Manager (e.g. `https://app.harness.io`) over outbound HTTPS/WebSocket.
- **Executes tasks** for CI/CD pipelines (builds, deployments, Shell Script steps, etc.).
- **Reaches** your infrastructure (Kubernetes, cloud, Git, etc.) from your network.
- **Keeps secrets** in your network; only the delegate talks to Harness.

The container runs this worker so Harness tasks execute in your environment.

### Typical image contents

- Java 17 (Eclipse Temurin JRE)
- Delegate JAR (registers with Harness, runs tasks)
- Client tools: kubectl, Helm, terraform-config-inspect, go-template, oc, scm, etc.
- HTTP server on **port 3460** for `/api/health` and admin.

---

## 2. Prerequisites

- **Harness account** at [https://app.harness.io](https://app.harness.io).
- **Account ID** and **Delegate Token** from Harness UI (Account/Project → Delegates → Tokens).
- **Docker** installed locally.
- **Outbound HTTPS** to `app.harness.io` (no inbound ports required).

---

## 3. Configuration (This Sub-Project)

All tests use **config.env** (copy from **config.env.example**).

| Variable | Description |
|----------|-------------|
| `ACCOUNT_ID` | Harness account ID |
| `DELEGATE_TOKEN` | Delegate token (shared key) from Harness |
| `DELEGATE_IMAGE` | **Which container to use** (e.g. `harness/delegate:25.07.86408-local-binaries`) |
| `DELEGATE_CONTAINER_NAME` | Docker container name |
| `DELEGATE_NAME` | Delegate name in Harness UI (unique in account) |

Optional: `MANAGER_HOST_AND_PORT`, `HEALTH_PORT`, `STARTUP_WAIT_SECONDS`, `PRECHECK_CONN`.

---

## 4. Running the Tests

### One-time setup

```bash
cd functionality-tests
cp config.env.example config.env
# Edit config.env: set ACCOUNT_ID, DELEGATE_TOKEN, DELEGATE_IMAGE (and optionally DELEGATE_NAME, DELEGATE_CONTAINER_NAME)
```

### Run full suite (start delegate + health + readiness)

```bash
./run-tests.sh
```

### Run individual steps

```bash
# Start delegate only
./scripts/run-delegate.sh

# Check health (delegate must already be running)
./scripts/test-health.sh

# Check pipeline readiness
./scripts/test-pipeline-readiness.sh
```

---

## 5. What to Verify Manually

1. **Harness UI → Delegates:** Delegate with `DELEGATE_NAME` shows **Connected**.
2. **Pipeline execution:** Create a pipeline with a Shell Script step, set delegate to `DELEGATE_NAME`, run pipeline, confirm success and that the step ran on this delegate (e.g. via `docker logs <DELEGATE_CONTAINER_NAME>` and task type `SHELL_SCRIPT_TASK_NG`).

---

## 6. References

- [Delegate overview](https://developer.harness.io/docs/platform/delegates/delegate-concepts/delegate-overview)
- [Docker delegate environment variables](https://developer.harness.io/docs/platform/delegates/delegate-reference/docker-delegate-environment-variables)
- **TEST_COVERAGE.md** in this folder — detailed description of tests and coverage.
