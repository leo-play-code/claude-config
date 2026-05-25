---
description: Final review pass — code-reviewer, security-reviewer, qa-engineer (with smoke test) audit the full codebase against CONSTITUTION + specs. Runs tech-writer for docs. Writes state/code-review.md.
---

Final code review across the whole codebase. Talk to Leo in **Traditional Chinese**; report in English.

## Entry checklist

- [ ] `state/manifest.json` exists
- [ ] All non-doc tasks are `done` (allow `doc-*` tasks pending — `tech-writer` runs after)
- [ ] No tasks `blocked`

If `blocked > 0`, warn:
```
還有 <N> 個 blocked tasks。建議先 /resume 修完。要強制繼續嗎?
```

If `running > 0`, hard stop and tell Leo to clean up first.

## Steps

1. **Brief Leo in Chinese:**
   ```
   即將做最終審查 (預估 5-10 分鐘):
   1. code-reviewer 全 codebase 審 (CONSTITUTION + specs 對照)
   2. security-reviewer 安全審 + dep audit
   3. qa-engineer 跑全部測試 + dev server smoke test
   4. tech-writer 跑 doc-* tasks (產 README / docs / CHANGELOG)
   5. 結果寫入 state/code-review.md

   開始?
   ```
   // 自動開始，不等待確認

2. **Phase 1 — parallel code + security review** (worktree-isolated, single message, `model: "opus"`):
   - `code-reviewer`: full codebase + CONSTITUTION + all specs
   - `security-reviewer`: full audit + run `npm audit` / `pip-audit`

3. **Phase 2 — qa smoke test:**
   ```
   Smoke test mode.
   Run full test suite.
   Start dev server, hit health endpoint, confirm.
   Stop server.
   Report as markdown section under ## Smoke test.
   ```

4. **Phase 3 — docs (if doc-* tasks pending):**
   Dispatch `tech-writer` per `/implement` flow (one task per dispatch, code-reviewer pass, commit).

5. **Combine** all outputs into `state/code-review.md`:
   ```markdown
   # Final Code Review

   Reviewed at: <timestamp>
   Commit: <git rev-parse HEAD>

   ## Summary
   - Code-reviewer: <PASS / PASS_WITH_NOTES / FAIL>
   - Security: <PASS / FAIL — N blockers>
   - Tests: <X passed / Y failed>
   - Smoke: <PASS / FAIL>
   - Docs: <generated / skipped>

   <code-reviewer section>
   <security-reviewer section>

   ## Smoke test (qa-engineer)
   <qa output>

   ## Recommended actions
   - [ ] <consolidated must-fix list>
   ```

## Exit checklist (Definition of Done)

- [ ] `state/code-review.md` written
- [ ] All `doc-*` tasks done in manifest
- [ ] Final message in Chinese:
  - All PASS:
    ```
    ✅ 全部審查通過。下一步: /git-push 推上 GitHub。
    ```
  - Any FAIL (一般問題):
    自動修復後重跑審查，不問 Leo。
  - Any FAIL (架構問題):
    ```
    ⚠️ 審查發現 <N> 個 blocker:
    <each one line>
    建議: /implement --task <id> 修復,或手動修完跑 /review-code 再來。
    ```

## Three-tier rules

### ✅ Always do
- Run all 3 review phases (code, security, smoke)
- Save full review even on failure
- Tech-writer runs LAST (needs to see final code)

### ⚠️ Ask first
- Smoke test fails because dev server doesn't start → ask Leo whether to debug or skip

### 🚫 Never do
- Auto-fix 架構層問題（設計決策類）— 這類必須問 Leo
- 一般 code 問題（lint、格式、小 bug）→ 自動修，修完重跑審查
- 同一問題修超過 2 次還失敗 → 停下來問 Leo
- `git push`
- Skip phases on time pressure
