#!/usr/bin/env bash
# bump-version.sh PART [PYPROJECT]
#
# Bumps semantic version in pyproject.toml.
# PART: patch | minor | major
# PYPROJECT: path to pyproject.toml (default: pyproject.toml in CWD)
#
# Usage (from any repo root via poe):
#   uv run poe version-patch
#   uv run poe version-minor
#   uv run poe version-major

set -euo pipefail

PART=${1:-patch}
PYPROJECT=${2:-pyproject.toml}

if [ ! -f "$PYPROJECT" ]; then
    echo "Error: $PYPROJECT not found. Run from a repo root." >&2
    exit 1
fi

# Read current version via Python tomllib (stdlib since 3.11)
CURRENT=$(python3 -c "
import tomllib
with open('$PYPROJECT', 'rb') as f:
    t = tomllib.load(f)
print(t['project']['version'])
")

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$PART" in
    patch) PATCH=$((PATCH + 1)) ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    *) echo "Usage: bump-version.sh [patch|minor|major]" >&2; exit 1 ;;
esac

NEW="$MAJOR.$MINOR.$PATCH"

# Update version = "..." in pyproject.toml (first occurrence only)
python3 -c "
import re
content = open('$PYPROJECT').read()
new = re.sub(r'^version = \"[^\"]+\"', f'version = \"$NEW\"', content, count=1, flags=re.MULTILINE)
open('$PYPROJECT', 'w').write(new)
"

echo "✓ $CURRENT → $NEW  ($PYPROJECT)"
echo "$NEW"
