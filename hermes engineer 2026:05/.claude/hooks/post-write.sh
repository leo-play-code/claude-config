#!/bin/bash
# PostToolUse hook for Write/Edit. Read tool input from stdin, log activity, run formatter if configured.
# Non-blocking — exit 0 always so it never breaks the agent.

set -e

# Read JSON payload from stdin
PAYLOAD=$(cat)

# Extract file path (best-effort; fail silent if not present)
FILE_PATH=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only act on files inside the project root (CLAUDE_PROJECT_DIR is set by the runtime)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "$FILE_PATH" in
  "$PROJECT_DIR"/*) ;;
  *) exit 0 ;;
esac

# Skip files inside .claude/, state/, specs/, discussion/ — those are workflow infra, not product code
case "$FILE_PATH" in
  *"/.claude/"*) exit 0 ;;
  *"/state/"*) exit 0 ;;
  *"/specs/"*) exit 0 ;;
  *"/discussion/"*) exit 0 ;;
  *"/node_modules/"*) exit 0 ;;
esac

# Append to daily activity log (helps /status see what's been touched)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
LOG_DIR="$PROJECT_DIR/state/activity"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date -u +%Y-%m-%d).log"
echo "$TS  $FILE_PATH" >> "$LOG_FILE"

# Best-effort format depending on file extension and what the project has installed
EXT="${FILE_PATH##*.}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs|json|md|yml|yaml|css|scss|html)
    if [ -f "package.json" ] && command -v npx >/dev/null 2>&1; then
      npx --no-install prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$FILE_PATH" 2>/dev/null || true
    elif command -v black >/dev/null 2>&1; then
      black -q "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
