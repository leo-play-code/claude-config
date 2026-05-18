---
description: Reset a done task back to pending so it can be re-implemented. Optionally reverts the associated git commit. Use when an architectural change requires redoing earlier work.
argument-hint: <task-id> [--revert | --hard | --keep-commit]
---

Reset a `done` task back to `pending`. Talk to Leo in **Traditional Chinese**.

## Args

$ARGUMENTS

Required: a task id (e.g., `be-001`).

Optional commit-handling flag:
- `--revert` — create a new commit that undoes the original (safe, history preserved)
- `--hard` — `git reset --hard` to before the commit (destructive; only allowed if the task's commit is the latest)
- `--keep-commit` — leave the commit alone, just reset manifest status (next `/implement` will create a duplicate commit — usually wrong)

If no flag given, prompt Leo for the choice.

## Entry checklist

- [ ] `state/manifest.json` exists
- [ ] Task id given in args (else stop and ask)
- [ ] Task exists in manifest

## Step 1 — Show current state

```
Task <id>:
  Status: <current>
  Title: <title>
  Agent: <agent>
  Commit SHA: <sha or null>
  Artifacts: <list>
  Finished at: <ts>
  Review notes: <notes or none>
  Downstream tasks (depend on this): <list of ids>
```

If task is not `done`, abort:
```
Task <id> 目前 status 是 <current>,不需要 reset。
若想處理 blocked task,用 /resume。
若想重跑 pending task,用 /implement --task <id>。
```

## Step 2 — Warn about downstream

If any downstream tasks (tasks whose `depends_on` includes this id) are `done`, tell Leo:

```
⚠️ 注意: <N> 個下游 tasks 已經 done,它們依賴 <id> 的舊版 implementation:
- <downstream-id>: <title>

選項:
1. 只 reset 這個 task,下游 tasks 保持 done(如果改動向下相容)
2. 連帶 reset 所有下游 tasks 一起重做(如果 contract / schema 有變)

選 1 / 2?
```
Wait for choice.

## Step 3 — Decide commit handling

If commit_sha is null:
- No commit was ever made — just reset manifest status. Skip step 4.

If commit_sha exists:
- Default proposal:
  ```
  Task <id> 對應 commit <short-sha>: "<commit subject>"

  選項:
  1. --revert    建一個新 commit 反轉原 commit (推薦,history 保留)
  2. --hard      git reset --hard 刪除 commit (危險,只在這是最新 commit 且沒 push 才安全)
  3. --keep-commit 留著 commit 不動,只 reset manifest status (下次 implement 會建第二個 commit,通常不對)

  選哪個?
  ```
- For `--hard`, additional check: is this the HEAD commit? If not, refuse and force user to choose `--revert`.
- For `--hard`, additional check: has it been pushed to origin? If yes, warn loudly and require explicit re-confirmation.

## Step 4 — Execute commit handling

```bash
case $CHOICE in
  revert)
    git revert --no-edit "$SHA"
    ;;
  hard)
    if [ "$(git rev-parse HEAD)" != "$SHA" ]; then
      echo "Refusing --hard: not HEAD" >&2
      exit 1
    fi
    git reset --hard "$SHA~1"
    ;;
  keep-commit)
    : # no-op
    ;;
esac
```

## Step 5 — Reset manifest

For the target task (and downstream if option 2 was chosen):

```bash
jq --arg id "$TASK_ID" \
   '.tasks |= map(if .id == $id then
      .status = "pending"
      | .started_at = null
      | .finished_at = null
      | .error = null
      | .commit_sha = null
      | .review_notes = null
   else . end) | .updated_at = (now | todate)' \
   state/manifest.json > state/manifest.json.tmp
mv state/manifest.json.tmp state/manifest.json
```

Keep `kind`, `added_at`, `added_by`, `artifacts` (artifacts field hints what files will probably be touched again).

## Step 6 — Wrap up

```
✅ Reset 完成:
- Task <id>: done → pending
- <若連帶> N 個下游 tasks 也 reset
- Commit handling: <revert/hard/keep-commit>
- <若 revert> 新增 commit: <new sha> "Revert ..."

下一步: /implement (會自動挑到 reset 的 task)
```

## Three-tier rules

### ✅ Always do
- Show current state before resetting
- Warn about downstream dependencies
- Default to `--revert` (safest)
- Use atomic manifest write
- Ask before destructive operations

### ⚠️ Ask first
- Commit handling choice (default revert, but Leo decides)
- Downstream cascade choice (1 vs 2)
- `--hard` if commit was already pushed

### 🚫 Never do
- `--hard` on non-HEAD commit
- `--hard` on pushed commit without explicit second confirmation
- Reset without showing current state and downstream impact
- Delete artifacts files (only manifest fields are reset)
