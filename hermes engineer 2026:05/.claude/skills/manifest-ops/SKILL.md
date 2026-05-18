---
name: manifest-ops
description: Schema and operations for state/manifest.json — the single source of truth for task progress. Use whenever the orchestrator (/implement, /status, /resume, /feature, /fix, /reset-task) reads or writes manifest. Covers schema, atomic write recipe, status transitions, kind field for distinguishing initial/feature/fix tasks, and append-only growth.
---

# Manifest Operations

`state/manifest.json` is the source of truth. Specs are for humans; manifest is for the orchestrator.

## Schema

```json
{
  "version": 2,
  "created_at": "2026-05-02T12:00:00Z",
  "updated_at": "2026-05-02T12:00:00Z",
  "tasks": [
    {
      "id": "db-001",
      "kind": "initial",
      "spec": "specs/10-database.md",
      "title": "Create users table with email/password",
      "agent": "database-engineer",
      "depends_on": [],
      "status": "pending",
      "artifacts": [],
      "started_at": null,
      "finished_at": null,
      "error": null,
      "commit_sha": null,
      "review_notes": null,
      "added_at": "2026-05-02T12:00:00Z",
      "added_by": "/generate-specs"
    }
  ]
}
```

## Field reference

| Field | Type | Notes |
|---|---|---|
| `id` | string | Unique. Format `<layer>-<seq>`. Layer: `pm/arch/db/api/be/fe/qa/ops/doc`. Seq is per-layer monotonic. |
| `kind` | enum | `initial` (from `/generate-specs`), `feature` (from `/feature`), `fix` (from `/fix`). Default `initial` if missing. |
| `spec` | string | Path to the spec section that authorized this task. |
| `title` | string | Imperative title from spec. |
| `agent` | string | Subagent name to dispatch. |
| `depends_on` | string[] | Task ids that must be `done` first. |
| `status` | enum | `pending / running / done / blocked` |
| `artifacts` | string[] | Files the agent created/modified. Filled on completion. |
| `started_at` / `finished_at` | string \| null | UTC ISO. |
| `error` | string \| null | If blocked, the failure reason + worktree path if any. |
| `commit_sha` | string \| null | Set by `/implement` when the task is committed. |
| `review_notes` | string \| null | code-reviewer's PASS_WITH_NOTES summary. |
| `added_at` | string | When this task was added to the manifest. Useful for audit. |
| `added_by` | string | Which command added it (`/generate-specs`, `/feature`, `/fix`, manual). |

## Status values & transitions

| Status | Meaning | Set by |
|---|---|---|
| `pending` | Not started | `/generate-specs`, `/feature`, `/fix`, `/resume`, `/reset-task` |
| `running` | Currently dispatched | `/implement` at dispatch |
| `done` | Agent finished + reviewer passed + commit made | `/implement` after success |
| `blocked` | Agent failed or reviewer rejected | `/implement` on failure |

Allowed transitions:

```
pending  → running → done
pending  → running → blocked
blocked  → pending  (via /resume)
done     → pending  (via /reset-task — only if user explicitly chose)
done     → done     (idempotent re-run is a no-op)
```

## Atomic write recipe

Always write via temp file + rename:

```bash
TS=$(date -u +%Y%m%dT%H%M%SZ)
cp state/manifest.json state/manifest.json.bak  # one-shot backup before risky op
# ... build new content ...
echo "$NEW" > state/manifest.json.tmp
mv state/manifest.json.tmp state/manifest.json
```

When using `jq` to patch a specific task:

```bash
jq --arg id "$TASK_ID" --arg status "done" \
   '.tasks |= map(if .id == $id then .status = $status | .finished_at = (now | todate) else . end) | .updated_at = (now | todate)' \
   state/manifest.json > state/manifest.json.tmp
mv state/manifest.json.tmp state/manifest.json
```

## Adding tasks (append-only)

`/feature`, `/fix`, and `/generate-specs --incremental` add tasks WITHOUT touching existing tasks:

```bash
# Compute next available seq for a layer (e.g., be-)
PREFIX="be"
NEXT=$(jq -r --arg p "$PREFIX" '
  [.tasks[] | select(.id | startswith($p + "-"))
            | .id | sub("^" + $p + "-"; "") | tonumber]
  | (max // 0) + 1
' state/manifest.json)
NEW_ID=$(printf "%s-%03d" "$PREFIX" "$NEXT")

# Append new task
jq --argjson new "$NEW_TASK_JSON" \
   '.tasks += [$new] | .updated_at = (now | todate)' \
   state/manifest.json > state/manifest.json.tmp
mv state/manifest.json.tmp state/manifest.json
```

The new task's `id` must NOT collide with any existing task. The seq computation above guarantees that.

## Finding tasks

- "What's ready to run?" → `status==pending` AND every id in `depends_on` exists AND those tasks have `status==done`
- "What's blocked?" → `status==blocked`
- "What was added in last `/feature` call?" → filter by `added_by == "/feature"` ordered by `added_at`
- "How many fixes done in last 30 days?" → `kind == "fix"` AND `status == "done"` AND `finished_at` within 30 days

## Migration: pre-v2 manifests

Manifests written by older `/generate-specs` may lack `kind`, `added_at`, `added_by`. Treat missing fields as:
- `kind` → `"initial"`
- `added_at` → `created_at` of the manifest
- `added_by` → `"/generate-specs"`

`/implement` and `/status` must tolerate missing fields gracefully. `/feature` and `/fix` always set them when adding new tasks.

## Reset semantics (used by `/reset-task`)

When a task is reset from `done` → `pending`:
- Keep `id`, `kind`, `spec`, `title`, `agent`, `depends_on`, `added_at`, `added_by`, `artifacts`
- Clear `status` → `pending`, `started_at` → null, `finished_at` → null, `error` → null, `commit_sha` → null, `review_notes` → null
- The decision of whether to revert/reset the related git commit is separate from manifest state

## artifacts field

List of file paths the agent created/modified. Filled by the agent on completion. Used by `code-reviewer` to know what diff to look at and by `/reset-task` to know what to potentially revert.
