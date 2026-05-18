#!/bin/bash
# Stop hook. Sanity-check workflow state when a session ends.
# Print warnings to stderr — they're shown to the user but don't block.

set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MANIFEST="$PROJECT_DIR/state/manifest.json"

if [ ! -f "$MANIFEST" ]; then
  exit 0
fi

# Check for stuck "running" tasks — means /implement crashed mid-batch
RUNNING=$(python3 -c "
import json,sys
try:
  d=json.load(open('$MANIFEST'))
  ids=[t['id'] for t in d.get('tasks',[]) if t.get('status')=='running']
  print(','.join(ids))
except Exception:
  pass
" 2>/dev/null || echo "")

if [ -n "$RUNNING" ]; then
  echo "" >&2
  echo "⚠️  Workflow warning: tasks left in 'running' state: $RUNNING" >&2
  echo "    Last /implement run likely crashed. Run /status to inspect, then" >&2
  echo "    manually flip those tasks to 'pending' or 'done' before continuing." >&2
  echo "" >&2
fi

# Detect orphan git worktrees (typically left behind by failed /implement tasks).
# Print a hint, but do NOT auto-remove — Leo may want to inspect dirty changes.
if command -v git >/dev/null 2>&1 && git -C "$PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  ORPHANS=$(git -C "$PROJECT_DIR" worktree list --porcelain 2>/dev/null \
    | awk '/^worktree /{print $2}' \
    | grep -vF "$PROJECT_DIR" \
    || true)
  if [ -n "$ORPHANS" ]; then
    COUNT=$(echo "$ORPHANS" | wc -l | tr -d ' ')
    echo "" >&2
    echo "ℹ️  Found $COUNT orphan git worktree(s) (probably from failed /implement tasks):" >&2
    while IFS= read -r path; do
      [ -z "$path" ] && continue
      echo "    $path" >&2
    done <<< "$ORPHANS"
    echo "" >&2
    echo "    Inspect: cd <path> && git status" >&2
    echo "    Remove:  git worktree remove <path>   (add --force if dirty)" >&2
    echo "    Bulk:    /resume   (will offer to clean up)" >&2
    echo "" >&2
  fi
fi

# Layer 2: surface staged learnings from blocked tasks
PENDING_LEARNINGS="$PROJECT_DIR/state/pending-learnings.md"
if [ -f "$PENDING_LEARNINGS" ]; then
  ENTRY_COUNT=$(grep -c '^## Learning:' "$PENDING_LEARNINGS" 2>/dev/null || echo "0")
  if [ "${ENTRY_COUNT:-0}" -gt 0 ] 2>/dev/null; then
    echo "" >&2
    echo "📚  $ENTRY_COUNT pending learning(s) from blocked tasks." >&2
    echo "    Review:  state/pending-learnings.md" >&2
    echo "    Promote worthy entries to AGENTS.md, then delete them from the staging file." >&2
    echo "" >&2
  fi
fi

# Layer 1: remind Claude to save session findings to memory
echo "" >&2
echo "💡  End of session: save key findings, decisions, or patterns to project memory." >&2
echo "" >&2

exit 0
