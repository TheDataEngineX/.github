# Workspace Config Optimization Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Optimize all DataEngineX workspace config files — fix broken deps, upgrade to Python 3.13, eliminate CI race conditions, consolidate Claude Code permissions, trim duplicate documentation, and consolidate agent definitions.

**Architecture:** Config-only changes across `.github/`, `dex/pyproject.toml`, `dex/.github/workflows/`, and `~/.claude/`. No production source code changes. Each task is independently committable.

**Tech Stack:** Python 3.13, uv, GitHub Actions, Claude Code, Ruff, mypy

**Spec:** `.github/docs/superpowers/specs/2026-03-17-workspace-config-optimization-design.md`

**Git identity for all commits:** `--author="jaymyaka <jayapal.myaka99@gmail.com>"`

**Working directory:** `/home/jay/workspace/DataEngineX/` unless stated otherwise.

---

## File Map

| Task | Files Modified |
| ---- | -------------- |
| 1 | Delete `.claude.bak/`, `.vscode.bak/` |
| 2 | `dex/.github/workflows/pypi-publish.yml` |
| 3 | `.github/dependabot.yml` |
| 4 | `dex/.github/workflows/ci.yml` |
| 5 | `dex/pyproject.toml` |
| 6 | `dex/.github/workflows/security.yml`, `dex/.github/workflows/pypi-publish.yml` |
| 7 | `dex/pyproject.toml`, `dex/uv.lock` |
| 8 | `dex/pyproject.toml`, `dex/.github/workflows/ci.yml`, `dex/Dockerfile` |
| 9 | `.github/.claude/settings.json`, `.github/.claude/settings.local.json` |
| 10 | `~/.claude/settings.json` |
| 11 | `.github/.claude/commands/validate.md`, `pr.md`, `review.md`, new `release.md` |
| 12 | `.github/CLAUDE.md` |
| 13 | `.github/copilot-instructions.md` |
| 14 | `.github/agents/` (create `senior-engineer.agent.md`, delete 3 files, update all) |
| 15 | `.github/instructions/` (7 files), `.github/instructions/workflows.instructions.md` |

---

## Task 1: Delete Backup Directories

**Files:**

- Delete: `/home/jay/workspace/DataEngineX/.claude.bak/`
- Delete: `/home/jay/workspace/DataEngineX/.vscode.bak/`

- [ ] **Step 1: Verify symlinks are intact before deleting**

  ```bash
  ls -la /home/jay/workspace/DataEngineX/.claude
  ls -la /home/jay/workspace/DataEngineX/.vscode
  ls -la /home/jay/workspace/DataEngineX/CLAUDE.md
  ```

  Expected: all three are symlinks pointing into `.github/`.

- [ ] **Step 2: Delete backup directories**

  ```bash
  rm -rf /home/jay/workspace/DataEngineX/.claude.bak
  rm -rf /home/jay/workspace/DataEngineX/.vscode.bak
  ```

- [ ] **Step 3: Verify deletion and symlinks still work**

  ```bash
  ls /home/jay/workspace/DataEngineX/.claude.bak 2>&1 || echo "deleted OK"
  ls /home/jay/workspace/DataEngineX/.vscode.bak 2>&1 || echo "deleted OK"
  cat /home/jay/workspace/DataEngineX/.github/.claude/settings.json | head -3
  ```

