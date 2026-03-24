# CLAUDE.md — DEX Workspace

Always Be pragmatic, straight forward and challenge my ideas and system design focus on creating a consistent, scalable, and accessible user experience while improving development efficiency. Always refer to up to date resources as of today. Question my assumptions, point out the blank/blind spots and highlight opportunity costs. No sugarcoating. No pandering. No bias. No both siding. No retro active reasoning. If there is something wrong or will not work let me know even if I don't ask it specifically. If it is an issue/bug/problem find the root problem and suggest a solution refering to latest day resources — don't skip, bypass, supress or don't fallback to a defense mode.

Workspace-wide rules for all repos: **DEX · dex-studio · infradex**

Repo-specific context is in each repo's own `CLAUDE.md`.

______________________________________________________________________

## Repo Map

| Repo | Package | Port | Purpose |
|------|---------|------|---------|
| `dataenginex` (dex) | `dataenginex` | 17000 | Core framework — config, registry, CLI, API, ML, AI |
| `dex-studio` | `dex-studio` | 7860 | Web UI — single pane of glass (NiceGUI) |
| `infradex` | — | — | K3s / Helm / Terraform infrastructure |

> **Note:** datadex, agentdex, and careerdex have been consolidated into the `dataenginex` monorepo (data, agents, and templates modules).

______________________________________________________________________

## Git & Branch Conventions

- **Branch naming:** `feature/<desc>` or `fix/<desc>` — never commit directly to `dev` or `main`
- **Flow:** feature branch → PR to `dev` → PR `dev` to `main`
- **dataenginex first:** When changes span repos, commit dataenginex before dex-studio/infradex — it is upstream
- **Author:** `git commit --author="jaymyaka <jayapal.myaka99@gmail.com>"` on every commit
- **No Co-Authored-By** trailer in commit messages

## Conventional Commits

Commit messages drive release-please version bumps:

| Type | Bump | Use for |
|------|------|---------|
| `feat:` | minor | New backward-compatible feature |
| `feat!:` / `BREAKING CHANGE:` | major | Breaking API change |
| `fix:` | patch | Bug fix |
| `perf:` | patch | Performance improvement |
| `chore:`, `refactor:`, `test:`, `ci:`, `docs:` | none | No release |

______________________________________________________________________

## Release Flow (automated via release-please)

```
conventional commits → push to main
  → release-please creates Release PR (bumps pyproject.toml + CHANGELOG + uv.lock)
  → merge PR
  → release-please creates tag v{version} + GitHub Release
  → pypi-publish.yml publishes to PyPI  (dex only)
  → release-dex.yml attaches SBOM  (dex only)
```

**Version is managed automatically.** Never manually run version bump commands.
Pre-commit hook auto-bumps patch if you commit without changing the version.

______________________________________________________________________

## Coding Standards

See `.github/instructions/` for per-domain checklists applied during `/review`.

**Universal rules (all repos, all files):**
- `from __future__ import annotations` — first import in every source file
- Type hints on all public functions — `mypy --strict` must pass
- No `print()` — use `structlog` (standardized across all repos, no loguru)
- No hardcoded secrets — use env vars or Vault
- Tests required for all new code — 80%+ coverage on new paths
- DRY enforced — no copy-paste across repos; extract to shared base

______________________________________________________________________

## Shared Tooling

| Tool | Config source |
|------|--------------|
| poethepoet tasks | Each repo owns `poe_tasks.toml` — standard task names: `lint`, `test`, `check-all`, `dev`, `version`, `clean` |
| Git hooks | `.github/scripts/pre-commit-version-bump.sh` (install: `uv run poe install-hooks`) |
| Workflow sync | `.github/scripts/sync-workflows.sh` (dry-run) / `--apply` |
| Reusable workflows | `.github/.github/workflows/` (security, claude, enforce-dev-to-main, release-please) |

______________________________________________________________________

## Commands (Claude slash commands)

| Command | Purpose |
|---------|---------|
| `/validate` | Full lint → typecheck → test → smoke test pipeline |
| `/review` | Code review against `.github/CHECKLISTS.md` + instruction files |
| `/pr` | Generate PR description for current branch |
| `/release` | Release checklist (release-please flow) |
| `/new-feature` | Scaffold new feature with tests |
| `/sync` | Sync task files, check CLAUDE.md freshness |
| `/techdebt` | Identify and prioritize tech debt |
| `/debug` | Structured debugging session |
| `/fix-lint` | Run lint fixes and typecheck |

______________________________________________________________________

## Production Rules

- **Root-cause fixes only** — no workarounds, no `# type: ignore` without explanation
- **No shortcuts** — DRY enforced, no backwards-compatibility shims for dead code
- **Ask before committing** — always show staged diff and wait for approval
- **Ask before pushing** — confirm before any `git push`
- **Verify external versions** — always WebSearch/WebFetch for latest versions; never assume from training knowledge
