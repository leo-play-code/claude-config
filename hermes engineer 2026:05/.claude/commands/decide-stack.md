---
description: Read discussion notes and decide the tech stack. Writes specs/00-stack.md and drafts specs/CONSTITUTION.md after Leo confirms.
---

Read `discussion/notes.md`, propose a tech stack, then draft the project's constitution. Talk to Leo in **Traditional Chinese**; specs in English.

## Entry checklist

- [ ] `discussion/notes.md` exists and has content (≥1 round of `/discuss-project`)

If not, stop and tell Leo to run `/discuss-project` first.

## Model

> 此 command 本身是 orchestrator，模型由當前 session 決定。建議執行前先 `/model opus` — 架構決策是高風險一次性選擇，值得最強推理能力。

## Steps

1. **Read** `discussion/notes.md` thoroughly.

2. **Propose stack.** Recommend ONE choice per layer with one-line rationale. Cover:
   - Frontend (framework + language + styling)
   - Backend (runtime + framework + ORM if applicable)
   - Database (engine + migration tool)
   - Auth (library / strategy)
   - Hosting / Deploy (platform)
   - CI (provider)
   - Testing (unit + E2E tools)

   Plus project-specific tools mentioned in discussion (payments, queues, AI SDKs, etc.).

3. **Show Leo the proposal in Chinese** as a markdown table:
   ```
   | 層 | 推薦 | 替代選項 | 理由 |
   |---|---|---|---|
   | Frontend | Next.js 15 + TS | Vite+React, Astro | <1-line> |
   ...
   ```
   End with: "確認用這套 stack 嗎? 有任何想換的請告訴我。"

4. **Loop until Leo confirms** or overrides.

5. **Write `specs/00-stack.md`** in English per spec-writing skill. Sections: Purpose, Decisions (chosen tech + rationale), Versions (current latest stable majors), Out of scope (rejected alternatives), Tasks (usually empty), Definition of Done.

6. **Draft `specs/CONSTITUTION.md`** using the constitution-template skill. Pre-fill with stack-specific rules:
   - Architecture: ORM choice, API response shape (per stack convention), auth middleware location
   - Security: validation library based on stack (zod for TS, pydantic for Python)
   - Testing: test runner from stack
   - Code style: language-idiomatic conventions
   - Git, scope discipline, process — copy from skill template

7. **Show Leo the draft constitution in Chinese summary**:
   ```
   已草擬 specs/CONSTITUTION.md (專案憲法,所有 specs / code 都不能違反):
   - <N> 條 architecture rules
   - <M> 條 security rules
   - <P> 條 testing rules
   - <Q> 條 code style rules
   - <R> 條 git / process rules

   有要加 / 改 / 刪的嗎? 這份檔案以後 agents 都會讀,會直接影響全部產出。
   ```
   Loop until Leo confirms.

## Exit checklist (Definition of Done)

- [ ] `specs/00-stack.md` exists with all sections
- [ ] `specs/CONSTITUTION.md` exists with all required sections
- [ ] Leo confirmed both
- [ ] Final message printed: "✅ Stack 寫入 specs/00-stack.md,Constitution 寫入 specs/CONSTITUTION.md。下一步: /generate-specs。"

## Three-tier rules

### ✅ Always do
- Be opinionated (one recommendation per layer)
- Pin specific versions where it matters (framework majors)
- Match project scale (no Postgres+Redis+Kafka for a Todo app)
- Draft CONSTITUTION as part of this step (not later)

### ⚠️ Ask first
- Leo's discussion specified a tech (e.g., "I want FastAPI") → respect it; recommend WITHIN that constraint
- A constitution rule is genuinely controversial → flag it and ask Leo to decide

### 🚫 Never do
- Run package installs (that's `/init-project`)
- Skip the CONSTITUTION step
- Add 8 alternatives per layer (pick winners)
