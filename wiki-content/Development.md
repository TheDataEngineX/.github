# Development

## Prerequisites

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) package manager

```bash
git clone https://github.com/TheDataEngineX/dataenginex && cd dataenginex
uv run poe setup    # install deps + pre-commit hooks
```

## Task Runner

All commands use [poethepoet](https://github.com/nat-n/poethepoet) via `uv run poe <task>`. Task definitions live in `poe_tasks.toml`.

## Quality Commands

| Command | Description |
|---------|-------------|
| `uv run poe lint` | Ruff lint (rules: E, F, I, B, UP, SIM, C90) |
| `uv run poe lint-fix` | Ruff lint + auto-fix |
| `uv run poe typecheck` | mypy --strict on `src/dataenginex/` only |
| `uv run poe check-all` | lint + typecheck + test |

## Test Commands

| Command | Description |
|---------|-------------|
| `uv run poe test` | All tests |
| `uv run poe test-unit` | Unit tests only (`tests/unit/`) |
| `uv run poe test-integration` | Integration tests only (`tests/integration/`) |
| `uv run poe test-cov` | Tests with HTML coverage report |

**Integration tests** require running storage emulators:

```bash
docker compose -f docker-compose.test.yml up -d
uv run poe test-integration
docker compose -f docker-compose.test.yml down
```

## Run Commands

| Command | Description |
|---------|-------------|
| `uv run poe dev` | Dev server (uvicorn reload, port 17000) |
| `uv run poe docker-up` | Docker Compose up |
| `uv run poe docker-down` | Docker Compose down |

## Dependency Management

| Command | Description |
|---------|-------------|
| `uv run poe uv-sync` | Sync deps from lockfile |
| `uv run poe uv-lock` | Regenerate lockfile |
| `uv run poe security` | Audit deps for vulnerabilities |

The `uv.lock` file **must always be committed** — it is the reproducibility contract.

## Mandatory Validation Pipeline

Run in this exact order after any code change:

```bash
# 1. Lint
uv run poe lint

# 2. Type check
uv run poe typecheck

# 3. Tests
uv run poe test

# 4. Real server smoke test
uv run python examples/02_api_quickstart.py
# Then verify endpoints:
# curl http://localhost:17000/health
# curl http://localhost:17000/
# curl http://localhost:17000/metrics

# 5. Standalone import check
python -c "from dataenginex.core import MedallionArchitecture, QualityGate"
python -c "from dataenginex.ml import ModelRegistry, RAGPipeline"
```

Tests passing does not equal the app working. Step 4 is non-negotiable.

## API Endpoints (Dev Server)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Root |
| `/echo` | POST | Echo endpoint |
| `/health` | GET | Health check |
| `/metrics` | GET | Prometheus metrics |

## Coding Standards

- `from __future__ import annotations` in all source files
- Line length: 100 characters
- Max function complexity: 8
- Functions: under 50 lines, max 4 parameters
- Type hints on all public functions
- `mypy --strict` must pass on `src/dataenginex/`

### Logging

- **All code**: `import structlog; logger = structlog.get_logger()` with `logger.info("event", key=value)`
- Never use `print()`, `loguru`, stdlib `logging`, or f-strings in log calls

## Git Conventions

- Branches: `main` (prod), `dev` (integration), `feature/<desc>`, `fix/<desc>`
- Commits: Conventional — `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`
- Reference issues: `feat: add drift detection (#42)`
- Deployment: `dev` → staging/dev cluster, `main` → production

## Running Examples

```bash
uv run python examples/01_core_demo.py
uv run python examples/02_api_quickstart.py
uv run python examples/05_rag_demo.py --embed --llm ollama --model llama3.2
uv run python examples/08_spark_ml.py
```

Examples are numbered 01–10 and cover progressively more advanced features.
