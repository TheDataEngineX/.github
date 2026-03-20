# Workspace Config Optimization — Design Spec

> **STATUS: HISTORICAL** — Implemented March 2026. Release flow, version bump tasks (`version-patch/minor/major`), and `dataenginex-v` tag format documented here are superseded. Current state: release-please automation, `v{version}` tags, pre-commit hook for version bumps.

**Date:** 2026-03-17
**Author:** jaymyaka
**Scope:** `.github/`, `.claude/`, `.vscode/`, global `~/.claude/`, workspace root config files

---

## Goal

Optimize all workspace configuration files across three axes:

1. **Housekeeping** — remove stale artifacts, fix version drift, fix release workflow race condition
2. **Claude Code config** — consolidate permissions, align commands with actual workflows, add missing flows
3. **Content quality** — reduce CLAUDE.md redundancy with enforced tooling config, shrink
   copilot-instructions, consolidate overlapping agent definitions

All existing rules are preserved. Sections that duplicate what Ruff/mypy/pytest config already
enforces are removed from prompt files (they add noise without adding value).

---

## Section 1: Housekeeping

### 1.1 Delete Backup Directories

- **Delete** `/home/jay/workspace/DataEngineX/.claude.bak/`
- **Delete** `/home/jay/workspace/DataEngineX/.vscode.bak/`
- **Reason:** Migration to centralized `.github/` with symlinks is complete. Backups are stale and
  misleading. `setup-workspace.sh` only creates `.bak` directories when it finds a real (non-symlink)
  directory at the target path, which cannot happen on a clean clone — safe to delete permanently.

### 1.2 Fix `workspace.env` Version Staleness

