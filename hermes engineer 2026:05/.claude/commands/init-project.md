---
description: Scaffold the project — generate root CLAUDE.md, AGENTS.md, .gitignore, .env.example, README skeleton, and the directory layout per stack.
---

Bootstrap the project. Talk to Leo in **Traditional Chinese**; produced files in English.

## Entry checklist

- [ ] `specs/CONSTITUTION.md` exists
- [ ] `specs/00-stack.md`, `specs/01-overview.md`, `specs/02-architecture.md` exist
- [ ] `specs/REVIEW.md` exists with no BLOCKING items

If REVIEW missing or has BLOCKING, warn Leo:
```
注意: <REVIEW 沒跑 / 有 N 個 BLOCKING>。建議先修。要強制繼續嗎?
```

## Steps

1. **Read** all 9 specs + CONSTITUTION. Pull stack, conventions, env vars.

2. **Generate files in parallel** (Write tool can do these together):

   ### `CLAUDE.md` (project root) — claude-md-template skill
   Fill stack, run commands, conventions (don't duplicate CONSTITUTION — link to it), structure. 60-100 lines.

   ### `AGENTS.md` (project root) — claude-md-template skill
   Initial template with empty Patterns / Gotchas / ADRs / Post-mortems sections. **Note in the file: agents must NOT edit this — humans only.**

   ### `.gitignore`
   Stack-appropriate. Always include:
   - `.env`, `.env.local`, `.env.*.local`
   - `node_modules/` / `__pycache__/` / `.venv/`
   - `dist/`, `build/`, `.next/`, `target/`
   - `.DS_Store`, `Thumbs.db`
   - `coverage/`, `.nyc_output/`
   - `state/.status-cache.md`, `state/.status-cache.meta` (derived; rebuilt by `/status`)
   - **Never** ignore `.env.example`

   ### `.env.example`
   Every var from `specs/60-devops.md` with placeholder + comment.

   ### `README.md` (skeleton)
   ```markdown
   # <Project Name from specs/01-overview.md>

   <one-sentence pitch>

   > Status: under development. See `specs/` for the full design and `state/manifest.json` for progress.

   ## Quickstart
   _To be filled in by tech-writer after implementation._

   ## Workflow
   This project uses the AI_worker workflow. See `.claude/CLAUDE.md`.
   ```

   ### Directory scaffold (mkdir -p)
   Per `specs/02-architecture.md` module layout.

3. **Verify** with `ls -la`.

## Exit checklist (Definition of Done)

- [ ] `CLAUDE.md` exists, references CONSTITUTION + AGENTS.md
- [ ] `AGENTS.md` exists with template sections
- [ ] `.gitignore` exists; `.env` ignored; `.env.example` NOT ignored
- [ ] `.env.example` exists (or has comment "no env vars in v1")
- [ ] `README.md` skeleton exists
- [ ] All directories from architecture spec created
- [ ] Final message in Chinese:
  ```
  ✅ 專案骨架完成:
  - CLAUDE.md / AGENTS.md
  - .gitignore (<N> patterns)
  - .env.example (<M> env vars)
  - 目錄: <list>

  下一步: /implement 開始派 agents 寫 code。
  ```

## Three-tier rules

### ✅ Always do
- Verify `.env` is gitignored
- Make AGENTS.md note the human-only edit rule prominently
- Match directory layout to architecture spec

### ⚠️ Ask first
- File exists already → ask before overwriting
- Stack uses something exotic with non-standard ignores → confirm patterns

### 🚫 Never do
- Run `npm install` or any package install (let agents pull deps as needed)
- Write any source code under `src/**` (that's `/implement`)
