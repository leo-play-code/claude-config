---
name: constitution-template
description: Standard format for specs/CONSTITUTION.md — the project's immutable architectural principles. Used by /decide-stack to bootstrap, read by every agent before starting work. Higher authority than any individual spec.
---

# Constitution Template

`specs/CONSTITUTION.md` is the **immutable rules layer** above all other specs. Specs describe *what* to build; the constitution describes *how things must always be done* regardless of what's being built.

When an agent finds a conflict between a spec and the constitution, **constitution wins**. The agent must stop and surface the conflict to the user.

## Required sections

```markdown
# Project Constitution

> **Immutable architectural principles. Specs and code must comply. Conflicts surface to the user, never silently overridden.**

Last amended: <YYYY-MM-DD>

## Architecture
- All database access goes through `<ORM choice from stack>`. No raw SQL except in migrations.
- All API responses follow the shape `{ data: T | null, error: { code, message } | null }`.
- Auth checks live in middleware, never in route handlers.
- No business logic in components / pages. Move to `lib/` or `server/services/`.

## Security
- No secrets in code. Read from env vars only. `.env` always gitignored.
- All user input validated at the API boundary using `<validation library>`.
- No `dangerouslySetInnerHTML` (or framework equivalent) on untrusted data.
- Rate limit on every auth endpoint (login, register, password reset).

## Testing
- Every API endpoint has at least 1 contract test.
- Critical user paths have at least 1 E2E test.
- Tests live next to the code they test (`foo.ts` → `foo.test.ts`) OR in `tests/` mirroring `src/`.
- Don't disable failing tests. Fix the test or fix the code.

## Code style
- File naming: <kebab-case / PascalCase / etc.>
- Function naming: <camelCase>
- No default exports for components (named only).
- Error handling: only at boundaries. Trust internal calls.
- No comments explaining *what* code does. Only *why* if non-obvious.

## Git
- Every task is one commit with `[<agent>] <task title>`.
- No force-push to main.
- `.env` files never committed.
- Branch naming: <e.g., feature/<task-id>>

## Scope discipline
- Agents only modify files in their stated `Outputs`. No drive-by refactors.
- New deps require justification in the runlog (which task needs it, why nothing existing fits).
- Don't add features not in a spec. If you spot a gap, surface it as a new task.

## Process
- All conversation in Traditional Chinese; all code/specs/commits in English.
- Spec is the source of truth. Code that drifts from spec → run /sync-spec.
- Every implementation task ends with code-reviewer PASS before commit.

## Amendments
This file is amended only by explicit user request, never by agents. To amend, the user runs `/discuss-project` mentioning the change, or edits this file directly. Amendment history below:

- <YYYY-MM-DD>: Initial version (drafted by /decide-stack from <stack choices>).
```

## Filling rules

- **Drafted during `/decide-stack`** — once the stack is chosen, generate this file with stack-specific rules pre-filled.
- **One bullet, one rule.** No paragraphs. Rules must be unambiguous and testable.
- **Aim for 30–60 rules total.** More than that is unmemorable; fewer leaves gaps.
- **Every rule has a falsifiable interpretation.** "Code should be clean" is not a rule. "No function longer than 50 lines" is.

## What NOT to put here

- Tech choices (those are in `specs/00-stack.md`)
- Feature decisions (those are in `specs/01-overview.md`)
- Schema design (`specs/10-database.md`)
- Anything that might genuinely change project-to-project — only put what's a hard rule for THIS project's life

## How agents use it

Every agent's prompt template starts with:

> **Read `specs/CONSTITUTION.md` first. If your task conflicts with it, stop and report. Constitution > spec > your judgment.**

`code-reviewer` checks the diff against the constitution as part of every review.
