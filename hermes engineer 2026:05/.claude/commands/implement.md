---
description: Auto-execute pending tasks from manifest in dependency order. Dispatches the right agent per task in isolated git worktrees, retries once on failure, runs code-reviewer after each, commits per task. Resumable.
argument-hint: [--task <id> for single-task mode] [--no-worktree to disable isolation]
---

You are the implementation orchestrator. Dispatch agents per `state/manifest.json` in dependency order, with worktree isolation and a 1-retry budget. Talk to Leo in **Traditional Chinese**; all code/commits in English.

## Args

$ARGUMENTS

If `--task <id>` is present, run only that single task.
If `--no-worktree` is present, skip worktree isolation (debug mode — slower-fail but easier to inspect).

## Entry checklist (Definition of Done — In)

Before doing anything else, verify:

- [ ] `specs/CONSTITUTION.md` exists
- [ ] `state/manifest.json` exists and parses
- [ ] `CLAUDE.md` (project root) exists (i.e., `/init-project` has been run)
- [ ] `specs/REVIEW.md` exists with no BLOCKING items (i.e., `/review-specs` passed)
- [ ] Git repo initialized; if not, `git init && git branch -M main` and commit specs first

If any unchecked, tell Leo which step to run and STOP.

## Setup

```bash
TS=$(date -u +%Y%m%dT%H%M%SZ)
mkdir -p state/runlog
echo "# /implement run at $TS" > state/runlog/$TS.md
```

Hold $TS in context for later appends.

## Loop (per dependency-ordering skill)

### Step A — pick batch

Read `state/manifest.json`. Find tasks where `status == "pending"` AND every id in `depends_on` has `status == "done"`.

Cap at **4 tasks per batch**. Exception: if every task in the selected batch belongs to `qa-engineer`, cap at **6** instead (QA tasks are file-isolated and rarely conflict).

If batch is empty:
- Any task `running` → previous run crashed. Tell Leo. Stop.
- Any task `blocked` → tell Leo to fix and `/resume`. Stop.
- Everything `done` → success summary. Stop.

### Step B — brief Leo in Chinese

```
本批次 <N> 個 tasks (worktree 並行):
- <id> [<agent>] <title>
- ...
開始?
```
Wait for confirmation.

### Step C-prep — build batch-shared static prefix (B1 + A2)

Before dispatching, build a **batch-shared static prefix** to inline into every agent prompt in this batch.

Why:
- **A2**: byte-identical prefix across the 4 parallel Agent calls → Anthropic API's automatic prompt caching kicks in (saves ~25–30% on repeated prefixes within a batch / within 5-minute TTL across batches).
- **B1**: agents skip Read tool round trips for foundational specs (content is already inline in their prompt).

Steps:
1. **Read once** (orchestrator main thread):
   - `specs/CONSTITUTION.md`
   - `specs/00-stack.md`
   - `specs/01-overview.md`
   - `specs/02-architecture.md`
2. **Construct STATIC_PREFIX** as a single string concatenating the four files' full contents with the headers shown in the prompt template below.
3. **Use byte-identical STATIC_PREFIX** in every agent prompt in this batch — do NOT customize per agent or interpolate per-task data into the prefix; that breaks the cache.
4. Domain specs (10-database, 20-api, 30-backend, 40-frontend, 50-tests, 60-devops) are NOT in the shared prefix — each agent reads only its own domain spec.

If any of the four foundational files is missing, fall back to the legacy template (just reference paths) and warn Leo — don't block the batch.

### Step C — dispatch in worktrees (parallel)

For each task in the batch, atomically update `status` to `running` and `started_at` to now in manifest.

Dispatch all batch tasks in a SINGLE message with multiple Agent tool calls. Each Agent call uses `isolation: "worktree"` UNLESS `--no-worktree` was passed. Model selection:
- `model: "sonnet"` for `product-manager` and `system-architect` tasks (text/notes only, no code generated)
- `model: "opus"` for all code-writing agents: db-engineer, api-designer, backend-engineer, frontend-engineer, qa-engineer, devops-engineer, worker

