---
description: Add a new feature to an existing project. Auto-classifies size (small/medium/big) and runs the matching sub-flow. Updates specs incrementally and appends tasks to manifest.
argument-hint: <feature description>
---

Add a new feature to the project. Talk to Leo in **Traditional Chinese**; specs and code in English.

## Args

$ARGUMENTS

If no description given, ask Leo: "想加什麼 feature? 一兩句話描述一下。"

## Entry checklist

- [ ] `state/manifest.json` exists (i.e., `/generate-specs` was run at least once)
- [ ] `specs/CONSTITUTION.md` and 9 specs exist
- [ ] No tasks in `running` state
- [ ] Working tree is clean OR Leo confirms staged changes are OK to be part of this feature

If any unmet, stop and tell Leo what to do first.

## Step 1 — Brief discussion (mini /discuss-project)

In Chinese, ask Leo 1-3 focused questions to understand the feature. Cover:
- What does the user gain from this feature?
- Which existing screens/endpoints does it touch?
- Any non-goals?

Append the round to `discussion/notes.md` with header `## <YYYY-MM-DD HH:MM> — Feature: <short name>`.

## Step 2 — Classify size

Read CONSTITUTION + relevant specs. Make a sizing decision and propose to Leo in Chinese:

```
我評估這個 feature 是 **<🟢 Small | 🟡 Medium | 🔴 Big>**:

🟢 Small (1-3 tasks, 不動 spec 結構):
  - 估計 <N> 個 tasks
  - 不需改 spec(只在 spec 的 ## Tasks 末尾追加)
  - 跳過 /review-specs

🟡 Medium (改 specs + 新 tasks):
  - 估計需要改 <list of specs>
  - <N> 個新 tasks
  - 跑 /review-specs 只審改動的 specs

🔴 Big (跨多 specs + 可能新 ADR):
  - 改 <list of specs>
  - 新 ADR: <topic>
  - <N> 個新 tasks
  - 跑完整 /review-specs

要按這個大小走嗎? 或你覺得 sizing 不對請告訴我。
```

Wait for confirmation. Allow Leo to override the size.

## Step 3 — Branch off

Before any spec/code changes:

```bash
SLUG=<short-kebab-from-feature-name>
git checkout -b "feat/$SLUG"
```

Tell Leo: `已切到 feat/<slug> 分支。所有改動會在這個分支累積,最後用 /git-pr 開 PR。`

## Step 4 — Sub-flow per size

### 🟢 Small flow

1. Compute next IDs per affected layer (per manifest-ops skill).
2. Append task entries to the relevant spec's `## Tasks` section (use Edit tool).
3. Append task entries to `state/manifest.json` (atomic write). Each task has:
   - `kind: "feature"`
   - `added_at: <now>`
   - `added_by: "/feature"`
4. Show Leo the new tasks in Chinese:
   ```
   已加 <N> 個新 tasks 到 manifest:
   - <id>: <title> (deps: <list>)
   ```
5. Ask: `馬上跑 /implement 這幾個 task 嗎?`
6. If yes → invoke `/implement` (it'll pick up the new pending tasks automatically).
7. After implement → skip `/review-code` (small features don't warrant it). Just verify `code-reviewer` PASSed each task.

### 🟡 Medium flow

1. Dispatch `product-manager` (`model: "opus"`) to APPEND new user stories to `specs/01-overview.md` (use Edit tool — don't overwrite existing content).
2. Dispatch the relevant domain agents (db-engineer, api-designer, backend-engineer, frontend-engineer, qa-engineer) **in sequence** with `model: "opus"` to APPEND new sections + new tasks to their specs:
   - Each agent prompt includes: `Mode: incremental. Append new content to <spec>. DO NOT delete or rewrite existing sections.`
   - Each agent computes next id seq and uses unique IDs.
3. Append new tasks to `state/manifest.json` with `kind: "feature"`.
4. Run `/review-specs` BUT pass an arg `--changed-only` (the reviewer only looks at the new sections + new tasks). Skip if Leo says it's not needed.
5. Run `/implement` → DAG picks up new pending tasks.
6. Run `/review-code` (focused on changed area).

### 🔴 Big flow

1. Run `/discuss-project` for one more round to deepen requirements.
2. Optionally suggest re-running `/decide-stack` if the feature implies a stack change (e.g., adding real-time → need WebSocket choice).
3. Dispatch `system-architect` (`model: "opus"`) to update `specs/02-architecture.md` and add new ADR(s) under `docs/adr/`.
4. Then medium flow steps 1-6.

## Step 5 — Wrap up

After implementation + review:

```
✅ Feature "<name>" 完成:
- 新 tasks: <N> 個全部 done
- Commits: <count>
- 分支: feat/<slug>

下一步:
- /git-pr 開 PR(推上 GitHub,你可以在網頁上 review + merge)
- 或 git checkout main && git merge feat/<slug>(如果你想直接合)
```

## Three-tier rules

### ✅ Always do
- Branch off main FIRST (don't pollute main with WIP)
- Append, never overwrite, when editing specs and manifest
- Use the next available id seq per layer
- Set `kind: "feature"` on every new task
- Comply with CONSTITUTION

### ⚠️ Ask first
- Sizing classification — let Leo override
- Whether to skip `/review-specs` for small features
- Whether to merge to main directly or open PR

### 🚫 Never do
- Overwrite existing spec content
- Reuse a task id that's already in manifest
- Skip the discussion step (even small features benefit from 1 question)
- Push to main directly (always branch first; `/git-pr` is the merge gate)
