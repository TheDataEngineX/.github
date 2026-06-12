# CLAUDE.md — DEX Workspace

Be pragmatic, direct, and challenge assumptions. No sugarcoating. Point out blank spots and opportunity costs. If something is wrong or won't work, say so. Find root causes, never workarounds.

Workspace-wide rules: **dex · dex-studio · infradex**. Repo-specific context in each repo's `CLAUDE.md`.

## Repo Map

| Repo | Package | Port | Purpose |
|------|---------|------|---------|
| `dex` | `dataenginex` | — | Core library — config, registry, CLI, pipelines, ML, AI, PrivacyGuard (pure Python, no HTTP server) |
| `dex-studio` | `dex-studio` | 7860 | Web UI — FastAPI + Jinja2 + HTMX, direct dataenginex import |
| `infradex` | — | — | K3s / Helm / Terraform / ArgoCD infrastructure |

## Git

- **Branches:** `feature/<desc>` or `fix/<desc>` — never commit to `dev` or `main` directly
- **Flow:** feature → PR to `dev` → PR to `main`
- **Order:** commit `dex` before `dex-studio`/`infradex` (dex is upstream)
- **Author:** `git commit --author="jaymyaka <jayapal.myaka99@gmail.com>"` — no Co-Authored-By

## Conventional Commits

| Prefix | Bump | Use for |
|--------|------|---------|
| `feat:` | minor | New feature |
| `feat!:` / `BREAKING CHANGE:` | major | Breaking change |
| `fix:` / `perf:` | patch | Bug fix / perf |
| `chore:` `refactor:` `test:` `ci:` `docs:` | none | No release |

Release-please automates versioning. Never bump manually. Pre-commit hook handles patch bump on commit.

## Coding Standards

- `from __future__ import annotations` — first import in every source file
- Type hints everywhere — `mypy --strict` must pass
- No `print()` — use `structlog`
- No hardcoded secrets — env vars or Vault
- Tests required for all new code — 80%+ coverage on new paths
- DRY — no copy-paste across repos

## Tooling

- **Tasks:** `poe lint` / `poe test` / `poe check-all` / `poe dev` — defined in `poe_tasks.toml`
- **Hooks:** `.github/scripts/pre-commit-version-bump.sh` (`uv run poe install-hooks`)
- **Workflows:** `.github/.github/workflows/` (security, release-please, enforce-dev-to-main)
- **Slash commands:** `/validate` `/review` `/pr` `/new-feature` `/fix-lint` `/debug`

## Production Rules

- Root-cause fixes only — no `# type: ignore` without explanation
- Ask before committing — show diff, wait for approval
- Ask before pushing
- Always WebSearch/WebFetch for latest package versions — never assume from training
