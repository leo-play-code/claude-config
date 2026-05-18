---
name: spec-writing
description: Standard format for writing project specs under specs/*.md. Use whenever an agent (product-manager, system-architect, database-engineer, api-designer, etc.) is asked to produce or modify a spec file. Defines section structure, the Tasks checklist format, the Definition-of-Done block, and the link back to manifest.json.
---

# Spec Writing Standard

All spec files under `specs/` follow this template. The `## Tasks` section feeds `state/manifest.json`. The `## Definition of Done` section is the phase exit gate.

Every agent reading or writing a spec MUST first read `specs/CONSTITUTION.md` and obey it. Constitution > spec.

## File naming convention

```
specs/CONSTITUTION.md     # immutable project rules (drafted in /decide-stack)
specs/00-stack.md         # tech stack decision
specs/01-overview.md      # product / user stories
specs/02-architecture.md  # system topology
specs/10-database.md      # schema, migrations
specs/20-api.md           # endpoints, contracts
specs/30-backend.md       # server impl tasks
specs/40-frontend.md      # UI impl tasks
specs/50-tests.md         # test plan
specs/60-devops.md        # docker, CI, deploy
specs/REVIEW.md           # output of /review-specs
```

Number prefix encodes order. Same first digit = same layer (10s = data, 20s = API, etc.).

## Required sections per spec

```markdown
# <Spec Title>

## Purpose
One paragraph: what this layer is responsible for, what it is NOT.

## Decisions
Bulleted list of concrete decisions (libraries, patterns, conventions).
Each decision: **<choice>** — <one-line rationale>

## Interfaces / Contracts
What this layer exposes to others. For DB: table schemas. For API: endpoints. For frontend: component public props.

## Out of scope
Bulleted list of things explicitly NOT in this spec — prevents scope creep.

## Tasks
Each task is one atomic unit of work owned by exactly one agent.

- [ ] **<task-id>** — <imperative title> (agent: `<agent-name>`, deps: `<comma-separated-task-ids or none>`)
  - Acceptance: <one or two bullets describing how we know it is done>
  - Files: <expected paths to be created/modified>

## Definition of Done
This spec is "done" when ALL of the following are checked. /review-specs verifies these before allowing /implement to start.

- [ ] Purpose, Decisions, Interfaces, Out of scope sections all filled in (no placeholders)
- [ ] Every task has unique id, agent, deps, acceptance, files
- [ ] No task references a missing dep id
- [ ] No conflict with `specs/CONSTITUTION.md`
- [ ] At least one entry in `Out of scope` (forces scope discipline)
- [ ] <spec-specific items, e.g., for DB: every FK has an index>
```

## Task ID convention

`<layer>-<seq>` where layer is:
- `pm` — product-manager
- `arch` — system-architect
- `db` — database-engineer
- `api` — api-designer
- `be` — backend-engineer
- `fe` — frontend-engineer
- `qa` — qa-engineer
- `ops` — devops-engineer
- `doc` — tech-writer

Examples: `db-001`, `db-002`, `api-001`, `be-001`, `fe-001`.

## Example task entry

```markdown
- [ ] **db-001** — Create users table with email/password (agent: `database-engineer`, deps: none)
  - Acceptance: migration runs cleanly on a fresh DB; users table has unique index on email
  - Files: `prisma/schema.prisma`, `prisma/migrations/<ts>_init/migration.sql`
```

## Hard rules

1. Read `specs/CONSTITUTION.md` first. Comply with it. If your spec content conflicts with the constitution, stop and surface it.
2. Every task MUST have a unique id, an agent, deps (or `none`), acceptance criteria, and expected file paths.
3. Tasks are atomic — if it would take more than ~30 minutes of focused work, split it.
4. Don't write code in specs. Specs describe *what*, not *how to type it out*.
5. `Out of scope` and `Definition of Done` are mandatory. Empty = spec rejected by `/review-specs`.
6. Keep specs short. Aim for 200–400 lines per spec, not 2000.
