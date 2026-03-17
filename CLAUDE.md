# CLAUDE.md — DataEngineX Workspace

> Loaded by Claude Code for ALL repos in this workspace.
> Each repo has its own CLAUDE.md with repo-specific commands and key files.

Be pragmatic, straight forward and challenge my ideas. Question my assumptions, point out the blank spots and highlight opportunity costs. No sugarcoating. No pandering. No bias. No both siding. No retro active reasoning. If it is an issue/bug/problem find the root problem and suggest a solution — don't skip or bypass it.

______________________________________________________________________

## Design Philosophy

Every architectural and code decision must be measured against these principles.

### Self-Hosted & Portable
Runs identically on local Docker Compose or any cloud provider via environment-specific config only.
*Enforced by: standard protocols (S3-compatible, PostgreSQL, Redis, Kubernetes API) — no cloud-provider SDKs in app code.*

### Vendor-Neutral / No Lock-in
Standard open protocols and OSI-approved open-source dependencies only — no proprietary APIs or formats.
*Enforced by: dependency audits on every PR (Trivy), OSI license gate.*

### Privacy by Design
Collect only what's needed; no PII in logs/metrics/traces; zero telemetry without explicit opt-in.
*Enforced by: structured logging rules, Ruff no-print, pre-commit secret scan.*

### Security by Default (Zero Trust)
Least privilege everywhere; all secrets via external managers; immutable audit logs.
*Enforced by: CodeQL + Trivy on every PR, deny list in Claude Code settings.*

### Future-Proof Architecture
Semantic versioning, versioned APIs (`/api/v1/`), plugin architecture, backward compatibility within major versions.
*Enforced by: `enforce-dev-to-main.yml` workflow, semver version bump commands.*

### Resilience & Reliability
Graceful degradation, circuit breakers, health probes on every service, zero-downtime deployments.
*Enforced by: required health probe in Kubernetes manifests, integration test suite.*

### Observability-First
Metrics, logs, and traces built in from day 1 — Prometheus + Grafana, structured logs, OpenTelemetry tracing.
*Enforced by: dual logging stack rule (structlog/loguru), metrics prefix convention.*

### Interoperability
Standard data formats (Parquet, Arrow, JSON Schema, OpenAPI), CLI + HTTP API interfaces, documented extension points.
*Enforced by: OpenAPI spec auto-generation via FastAPI, no undocumented internal coupling.*

### Data Lineage & Auditability
Track data source-to-output; schema registry with versioned contracts; quality gates at ingestion.
*Enforced by: `DataCatalog`, `SchemaRegistry`, and data contract Pydantic models in `dex`.*

### Performance & Cost Efficiency
Async-first for I/O, connection pooling, horizontal scaling via stateless services, right-size LLMs with `llmfit`.
*Enforced by: asyncio rule in Ruff, no unbounded query patterns in code review.*

### Maintainability
Automated quality gates on every PR, no dead/commented-out code, type hints everywhere.
*Enforced by: `uv run poe check-all` (lint + typecheck + test), mypy strict.*

### Open Source Community
MIT license, OSI-approved transitive deps, public OpenAPI specs, contribution-friendly repo structure.
*Enforced by: LICENSE file, Trivy license scan, CODEOWNERS.*

### Offline / Air-Gap Capable
No mandatory internet at runtime; container images pinned by digest; Helm charts self-contained.
*Enforced by: pinned action versions in workflows, digest pinning in Dockerfiles.*

______________________________________________________________________

## Workspace Layout

| Repo | Package | Purpose | Port |
|------|---------|---------|------|
| `dex` | `dataenginex` | Core framework (FastAPI, ML, observability, plugins) | 8000 |
| `datadex` | `datadex` | Config-driven pipeline engine | 8001 |
| `agentdex` | `agentdex` | AI agent orchestration platform | 8002 |
| `careerdex` | `careerdex` | Career intelligence (ML, job matching) | 8003 |
| `dex-studio` | `dex-studio` | Desktop UI (NiceGUI) | 8080 |
| `infradex` | `infradex` | IaC + monitoring (Terraform, Helm, Ansible) | — |

