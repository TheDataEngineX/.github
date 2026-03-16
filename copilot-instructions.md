# DataEngineX — AI Instructions

Be pragmatic, straight forward and challenge my ideas. Question my assumptions, point out the blank spots and highlight opportunity costs. No sugarcoating. No pandering. No bias. No both siding. No retro active reasoning. If it is an issue/bug/problem find the root problem and suggest a solution — don't skip or bypass it.

These standards apply to **all code** across the DataEngineX workspace.
Domain-specific guidance lives in [instructions/](instructions/) — loaded automatically by file path.

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

### Monitoring Stack (`infradex docker-compose.monitoring.yml`)

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics |
| Grafana | 3000 | Dashboards |
| Alertmanager | 9093 | Alert routing |
| Jaeger | 16686 | Distributed tracing |

---

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

---

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections
7. **Log Research**: Record findings, dead ends, and decisions in `tasks/findings.md`

---

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

---

## Coding Standards

### 1. Security 🔒
- Never hardcode secrets, API keys, passwords, tokens
- Validate all inputs at system boundaries (Pydantic)
- Parameterized queries only (never concatenate SQL)
- Never log PII, credentials, or sensitive data

### 2. Clarity 📖
- Single responsibility — one function does one thing
- Functions under 50 lines, max 4 parameters
- Clear naming (no `x`, `temp`, `data`)
- Comments explain "why", not "what"

### 3. Error Handling 🛡️
- Catch specific exceptions, never bare `except:`
- Log errors with full context (structured key-value pairs)
- Re-raise with context, never silently swallow
- Stubs: `raise NotImplementedError("descriptive message")` — never fake data

### 4. Testing 🧪
- Write tests alongside code — 80%+ coverage target
- Tests are independent, use Arrange-Act-Assert
- Mock external services, not code under test
- Cover edge cases: empty, None, boundary, error paths
- `asyncio_mode = "auto"` — no `@pytest.mark.asyncio` needed
- Test paths: `tests/unit/` (isolated) · `tests/integration/` (live server)

### 5. Type Safety 🏷️
- Type hints on all public functions (params + return)
- `mypy --strict` on each repo's `src/<package>/` only
- Validate input at API boundaries (Pydantic)
- `from __future__ import annotations` in ALL source files

### 6. Observability 📊
- **API/middleware:** `structlog.get_logger(__name__)` with `logger.info("event", key=value)`
- **ML/backend:** `from loguru import logger` with `logger.info("message %s", arg)`
- **NEVER:** `print()`, stdlib `logging`, or f-strings in log calls
- Prometheus metrics (`http_` prefix) + OpenTelemetry tracing

### 7. Dependencies 📦
- `uv` only (never raw pip) — pin with minimum version bounds
- Dev deps in `[dependency-groups]` — run `poe security` to audit
- Lock file (`uv.lock`) must always be committed — it is the reproducibility contract

### 8. Compatibility 🔄
- API changes backwards compatible within major version
- Deprecate before removing — version via `/api/v1/`, `/api/v2/`

