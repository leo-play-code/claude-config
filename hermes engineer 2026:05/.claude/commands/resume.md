---
description: Reset blocked tasks back to pending and re-run /implement. Use after manually fixing the cause of a block. Cleans up associated worktrees.
argument-hint: [optional task id to resume just that one]
---

Reset blocked tasks and continue. Talk to Leo in **Traditional Chinese**.

## Entry checklist

- [ ] `state/manifest.json` exists

## Args

$ARGUMENTS

If a specific task id given, resume only that one. Otherwise resume all blocked tasks.

## Steps

1. **Read** `state/manifest.json`. Find blocked tasks (or just the one specified).

2. **If no blocked tasks:**
   ```
   目前沒有 blocked 的 tasks。要跑 /implement 繼續 pending 的嗎?
   ```
   Stop.

3. **Show Leo the blocked tasks** in Chinese:
   ```
   即將重置 <N> 個 blocked tasks 回 pending:
   - <id> [<agent>] <title>
     之前 error: <error>
     Worktree (若有): <path>  ← 你修在這裡了嗎?

   選項:
   1. 重置 + 從頭跑 (worktree 會被刪除)
   2. 接受 worktree 現有改動為 done (跳過 agent,直接 review + commit)

   選哪個? (1 / 2 / cancel)
   ```
   Wait.

4. **If option 1 (re-run):**
   - Clean up associated worktrees: `git worktree remove <path> --force`
   - Reset manifest fields: `status="pending"`, `error=null`, `started_at=null`, `finished_at=null`
   - Atomic write
   - Trigger `/implement` (don't ask again, Leo just confirmed)

5. **If option 2 (accept worktree):**
   - For each task: dispatch `code-reviewer` on the worktree's diff
   - If PASS: merge worktree → commit → mark `done` (same flow as `/implement` Step E)
   - If FAIL: tell Leo, leave as blocked

## Exit checklist

- [ ] Either blocked tasks reset to pending and `/implement` triggered, OR worktrees accepted+committed and tasks marked done
- [ ] No leftover orphan worktrees

## Three-tier rules

### ✅ Always do
- Show worktree path so Leo can inspect first
- Offer both "re-run" and "accept worktree" options

### ⚠️ Ask first
- Multiple tasks blocked with different fix strategies → ask per-task instead of bulk

### 🚫 Never do
- Reset `done` tasks (those need manual edit + `--force`)
- Delete a worktree without confirmation if it has changes
- Auto-fix the underlying cause