Prompt template per agent (STATIC_PREFIX block must be byte-identical across all batch agents — see Step C-prep):

```
=== STATIC PREFIX (foundational context — already loaded inline; do NOT Read these files again) ===

# specs/CONSTITUTION.md
<full content of CONSTITUTION.md>

# specs/00-stack.md
<full content of 00-stack.md>

# specs/01-overview.md
<full content of 01-overview.md>

# specs/02-architecture.md
<full content of 02-architecture.md>

=== END STATIC PREFIX ===

=== TASK-SPECIFIC ===

You are implementing task <id> from <spec>.

Task title: <title>
Acceptance criteria: <from spec>
Files: <expected paths from spec>
Depends on (already done): <list>
Retry attempt: <1 of 1 | 2 of 2>

Read your agent definition for inputs/outputs/constraints.
Read your DOMAIN spec section for this task (the spec file referenced above — e.g. specs/30-backend.md if you are backend-engineer). Implement it.

When done, append a one-line entry to state/runlog/<TS>.md:
[<agent-name>] <id>: <comma-separated artifact paths>

Hard rules:
- Modify ONLY files in your declared Outputs
- Comply with CONSTITUTION (inline in STATIC PREFIX — do NOT Read it again)
- Do NOT re-Read 00-stack / 01-overview / 02-architecture (inline in STATIC PREFIX)
- Do not add scope
- Do not modify other tasks' files
```

Wait for all batch agents to return.

### Step C2 — deterministic tool feedback loop

For each agent that returned, run static analysis tools inside its worktree **before** the LLM reviewer. Max **3 iterations** per task. This loop catches type errors and style issues deterministically — the LLM reviewer should not need to flag these.

**Backend tasks** (any task touching `app/` files):

```bash
cd <worktree_path>

# Iteration 1 — ruff
ruff check <artifact_paths> --output-format=text 2>&1
# If errors → send exact output back to the same agent via SendMessage:
#   "ruff check 回報以下錯誤，請修正後回覆 DONE:\n<errors>"
# Wait for agent to fix, then continue.

# Iteration 2 — ruff confirm + mypy
ruff check <artifact_paths> 2>&1          # must be clean first
mypy <artifact_paths> --strict --follow-imports=silent 2>&1
# If errors → send exact output to agent, wait for fix.

# Iteration 3 — final confirm
ruff check <artifact_paths> && mypy <artifact_paths> --strict --follow-imports=silent
# If still failing → treat as FAIL; go to retry budget (Step E).
# If green → proceed to Step D.
```

`--follow-imports=silent` prevents false positives from parallel tasks whose changes haven't merged yet.

**Frontend tasks** (any task touching `web/` files):

```bash
cd <worktree_path>/web

# Iteration 1 — biome
pnpm exec biome check <artifact_paths> 2>&1
# If errors → send to agent, wait for fix.

# Iteration 2 — tsc
pnpm exec tsc --noEmit 2>&1
# If errors → send to agent, wait for fix.

# Iteration 3 — final confirm
pnpm exec biome check <artifact_paths> && pnpm exec tsc --noEmit
# If still failing → FAIL; go to retry budget.
# If green → proceed to Step D.
```

**Mixed tasks** (touching both `app/` and `web/`): run backend checks then frontend checks.

**Tasks with no `app/` or `web/` artifacts** (e.g. pure spec/config tasks): skip Step C2.

### Step D — per-task code review

Static analysis has already passed by the time this runs. Focus the reviewer on **architecture and business logic**, not types or style.

**Skip code review entirely** for tasks whose agent is `product-manager` or `system-architect` AND whose artifacts contain no `.py` or `.ts` files (these tasks produce only `.md` notes — architecture review is meaningless). Go directly to Step E for those tasks.