### 9. Git 🌿
- Branches: `main` (prod), `dev` (integration), `feature/<desc>` or `fix/<desc>`
- Branch-based deployment: `dev` → staging/dev cluster, `main` → production
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`
- Reference issues: `feat: add drift detection (#42)`

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

## Cross-Repo Sync Policy

Every deployment (dev → main PR merge) must verify these are consistent across all 6 repos.

### Workflows (must exist in all repos)

| Workflow | Purpose | Template source |
|----------|---------|----------------|
| `ci.yml` | Lint · typecheck · test | Repo-specific |
| `enforce-dev-to-main.yml` | Block PRs not from `dev` | Copy from dex |
| `claude.yml` | @claude mentions on issues/PRs | Copy from dex |
| `claude-code-review.yml` | Auto code review on PRs | Copy from dex |
| `security.yml` | Trivy + CodeQL scanning | Copy from dex |

### Repo Files (must exist in all repos)

| File | Purpose |
|------|---------|
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

When any shared file changes in `dex`, propagate to all other repos:
1. Update the source file in `dex`
2. Copy to other repos (checkout dev, write, commit, push)
3. Open PRs from `dev` → `main` in each affected repo

Do NOT copy dex-only workflows (`pypi-publish.yml`, `release-dataenginex.yml`) to other repos.

---

## For Claude Code 🤖

### Context Hierarchy

Claude Code reads `CLAUDE.md` files automatically:
- **Workspace:** `../CLAUDE.md` — loaded for all repos, canonical source of truth
- **Repo:** `<repo>/CLAUDE.md` — repo-specific commands, key files, architecture

Always check the repo's `CLAUDE.md` before writing code. Match existing patterns.

### Tools — Use Dedicated Tools, Not Shell

| Task | Tool to use | Never use |
|------|-------------|-----------|
| Find files by pattern | `Glob` | `find`, `ls` |
| Search file contents | `Grep` | `grep`, `rg` |
| Read files | `Read` | `cat`, `head`, `tail` |
| Edit files | `Edit` | `sed`, `awk` |
| Create files | `Write` | `echo >`, heredocs |
| Shell/system ops | `Bash` | — |
| Task tracking | `TodoWrite` | — |
| Research/exploration | `Agent (Explore)` | — |
| Architecture planning | `Agent (Plan)` | — |

### Plan Mode

Enter plan mode (`EnterPlanMode`) before ANY non-trivial task (3+ steps or architectural changes). Write the plan to `tasks/todo.md`. Get alignment before implementation.

### Subagents

Use the `Agent` tool with the appropriate subagent type:
- `Explore` — codebase search, keyword search, file pattern matching
- `Plan` — architecture design, implementation strategy
- `general-purpose` — multi-step research, parallel analysis

Group independent tasks in parallel waves. Sequence dependent ones.

### Task Tracking

Use `TodoWrite` to create and update task lists. Mark each item complete immediately when done — don't batch. This keeps the user informed of progress.

### Memory System

Persist cross-session context in `/home/jay/.claude/projects/<project>/memory/`:
- `user_*.md` — user preferences, role, expertise
- `feedback_*.md` — corrections and behavior guidance
- `project_*.md` — ongoing work, decisions, deadlines
- `reference_*.md` — pointers to external systems

Read memory when the user references prior work. Write memory after corrections or when learning important context.

### Skills (Slash Commands)

Available skills in this workspace:
- `/new-feature` — scaffold a new feature end-to-end
- `/validate` — run full validation pipeline (lint + typecheck + test)
- `/commit` — conventional commit with co-author tag
- `/simplify` — review changed code for quality and fix issues

### Context7 MCP Rule

**Always use Context7 MCP** when needing library/API documentation, code generation, or setup steps for FastAPI, PySpark, Pydantic, Airflow, NiceGUI, or any third-party library — without waiting for the user to ask. Add `use context7` to research prompts.

### Validation Pipeline (Non-Negotiable Order)

After ANY code change run in this exact order:

1. `uv run poe lint` — Ruff lint
2. `uv run poe typecheck` — mypy strict
3. `uv run poe test` — pytest
4. Start the real server and verify endpoints (see repo CLAUDE.md for commands)
5. Standalone module import check — verify modules work independently

**Tests passing ≠ app working. Step 4 is mandatory.**

### Before Submitting PRs

- Run the full validation pipeline
- Sync all affected files across the workspace (code, tests, workflows, configs, docs)
- Bump versions where appropriate
- Verify Cross-Repo Sync Policy compliance
- Check [CHECKLISTS.md](CHECKLISTS.md) for domain-specific review checklist

---

## Developer Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `llmfit` | Right-size LLM models to hardware | `llmfit recommend --json --use-case coding --limit 5` |
| Context7 MCP | Up-to-date library docs | Add `use context7` to prompts |

**Local LLM (Ollama):** 15.5 GB RAM + Quadro T2000 (4 GB VRAM). Use MoE models (Qwen3-Coder-30B-A3B at Q4_K_M). Dense models >8B will swap-thrash. Run `llmfit` before pulling new models.

---

## Reference

- [instructions/](instructions/) — Domain-specific guidance (auto-loaded by file path)
- [CHECKLISTS.md](CHECKLISTS.md) — Code review checklists by domain
- [agents/](agents/) — Specialized agent definitions
- [prompts/](prompts/) — Reusable prompt templates