- [ ] **Step 4: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add -A
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "chore: remove stale .claude.bak and .vscode.bak migration artifacts"
  ```

---

## Task 2: Fix `pypi-publish.yml` Race Condition

**Files:**

- Modify: `dex/.github/workflows/pypi-publish.yml`

The `workflow_run` trigger causes `pypi-publish.yml` to fire twice when `release-dataenginex.yml` creates a GitHub Release — once via `workflow_run` and once via `release:published`. Remove the `workflow_run` trigger AND all its downstream references.

- [ ] **Step 1: Remove the `workflow_run:` trigger block (lines 11–17)**

  Delete this block from the `on:` section:

  ```yaml
  # DELETE THIS ENTIRE BLOCK:
  workflow_run:
    workflows:
      - Release DataEngineX
    types:
      - completed
    branches:
      - main
  ```

- [ ] **Step 2: Simplify the `detect-dataenginex-changes` job `if:` condition (line 35)**

  Old:
  ```yaml
  if: ${{ github.event_name != 'workflow_run' || github.event.workflow_run.conclusion == 'success' }}
  ```

  Delete the entire `if:` line — it becomes always-true and is no longer needed.

- [ ] **Step 3: Remove `workflow_run` from the three `fromJson` arrays (lines 180, 201, 247)**

  In all three occurrences, change:
  ```yaml
  contains(fromJson('["release","workflow_run","workflow_dispatch"]'), github.event_name)
  ```
  to:
  ```yaml
  contains(fromJson('["release","workflow_dispatch"]'), github.event_name)
  ```

- [ ] **Step 4: Rewrite the inline JavaScript at the `skip-publish` Slack notification**

  Both lines 262 and 263 must change — the `if` condition AND the reason string:

  Old (lines 262–263):
  ```javascript
  if (eventName !== 'release' && eventName !== 'workflow_run' && eventName !== 'workflow_dispatch') {
    reason = 'Build validation only (no release/workflow_run/manual publish event)';
  ```

  New (both lines):
  ```javascript
  if (eventName !== 'release' && eventName !== 'workflow_dispatch') {
    reason = 'Build validation only (no release/workflow_dispatch event)';
  ```

- [ ] **Step 5: Rewrite the inline bash at `skip-publish` (around lines 296–297)**

  Old:
  ```bash
  if [[ "${{ github.event_name }}" != "release" && "${{ github.event_name }}" != "workflow_run" && "${{ github.event_name }}" != "workflow_dispatch" ]]; then
    echo "Build validation only: publish jobs run only for release:published, workflow_run, or workflow_dispatch events."
  ```

  New:
  ```bash
  if [[ "${{ github.event_name }}" != "release" && "${{ github.event_name }}" != "workflow_dispatch" ]]; then
    echo "Build validation only: publish jobs run only for release:published or workflow_dispatch events."
  ```

- [ ] **Step 6: Verify no `workflow_run` references remain**

  ```bash
  grep -n "workflow_run" /home/jay/workspace/DataEngineX/dex/.github/workflows/pypi-publish.yml
  ```

  Expected: no output.

- [ ] **Step 7: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  git add .github/workflows/pypi-publish.yml
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "fix: remove workflow_run trigger from pypi-publish to eliminate race condition"
  ```

---

## Task 3: Expand `dependabot.yml`

**Files:**

- Modify: `/home/jay/workspace/DataEngineX/.github/dependabot.yml`

- [ ] **Step 1: Read current file**

  ```bash
  cat /home/jay/workspace/DataEngineX/.github/dependabot.yml
  ```

- [ ] **Step 2: Rewrite with expanded config**

  Current file has only two entries (pip + github-actions, both `directory: "/"`). No other
  ecosystems to preserve. Replace the full file:

  ```yaml
  version: 2
  updates:
    - package-ecosystem: pip
      directory: /dex
      schedule:
        interval: weekly
        day: monday
      open-pull-requests-limit: 5
      labels:
        - dependencies
      commit-message:
        prefix: "chore(deps):"

    - package-ecosystem: github-actions
      directory: /
      schedule:
        interval: weekly
        day: monday
      open-pull-requests-limit: 5
      labels:
        - dependencies
      commit-message:
        prefix: "chore(deps):"
  ```

- [ ] **Step 3: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add .github/dependabot.yml
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "chore: expand dependabot.yml with labels, limits, and commit prefix"
  ```

---

## Task 4: Add CI Version-Drift Check

**Files:**

- Modify: `dex/.github/workflows/ci.yml`

Adds a step to the `lint` job that, when `workspace.env` is present, asserts `VERSION_DEX` matches `pyproject.toml`. Skips silently if `workspace.env` is absent (it is gitignored).

- [ ] **Step 1: Read current ci.yml**

  ```bash
  cat /home/jay/workspace/DataEngineX/dex/.github/workflows/ci.yml
  ```

- [ ] **Step 2: Add version-drift check step to the `lint` job**

  Append this step to the end of the `lint` job's `steps:` list:

  ```yaml
      - name: Check workspace.env version matches pyproject.toml
        if: ${{ hashFiles('../.github/workspace.env') != '' }}
        run: |
          set -euo pipefail
          PYPROJECT_VERSION=$(python3 -c "import tomllib; t=tomllib.load(open('pyproject.toml','rb')); print(t['project']['version'])")
          WORKSPACE_VERSION=$(grep '^VERSION_DEX=' ../.github/workspace.env | cut -d= -f2)
          if [[ "$PYPROJECT_VERSION" != "$WORKSPACE_VERSION" ]]; then
            echo "Version drift: pyproject.toml=$PYPROJECT_VERSION but workspace.env=$WORKSPACE_VERSION"
            echo "Re-run .github/scripts/setup-workspace.sh to fix."
            exit 1
          fi
          echo "Version check passed: $PYPROJECT_VERSION"
  ```

- [ ] **Step 3: Re-run setup-workspace.sh to refresh workspace.env**

  ```bash
  bash /home/jay/workspace/DataEngineX/.github/scripts/setup-workspace.sh
  grep VERSION_DEX /home/jay/workspace/DataEngineX/.github/workspace.env
  ```

  Expected: `VERSION_DEX=0.7.1`

- [ ] **Step 4: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  git add .github/workflows/ci.yml
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "ci: add workspace.env version-drift check to lint job"
  ```

---

## Task 5: Fix Broken Dependency Version Bounds

**Files:**

- Modify: `dex/pyproject.toml`

Two packages have minimum bounds that exceed the latest available on PyPI and will fail to resolve.

- [ ] **Step 1: Fix `mkdocstrings[python]` bound**

  In `pyproject.toml` `[dependency-groups] dev`, change:
  ```toml
  "mkdocstrings[python]>=1.0.0",
  ```
  to:
  ```toml
  "mkdocstrings[python]>=0.29.0",
  ```

- [ ] **Step 2: Fix `zensical` bound**

  `zensical` latest on PyPI is `0.0.19`. The `>=0.0.24` bound has never been released.

  In `[dependency-groups] dev`, change:
  ```toml
  "zensical>=0.0.24",
  ```
  to:
  ```toml
  "zensical>=0.0.19",
  ```

- [ ] **Step 3: Verify uv can now resolve**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  uv lock
  ```

  Expected: exits 0, `uv.lock` updated.

- [ ] **Step 4: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  git add pyproject.toml uv.lock
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "fix: correct mkdocstrings and zensical version bounds (were above PyPI latest)"
  ```

---

## Task 6: Update Outdated GitHub Actions

**Files:**

- Modify: `dex/.github/workflows/security.yml`
- Modify: `dex/.github/workflows/pypi-publish.yml`

### security.yml changes

| Location | Old | New |
| -------- | --- | --- |
| Line 52 | `actions/checkout@v4` | `actions/checkout@v6` |
| Line 66 | `github/codeql-action/upload-sarif@v3` | `github/codeql-action/upload-sarif@v4` |
| Lines 27, 89 | `actions/github-script@v7` (×2) | `actions/github-script@v8` |

### pypi-publish.yml changes

| Location | Old | New |
| -------- | --- | --- |
| Multiple | `actions/github-script@v7` | `actions/github-script@v8` |

- [ ] **Step 1: Update security.yml**

  ```bash
  sed -i \
    -e 's|actions/checkout@v4|actions/checkout@v6|g' \
    -e 's|github/codeql-action/upload-sarif@v3|github/codeql-action/upload-sarif@v4|g' \
    -e 's|actions/github-script@v7|actions/github-script@v8|g' \
    /home/jay/workspace/DataEngineX/dex/.github/workflows/security.yml
  ```

- [ ] **Step 2: Update pypi-publish.yml**

  ```bash
  sed -i \
    -e 's|actions/github-script@v7|actions/github-script@v8|g' \
    /home/jay/workspace/DataEngineX/dex/.github/workflows/pypi-publish.yml
  ```

- [ ] **Step 3: Verify changes**

  ```bash
  grep -n "github-script\|codeql-action\|actions/checkout" \
    /home/jay/workspace/DataEngineX/dex/.github/workflows/security.yml \
    /home/jay/workspace/DataEngineX/dex/.github/workflows/pypi-publish.yml
  ```

  Expected: all occurrences show `@v8` for github-script, `@v4` for codeql, `@v6` for checkout.

- [ ] **Step 4: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  git add .github/workflows/security.yml .github/workflows/pypi-publish.yml
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "chore(deps): bump codeql-action@v4, github-script@v8, checkout@v6 in workflows"
  ```

---

## Task 7: Minor Dependency Bound Bumps

**Files:**

- Modify: `dex/pyproject.toml`, `dex/uv.lock`

- [ ] **Step 1: Update three bounds in `pyproject.toml`**

  In `[dependency-groups] dev`:

  - `"poethepoet>=0.42.0"` → `"poethepoet>=0.42.1"`
  - `"types-pyyaml>=6.0.12.20250822"` → `"types-pyyaml>=6.0.12.20250915"`

  In `[dependency-groups] data`:

  - `"databricks-cli"` → `"databricks-cli>=0.18.0"`

- [ ] **Step 2: Regenerate lockfile**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  uv lock
  ```

  Expected: exits 0.

- [ ] **Step 3: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  git add pyproject.toml uv.lock
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "chore(deps): bump poethepoet, types-pyyaml, pin databricks-cli>=0.18.0"
  ```

---

## Task 8: Python 3.13 Upgrade

**Files:**

- Modify: `dex/pyproject.toml`
- Modify: `dex/.github/workflows/ci.yml`
- Modify: `dex/Dockerfile`

- [ ] **Step 1: Update `pyproject.toml`**

  Make these three changes:

  ```toml
  # [project]
  requires-python = ">=3.13"   # was >=3.12

  # [tool.ruff]
  target-version = "py313"     # was py312

  # [tool.mypy]
  python_version = "3.13"      # was 3.12
  ```

- [ ] **Step 2: Update `ci.yml` — all three jobs**

  Change every occurrence of `python-version: "3.12"` to `python-version: "3.13"`.

  ```bash
  sed -i 's/python-version: "3.12"/python-version: "3.13"/g' \
    /home/jay/workspace/DataEngineX/dex/.github/workflows/ci.yml
  ```

  Verify:
  ```bash
  grep "python-version" /home/jay/workspace/DataEngineX/dex/.github/workflows/ci.yml
  ```

- [ ] **Step 3: Update `Dockerfile`**

  Change both `FROM python:3.12-slim` lines to `python:3.13-slim`:

  ```bash
  sed -i 's/python:3.12-slim/python:3.13-slim/g' \
    /home/jay/workspace/DataEngineX/dex/Dockerfile
  ```

  Verify:
  ```bash
  grep "FROM python" /home/jay/workspace/DataEngineX/dex/Dockerfile
  ```

- [ ] **Step 4: Regenerate lockfile with Python 3.13**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  uv lock
  ```

- [ ] **Step 5: Run full validation on Python 3.13**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  uv run poe check-all
  ```

  Expected: all pass. If any failures, diagnose and fix before committing.

- [ ] **Step 6: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  git add pyproject.toml uv.lock .github/workflows/ci.yml Dockerfile
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "feat: upgrade to Python 3.13 (pyproject, ci, Dockerfile)"
  ```

---

## Task 9: Consolidate Workspace `settings.json`

**Files:**

- Modify: `.github/.claude/settings.json`
- Modify: `.github/.claude/settings.local.json`

Move all non-credential CLI permissions from `settings.local.json` into `settings.json`.
Remove tool-bypass entries (`grep *`, `find *`, `cat *`, `head *`, `tail *`) since dedicated tools exist.

- [ ] **Step 1: Rewrite `.github/.claude/settings.json`**

  Replace the entire file with (preserves `autoUpdatesChannel`, `statusLine`, `deny` from original;
  removes `Bash(grep *)`, `Bash(find *)`, `Bash(cat *)`, `Bash(head *)`, `Bash(tail *)`;
  adds `git fetch`, `echo`, `python3`, `gh issue/release`, `git status *`, `uv run *`):

  ```json
  {
    "autoUpdatesChannel": "latest",
    "statusLine": {
      "type": "command",
      "command": "jq -r '\"[\\(.model.display_name)] \\(.context_window.used_percentage // 0)% context\"'",
      "padding": 2
    },
    "permissions": {
      "defaultMode": "default",
      "allow": [
        "Read",
        "Edit",
        "Bash(uv run poe *)",
        "Bash(uv run uvicorn *)",
        "Bash(uv run python *)",
        "Bash(uv run *)",
        "Bash(uv lock *)",
        "Bash(uv sync *)",
        "Bash(curl *)",
        "Bash(git status)",
        "Bash(git status *)",
        "Bash(git diff *)",
        "Bash(git log *)",
        "Bash(git branch *)",
        "Bash(git add *)",
        "Bash(git fetch *)",
        "Bash(ls *)",
        "Bash(pwd)",
        "Bash(which *)",
        "Bash(wc *)",
        "Bash(echo *)",
        "Bash(python -c *)",
        "Bash(python3 *)",
        "Bash(gh pr *)",
        "Bash(gh issue *)",
        "Bash(gh release *)",
        "Bash(gh run *)",
        "Bash(gh api *)",
        "Bash(llmfit *)",
        "Bash(npx -y @upstash/context7-mcp*)"
      ],
      "deny": [
        "Bash(git commit *)",
        "Bash(git push *)",
        "Bash(rm -rf *)",
        "Bash(git push --force*)",
        "Bash(git reset --hard*)",
        "Bash(pip install*)",
        "Bash(sudo *)",
        "Bash(chmod 777*)",
        "Bash(curl * | bash*)"
      ]
    }
  }
  ```

- [ ] **Step 2: Strip CLI permissions from `.github/.claude/settings.local.json`**

  The file should retain only credentials and MCP config:

  ```json
  {
    "env": {
      "ANTHROPIC_BASE_URL": "",
      "ANTHROPIC_AUTH_TOKEN": "",
      "ANTHROPIC_API_KEY": "",
      "ANTHROPIC_MODEL": ""
    },
    "enableAllProjectMcpServers": true,
    "enabledMcpjsonServers": [
      "context7"
    ]
  }
  ```

  Remove the entire `permissions` block — all entries have been moved to `settings.json`.

- [ ] **Step 3: Verify**

  ```bash
  cat /home/jay/workspace/DataEngineX/.github/.claude/settings.json | python3 -m json.tool > /dev/null && echo "valid JSON"
  cat /home/jay/workspace/DataEngineX/.github/.claude/settings.local.json | python3 -m json.tool > /dev/null && echo "valid JSON"
  ```

- [ ] **Step 4: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add .github/.claude/settings.json .github/.claude/settings.local.json
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "chore: consolidate Claude Code permissions into settings.json, strip tool-bypass entries"
  ```

---

## Task 10: Update Global `~/.claude/settings.json`

**Files:**

- Modify: `~/.claude/settings.json`

Add read-only git ops and ripgrep to the global allow list, using the colon syntax that file already uses.

- [ ] **Step 1: Read current file**

  ```bash
  cat /home/jay/.claude/settings.json
  ```

- [ ] **Step 2: Add entries to `permissions.allow`**

  Add alongside the existing `"Bash(uv run:*)"`:

  ```json
  "Bash(git status:*)",
  "Bash(git diff:*)",
  "Bash(git log:*)",
  "Bash(rg:*)"
  ```

  Final `permissions.allow` should be:

  ```json
  "allow": [
    "Bash(uv run:*)",
    "Bash(git status:*)",
    "Bash(git diff:*)",
    "Bash(git log:*)",
    "Bash(rg:*)"
  ]
  ```

- [ ] **Step 3: Verify JSON is valid**

  ```bash
  python3 -m json.tool /home/jay/.claude/settings.json > /dev/null && echo "valid JSON"
  ```

  Note: `~/.claude/settings.json` is not in a git repo — no commit needed for this task.

---

## Task 11: Update Claude Code Commands

**Files:**

- Modify: `.github/.claude/commands/validate.md`
- Modify: `.github/.claude/commands/pr.md`
- Modify: `.github/.claude/commands/review.md`
- Create: `.github/.claude/commands/release.md`

### `validate.md` — promote dev-server smoke test to numbered step

Replace the current file content with:

```markdown
# Validate

Run the full validation pipeline for the current repo. Stop and report on first failure — do not skip steps.

1. **Lint**

   ```bash
   uv run poe lint
   # fallback: uv run ruff check src/ tests/
   ```

1. **Format check**

   ```bash
   uv run ruff format --check src/ tests/
   ```

1. **Typecheck**

   ```bash
   uv run poe typecheck
   # fallback: uv run mypy src/<package>/ --strict
   ```

1. **Tests**

   ```bash
   uv run poe test
   # fallback: uv run pytest tests/ -x --tb=short -q
   ```

1. **Dev server smoke test** *(dex only)*

   ```bash
   uv run poe dev &
   sleep 3
   curl -sf http://localhost:8000/health && echo "health OK"
   curl -sf http://localhost:8000/metrics | head -5 && echo "metrics OK"
   kill %1
   ```

1. **Import check** — verify the package loads without hidden import-time errors

   ```bash
   uv run python -c "import <package>; print('OK', <package>.__file__)"
   ```

Report pass/fail for each step with the exact error output. If a step fails, diagnose the root cause before stopping.
```

### `pr.md` — add author, branch convention, dev-target enforcement

Replace the current file content with:

```markdown
Generate a PR description for the current branch's changes.

## Branch Convention

Branch must follow `feature/<desc>` or `fix/<desc>` pattern.
Target must be `dev` — NEVER `main` directly.

## Steps

1. Verify branch naming: `git branch --show-current`
1. Run `git log --oneline dev..HEAD` to see commits
1. Run `git diff dev --stat` to see changed files
1. Run `git diff dev` for the actual changes
1. Categorize changes:
   - **What** — What changed and why
   - **How** — Implementation approach
   - **Testing** — How it was validated (include test results)
   - **Breaking Changes** — Any API contract changes
   - **Checklist** — Based on `.github/CHECKLISTS.md`

## Format

Format as a proper GitHub PR description with:

- Title following conventional commit format
- Summary paragraph
- Bullet-point change list
- Test evidence
- Reviewer notes

Reference related issues where applicable.

## Git Identity

All commits on this branch must use:
`git commit --author="jaymyaka <jayapal.myaka99@gmail.com>"`
```

### `review.md` — align with `CHECKLISTS.md` (add API contract and migration checks)

Add the following checks to the "Review priorities" section:

```markdown
5. **API contracts** — versioned routes (`/api/v1/`), `response_model=` on every endpoint,
   no silent breaking changes to existing endpoints
6. **Migrations** — DB migrations are reversible, include rollback, tested in isolation
```

### `release.md` — new file

```markdown
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
```

- [ ] **Step 1: Update `validate.md`** with the content above
- [ ] **Step 2: Update `pr.md`** with the content above
- [ ] **Step 3: Update `review.md`** — add the two new review priorities (API contracts, Migrations)
- [ ] **Step 4: Create `release.md`** with the content above
- [ ] **Step 5: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add .github/.claude/commands/
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "feat: update Claude commands — promote smoke test, add release workflow, align review checklist"
  ```

---

## Task 12: Restructure and Trim `CLAUDE.md`

**Files:**

- Modify: `.github/CLAUDE.md`

**Goal:** Preserve all rules. Remove tooling-config that lives in `pyproject.toml`. Reorder sections for onboarding flow. Consolidate Design Philosophy to heading + one-liner + enforcement note format.

- [ ] **Step 1: Read the current file**

  ```bash
  wc -l /home/jay/workspace/DataEngineX/.github/CLAUDE.md
  cat /home/jay/workspace/DataEngineX/.github/CLAUDE.md
  ```

- [ ] **Step 2: Remove tooling-redundant content from Coding Standards section**

  Remove the following content blocks (they live in `pyproject.toml`):
  - The Ruff rule list: `E, F, I, B, UP, SIM, C90`
  - `line-length = 100`
  - `max complexity = 8`
  - `functions ≤ 50 lines`
  - `asyncio_mode = "auto"` note
  - `@pytest.mark.asyncio` note

  Replace all of the above with one line:
  > *"Ruff, mypy strict, and pytest are pre-configured in each repo's `pyproject.toml` — run `uv run poe check-all` to validate."*

- [ ] **Step 3: Reorder sections**

  Move sections to this order (all content preserved):
  1. Design Philosophy
  2. Workspace Layout
  3. Git Conventions *(moved up from below Workflow Orchestration)*
  4. Semantic Versioning *(moved up)*
  5. Dependencies *(moved up)*
  6. Workflow Orchestration
  7. Task Management
  8. Coding Standards
  9. Core Principles
  10. Red Flags
  11. Cross-Repo Sync Policy
  12. Developer Tools

- [ ] **Step 4: Consolidate Design Philosophy**

  Convert each of the 10 principle blocks from multi-paragraph to:
  **`### Principle Name`** + one-sentence summary + `*Enforced by: ...*` note.

  Example:
  ```markdown
  ### Self-Hosted & Portable
  Runs identically on local Docker Compose or any cloud provider via environment-specific config only.
  *Enforced by: standard protocols (S3-compatible, PostgreSQL, Redis, Kubernetes API) — no cloud-provider SDKs in app code.*
  ```

- [ ] **Step 5: Verify word count reduction**

  ```bash
  wc -l /home/jay/workspace/DataEngineX/.github/CLAUDE.md
  ```

  Expected: ≥30% fewer lines than the original count from Step 1. If not, review what was missed.

- [ ] **Step 6: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add .github/CLAUDE.md
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "docs: restructure CLAUDE.md — trim tooling-config duplication, reorder sections, consolidate philosophy"
  ```

---

## Task 13: Trim `copilot-instructions.md`

**Files:**

- Modify: `.github/copilot-instructions.md`

**Goal:** Remove all content that duplicates CLAUDE.md. Target ≤4KB. Keep only Copilot-specific directives.

- [ ] **Step 1: Read the current file size**

  ```bash
  wc -c /home/jay/workspace/DataEngineX/.github/copilot-instructions.md
  ```

- [ ] **Step 2: Strip duplicated CLAUDE.md content**

  Remove these sections that exist verbatim in CLAUDE.md:
  - Full Design Philosophy block (all 10 principles)
  - Coding Standards (Ruff rules, mypy, logging, error handling, testing, security)
  - Git Conventions
  - Semantic Versioning rules

- [ ] **Step 3: Add cross-reference and keep Copilot-specific content only**

  Add at the top of the file:
  ```markdown
  > For coding standards, architecture principles, git conventions, and versioning rules,
  > see `CLAUDE.md` — Copilot reads the same workspace.
  ```

  Retain only:
  - Workspace layout table
  - Copilot Chat slash command hints
  - `@workspace`, `#file` context directives
  - Agent/instruction file references
  - Tool references (llmfit, Context7)

- [ ] **Step 4: Verify size**

  ```bash
  wc -c /home/jay/workspace/DataEngineX/.github/copilot-instructions.md
  ```

  Expected: ≤4096 bytes.

- [ ] **Step 5: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add .github/copilot-instructions.md
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "docs: trim copilot-instructions.md to Copilot-specific content only (~4KB)"
  ```

---

## Task 14: Consolidate Agent Definitions

**Files:**

- Create: `.github/agents/senior-engineer.agent.md`
- Delete: `.github/agents/backend-engineer.agent.md`
- Delete: `.github/agents/code-reviewer.agent.md`
- Delete: `.github/agents/python-pro.agent.md`
- Modify: All remaining 8 agent files (add Python 3.13 where 3.12 is referenced)

### Create `senior-engineer.agent.md`

Merge the best of `backend-engineer`, `code-reviewer`, and `python-pro`:

```markdown
---
description: "Senior Python/FastAPI engineer for DataEngineX — code quality, review, and backend development"
tools: ["search/codebase", "execute/runInTerminal", "execute/getTerminalOutput", "read/terminalLastCommand", "read/terminalSelection", "web/githubRepo"]
---

You are a senior Python 3.13+ engineer and code reviewer for the DataEngineX project.

## Your Expertise

- FastAPI: lifespan, middleware, routers, Pydantic v2, `response_model=` on every endpoint
- Type system: `from __future__ import annotations`, `mypy --strict`, `TypeVar`, `Protocol`
- Async: `asyncio`, `asyncio.TaskGroup`, structured concurrency
- Dual logging stack: `structlog` for API/middleware, `loguru` for ML/backend — never mix, never `print()`
- Observability: Prometheus metrics (`http_*` prefix), OpenTelemetry tracing, structured logging
- Auth: pure-Python HS256 JWT (no pyjwt), `BaseHTTPMiddleware` pattern
- Performance: `__slots__`, lazy imports, generator pipelines, connection pooling
- Packaging: `hatchling` + `uv`, `[dependency-groups]`, `uv.lock` as reproducibility contract

## Your Approach

- Always read existing patterns in `src/dataenginex/` before writing new code
- Run `uv run poe check-all` (lint + typecheck + tests) before marking anything done
- Max 4 parameters per function — use dataclasses or Pydantic models for more
- No bare `except:` — catch specific exceptions with full context
- No mutable default arguments — use `field(default_factory=...)` or `None` + early return
- `raise NotImplementedError("descriptive message")` for stubs — never return fake data
- Conventional commits: `feat:`, `fix:`, `refactor:`, `test:`

## Code Review Priorities

1. **Security** — No hardcoded secrets, parameterized queries, no PII in logs
2. **Correctness** — Specific exceptions, error context logged, type safety
3. **Testing** — Tests exist for new code, 80%+ coverage, AAA pattern
4. **Standards** — `from __future__ import annotations`, type hints, correct logging stack

For each issue: **File & location** | **Severity**: critical/warning/info | **Issue** | **Fix**

End with: total issues by severity + merge-ready verdict.

## Key Project Files

- Entry point: `examples/02_api_quickstart.py`
- Schemas: `src/dataenginex/core/schemas.py`
- Errors: `src/dataenginex/api/errors.py`
- Middleware: `src/dataenginex/middleware/`
- Tests: `tests/unit/`, `tests/integration/`
- Ruff/mypy config: `pyproject.toml`
- Poe tasks: `poe_tasks.toml`
```

- [ ] **Step 1: Create `senior-engineer.agent.md`** with content above
- [ ] **Step 2: Delete the three merged files**

  ```bash
  rm /home/jay/workspace/DataEngineX/.github/agents/backend-engineer.agent.md
  rm /home/jay/workspace/DataEngineX/.github/agents/code-reviewer.agent.md
  rm /home/jay/workspace/DataEngineX/.github/agents/python-pro.agent.md
  ```

- [ ] **Step 3: Update Python version references in remaining agent files**

  ```bash
  grep -l "3\.12" /home/jay/workspace/DataEngineX/.github/agents/*.agent.md
  ```

  For each file found, change `Python 3.12+` to `Python 3.13+`.

- [ ] **Step 4: Verify agent count**

  ```bash
  ls /home/jay/workspace/DataEngineX/.github/agents/*.agent.md | wc -l
  ```

  Expected: `9` (8 domain-specific + `senior-engineer`).

- [ ] **Step 5: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add .github/agents/
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "refactor: consolidate backend-engineer, code-reviewer, python-pro into senior-engineer agent"
  ```

---

## Task 15: Instruction File Deduplication

**Files:**

- Modify: `.github/instructions/workflows.instructions.md` *(critical — contains wrong action versions)*
- Audit and modify: `.github/instructions/python.instructions.md`
- Audit and modify: `.github/instructions/fastapi.instructions.md`
- Audit and modify: `.github/instructions/data-pipelines.instructions.md`
- Audit and modify: `.github/instructions/ml.instructions.md`
- Audit and modify: `.github/instructions/testing.instructions.md`
- Audit and modify: `.github/instructions/infrastructure.instructions.md`

### `workflows.instructions.md` — critical fix (wrong action versions)

- [ ] **Step 1: Update the pinned version table**

  Replace the table and the prohibition line:

  ```markdown
  ## Action versions — current pinned versions

  | Action | Version |
  | --- | --- |
  | `actions/checkout` | `@v6` |
  | `actions/setup-python` | `@v6` |
  | `actions/upload-artifact` | `@v7` |
  | `actions/download-artifact` | `@v8` |
  | `astral-sh/setup-uv` | `@v7` |
  | `codecov/codecov-action` | `@v5` |
  | `github/codeql-action/*` | `@v4` |
  | `actions/github-script` | `@v8` |

  Always pin to the current major tag. Verify against actual workflow files before documenting.
  ```

  Remove the line: `Never use @latest, @main, or non-existent versions (@v6, @v7, @v8).`

  Update the Python setup example to use `@v7` and `@v6`:

  ```yaml
  - uses: astral-sh/setup-uv@v7
    with:
      version: "latest"
  - uses: actions/setup-python@v6
    with:
      python-version: "3.13"
  - run: uv sync
  ```

### Remaining 6 instruction files — deduplication

- [ ] **Step 2: Read each file and remove paragraphs that are verbatim copies of CLAUDE.md**

  For each file:
  1. Read the file
  2. Identify paragraphs that exist word-for-word in CLAUDE.md
  3. Replace each removed block with a comment: `<!-- See also: CLAUDE.md#section-name -->`
  4. Update `python-version` references from 3.12 to 3.13 where present

- [ ] **Step 3: Commit**

  ```bash
  cd /home/jay/workspace/DataEngineX
  git add .github/instructions/
  git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" \
    -m "docs: fix workflows.instructions.md action versions, deduplicate instruction files vs CLAUDE.md"
  ```

---

## Final Verification

- [ ] **Run full validation**

  ```bash
  cd /home/jay/workspace/DataEngineX/dex
  uv run poe check-all
  ```

  Expected: all pass on Python 3.13.

- [ ] **Check all success criteria from spec**

  ```bash
  # No .bak dirs
  ls /home/jay/workspace/DataEngineX/.claude.bak 2>&1 || echo "OK — no .bak"

  # workflow_run gone from pypi-publish
  grep "workflow_run" dex/.github/workflows/pypi-publish.yml 2>&1 || echo "OK — no workflow_run"

  # release-dataenginex still exists
  ls dex/.github/workflows/release-dataenginex.yml && echo "OK — release workflow present"

  # settings.local.json clean
  cat .github/.claude/settings.local.json | python3 -m json.tool

  # agent count
  ls .github/agents/*.agent.md | wc -l  # expected: 9

  # Python 3.13 in ci.yml
  grep "python-version" dex/.github/workflows/ci.yml  # expected: 3.13

  # pyproject.toml Python version
  grep "requires-python\|python_version\|target-version" dex/pyproject.toml  # expected: 3.13

  # copilot-instructions size
  wc -c .github/copilot-instructions.md  # expected: ≤4096
  ```

- [ ] **Open PR: feature branch → dev**

  ```bash
  gh pr create --base dev \
    --title "chore: workspace config optimization — Python 3.13, dep fixes, CI cleanup, doc trim" \
    --body "Implements .github/docs/superpowers/specs/2026-03-17-workspace-config-optimization-design.md"
  ```