For each agent that passed Step C2 (and is not skipped above), dispatch `code-reviewer` with `model: "sonnet"` (NOT in a worktree — needs to see the agent's worktree changes; pass the worktree path):

```
Review task <id>'s diff in worktree <path>.
Files modified: <artifacts>.
Spec: <spec file>, acceptance: <criteria>.

Note: ruff + mypy (or biome + tsc for frontend) have already passed on these files.
Do NOT flag type annotation issues or style problems — those are already clean.
Focus your review on:
- CONSTITUTION compliance (multi-tenancy, auth boundaries, error handling, AI provider isolation)
- Spec compliance and scope discipline (no extra features)
- Business logic correctness (auth flows, tenant filtering, idempotency)
- Security issues (injection, secrets leakage, missing authz)

Verdict: PASS / PASS_WITH_NOTES / FAIL with notes.
```

### Step E — merge worktree, commit, update manifest

For each task:

**If reviewer says PASS or PASS_WITH_NOTES:**
1. Merge the worktree's changes back to main:
   ```bash
   # Agent worktree path is returned by the Agent tool
   # Merge by copying / committing from the worktree
   git -C <main> merge <worktree-branch> --no-ff -m "[<agent>] <task title>" || handle conflict
   ```
   For non-worktree mode: just `git add <artifacts>`.
2. Commit with HEREDOC:
   ```bash
   git commit -m "$(cat <<'EOF'
[<agent>] <task title>

Task: <id>
Spec: <spec file>
Reviewer: <PASS or PASS_WITH_NOTES — note summary>
EOF
)"
   ```
3. Capture SHA: `SHA=$(git rev-parse HEAD)`
4. Atomically update manifest: `status="done"`, `finished_at=now`, `commit_sha=SHA`, `artifacts=[...]`, `review_notes=<reviewer notes>`.
5. Clean up worktree: `git worktree remove <path>` (skip if `--no-worktree`).

**If reviewer says FAIL OR agent itself errored:**

This is the **retry budget** check:
- If this was retry attempt 1 (first try): re-dispatch the same task with retry attempt = 2. Reset its `error` field. Stay in `running`.
- If this was retry attempt 2 (second try): mark `status="blocked"`, write reviewer notes / agent error to `error` field. Leave the worktree intact for Leo to inspect; record path in `error` notes. Atomic write.

  Then append a structured entry to `state/pending-learnings.md` (create the file with the standard header if it does not exist yet). Only capture architecture-level lessons — do NOT record specific debug steps, bug fixes, or environment issues:

  ```
  ## Learning: <task-id> — <task-title>
  Date: <YYYY-MM-DD>
  Task: <id>  |  Agent: <agent>  |  Kind: <kind>

  ### Root cause
  <error field verbatim, trimmed to 400 chars>

  ### Reviewer notes
  <review_notes field verbatim, or "none">

  ### Suggested AGENTS.md entry
  _pending Leo review_

  ---
  ```

### Step F — append batch summary to runlog

```
## Batch <N>
- <id> → done (commit <short-sha>) [retries: 0|1]
- <id> → blocked: <reason> [worktree: <path>]
```

If any task in this batch ended as `blocked`, also append to the runlog entry:
`📚 Learnings staged → state/pending-learnings.md`

### Step G — layer transition check, then loop or exit

After updating the manifest, check whether this batch just completed an entire layer. A layer is "just completed" when **before this batch** at least one task in that layer was pending/running, and **after this batch** every task in that layer is done.

If a layer just completed, print the corresponding milestone checklist below and **wait for Leo to reply before continuing**. Leo should reply "繼續" to proceed or "停止" with details to pause.

---

**M1 checklist — fires when all `be-*` tasks are done:**

```
🔖 里程碑 M1：後端 API 可跑通完整問答

現在可以驗收的功能：
- 文件上傳 (PDF/DOCX/XLSX) → 解析 → 分塊 → embedding → 寫入 DB
- 混合搜尋 (BM25 + pgvector) → Cohere rerank → GPT-4o 合成答案 + citation
- tenant 隔離 (tenant A 看不到 tenant B 的文件)
- vague 問題偵測 → 回傳 clarify options

驗收步驟：
  make dev   # backend + arq worker 都起來，無 crash log

  # 1. 註冊 + 登入
  curl -s -X POST http://localhost:8000/api/v1/auth/register \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"Test1234!","company_name":"Acme"}' | jq .

  # 2. 上傳一份 PDF（換成你有的真實 PDF）
  curl -s -X POST http://localhost:8000/api/v1/documents/upload \
    -H "Authorization: Bearer <token>" \
    -F "file=@sample.pdf" | jq .

  # 3. Polling job 直到 status = completed
  curl -s http://localhost:8000/api/v1/jobs/<job_id> \
    -H "Authorization: Bearer <token>" | jq .status

  # 4. 建 chat session + 問問題，確認 SSE 串流有 citation
  curl -s -X POST http://localhost:8000/api/v1/chat/sessions \
    -H "Authorization: Bearer <token>" \
    -H "Content-Type: application/json" \
    -d '{"title":"test"}' | jq .

  curl -N -X POST http://localhost:8000/api/v1/chat/sessions/<session_id>/messages \
    -H "Authorization: Bearer <token>" \
    -H "Content-Type: application/json" \
    -d '{"content":"這份文件的主要結論是什麼？"}'

  # 5. 用第二個 tenant 問 → 應該拿不到第一個 tenant 的文件
  # （重複步驟 1 建第二帳號，跑步驟 4，預期回覆表示查無相關文件）

期望結果：
  ✅ job status 變 completed，無 error
  ✅ SSE 串流中包含 citations 欄位（來源文件 + 頁碼）
  ✅ 第二個 tenant 拿不到第一個 tenant 的資料
  ✅ 輸入模糊問題（如「告訴我更多」）→ 回傳 clarify_options 而非直接答案

這個里程碑完成後解鎖：
  → FE 可以串接真實 API（不需要 mock）
  → QA 可以跑 contract + integration test
  → 你可以體驗 AI 問答品質，決定是否需要調整 prompt 或 rerank 參數

驗收通過請回覆「繼續」，有問題請回覆「停止」並說明。
```

---

**M2 checklist — fires when all `fe-*` tasks are done:**

```
🔖 里程碑 M2：前端在瀏覽器跑通黃金路徑

現在可以驗收的功能：
- 登入 / 註冊頁面
- App shell + side-nav
- 文件上傳（dropzone + ingestion 進度條）
- Chat：composer → streaming 回答 → citation chip → citation side panel
- Clarify-buttons 流程
- 文件列表 + 狀態 polling
- Settings：tenant rename + 邀請成員

驗收步驟：
  make dev   # backend + frontend 同時起來

  在瀏覽器開 http://localhost:3000，依序走：

  1. 註冊新帳號 → 看到 onboarding tenant 頁 → 填公司名
  2. 進入 app → 點「上傳文件」→ 拖一份 PDF → 看到進度條 → 完成
  3. 開新 Chat session → 輸入問題 → 確認文字逐字串流出現（不是一次全出）
  4. 點 citation chip → 右側 panel 出現來源段落
  5. 輸入模糊問題 → 出現 clarify 按鈕 → 點其中一個 → 拿到答案
  6. 到 Settings 頁 → 邀請一個新成員（確認 invite link 產出）
  7. 打開 F12 console → 確認無紅色 error

期望結果：
  ✅ 全程無 console error
  ✅ SSE 串流字逐字出現，不是一整包
  ✅ Citation 內容正確對應上傳的 PDF 段落
  ✅ 繁體中文 UI 文字顯示正確
  ✅ Clarify 流程完整（問題 → 選項 → 答案）

這個里程碑完成後解鎖：
  → QA 的 E2E Playwright 測試可以有真實 UI 可跑
  → 可以給內部用戶試用，收集第一手反饋
  → 可以開始決定 v2 feature 優先順序

驗收通過請回覆「繼續」，有問題請回覆「停止」並說明。
```

---

**M3 checklist — fires when all `qa-*` tasks are done:**

```
🔖 里程碑 M3：自動化測試全綠

現在可以驗收的功能：
- pytest：contract + integration + isolation + migration tests
- vitest：Zod schemas + SSE parser + CitationChip
- Playwright：5 條 E2E 跑完

驗收步驟：
  # 確保 compose stack 跑起來（Postgres + pgvector + Redis）
  docker compose up -d

  make test    # pytest + vitest
  make e2e     # Playwright (chromium)

期望結果：
  ✅ pytest：0 failed，包含 tenant-isolation 跨 tenant 測試
  ✅ vitest：0 failed
  ✅ Playwright：e2e-1 signup→answer / e2e-2 invite / e2e-3 clarify /
                 e2e-4 tenant-isolation / e2e-5 ingestion-failure 全通

這個里程碑完成後解鎖：
  → CI pipeline 可以有意義地擋壞程式碼
  → /review-code 的 smoke test phase 可以跑
  → 準備好做 DevOps（CI/CD + 部署）

驗收通過請回覆「繼續」，有問題請回覆「停止」並說明。
```

---

**M4 checklist — fires when all `ops-*` tasks are done:**

```
🔖 里程碑 M4：可部署上線

現在可以驗收的功能：
- Docker image build（後端）
- Next.js standalone build（前端）
- GitHub Actions CI pipeline
- Fly.io fly.toml 設定
- Pre-commit hooks

驗收步驟：
  # 後端 image
  docker build -t ai-worker-api . && docker images ai-worker-api

  # 前端 standalone build
  cd web && pnpm build

  # Push 一個 branch 觸發 GitHub Actions
  git push origin main

  # 確認 CI 跑過：Actions tab → backend-test / frontend-test / migration-test 全綠

期望結果：
  ✅ Docker image 建成功，size < 1 GB
  ✅ pnpm build 無 error，.next/standalone 存在
  ✅ GitHub Actions 全部 job 綠燈
  ✅ pre-commit hooks 在 git commit 時正確執行 ruff + biome

這個里程碑完成後解鎖：
  → 可以跑 /review-code 做最終審查
  → 可以跑 /git-push 推上 GitHub
  → 準備好實際部署到 Fly.io + Vercel

驗收通過請回覆「繼續」，有問題請回覆「停止」並說明。
```

---

If no layer just completed (mid-layer batch), go back to Step A immediately.

## On exit (Definition of Done — Out)

```
✅ /implement 結束。

本次:
- 完成: <count> tasks
- 阻擋: <count> tasks (含失敗的 worktree 路徑供你 inspect)
- 重試成功: <count>

剩餘 pending: <count>

Blocked tasks:
- <id> [<agent>]: <error 一行>
  worktree: <path>

下一步:
- 還有 pending → /implement 繼續
- 有 blocked → 看 worktree 修完後 /resume
- 全部 done (除了 doc-* tasks) → /review-code
```

## Single-task mode (`--task <id>`)

1. Find task in manifest. Not found → error.
2. Verify deps done (or `--force` to skip).
3. Run Steps C-F for just that task (still with retry budget).
4. Print result.

## Three-tier rules

### ✅ Always do
- Atomic-write manifest per manifest-ops skill
- Worktree per parallel agent (unless `--no-worktree`)
- Retry once before marking blocked
- Per-task code review before commit (except pm/arch .md-only tasks)
- 1 commit per done task
- Build STATIC_PREFIX once per batch (Step C-prep) and reuse byte-identical across all agents in the batch — this is what makes prompt caching work
- Print milestone checklist and wait for Leo's confirmation when a layer (be-* / fe-* / qa-* / ops-*) just completed
- Use `model: "sonnet"` for product-manager and system-architect tasks

### ⚠️ Ask first
- More than 4 ready tasks (non-QA) → don't auto-expand batch; confirm with Leo if he wants larger batch
- Worktree merge conflict → stop and surface; don't auto-resolve

### 🚫 Never do
- More than 4 agents in one batch (except QA-only batches: max 6)
- Skip per-task code review for code-generating tasks (backend, frontend, qa, devops, db, api)
- Run code-reviewer on pm/arch tasks whose artifacts are .md only
- Auto-fix blocked tasks
- `git push` (that's `/git-push`'s job)
- Delete a worktree before merging if reviewer PASSed
- Continue past a layer-complete milestone without Leo's explicit "繼續"
