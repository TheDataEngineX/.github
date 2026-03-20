#!/usr/bin/env bash
# memory-consolidate-cron.sh
# Called by SessionStart hook. Fires once per night (86400s).
# Injects a consolidate-memory prompt into the session context when due.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$SCRIPT_DIR/memory"

LOGS_DIR="$HOME/.claude/logs"
STAMP="$LOGS_DIR/memory-consolidate-last.txt"
mkdir -p "$LOGS_DIR"

now=$(date +%s)

if [[ -f "$STAMP" ]]; then
    last=$(cat "$STAMP")
    diff=$(( now - last ))
else
    diff=99999
fi

if [[ $diff -ge 86400 ]]; then
    echo "$now" > "$STAMP"
    msg="MEMORY CONSOLIDATION DUE: Use the consolidate-memory skill to read the last 24h of conversation logs, extract key decisions, preferences, and facts, update $MEMORY_DIR/recent-memory.md and $MEMORY_DIR/project-memory.md, and promote confirmed patterns into $MEMORY_DIR/long-term-memory.md. Prune recent-memory.md entries older than 48h. Print a brief summary when done."
    safe=$(echo "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$safe"
fi
