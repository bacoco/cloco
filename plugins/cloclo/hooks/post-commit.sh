#!/usr/bin/env bash
# CLoClo PostToolUse hook — remind to update wiki after git commits
# Only fires on Bash tool calls containing "git commit".
# Lightweight: just a context nudge, not a full wiki operation.

# No set -e: hooks must never crash
set -o pipefail 2>/dev/null || true

INPUT=$(cat)

# Kill switch
PROJECT_DIR_CHECK=$(echo "$INPUT" | python3 -c "import sys,json,os; print(json.load(sys.stdin).get('cwd',os.getcwd()))" 2>/dev/null || pwd)
[ -f "$PROJECT_DIR_CHECK/.cloclo-disabled" ] && exit 0

# Extract command
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tool_input = data.get('tool_input', {})
if isinstance(tool_input, dict):
    print(tool_input.get('command', ''))
elif isinstance(tool_input, str):
    print(tool_input)
" 2>/dev/null || echo "")

# Only trigger on git commit
if ! echo "$COMMAND" | grep -qE 'git commit'; then
  exit 0
fi

# Find project directory — try cwd from JSON input, then os.getcwd(), then pwd
PROJECT_DIR=$(echo "$INPUT" | python3 -c "
import sys, json, os
data = json.load(sys.stdin)
print(data.get('cwd', os.getcwd()))
" 2>/dev/null || pwd)

# Try project dir and git root
for dir in "$PROJECT_DIR" "$(git -C "$PROJECT_DIR" rev-parse --show-toplevel 2>/dev/null)"; do
  if [ -f "$dir/wiki/schema.md" ] 2>/dev/null; then
    REMINDER="CLoClo: Commit detected. If this was a significant change, update relevant wiki pages (entities, concepts, decisions)."
    REMINDER_ESCAPED=$(echo "$REMINDER" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null)
    printf '{"additionalContext":%s}\n' "$REMINDER_ESCAPED"
    exit 0
  fi
done
