#!/bin/bash
# Session log hook — appends a row to docs/session-logs/YYYY-MM-DD.md
# Called on session end by Claude Code hooks

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/docs/session-logs"
TODAY=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/$TODAY.md"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

# Read hook input from stdin if available
TASK_DESC="Manual session"
if [ -t 0 ]; then
  : # No stdin, use default
else
  INPUT=$(cat)
  if [ -n "$INPUT" ]; then
    # Extract first line as task description, truncate to 80 chars
    TASK_DESC=$(echo "$INPUT" | head -1 | cut -c1-80)
  fi
fi

# Create log file with header if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
  mkdir -p "$LOG_DIR"
  cat > "$LOG_FILE" << 'HEADER'
# Session Log

| Time (UTC) | Task | Agent/Skill | Model |
|------------|------|-------------|-------|
HEADER
fi

# Append the session row
echo "| $TIMESTAMP | $TASK_DESC | main | - |" >> "$LOG_FILE"
