# Release

Canonical release flow for dataenginex. Claude must show the staged diff and wait for
explicit approval before executing any commit.

## Prerequisites

- All tests passing: `uv run poe check-all`
- On a `feature/*` or `fix/*` branch (not directly on `dev` or `main`)

## Steps

1. **Bump version** (choose one):

   ```bash
   uv run poe version-patch   # bug fixes
   uv run poe version-minor   # new features
   uv run poe version-major   # breaking changes
   ```

1. **Stage the version bump files**

   ```bash
   git add pyproject.toml uv.lock CHANGELOG.md
   git diff --staged
   ```

1. **STOP — show diff and request explicit approval before committing.**
   Do not proceed until the user approves the staged changes.

1. **Commit with author identity** (after approval only):

   ```bash
   git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
     -m "chore: bump version to $(python3 -c "import tomllib; print(tomllib.load(open('pyproject.toml','rb'))['project']['version'])")"
   ```

1. **Push branch and open PR to `dev`**

   ```bash
   git push -u origin HEAD
   gh pr create --base dev --title "chore: release vX.Y.Z" --body "Version bump"
   ```

1. **After dev PR merges — open PR `dev` → `main`**

   ```bash
   gh pr create --base main --head dev --title "release: vX.Y.Z" --body "Release vX.Y.Z"
   ```

1. **After main PR merges — create GitHub Release**

   ```bash
   VERSION=$(python3 -c "import tomllib; print(tomllib.load(open('pyproject.toml','rb'))['project']['version'])")
   gh release create "dataenginex-v${VERSION}" --generate-notes --title "dataenginex v${VERSION}"
   ```

1. **Monitor PyPI publish**

   ```bash
   gh run list --workflow=pypi-publish.yml --limit 5
   ```
