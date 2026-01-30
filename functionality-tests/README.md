# Delegate Functionality Tests

Sub-project for functionally testing the Harness Delegate container. You can configure **which container image** to use and run automated startup, health, and pipeline-readiness checks.

---

## Quick start

1. **Configure**
   ```bash
   cp config.env.example config.env
   ```
   Edit `config.env` and set:
   - `ACCOUNT_ID` — Harness account ID
   - `DELEGATE_TOKEN` — Delegate token (from Harness UI → Delegates → Tokens)
   - `DELEGATE_IMAGE` — **Which container to use** (e.g. `harness/delegate:25.07.86408-local-binaries`)

2. **Run tests**
   ```bash
   ./run-tests.sh
   ```
   This starts the delegate, waits, runs a health check, and runs a pipeline-readiness check.

3. **Manual checks**
   - In Harness UI → Delegates, confirm the delegate (name from `DELEGATE_NAME` in config) shows **Connected**.
   - Run a simple pipeline with a Shell Script step assigned to this delegate to verify task execution.

---

## Configuring which container to use

Set **DELEGATE_IMAGE** in `config.env` to the image you want to test, for example:

| Image | Description |
|-------|-------------|
| `harness/delegate:25.07.86408` | Official Harness image |
| `harness/delegate:25.07.86408-local-binaries` | Local build with copied client tools (kubectl, helm, go-template, terraform-config-inspect, etc.) |
| `harness/delegate:25.07.86408-original-final` | Local build with original delegate JAR and local client tools |

You can also set:
- **DELEGATE_CONTAINER_NAME** — Docker container name (default: `harness-delegate-func-test`)
- **DELEGATE_NAME** — Name shown in Harness UI (default: `local-func-test-25-07-86408`)
- **HEALTH_PORT** — Port on host for health checks (default: `3460`)
- **STARTUP_WAIT_SECONDS** — Seconds to wait before first health check (default: `60`)
- **HEALTH_CHECK_RETRIES** — After startup wait, retry health this many times (default: `6`)
- **HEALTH_CHECK_INTERVAL** — Seconds between health retries (default: `15`). Total extra wait before failing health = RETRIES × INTERVAL (e.g. 90s)

---

## Layout

```
functionality-tests/
├── README.md                 # This file
├── config.env.example        # Example config (copy to config.env)
├── config.env                # Your config (gitignored)
├── run-tests.sh              # Run full test suite
├── scripts/
│   ├── common.sh             # Loads config; used by all scripts
│   ├── run-delegate.sh       # Start delegate container
│   ├── test-health.sh        # Health endpoint check
│   └── test-pipeline-readiness.sh  # Pipeline readiness check
└── docs/
    ├── FUNCTIONAL_TEST_PLAN.md   # Test plan and how to run
    └── TEST_COVERAGE.md          # Detailed test coverage
```

---

## Scripts

| Script | Purpose |
|--------|--------|
| **run-tests.sh** | Start delegate, then run health and pipeline-readiness checks. |
| **scripts/run-delegate.sh** | Start delegate container from config; show health and logs. |
| **scripts/test-health.sh** | Verify container is running and `/api/health` returns healthy. |
| **scripts/test-pipeline-readiness.sh** | Verify delegate is ready for pipeline assignment; print manual pipeline test steps. |

All scripts read **config.env** (and use defaults from **scripts/common.sh**).

---

## Documentation

- **docs/FUNCTIONAL_TEST_PLAN.md** — What we test, prerequisites, and how to run (including manual steps).
- **docs/TEST_COVERAGE.md** — Detailed description of each test, what is covered, and what is not.

---

## Security

- **Do not commit config.env.** It contains `ACCOUNT_ID` and `DELEGATE_TOKEN`. `config.env` is in `.gitignore`.
- Use **config.env.example** only as a template; leave credentials blank in the example.
