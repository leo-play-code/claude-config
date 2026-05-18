---
description: Read discussion + stack + constitution, dispatch product-manager and system-architect to draft top-level specs, then domain agents to add their tasks. Builds state/manifest.json.
---

Generate the complete spec set. Talk to Leo in **Traditional Chinese**; specs in English.

## Entry checklist

- [ ] `discussion/notes.md` exists and has content
- [ ] `specs/00-stack.md` exists
- [ ] `specs/CONSTITUTION.md` exists

If any missing, stop and tell Leo which step to run.

## Steps

1. **Read CONSTITUTION** into context — every dispatched agent will be told to comply.

2. **Brief Leo in Chinese:**
   ```
   準備產出 9 份 specs。流程:
   - 階段 1 (並行 worktree): product-manager 寫 overview, system-architect 寫 architecture (+ ADRs)
   - 階段 2 (序列): db → api → backend → frontend → qa → devops 各自寫 spec + task list

   每個 agent 都會被要求遵守 CONSTITUTION。預計幾分鐘。開始?
   ```
   Wait.

3. **Phase 1 — product + architecture (parallel, worktree-isolated).**
   Single message, two Agent calls with `isolation: "worktree"` and `model: "opus"`:
   - `product-manager` → `specs/01-overview.md`
   - `system-architect` → `specs/02-architecture.md` + `docs/adr/*.md`

   After both return, merge worktrees back to main (handle conflicts in `docs/adr/` numbering — system-architect typically owns that dir alone, so no real conflict).

4. **Phase 2 — domain specs (sequential).**
   Each agent reads previously-written specs. All dispatched with `model: "opus"`:
   - `database-engineer` → `specs/10-database.md`
   - `api-designer` → `specs/20-api.md` (depends on db)
   - `backend-engineer` → `specs/30-backend.md` (depends on api+db)
   - `frontend-engineer` → `specs/40-frontend.md` (depends on api)
   - `qa-engineer` → `specs/50-tests.md` (depends on impl specs)
   - `devops-engineer` → `specs/60-devops.md` (depends on stack+architecture)

   Each agent prompt includes:
   ```
   CONSTITUTION (read first, must comply): specs/CONSTITUTION.md
   Mode: spec writing
   Read your agent definition for inputs/outputs/constraints.
   Produce <spec file> per spec-writing skill (must include Definition of Done section).
   ```

5. **Build `state/manifest.json`.** Parse `## Tasks` from every spec, assemble manifest:

   ```json
   {
     "version": 1,
     "created_at": "<UTC ISO>",
     "updated_at": "<UTC ISO>",
     "tasks": [
       {
         "id": "<task-id>",
         "spec": "specs/<file>",
         "title": "<task title>",
         "agent": "<agent-name>",
         "depends_on": [<from spec>],
         "status": "pending",
         "artifacts": [],
         "started_at": null,
         "finished_at": null,
         "error": null,
         "commit_sha": null,
         "review_notes": null
       }
     ]
   }
   ```

6. **Validate:**
   - All `depends_on` ids exist
   - No cycles (topological sort)
   - Every spec has at least one task except `01-overview.md` and `02-architecture.md`
   - Every task in manifest has a corresponding `## Tasks` entry in its spec

   If validation fails, report and don't write manifest.

7. **Save** `state/manifest.json` (atomic write per manifest-ops skill).

## Exit checklist (Definition of Done)

- [ ] All 9 specs exist (`00-stack.md` already; `01..60-*.md` newly written)
- [ ] Every spec has Purpose, Decisions, Out of scope, Tasks, Definition of Done sections filled in
- [ ] `state/manifest.json` exists, parses, no cycles
- [ ] No spec contradicts CONSTITUTION (visual check; full check happens in `/review-specs`)
- [ ] Final summary in Chinese:
  ```
  ✅ Specs 產出完成:
  - 9 份 specs in specs/
  - <N> ADRs in docs/adr/
  - state/manifest.json 共 <N> 個 tasks (<count> 批次)

  下一步: /review-specs 讓 reviewer 檢查矛盾與安全問題。
  ```

## Three-tier rules

### ✅ Always do
- Phase 1 first (overview + architecture inform every later spec)
- Pass CONSTITUTION reference to every agent prompt
- Validate manifest before writing
- Use worktrees in Phase 1 to prevent overlapping writes

### ⚠️ Ask first
- Any agent says "needs clarification" → surface to Leo; don't paper over
- Any spec exceeds 600 lines → ask Leo if you should split it

### 🚫 Never do
- Skip Phase 1
- Write specs yourself (always dispatch responsible agent)
- Write any code in this command
