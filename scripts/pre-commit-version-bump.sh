#!/usr/bin/env bash
# pre-commit-version-bump.sh
#
# Git pre-commit hook: auto-bump patch version if pyproject.toml version
# was not manually changed since HEAD.
#
# Install via: uv run poe install-hooks
# Installed to: .git/hooks/pre-commit
#
# Behavior:
#   - Reads version from HEAD:pyproject.toml (last committed)
#   - Reads version from index (:pyproject.toml) (about to be committed)
#   - If same → bumps patch in pyproject.toml + .release-please-manifest.json
#               and re-stages both files
#   - If different → user manually changed it; do nothing

set -euo pipefail

PYPROJECT="pyproject.toml"
MANIFEST=".release-please-manifest.json"

# Nothing to do on initial commit (no HEAD yet)
if ! git rev-parse --verify HEAD > /dev/null 2>&1; then
  exit 0
fi

# Read version from last committed state
HEAD_VERSION=$(git show HEAD:"$PYPROJECT" 2>/dev/null \
  | grep -m1 '^version = ' \
  | sed 's/version = "//;s/".*//' \
  || true)

if [[ -z "$HEAD_VERSION" ]]; then
  exit 0
fi

# Read version from the index (what's staged right now)
STAGED_VERSION=$(git show :"$PYPROJECT" 2>/dev/null \
  | grep -m1 '^version = ' \
  | sed 's/version = "//;s/".*//' \
  || echo "$HEAD_VERSION")

# Version was manually changed — respect it
if [[ "$STAGED_VERSION" != "$HEAD_VERSION" ]]; then
  exit 0
fi

# Version unchanged — auto-bump patch
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEW_VERSION=$(bash "$SCRIPT_DIR/bump-version.sh" patch "$PYPROJECT" | tail -n1)

# Sync .release-please-manifest.json if it exists
if [[ -f "$MANIFEST" ]]; then
  python3 - "$MANIFEST" "$HEAD_VERSION" "$NEW_VERSION" <<'EOF'
import sys, json, re

manifest_path, old_ver, new_ver = sys.argv[1], sys.argv[2], sys.argv[3]
content = open(manifest_path).read()
updated = content.replace(f'"{old_ver}"', f'"{new_ver}"')
open(manifest_path, 'w').write(updated)
EOF
  git add "$MANIFEST"
fi

git add "$PYPROJECT"
echo "auto-bumped version: $HEAD_VERSION → $NEW_VERSION"
