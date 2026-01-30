# How to Run a Pipeline Through the Harness UI (Delegate Test)

Use this guide to run a pipeline in the Harness UI so that it executes on your delegate (e.g. `local-func-test-25-07-86408`). You can repeat these steps anytime to verify the delegate.

---

## Prerequisites

1. **Delegate is running**  
   Start it from this project:
   ```bash
   cd functionality-tests
   ./scripts/run-delegate.sh
   ```
   Or run the full test suite first: `./run-tests.sh`

2. **Delegate name**  
   Use the value of `DELEGATE_NAME` from `config.env`. Default: **`local-func-test-25-07-86408`**.

3. **Harness account**  
   You need access to [https://app.harness.io](https://app.harness.io) (or your Harness Manager URL) with the same account ID and delegate token used in `config.env`.

---

## Step-by-step: Run a pipeline in the UI

### 1. Open Harness and go to Delegates

1. Go to **https://app.harness.io** (or your `MANAGER_HOST_AND_PORT`).
2. Log in.
3. In the left sidebar: **Project Setup** → **Delegates** (or **Account Settings** → **Delegates** depending on your UI).
4. Confirm your delegate (e.g. **`local-func-test-25-07-86408`**) appears and shows **Connected**.  
   If it shows **Disconnected**, wait for it to connect or check `docker logs harness-delegate-func-test`.

---

### 2. Create or open a pipeline

1. In the left sidebar: **Pipelines** (or **Builds** / **Deployments** depending on module).
2. Either:
   - **Create:** **Create Pipeline** → give it a name (e.g. “Delegate test”) → save.
   - **Or** open an existing pipeline and edit it.

---

### 3. Add a stage and a Shell Script step

1. In the pipeline editor, add or open a **Stage** (e.g. “Build” or “Deploy”).
2. Inside the stage, add a **Step**:
   - **Add Step** → search for **Shell Script** (or “Run” / “Execute”).
   - Add a **Shell Script** step.
3. In the step configuration:
   - **Name:** e.g. “Test on delegate”.
   - **Script:** e.g.:
     ```bash
     echo "Running on delegate: $(hostname)"
     echo "Delegate test OK"
     ```
   - Save the step.

---

### 4. Assign the step (or stage) to your delegate

1. Select the **Shell Script step** (or the **Stage** that contains it).
2. In the right panel, find **Execution** / **Advanced** or **Delegate**.
3. Under **Delegate** (or “Run on delegate”):
   - Choose **Specific delegate(s)** or **Delegate selector**.
   - Select your delegate by name: **`local-func-test-25-07-86408`** (or whatever is in your `config.env` as `DELEGATE_NAME`).
4. Save the pipeline.

---

### 5. Run the pipeline

1. Click **Run** (or **Execute**) on the pipeline.
2. If prompted, choose branch/inputs and start the run.
3. Open the **Execution** and watch the Shell Script step. It should change to **Running** and then **Success** (green).

---

### 6. Confirm it ran on your delegate (optional)

1. In the step logs in the UI, you should see the script output (e.g. “Running on delegate: …” and “Delegate test OK”).
2. To confirm from the delegate container:
   ```bash
   docker logs harness-delegate-func-test 2>&1 | grep -i SHELL_SCRIPT_TASK_NG
   ```
   You should see task activity for the pipeline run.

---

## Summary checklist

| Step | Action |
|------|--------|
| 1 | Harness UI → Delegates → confirm delegate **Connected** |
| 2 | Pipelines → create or open a pipeline |
| 3 | Add stage → add **Shell Script** step with a simple script |
| 4 | Set step/stage **Delegate** to `DELEGATE_NAME` (e.g. `local-func-test-25-07-86408`) |
| 5 | **Run** pipeline → check step shows **Success** |
| 6 | (Optional) Check `docker logs harness-delegate-func-test` for `SHELL_SCRIPT_TASK_NG` |


---

## References

- [Harness Pipelines](https://developer.harness.io/docs/category/pipelines)
- [Shell Script step](https://developer.harness.io/docs/continuous-integration/use-ci/run-ci-scripts/run-a-script-step)
- **FUNCTIONAL_TEST_PLAN.md** and **TEST_COVERAGE.md** in this folder for delegate test context.
