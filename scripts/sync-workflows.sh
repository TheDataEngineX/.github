#!/usr/bin/env bash
# sync-workflows.sh — propagate canonical .github files from dex to all repos.
#
# These files are identical across repos. Edit the source in dex, then run this
# script to push the change everywhere. Any diff after running means a repo has
# drifted and must be reconciled.
#
# Usage:
#   bash .github/scripts/sync-workflows.sh            # dry-run (shows diffs)
#   bash .github/scripts/sync-workflows.sh --apply    # write files

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APPLY=false
[[ "${1:-}" == "--apply" ]] && APPLY=true

DRIFT_FOUND=false

check_file() {
  local src="$1" dst="$2"
  if [[ ! -f "$src" ]]; then
    echo "ERROR: canonical source missing: $src" >&2
    exit 1
  fi
  if [[ ! -f "$dst" ]]; then
    echo "MISSING  ${dst#"$ROOT/"}"
    DRIFT_FOUND=true
    if $APPLY; then
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "  → created"
    fi
    return
  fi
  if ! diff -q "$src" "$dst" > /dev/null 2>&1; then
    echo "DRIFT    ${dst#"$ROOT/"}"
    diff --unified=3 "$src" "$dst" || true
    DRIFT_FOUND=true
    if $APPLY; then
      cp "$src" "$dst"
      echo "  → synced"
    fi
  else
    echo "OK       ${dst#"$ROOT/"}"
  fi
}

# ── Group 1: shared across ALL service repos ──────────────────────────────────
# dex is the canonical source; datadex agentdex careerdex dex-studio infradex receive
for file in \
    .github/workflows/enforce-dev-to-main.yml \
    .github/workflows/security.yml \
    .github/workflows/claude.yml \
    .github/workflows/release-please.yml \
    .github/PULL_REQUEST_TEMPLATE.md \
    release-please-config.json; do
  for repo in datadex agentdex careerdex dex-studio infradex; do
    check_file "$ROOT/dex/$file" "$ROOT/$repo/$file"
  done
done

# ── Group 2: most repos (infradex excluded — has extra terraform/helm entries) ─
for repo in datadex agentdex careerdex dex-studio; do
  check_file "$ROOT/dex/.github/dependabot.yml" "$ROOT/$repo/.github/dependabot.yml"
done

# ── Group 3: Claude Code settings — source of truth is .github/.claude/settings.json ─
for repo in dex datadex agentdex careerdex dex-studio infradex; do
  check_file "$ROOT/.github/.claude/settings.json" "$ROOT/$repo/.claude/settings.json"
done

# ── Result ────────────────────────────────────────────────────────────────────
if $DRIFT_FOUND && ! $APPLY; then
  echo ""
  echo "Drift detected. Run with --apply to sync all repos."
  exit 1
elif ! $DRIFT_FOUND; then
  echo ""
  echo "All shared files are in sync."
fi