- **Problem:** `workspace.env` shows `VERSION_DEX=0.6.1`; actual version is `0.7.1`.
- **Root cause:** `setup-workspace.sh` is correct — it already uses `tomllib` via Python to read
  `[project].version` from each `pyproject.toml`. The stale value exists because the script was not
  re-run after the 0.7.1 release (VSCode's `folderOpen` task should have caught this).
- **Fix (two-part):**
  1. Re-run `setup-workspace.sh` now to regenerate `workspace.env` with current versions.
  2. Add a step to the `lint` job in `dex/.github/workflows/ci.yml` that, when `workspace.env`
     is present, asserts `VERSION_DEX` matches the `version` in `pyproject.toml`. Skip silently
     if `workspace.env` is absent (it is gitignored and will not exist in CI or fresh clones —
     this check is only meaningful in the developer's local environment).
- **Do NOT change** the `tomllib`-based extraction logic — it is correct.

### 1.3 Fix Race Condition in Release Workflows

- **Keep:** Both `dex/.github/workflows/release-dataenginex.yml` AND
  `dex/.github/workflows/pypi-publish.yml`
- **Problem:** `pypi-publish.yml` has two simultaneous automatic triggers — `release:published`
  AND `workflow_run` (on "Release DataEngineX"). Flow: push to main →
  `release-dataenginex.yml` runs → creates GitHub Release → triggers `pypi-publish.yml` via
  BOTH paths at once. Two parallel publish runs, potential duplicate upload.
- **Fix:** In `pypi-publish.yml`, in a single commit:
  1. Remove the entire `workflow_run:` trigger block (lines 11–17)
  2. Simplify the `detect-dataenginex-changes` job `if:` condition (line 35): remove the
     `github.event_name != 'workflow_run'` guard — it becomes unreachable
  3. Remove `workflow_run` from `fromJson(...)` arrays in job `if:` conditions (lines 180, 201,
     247): change `'["release","workflow_run","workflow_dispatch"]'` to
     `'["release","workflow_dispatch"]'` in each occurrence
  4. Rewrite the inline JavaScript at lines 262–263 (`skip-publish` Slack notification): remove the
     `eventName !== 'workflow_run'` condition check and its corresponding reason string
  5. Rewrite the inline bash at lines 296–297: remove the `workflow_run` branch from the `if/elif`
     chain and the echo string that references it
  Canonical flow after fix: `release-dataenginex.yml` creates GitHub Release → `pypi-publish.yml`
  fires via `release:published` exactly once. `workflow_dispatch` is kept for manual runs.
- **Why `release-dataenginex.yml` must stay:** It owns tag creation, release notes, and SBOM
  generation — none of which exist in `pypi-publish.yml`.

### 1.4 Expand `dependabot.yml`

- **File:** `.github/dependabot.yml` (workspace root — the only `dependabot.yml` in the monorepo)
- **Add to each ecosystem entry:**
  - `schedule.day: monday` (explicit day alongside existing `interval: weekly`)
  - `open-pull-requests-limit: 5` (prevent PR flood)
  - `labels: ["dependencies"]` for easy filtering
  - `commit-message.prefix: "chore(deps):"` to match conventional commits
- **Add** a `github-actions` ecosystem entry if not already present

---

## Section 2: Claude Code Config

### 2.1 Workspace `settings.json` (`.github/.claude/settings.json`)

**Current state (confirmed by reading the file):**

Already present in allow list: `Read`, `Edit`, `Bash(uv run poe *)`, `Bash(uv run uvicorn *)`,
`Bash(uv lock *)`, `Bash(uv sync *)`, `Bash(curl *)`, `Bash(git status)`, `Bash(git diff *)`,
`Bash(git log *)`, `Bash(git branch *)`, `Bash(git add *)`, `Bash(grep *)`, `Bash(find *)`,
`Bash(cat *)`, `Bash(head *)`, `Bash(tail *)`, `Bash(wc *)`, `Bash(ls *)`, `Bash(pwd)`,
`Bash(which *)`, `Bash(python -c *)`, `Bash(uv run python *)`, `Bash(llmfit *)`,
`Bash(npx -y @upstash/context7-mcp*)`

**Changes:**

Move from `settings.local.json` to `settings.json` (non-credential CLI patterns):

- `Bash(gh run *)`, `Bash(gh api *)`, `Bash(gh pr *)` — already in local
- `Bash(git fetch *)` — already in local
- `Bash(echo *)` — already in local
- `Bash(python3 *)` — already in local
- `Bash(uv run *)` — already in local (broader than workspace's `uv run poe *` etc.)

Add new entries not in either file:

- `Bash(gh issue *)`, `Bash(gh release *)` — needed for release workflow

Remove from allow list:

- `Bash(grep *)` — the Grep tool exists for this; shell grep bypasses tool tracking
- `Bash(find *)` — the Glob tool exists for this
- `Bash(cat *)`, `Bash(head *)`, `Bash(tail *)` — the Read tool exists for these

**Keep the poe pattern as-is:** `Bash(uv run poe *)` is already correct and covers all tasks.
Do NOT change it to `Bash(uv run poe *:*)` — the colon syntax does not match poe invocations.

After moving non-credentials from `settings.local.json` to `settings.json`, `settings.local.json`
retains only: `env` block (API keys/tokens), `enableAllProjectMcpServers`, `enabledMcpjsonServers`.

**No changes to deny list** — current denials are correct and intentional.

### 2.2 Global `~/.claude/settings.json`

**Current state:** Single allow entry using colon syntax: `"Bash(uv run:*)"`. New entries must
match this format — NOT the space-glob format used in workspace `settings.json`.

**Add to allow list:**

- `"Bash(git status:*)"`, `"Bash(git diff:*)"`, `"Bash(git log:*)"` — safe read-only git ops
- `"Bash(rg:*)"` — ripgrep, used by many tools as a subprocess

**Verify plugin list** matches installed: superpowers (5.0.4), context7, code-review,
code-simplifier, huggingface-skills, github.

### 2.3 Claude Code Commands (`.github/.claude/commands/`)

**`validate.md`** — Align with the mandatory 5-step pipeline from `dex/CLAUDE.md`. Promote the
dev-server smoke test from a note to a full numbered step:

1. `uv run poe lint`
2. `uv run poe typecheck`
3. `uv run poe test`
4. Smoke test dev server: `uv run poe dev` + curl `/health`, `/metrics`
5. Standalone import check of key public classes

**`pr.md`** — Add:

- `--author="jaymyaka <jayapal.myaka99@gmail.com>"` to all git commit invocations
- Branch naming convention: `feature/<desc>` or `fix/<desc>`
- Explicit check: confirm target branch is `dev`, never `main`

**`review.md`** — Align checklist exactly with `.github/CHECKLISTS.md` (currently diverges on
API contract and migration checks).

**Add `release.md`** — New command documenting canonical release flow. Claude must NOT auto-commit;
it must show the staged diff and wait for explicit approval at the commit step:

1. Bump version: `uv run poe version-patch|minor|major`
2. Stage: `git add pyproject.toml uv.lock CHANGELOG.md`
3. Show diff (`git diff --staged`) and request explicit approval before committing
4. After approval: `git commit --author="jaymyaka <jayapal.myaka99@gmail.com>" -m "chore: bump version to x.y.z"`
5. Push branch, open PR to `dev`, merge
6. Open PR `dev` → `main`, merge
7. Create release: `gh release create vx.y.z --generate-notes`
8. Monitor: `gh run list --workflow=pypi-publish.yml`

**Git identity note:** The `release.md` command is the only place commit operations happen under
approval. Git identity (`jaymyaka <jayapal.myaka99@gmail.com>`) belongs here, not scattered across
all agent files (where `git commit` is blocked by the deny list anyway).

---

## Section 3: Content Quality

### 3.1 `CLAUDE.md` (workspace-level)

**Preserve:** All rules, all principles, all workflow steps.

**Remove (enforced by tooling, not prompt):**

- Full Ruff rule list (`E, F, I, B, UP, SIM, C90`), line-length 100, max complexity 8, function
  length 50 lines — all configured in `pyproject.toml`
- `asyncio_mode = "auto"` and `@pytest.mark.asyncio` note — configured in `pyproject.toml`
- Replace removed items with one line:
  *"Ruff, mypy strict, and pytest are pre-configured in each repo's `pyproject.toml` —
  run `uv run poe check-all` to validate."*

**Restructure sections (all content preserved, reordered for onboarding flow):**

| New Order | Section | Change |
| --------- | ------- | ------ |
| 1 | Design Philosophy | Consolidated — see below |
| 2 | Workspace Layout | Unchanged |
| 3 | Git Conventions | Moved earlier — devs hit this immediately |
| 4 | Semantic Versioning | Moved after Git — natural progression |
| 5 | Dependencies | Moved after versioning |
| 6 | Workflow Orchestration | Tightened — remove steps covered by superpowers skills |
| 7 | Task Management | Unchanged |
| 8 | Coding Standards | Trimmed as above; tooling config cross-referenced |
| 9 | Core Principles | Unchanged |
| 10 | Red Flags | Unchanged |
| 11 | Cross-Repo Sync Policy | Unchanged |
| 12 | Developer Tools | Unchanged |

**Design Philosophy consolidation:**

- Keep all 10 principles; zero information loss
- Convert each from a multi-paragraph block to: **heading** + one-sentence summary + enforcement
  note (e.g., *"Enforced by: OSI license check in CI"*)
- Estimated reduction: ~40% word count

### 3.2 `copilot-instructions.md`

**Current:** ~18KB, largely duplicates CLAUDE.md verbatim.

**Target:** ~4KB — Copilot-specific directives only:

- Inline completion hints (file context, symbol awareness)
- Copilot Chat slash commands and agent mode behavior
- Workspace-level context directives (`@workspace`, `#file`)
- One cross-reference line: *"For coding standards, architecture principles, and git conventions,
  see CLAUDE.md — Copilot reads the same workspace."*

**Remove:** All verbatim Design Philosophy, Coding Standards, Git Conventions.

### 3.3 Agent Definitions (`agents/`)

**Consolidate overlapping agents (3 files → 1):**

| Remove | Merge into | Reason |
| ------ | ---------- | ------ |
| `code-reviewer.agent.md` | `senior-engineer.agent.md` (new) | Scope fully overlaps the other two |
| `python-pro.agent.md` | `senior-engineer.agent.md` (new) | Python expertise is a senior baseline |
| `backend-engineer.agent.md` | `senior-engineer.agent.md` (new) | Repeats python-pro content entirely |

**Keep (domain-specific, non-overlapping):**
`data-engineer`, `mlops-engineer`, `llm-architect`, `sre-engineer`, `devops-engineer`,
`mcp-developer`, `security-auditor`, `multi-agent-coordinator`

**Git identity:** Do NOT add git identity instructions to agent bodies. `git commit` is on the
deny list — agents cannot commit regardless of identity. Git identity lives in `release.md`
(the only approved commit flow). Adding it to agent bodies adds noise without effect.

### 3.4 Instruction Files (`instructions/`)

- Audit each of the 7 files against CLAUDE.md
- Remove paragraphs that are verbatim copies of CLAUDE.md sections
- Add `<!-- See also: CLAUDE.md#section-name -->` cross-references where content was removed
- No content additions — strictly deduplication

**Critical fix — `workflows.instructions.md`:**

The file currently states (line 19): *"Never use `@latest`, `@main`, or non-existent versions
(`@v6`, `@v7`, `@v8`)."* This directly contradicts the actual `ci.yml`, which uses `@v6` and `@v7`
for checkout and setup-uv. The file is actively giving wrong guidance that would cause reviewers
to flag correct code. Update the pinned version table to match current workflow reality across all `.github/workflows/*.yml` files:

| Action | Old (wrong) | New (correct) |
| ------ | ----------- | ------------- |
| `actions/checkout` | `@v4` | `@v6` |
| `actions/setup-python` | `@v5` | `@v6` |
| `actions/upload-artifact` | `@v4` | `@v7` |
| `actions/download-artifact` | `@v4` | `@v8` |
| `astral-sh/setup-uv` | `@v5` | `@v7` |
| `codecov/codecov-action` | `@v4` | `@v5` |

Remove the "non-existent versions" prohibition line entirely — it is factually wrong and will
be wrong again as versions increment.

---

## Section 4: Dependency & Runtime Audit Fixes

*Findings from live PyPI and GitHub Actions audit on 2026-03-17.*

### 4.1 Python 3.13 Upgrade

- **Current:** Python 3.12 (`requires-python = ">=3.12"`, `target-version = "py312"`)
- **Target:** Python 3.13 (stable as of October 2024; 3.14 is pre-release — skip it)
- **Files to update:**
  - `pyproject.toml`: `requires-python = ">=3.13"`, `[tool.ruff] target-version = "py313"`,
    `[tool.mypy] python_version = "3.13"`
  - `dex/.github/workflows/ci.yml`: `python-version: "3.13"` in all three jobs
  - `Dockerfile` (if present): `FROM python:3.13-slim`
  - `setup-workspace.sh`: no change needed — reads live `python3 --version`
- **Verify before committing:** run `uv run poe check-all` with Python 3.13 to confirm no
  compatibility regressions. All current deps have 3.13 wheels on PyPI.

### 4.2 Broken Version Bounds

Two packages have minimum bounds that exceed the latest available version on PyPI — they will
fail to resolve in any environment that cannot satisfy the constraint.

**`mkdocstrings[python]>=1.0.0`** — latest on PyPI is `0.29.1`:

- Change to `>=0.29.0`
- This is a docs-only dev dependency; no runtime impact

**`zensical>=0.0.24`** — latest on PyPI is `0.0.19`:

- Investigate first: check if this is a private/internal package or if the version was yanked
- Run `uv lock` to see if uv can resolve it; if not, either drop the constraint to `>=0.0.19`
  or remove the package if unused
- If `zensical` is an internal tool not on PyPI, document this explicitly in `pyproject.toml`
  with a comment

### 4.3 Outdated GitHub Actions

| File | Action | Current | Latest | Change |
| ---- | ------ | ------- | ------ | ------ |
| `security.yml` | `github/codeql-action/*` | `@v3` | `@v4` | Update all occurrences |
| `pypi-publish.yml` | `actions/github-script` | `@v7` | `@v8` | Update all occurrences |
| `workflows.instructions.md` | `github/codeql-action/*` | `@v3` (documented) | `@v4` | Update table |
| `workflows.instructions.md` | `actions/github-script` | not in table | `@v8` | Add to table |

### 4.4 Minor Dependency Bound Bumps

Update lower bounds to match current latest (no breaking changes, strictly newer patches):

- `poethepoet`: `>=0.42.0` → `>=0.42.1`
- `types-pyyaml`: `>=6.0.12.20250822` → `>=6.0.12.20250915`
- `databricks-cli`: unpinned → `>=0.18.0` (add minimum bound, consistent with project standards)

After changes, run `uv lock` to regenerate `uv.lock`.

---

## Out of Scope

- `wiki-content/` — git submodule complexity, high blast radius, no functional benefit
- `dex/CLAUDE.md` — repo-specific, not part of this workspace-level optimization
- `pyproject.toml` / `ruff.toml` — correct and authoritative; being used as the source of truth

---

## Implementation Order

1. Housekeeping: delete `.bak` dirs, re-run `setup-workspace.sh`, add CI version-drift check,
   remove `workflow_run` trigger AND all `workflow_run` condition references from `pypi-publish.yml`,
   expand `dependabot.yml`
2. **Dependency fixes**: fix `mkdocstrings` and `zensical` bounds, bump `poethepoet`/`types-pyyaml`/
   `databricks-cli`, update `codeql-action@v4` and `github-script@v8` in workflows
3. **Python 3.13 upgrade**: update `pyproject.toml`, `ci.yml`; run `uv run poe check-all` to verify
4. `settings.json`: move non-credential permissions from `settings.local.json`, add `gh issue *`
   and `gh release *`, remove `grep *` / `find *` / `cat *` / `head *` / `tail *`
5. Global `~/.claude/settings.json`: add read-only git ops and `rg *`
6. Commands: update `validate.md`, `pr.md`, `review.md`; add `release.md`
   *(depends on step 4 for `gh release *` permission)*
7. `CLAUDE.md` restructure and trim
8. `copilot-instructions.md` trim
9. Agent consolidation: create `senior-engineer.agent.md`, delete 3 files
10. Instruction file deduplication (including `workflows.instructions.md` action version update)

---

## Success Criteria

- `workspace.env` version matches `pyproject.toml` after running `setup-workspace.sh`
- `pypi-publish.yml` has only `release:published` and `workflow_dispatch` triggers; no `workflow_run`
  references anywhere in the file
- `release-dataenginex.yml` still exists and owns tag + release + SBOM
- No `.bak` directories at workspace root
- `settings.local.json` contains only: `env` block + `enableAllProjectMcpServers` +
  `enabledMcpjsonServers` (no CLI permission entries)
- CLAUDE.md is ≥30% shorter with all rules intact (verified by human review of diff)
- `copilot-instructions.md` is ≤4KB
- Agent directory has 9 files: 8 domain-specific + `senior-engineer.agent.md`
- All commands reference correct author and branch conventions
- `release.md` command exists with explicit approval gate before commit
- `workflows.instructions.md` pinned version table matches current workflow reality across all
  `.github/workflows/*.yml` files; "non-existent versions" prohibition line removed
- `pyproject.toml` uses `requires-python = ">=3.13"`, ruff `target-version = "py313"`,
  mypy `python_version = "3.13"`
- `ci.yml` runs Python 3.13
- `mkdocstrings[python]` bound is satisfiable (`>=0.29.0`)
- `zensical` bound resolved (either satisfiable or package removed with explanation)
- `databricks-cli` has version pin `>=0.18.0`
- `codeql-action` updated to `@v4` in `security.yml`
- `actions/github-script` updated to `@v8` in all workflows
- `uv lock` regenerated after all `pyproject.toml` changes
- `uv run poe check-all` passes on Python 3.13
