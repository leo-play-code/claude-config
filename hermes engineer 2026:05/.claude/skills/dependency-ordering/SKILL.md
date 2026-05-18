---
name: dependency-ordering
description: Algorithm for picking the next batch of tasks to dispatch from manifest.json based on a DAG. Use inside /implement to determine ready tasks, detect cycles, and parallelize within a layer. Covers the standard layer ordering for web projects.
---

# Dependency Ordering

`/implement` runs in batches. Each batch is **all tasks whose deps are satisfied** (status `done`) right now. Within a batch, tasks run in parallel. After the batch finishes, recompute and pick the next batch.

## Algorithm

```
loop:
  ready = [t for t in manifest.tasks
           if t.status == "pending"
           and all(manifest.find(d).status == "done" for d in t.depends_on)]
  if ready is empty: break
  dispatch all ready tasks in parallel (single message, multiple Agent calls)
  await all
  update manifest with results
end loop
```

## Cycle detection

Before the loop, do a topological sort over `depends_on`. If it fails (cycle), abort and report which task ids form the cycle. Spec writers must fix the cycle before `/implement` can proceed.

## Standard layer ordering for web projects

```
arch / pm  →  db  →  api  →  be  →  fe  →  qa  →  ops  →  doc
```

- Architecture & overview specs are pre-conditions, not runnable tasks (they're produced during `/generate-specs`, not `/implement`).
- Tests for layer N can run in parallel with layer N+1 implementation. Encode this by setting `qa-XXX.depends_on = [be-XXX]` (the thing being tested), not on the next layer.
- DevOps can run in parallel with most things once `arch` is set. Encode minimum deps.

## Parallelism caps

Don't dispatch more than 4 agents in one batch. If a batch is bigger than 4, split it: dispatch the first 4, await, then continue. This avoids hitting tool-call limits and makes failure easier to debug.

## What blocks what — defaults the spec writer should follow

| Task type | Typically depends on |
|---|---|
| `db-*` | nothing (or earlier db tasks) |
| `api-*` | the `db-*` tasks defining tables it references |
| `be-*` | the `api-*` task defining its endpoint + the `db-*` for its data |
| `fe-*` | the `api-*` task whose endpoint it calls (impl can be mocked) |
| `qa-*` | the implementation task it tests |
| `ops-*` | nothing strictly, but realistically late |
| `doc-*` | last — needs everything else done |

## Edge case: a `blocked` task in the middle of the DAG

`blocked` is treated as not-done. Its descendants stay pending and won't run until user `/resume`s or manually flips status to done after a fix.
