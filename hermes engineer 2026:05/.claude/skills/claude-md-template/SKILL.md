---
name: claude-md-template
description: Standard CLAUDE.md and AGENTS.md templates for /init-project to generate at the project root. Provides sections for stack, conventions, run commands, testing, project-specific context, and the human-curated learnings file. Use when bootstrapping a fresh project after specs are agreed.
---

# CLAUDE.md and AGENTS.md Templates

`/init-project` writes BOTH files to the project root. They serve different purposes:

- **`CLAUDE.md`** — project context, auto-loaded into every session. Run commands, conventions, structure. Generated once and refreshed when stack changes.
- **`AGENTS.md`** — human-curated learnings. Patterns, gotchas, ADR pointers. NEVER auto-edited by agents. Grows over time as Leo and reviewers note things.

## CLAUDE.md template

```markdown
# <Project Name>

<One-sentence elevator pitch from specs/01-overview.md>

> **Authority order: `specs/CONSTITUTION.md` > `specs/*.md` > this file > agent judgment.**

## Stack

<Distilled from specs/00-stack.md>
- Frontend: <e.g., Next.js 15 + TypeScript + Tailwind>
- Backend: <e.g., Next.js Route Handlers / FastAPI / Express>
- Database: <e.g., Postgres via Prisma>
- Auth: <e.g., NextAuth / Lucia / Clerk>
- Deploy: <e.g., Vercel / Fly.io / self-hosted Docker>

## Run

\`\`\`bash
<install command>
<dev command>
\`\`\`

App runs at <URL>.

## Test

\`\`\`bash
<unit test command>
<e2e test command, if any>
\`\`\`

## Conventions (non-exhaustive — see CONSTITUTION.md for the full rules)

- <e.g., "API responses always { data, error }">
- <e.g., "Components in PascalCase, hooks prefixed use*">
- <e.g., "Database migrations checked in to prisma/migrations/">

## Project structure

\`\`\`
src/
  app/         # routes
  components/  # React components
  lib/         # shared utilities
  server/      # backend route handlers
prisma/
  schema.prisma
  migrations/
specs/         # source-of-truth specs (CONSTITUTION + 9 specs)
state/         # manifest.json + run logs + activity log
\`\`\`

## Workflow

This project uses the AI_worker workflow. Pipeline:

`/discuss-project` → `/decide-stack` → `/generate-specs` → `/review-specs` → `/init-project` → `/implement` → `/review-code` → `/git-push`

Other commands: `/status`, `/resume`, `/sync-spec`.

See `.claude/CLAUDE.md` for workflow details and `AGENTS.md` for accumulated project learnings.
```

## AGENTS.md template (initial)

```markdown
# Agent Learnings — <Project Name>

> Human-curated. Agents must NOT edit this file. Leo or human reviewers add entries here when they spot a pattern, gotcha, or decision worth remembering.
>
> Authority: This file is hints and history. `specs/CONSTITUTION.md` is the rule. If you find a learning here that contradicts the constitution, the constitution wins — and flag the inconsistency.

## How to use this file

- Read top-to-bottom before starting any non-trivial task.
- If a relevant learning exists, follow it.
- If you discover something new worth remembering, surface it to Leo in your output. Do NOT write to this file yourself.

## Patterns

(none yet — will grow)

## Gotchas

(none yet — will grow)

## Architectural decisions (ADRs)

See `docs/adr/` for full records. Index:

(none yet)

## Task post-mortems

When a task gets `blocked` and resolved in a non-obvious way, the resolution may be summarized here.

(none yet)
```

## CLAUDE.md filling rules

- Stack details from `specs/00-stack.md`.
- Elevator pitch from `specs/01-overview.md`'s first paragraph.
- Conventions: short summary only. Don't duplicate `specs/CONSTITUTION.md`.
- Project structure from the directory layout decided in `02-architecture.md`.
- Aim for 60–100 lines. Loaded into every session — long files cost tokens.

## AGENTS.md filling rules

- Initial version is mostly placeholders.
- Each `Pattern` / `Gotcha` / `ADR` / `Post-mortem` entry: 2-5 lines, dated.
- New entries are appended; old ones are not deleted unless they become wrong.
- If an entry contradicts current code, the entry stays as a historical record but is marked `[OBSOLETE 2026-MM-DD]` on its first line.

## Don't include in either file

- Secrets / credentials
- Internal-only URLs
- Anything that belongs in a spec (full DB schema → link to spec instead)
