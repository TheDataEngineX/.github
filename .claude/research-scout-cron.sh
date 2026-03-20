#!/usr/bin/env bash
# research-scout-cron.sh
# Called by SessionStart hook. Checks timestamps and injects a context
# reminder into the session when a daily scout or weekly promotion is due.

set -euo pipefail

# All paths relative to this script's directory — no hardcoded paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_FILE="$SCRIPT_DIR/memory/research-scout-staging.md"

LOGS_DIR="$HOME/.claude/logs"
DAILY_STAMP="$LOGS_DIR/research-scout-last-daily.txt"
WEEKLY_STAMP="$LOGS_DIR/research-scout-last-weekly.txt"
mkdir -p "$LOGS_DIR"

now=$(date +%s)
context=""

# --- Daily check (86400 s = 24 h) ---
if [[ -f "$DAILY_STAMP" ]]; then
    last=$(cat "$DAILY_STAMP")
    diff=$(( now - last ))
else
    diff=99999
fi

if [[ $diff -ge 86400 ]]; then
    echo "$now" > "$DAILY_STAMP"
    context+="RESEARCH SCOUT DAILY RUN DUE: Use the research-scout skill to hunt for new tools, strategies, announcements, and workflow changes relevant to DataEngineX. Search HN (hn.algolia.com), Reddit (r/dataengineering r/Python r/MachineLearning), GitHub trending, and official changelogs (FastAPI, Pydantic, uv, Ruff, mypy, PySpark, OpenTelemetry, Trivy, ArgoCD, Helm). Cross-reference every candidate against existing memory files and CLAUDE.md. Discard redundant findings. Write validated findings to the ## new_learnings section of $MEMORY_FILE using the format defined in the research-scout skill."
fi

# --- Weekly check (604800 s = 7 days) ---
if [[ -f "$WEEKLY_STAMP" ]]; then
    last_w=$(cat "$WEEKLY_STAMP")
    diff_w=$(( now - last_w ))
else
    diff_w=9999999
fi

if [[ $diff_w -ge 604800 ]]; then
    echo "$now" > "$WEEKLY_STAMP"
    [[ -n "$context" ]] && context+=" | "
    context+="RESEARCH SCOUT WEEKLY PROMOTION DUE: Review all staged entries in $MEMORY_FILE ## new_learnings. For each staged entry verify confirmation from a second source. Promote confirmed findings into appropriate memory files. Update MEMORY.md index for any new files. Mark unconfirmed entries older than 14 days as expired. Output a brief summary."
fi

# Output additionalContext JSON only when something is due
if [[ -n "$context" ]]; then
    safe=$(echo "$context" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n')
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$safe"
fi
