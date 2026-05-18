---
description: Show current progress from state/manifest.json — done, running, blocked, pending — and what's ready to run next. Includes worktree paths for blocked tasks.
argument-hint: [--detail to show full task list]
---

Print a progress dashboard. Headers in **Traditional Chinese**, task data in English.

## Entry checklist

- [ ] `state/manifest.json` exists

If not, tell Leo to run `/generate-specs`.

## Steps

1. **Cache short-circuit (B3):** before doing anything else, check if a fresh cache exists.
   ```bash
   # macOS: stat -f %m ; Linux: stat -c %Y. Use whichever works.
   MANIFEST_MTIME=$(stat -f %m state/manifest.json 2>/dev/null || stat -c %Y state/manifest.json 2>/dev/null)
   ```
   - If `state/.status-cache.md` AND `state/.status-cache.meta` both exist:
     - Read `state/.status-cache.meta` (one line: the cached manifest mtime).
     - If cached mtime == `$MANIFEST_MTIME` AND `--detail` was NOT passed AND no `--no-cache` flag: print the cached `state/.status-cache.md` content, append a final line `(cached — manifest unchanged since <ISO time of cache>; pass --no-cache to refresh)`, then STOP.
   - Otherwise, fall through to compute fresh.

2. **Read** `state/manifest.json`.

3. **Compute counts:**
   - done, running, blocked, pending
   - ready-to-run = pending whose deps are all done
   - waiting = pending with at least one undone dep
   - **By kind**: initial / feature / fix counts

4. **Print dashboard:**

   ```
   ## 進度總覽

   | 狀態 | 數量 |
   |---|---|
   | ✅ Done | <count> |
   | 🟡 Running | <count> |
   | 🔴 Blocked | <count> |
   | ⏳ Pending | <count> |
   | **總計** | <N> |

   進度: <done>/<total> (<pct>%)

   ## 分類 (by kind)
   | Kind | Done | Total |
   |---|---|---|
   | 🌱 initial (v1) | <X> | <Y> |
   | ✨ feature | <X> | <Y> |
   | 🐛 fix | <X> | <Y> |

   ## 下一批可跑 (Ready to run)
   <list id, title, agent OR "(目前無)">

   ## Blocked tasks
   <若 N>0:
   - **<id>** [<agent>] <title>
     Error: <error 一行>
     Spec: <spec path>
     Worktree (若有): <path>  ← 進去看 agent 改了什麼
   否則: "(目前無)">

   ## Running tasks
   <若 N>0 警告: 上次 /implement 可能中斷。建議:
   - 看 state/runlog/<latest>.md
   - 手動把 status 改回 pending,然後重跑 /implement>

   ## 今日活動 (今天的 file edits)
   <若 state/activity/<today>.log 存在,印最近 10 行>

   ## 建議下一步
   <根據狀態:
   - blocked > 0 → "進 worktree 修完後跑 /resume"
   - ready > 0 → "/implement 繼續"
   - all done (除 doc-*) → "/review-code"
   - all done + reviewed (主線無分支) → "/git-push"
   - all done + reviewed (在 feat/fix 分支) → "/git-pr"
   - 發現 spec 跟 code 不同步 → "/sync-spec"
   - 想加新 feature → "/feature <描述>"
   - 有 bug 要修 → "/fix <描述>"
   >

   ## 當前分支
   <git rev-parse --abbrev-ref HEAD>
   <若不是 main 提示: "在 feature/fix 分支,完工後用 /git-pr">
   ```

5. If `--detail` arg, also print full task list grouped by status.

6. **Write cache (B3):** unless `--detail` or `--no-cache` was passed, save the dashboard text (Step 4 output, without the cache footer) to `state/.status-cache.md`, and write the manifest mtime + cache ISO timestamp to `state/.status-cache.meta` (one line each: `mtime=<value>` then `cached_at=<ISO>`). Use atomic write (write to `.tmp` then `mv`).

## Exit checklist

- [ ] Dashboard printed
- [ ] Suggested next step matches actual state
- [ ] Cache files written (if not `--detail` / `--no-cache`)

## Three-tier rules

### ✅ Always do
- Read-only operation on manifest (cache files in `state/.status-cache.*` are derived, not authoritative)
- Show worktree paths for blocked tasks (so Leo can inspect)
- Honor `--no-cache` to force fresh compute

### ⚠️ Ask first
- (n/a — read-only)

### 🚫 Never do
- Modify manifest
- Suggest a step that requires precondition not yet met
- Use the cache when manifest mtime has changed (always recompute)
- Cache `--detail` output (full task list bloats the cache)
