---
description: Detect drift between specs and actual code. Lists places where the implementation deviates from spec, asks Leo whether to update spec or fix code per item.
---

Detect spec ↔ code drift. Talk to Leo in **Traditional Chinese**; analysis output in English.

## Entry checklist

- [ ] `specs/CONSTITUTION.md` and all 9 specs exist
- [ ] Some implementation exists in `src/` (otherwise nothing to compare)
- [ ] `state/manifest.json` exists

## Steps

1. **Brief Leo in Chinese:**
   ```
   準備掃描 spec ↔ code drift:
   - 比對 specs/10-database.md vs prisma/schema.prisma (or equivalent)
   - 比對 specs/20-api.md vs route handlers in src/server/
   - 比對 specs/40-frontend.md page list vs actual pages
   - 比對 CONSTITUTION rules vs code
   - 確認 manifest 上 done 的 task 真的有對應 commit + artifacts

   開始?
   ```
   Wait.

2. **Dispatch parallel detection** (worktree-isolated, single message):
   - `code-reviewer`: read each spec, find code paths it references, check actual code matches. Output drift list.
   - `database-engineer`: read `specs/10-database.md` schema vs actual schema file, list differences.
   - `api-designer`: read `specs/20-api.md` endpoints vs actual route handlers, list differences (extra endpoints, missing endpoints, contract mismatches).

3. **Aggregate findings** into a Drift Report:

   ```markdown
   # Spec ↔ Code Drift Report

   Generated: <timestamp>
   Commit: <git rev-parse HEAD>

   ## Drift items

   ### specs/10-database.md
   - [DRIFT] users.email is `String @unique` in schema but spec says "no unique constraint"
   - [MISSING IN CODE] sessions table in spec but not in schema
   - [EXTRA IN CODE] api_keys table in schema but not in spec

   ### specs/20-api.md
   - [DRIFT] POST /users response shape: spec says { data: User } but code returns { user: User }
   - [MISSING IN CODE] DELETE /users/:id endpoint in spec, not implemented
   - [EXTRA IN CODE] GET /users/:id/sessions implemented but not in spec

   ### specs/CONSTITUTION.md
   - [VIOLATION] src/server/users.ts:42 uses raw SQL but constitution says "ORM only"

   ### Manifest integrity
   - [OK] All `done` tasks have valid commit_sha
   ```

4. **For each drift item, ask Leo in Chinese** (one round per spec):
   ```
   specs/10-database.md drift (3 items):
   1. users.email unique 限制不一致 — 該改 spec 還是改 code?
   2. sessions table 在 spec 有,code 沒有 — 該補 code 還是從 spec 刪掉?
   3. api_keys 在 code 有,spec 沒有 — 該補 spec 還是從 code 刪掉?

   個別決定 (回:1=spec, 2=spec, 3=code) 或統一 (all=spec / all=code / skip)
   ```

5. **Apply decisions:**
   - "spec" choice → update the relevant spec to match code (and possibly add a manifest task to track this drift formally)
   - "code" choice → add a NEW manifest task for the responsible agent to fix code in next `/implement`
   - "skip" → record in drift report; don't act

6. **Save** drift report to `state/drift-<timestamp>.md`. Don't overwrite previous reports — they're history.

## Exit checklist (Definition of Done)

- [ ] `state/drift-<timestamp>.md` written
- [ ] Each drift item has a decision recorded (spec / code / skip)
- [ ] Specs updated if "spec" was chosen
- [ ] Manifest has new tasks for "code" decisions
- [ ] Final message in Chinese:
  ```
  ✅ Drift 處理完成:
  - <X> spec 改動已寫入
  - <Y> 新增 tasks 在 manifest 等待 /implement
  - <Z> skipped (記錄在 drift report)

  下一步:
  - 有新 tasks → /implement
  - 全部 OK → 繼續開發
  ```

## Three-tier rules

### ✅ Always do
- Process drift one spec at a time (don't dump 50 items in one message)
- Save drift report as historical record
- Add manifest tasks (don't silently fix code)

### ⚠️ Ask first
- A drift could be intentional (e.g., emergency hotfix that didn't update spec) → ask before forcing reconciliation

### 🚫 Never do
- Auto-fix code without asking
- Auto-rewrite specs without asking
- Delete spec sections to "clean up"
