# simplify

Review changed code for unnecessary scope, duplication, and premature abstractions — then fix what you find.

## When to invoke

After implementing a bug fix or small feature, before committing. Invoked via `/simplify`.

## Algorithm

Run these five checks against the current diff (`git diff HEAD` or staged changes):

### 1. Scope creep check
- List every file touched in the diff
- For each change, ask: "Is this required to satisfy the stated task?"
- Any change that isn't required → **surface as a new task**, do NOT include in the current diff
- Report: `SCOPE_CREEP: <file> — <what was changed and why it's out of scope>`

### 2. Duplication check
- For every new function, class, or utility introduced in the diff, grep the codebase for an existing equivalent
- If one exists → replace the new code with a call to the existing one
- Report: `DUPLICATE: <new symbol> duplicates <existing symbol at path:line>`

### 3. Abstraction check
- For every new helper function or extracted constant: count how many call sites exist
- If only 1 call site → inline it (three similar lines > premature abstraction)
- Exception: the extracted thing is tested independently, or is a named domain concept
- Report: `OVER_ABSTRACTION: <symbol> has 1 call site — inline it`

### 4. Diff size heuristic
- Count net lines changed (added + removed)
- Bug fixes: flag if > 30 lines changed without a clear reason
- Small features: flag if > 100 lines changed; verify scope
- Report: `LARGE_DIFF: <n> lines changed — confirm this is all required`

### 5. Unused code check
- Grep for any symbol introduced in the diff that has zero references elsewhere
- Dead on arrival → delete it
- Report: `DEAD_CODE: <symbol> at path:line — no references found`

## Output format

```markdown
## Simplify Report

Verdict: CLEAN | NEEDS_CHANGES

### Scope creep
- SCOPE_CREEP: <file> — <description> → move to new task

### Duplicates
- DUPLICATE: <new> duplicates <existing at path:line> → use existing

### Over-abstractions
- OVER_ABSTRACTION: <symbol> — 1 call site → inline

### Diff size
- LARGE_DIFF: <n> lines — <reason or "investigate"

### Dead code
- DEAD_CODE: <symbol> at path:line → delete

### What was fixed
- <brief list of changes made>
```

If verdict is CLEAN, nothing was changed. If NEEDS_CHANGES, apply all fixes and re-run the checks once.

## Hard rules

- Never expand scope — follow-up items go in a new task, not here
- Three similar lines is better than a premature abstraction
- Only add a comment if the why is non-obvious; never comment what the code already says
- If removing a symbol wouldn't confuse a future reader, remove it
- Don't reformat or rename things unrelated to the stated task
