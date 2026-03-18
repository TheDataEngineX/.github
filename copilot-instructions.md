# DataEngineX — AI Instructions

Be pragmatic, straight forward and challenge my ideas. Question my assumptions, point out the blank spots and highlight opportunity costs. No sugarcoating. No pandering. No bias. No both siding. No retro active reasoning. If it is an issue/bug/problem find the root problem and suggest a solution — don't skip or bypass it.

> For design philosophy, workflow, git conventions, versioning, and coding standards — see `CLAUDE.md`. Copilot reads the same workspace file.

---

## Workspace Layout

| Repo | Package | Purpose | Port |
|------|---------|---------|------|
| `dex` | `dataenginex` | Core framework (FastAPI, ML, observability, plugins) | 8000 |
| `datadex` | `datadex` | Config-driven pipeline engine | 8001 |
| `agentdex` | `agentdex` | AI agent orchestration platform | 8002 |
| `careerdex` | `careerdex` | Career intelligence (ML, job matching) | 8003 |
| `dex-studio` | `dex-studio` | Desktop UI (NiceGUI) | 8080 |
| `infradex` | `infradex` | IaC + monitoring (Terraform, Helm, Ansible) | — |

---

## Coding Standards

- `from __future__ import annotations` in ALL source files
- Max 4 parameters per function — use dataclasses or Pydantic for more
- **Logging:** `structlog` for API/middleware, `loguru` for ML/backend — never `print()`
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

Always use Context7 MCP for library/API docs (FastAPI, PySpark, Pydantic, Airflow, NiceGUI) — without the user having to ask.

---

## Cross-Repo Sync Policy

Verify consistency across all 6 repos on every `dev → main` PR.

### Required workflows in all repos

`ci.yml` · `enforce-dev-to-main.yml` · `claude.yml` · `claude-code-review.yml` · `security.yml`

### Required files in all repos

`CLAUDE.md` · `README.md` · `pyproject.toml` · `uv.lock` · `tasks/todo.md` · `tasks/lessons.md` · `tasks/findings.md` · `.github/PULL_REQUEST_TEMPLATE.md` · `.github/dependabot.yml` · `CODEOWNERS` · `LICENSE`

Do NOT copy dex-only workflows (`pypi-publish.yml`, `release-dataenginex.yml`) to other repos.

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
