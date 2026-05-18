---
description: Fix a bug in an existing project. Auto-classifies size (tiny/real/big) and runs the matching sub-flow. Tiny bugs are fixed inline; real and big bugs add manifest tasks.
argument-hint: <bug description or error message>
---

Fix a bug. Talk to Leo in **Traditional Chinese**; code and commits in English.

## Args

$ARGUMENTS

If no description given, ask Leo: "什麼 bug? 貼錯誤訊息或描述症狀都可以。"

## Entry checklist

- [ ] `state/manifest.json` exists
- [ ] `specs/CONSTITUTION.md` and specs exist
- [ ] No tasks in `running` state

## Step 1 — Reproduce / understand

In Chinese, confirm understanding:
- What's the symptom?
- What was the expected behavior?
- Steps to reproduce?
- Any error message / stack trace?

If Leo gave enough info, skip questions. Don't interrogate for trivial bugs.

## Step 2 — Locate

Use Read / Grep / Bash to find the offending file(s) and the relevant spec section. Decide:
- **Spec is correct, code is wrong** → most common case
- **Spec is incomplete or wrong** → spec needs a fix too
- **Bug reveals an architectural flaw** → big

## Step 3 — Classify size

Tell Leo in Chinese:

```
我看了 code,評估這個 bug 是 **<🟢 Tiny | 🟡 Real | 🔴 Big>**:

🟢 Tiny (typo, log, style, missing null-check on safe path):
  - 不動 spec
  - 不加 manifest task
  - 直接 Edit + code-reviewer 過 + commit

🟡 Real (logic / validation / auth bug):
  - 影響檔案: <list>
  - 是否要改 spec: <yes / no — 解釋為什麼>
  - 加 1 個 manifest task: <agent> 的 fix
  - 跑 /implement --task <id>

🔴 Big (架構錯誤 / 多檔案連鎖):
  - 影響範圍: <list>
  - 改 specs: <list>
  - 可能要新 ADR
  - 走類似 /feature big flow

走哪個? 或你不同意 sizing 請說。
```

Wait for confirmation.

## Step 4 — Branch (for Real and Big only)

```bash
SLUG=fix-<short-kebab>
git checkout -b "fix/$SLUG"
```

Tiny fixes can stay on main IF the working tree is otherwise clean. If on main with no other WIP → fine to commit directly. Otherwise branch off.

## Step 5 — Sub-flow per size

### 🟢 Tiny flow

1. Find the bad code line.
2. Use Edit to fix it.
3. Dispatch `code-reviewer` with `model: "sonnet"`: `Review this single fix. Verdict PASS / FAIL.`
4. If PASS:
   - `git add <file>`
   - `git commit -m "fix: <one-line description>"`
5. If FAIL:
   - Tell Leo what reviewer flagged
   - Ask whether to fix the flag or escalate to "real" flow

NO manifest task. NO spec update. NO `/review-code`. This is the express lane.

### 🟡 Real flow

1. **If spec also wrong:**
   - Use Edit to update the relevant spec section (e.g., `specs/30-backend.md` adds the missed validation rule).
   - Run `/sync-spec` to surface any other drift caught by the spec change. Skip if Leo says no.
2. Compute next task id (e.g., `be-NNN` for backend bug).
3. Append a task to manifest:
   ```json
   {
     "id": "be-NNN",
     "kind": "fix",
     "spec": "specs/30-backend.md",
     "title": "[fix] <bug summary>",
     "agent": "<responsible agent>",
     "depends_on": [],
     "status": "pending",
     "added_at": "<now>",
     "added_by": "/fix"
   }
   ```
4. Run `/implement --task be-NNN`. The agent will:
   - Read the spec section (now updated)
   - Implement the fix
   - code-reviewer passes
   - Commit with message `[<agent>] [fix] <title>`
5. Optionally suggest `/review-code` if multiple files were touched.

### 🔴 Big flow

Same as `/feature` 🔴 Big flow but commits message stem is `[fix]` not `[feat]`. Likely involves multiple agents and possibly a new ADR explaining why the original architecture was wrong.

## Step 6 — Wrap up

```
✅ Fix "<summary>" 完成:
- Tasks added: <N> (kind: fix)
- Commits: <count>
- 分支: <fix/... or main>

下一步:
- /git-pr 開 PR (Real / Big)
- /git-push (Tiny on main 直接推)
```

## Three-tier rules

### ✅ Always do
- Locate the bug FIRST before classifying size (sizing is not just by feel)
- Use git history (`git log -p <file>`) to understand intent before fixing
- For Real and Big: branch off main
- Add a regression test where it's cheap (qa-engineer can be dispatched after the fix)

### ⚠️ Ask first
- Sizing classification — let Leo override (Tiny might really be Real on inspection)
- Whether the spec needs updating
- Whether to add a regression test

### 🚫 Never do
- Suppress or `try/catch` away the symptom without finding root cause
- Disable the failing test that revealed the bug
- Edit unrelated code while fixing (no drive-by refactors)
- For Real/Big: skip the manifest task (we want git history to reflect "real" fixes)
