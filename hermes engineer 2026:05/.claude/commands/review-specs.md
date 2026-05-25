---
description: Dispatch code-reviewer and security-reviewer in parallel to audit all specs against the constitution. Writes specs/REVIEW.md.
---

Pre-implementation review of all specs. Talk to Leo in **Traditional Chinese**; REVIEW file in English.

## Entry checklist

- [ ] `specs/CONSTITUTION.md` exists
- [ ] All 9 specs exist (`00-stack.md` through `60-devops.md`)
- [ ] `state/manifest.json` exists

If any missing, tell Leo which.

## Steps

1. **Brief Leo in Chinese:**
   ```
   即將派 code-reviewer 和 security-reviewer 並行審查 (worktree 隔離):
   - 各 spec 的 Definition of Done 是否完整
   - specs 是否互相矛盾
   - specs 是否違反 CONSTITUTION
   - 安全考量缺漏
   開始?
   ```
   // 自動開始，不等待使用者確認

2. **Dispatch in parallel** (single message, two Agent calls, `isolation: "worktree"`, `model: "opus"`):
   - `code-reviewer`: read all specs + CONSTITUTION. Check internal contradictions, missing acceptance criteria, infeasible tasks, scope bloat, CONSTITUTION violations. Output markdown section.
   - `security-reviewer`: read all specs. Flag missing security considerations (auth gaps, missing validation policy, missing rate limit, missing audit logs). Output markdown section.

3. **Combine** outputs into `specs/REVIEW.md`:
   ```markdown
   # Spec Review

   Reviewed at: <timestamp>
   Specs reviewed: CONSTITUTION + 00-stack + 01-overview + 02-architecture + 10-database + 20-api + 30-backend + 40-frontend + 50-tests + 60-devops

   ## Summary
   - Total findings: <N>
   - BLOCKING: <count>
   - HIGH: <count>
   - NOTES: <count>
   - Definition of Done not met: <count of specs>

   <code-reviewer's section>

   <security-reviewer's section>

   ## Per-spec DoD status
   - specs/01-overview.md: ✓ DoD met / ✗ <missing items>
   - specs/02-architecture.md: ...
   ...

   ## Recommended actions
   - [ ] <consolidated list of must-fix items before /implement>
   ```

## Exit checklist (Definition of Done)

- [ ] `specs/REVIEW.md` written
- [ ] Leo informed of BLOCKING count
- [ ] If 0 BLOCKING:
  ```
  ✅ Spec 審查通過 (<NOTES count> notes,不阻擋)。
  下一步: /init-project 來建立 CLAUDE.md / AGENTS.md / .gitignore / .env.example。
  ```
- [ ] If BLOCKING > 0:
  ```
  ⚠️ 審查發現 <N> 個 BLOCKING:
  <每個用一行中文摘要>
  建議先修 specs 再繼續。要我幫忙修哪一個?
  ```

## Three-tier rules

### ✅ Always do
- Read CONSTITUTION before specs
- Surface BLOCKING items prominently
- Combine both reviewers' output into one file

### ⚠️ Ask first
- A finding could be either spec issue OR design intent → ask Leo

### 🚫 Never do
- Dispatch implementation agents here
- Auto-fix issues found
