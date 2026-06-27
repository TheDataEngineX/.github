# DataEngineX — AI Instructions

Be pragmatic, straight forward and challenge my ideas and system design focus on creating a consistent, scalable, and accessible user experience while improving development efficiency. Always refer to up to date resources as of today. Question my assumptions, point out the blank/blind spots and highlight opportunity costs. No sugarcoating. No pandering. No bias. No both siding. No retro active reasoning. If it is an issue/bug/problem find the root problem and suggest a solution refering to latest day resources — don't skip, bypass, supress or don't fallback to a defense mode.

> For design philosophy, workflow, git conventions, versioning, and coding standards — see `CLAUDE.md`. Copilot reads the same workspace file.

---

## Workspace Layout

| Repo | Package | Purpose | Port |
|------|---------|---------|------|
| `dataenginex` (dex) | `dataenginex` | Core library — config, registry, CLI, pipelines, ML, AI, PrivacyGuard (pure Python, no HTTP server) | — |
| `dex-studio` | `dex-studio` | Web UI — FastAPI + Jinja2 + HTMX, direct dataenginex import | 7860 |
| `infradex` | — | K3s / Helm / Terraform / ArgoCD infrastructure | — |

---

## Coding Standards

- `from __future__ import annotations` in ALL source files
- Max 4 parameters per function — use dataclasses or Pydantic for more
- **Logging:** `structlog` only — never `print()`, never `loguru`
- **Errors:** Catch specific exceptions, log with full context, re-raise — never swallow
- **Stubs:** `raise NotImplementedError("descriptive")` — never return fake data
- **Secrets:** Never hardcode — parameterized queries only, never log PII
- **Tests:** 80%+ coverage, Arrange-Act-Assert, mock external services not code under test

---

## Red Flags 🚨

- Hardcoded secrets or `pickle.loads` on untrusted data
- Bare `except:`, silent error swallowing, missing error context
- N+1 queries, unbounded result sets, full datasets in memory
- New feature with no tests, or tests that depend on each other
- API contract changes without versioning
- Fake/constant data from unimplemented endpoints (use `NotImplementedError`)
- Domain models in framework package (belong in application)

---

## For Claude Code

### Tools — Use Dedicated Tools, Not Shell

| Task | Use | Never |
|------|-----|-------|
| Find files by pattern | `Glob` | `find`, `ls` |
| Search file contents | `Grep` | `grep`, `rg` in Bash |
| Read files | `Read` | `cat`, `head`, `tail` |
| Edit files | `Edit` | `sed`, `awk` |
| Create files | `Write` | `echo >`, heredocs |

### Validation Pipeline (Non-Negotiable Order)

1. `uv run poe lint` — Ruff lint
2. `uv run poe typecheck` — mypy strict
3. `uv run poe test` — pytest
4. Start real server and verify endpoints (see repo `CLAUDE.md`)
5. Standalone import check

**Tests passing ≠ app working. Step 4 is mandatory.**

### Context7 MCP

Always use Context7 MCP for library/API docs (FastAPI, Pydantic, ArgoCD, Helm, etc.) — without the user having to ask.

---

## Cross-Repo Sync Policy

Verify consistency across all 3 repos on every `feature → main` PR.

### Required workflows in all repos

`ci.yml` · `security.yml`

### Required files in all repos

`CLAUDE.md` · `README.md` · `pyproject.toml` · `uv.lock` · `LICENSE`

Do NOT copy dex-only workflows (`release.yml`) to other repos.

---

## Developer Tools

| Tool | Usage |
|------|-------|
| `llmfit` | `llmfit recommend --json --use-case coding --limit 5` — run before pulling any LLM |
| Context7 MCP | Add `use context7` to research prompts |

---

## Reference

- [instructions/](instructions/) — Domain-specific guidance (auto-loaded by file path)
- [CHECKLISTS.md](CHECKLISTS.md) — Code review checklists by domain
- [agents/](agents/) — Specialized agent definitions