### Monitoring Stack (infradex `docker-compose.monitoring.yml`)

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics |
| Grafana | 3000 | Dashboards |
| Alertmanager | 9093 | Alert routing |
| Jaeger | 16686 | Distributed tracing |

______________________________________________________________________

## Git Conventions

- **Branches:** `main` (prod), `dev` (integration), `feature/<desc>`, `fix/<desc>`
- **Commits:** Conventional — `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`
- **Reference issues:** `feat: add drift detection (#42)`
- **Deployment:** `dev` → staging/dev cluster, `main` → production
- **Approval required:** Always show staged changes and ask for explicit approval before `git commit` or `git push`

______________________________________________________________________

## Semantic Versioning

All repos follow [semver](https://semver.org): `MAJOR.MINOR.PATCH`

- `patch` — bug fixes, no API changes → `uv run poe version-patch`
- `minor` — new backward-compatible features → `uv run poe version-minor`
- `major` — breaking changes, API removals → `uv run poe version-major`

**Rules:**

- Bump version in the same commit as the change — never in a separate cleanup commit
- `uv.lock` is auto-regenerated by version bump commands — always commit it together
- Current versions live in `.github/workspace.env` (auto-generated) — never hardcode versions in docs
- Cross-repo dependency bumps: when `dex` bumps minor/major, update `dataenginex>=x.y` in dependents
- Docker image tags must match the package version — no `latest`-only tags in production

**Current versions** (from `workspace.env`, regenerated on workspace open):

```bash
source .github/workspace.env && echo "dex=$VERSION_DEX datadex=$VERSION_DATADEX agentdex=$VERSION_AGENTDEX careerdex=$VERSION_CAREERDEX dex-studio=$VERSION_DEX_STUDIO infradex=$VERSION_INFRADEX"
```

______________________________________________________________________

## Dependencies

- `uv` only — never raw `pip`
- Pin with minimum version bounds
- Dev deps in `[dependency-groups]`
- Lock file (`uv.lock`) must always be committed — it is the reproducibility contract

______________________________________________________________________

## Workflow Orchestration

### 1. Plan First

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately — don't keep pushing
- Write plan to `tasks/todo.md` with checkable items before starting implementation
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution
- Wave execution: group independent tasks in parallel waves, sequence dependent ones

### 3. Self-Improvement Loop

- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for the relevant project
- Log research findings, dead ends, and architectural decisions to `tasks/findings.md`

### 4. Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes — don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests — then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

______________________________________________________________________

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
1. **Verify Plan**: Check in before starting implementation
1. **Track Progress**: Mark items complete as you go
1. **Explain Changes**: High-level summary at each step
1. **Document Results**: Add review section to `tasks/todo.md`
1. **Capture Lessons**: Update `tasks/lessons.md` after corrections
1. **Log Research**: Record findings, dead ends, and decisions in `tasks/findings.md`

______________________________________________________________________

## Coding Standards

### Style

- `from __future__ import annotations` in ALL source files
- Max 4 parameters per function — use dataclasses or Pydantic models for more
- Clear naming (no `x`, `temp`, `data`)
- Comments explain "why", not "what"

*Ruff, mypy strict, and pytest are pre-configured in each repo's `pyproject.toml` — run `uv run poe check-all` to validate.*

### Type Safety

- Type hints on all public functions (params + return)
- `mypy --strict` on each repo's `src/<package>/` only
- Pydantic models for API boundaries

### Logging — Dual Stack

- **API/middleware:** `structlog.get_logger(__name__)` with `logger.info("event", key=value)`
- **ML/backend:** `from loguru import logger` with `logger.info("message %s", arg)`
- **NEVER:** `print()`, stdlib `logging`, or f-strings in log calls

### Error Handling

- Catch specific exceptions, never bare `except:`
- Log errors with full context (structured key-value pairs)
- Re-raise with context, never silently swallow
- Stubs: `raise NotImplementedError("descriptive message")` — never fake data

### Testing

- 80%+ coverage target
- Arrange-Act-Assert pattern
- Mock external services, not code under test
- Test paths: `tests/unit/` (isolated) · `tests/integration/` (live server)

### Security

- Never hardcode secrets, API keys, passwords, tokens
- Parameterized queries only (never concatenate SQL)
- Never log PII, credentials, or sensitive data
- Validate all inputs at system boundaries (Pydantic)

### Observability

- Prometheus metrics with `http_` prefix
- OpenTelemetry tracing
- Structured logs (key-value pairs)

______________________________________________________________________

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

______________________________________________________________________

## Red Flags 🚨

- Hardcoded secrets or `pickle.loads` on untrusted data
- Bare `except:`, silent error swallowing, missing error context
- N+1 queries, unbounded result sets, full datasets in memory
- New feature with no tests, or tests that depend on each other
- API contract changes without versioning
- Fake/constant data from unimplemented endpoints (use NotImplementedError)
- Domain models in framework package (belong in application)
- Asserting a package/action/image version "doesn't exist" without checking — knowledge cutoff is stale, always verify via WebSearch before making version claims

______________________________________________________________________

## Cross-Repo Sync Policy

Every deployment (dev → main PR merge) must verify these are consistent across all 6 repos.
Run this check before opening a release PR or when asked to sync repos.

### Workflows (must exist in all repos)

| Workflow | Purpose | Template source |
| -------- | ------- | --------------- |
| `ci.yml` | Lint · typecheck · test | Repo-specific |
| `enforce-dev-to-main.yml` | Block PRs not from `dev` | Copy from dex |
| `claude.yml` | @claude mentions on issues/PRs | Copy from dex |
| `claude-code-review.yml` | Auto code review on PRs | Copy from dex |
| `security.yml` | Trivy + CodeQL scanning | Copy from dex |

### Repo Files (must exist in all repos)

| File | Purpose |
| ---- | ------- |
| `CLAUDE.md` | Repo-specific AI context |
| `README.md` | Project documentation |
| `.gitignore` | Ignore build/secrets/cache |
| `pyproject.toml` | Package config |
| `uv.lock` | Pinned dependency tree |
| `tasks/todo.md` | Active task board |
| `tasks/lessons.md` | Lessons learned |
| `tasks/findings.md` | Research log |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR checklist |
| `.github/dependabot.yml` | Dependency auto-updates |
| `CODEOWNERS` | Review assignment |
| `LICENSE` | MIT license |

### Sync Procedure

When any of the above change in `dex`, propagate to all other repos:

```bash
# 1. Update the source file in dex
# 2. Copy to other repos (checkout dev, write, commit, push)
# 3. Open PRs from dev → main in each affected repo
```

Do NOT let dex-specific content bleed into other repos (e.g. `pypi-publish.yml`
and `release-dataenginex.yml` are dex-only; do not copy those).

______________________________________________________________________

## Developer Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `llmfit` | Right-size LLM models to hardware | `llmfit recommend --json --use-case coding --limit 5` |
| Context7 MCP | Up-to-date library docs in LLM context | Add `use context7` to prompts for FastAPI, PySpark, etc. |

**Local LLM (Ollama):** Current system specs and recommended models are in `.github/workspace.env` (auto-generated on workspace open). Always run `llmfit recommend --json --use-case coding --limit 5` before pulling any model — never assume a model fits based on stale docs.

**Context7 Rule:** Always use Context7 MCP when needing library/API documentation, code generation, or setup steps for FastAPI, PySpark, Pydantic, Airflow, or any third-party library — without the user having to explicitly ask.
