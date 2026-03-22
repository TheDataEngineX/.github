# Review

Review the current changes (staged and unstaged) against project standards.

Steps:

1. Run `git diff` and `git diff --staged` to see all changes
1. Check against `.github/CHECKLISTS.md` review criteria
1. For each changed file, read and apply the matching instruction file from `.github/instructions/`:

   | File pattern | Instruction file |
   | --- | --- |
   | `src/**/api/**/*.py` | `.github/instructions/fastapi.instructions.md` |
   | `src/**/data/**/*.py`, `src/**/pipeline/**/*.py`, `src/**/connectors/**/*.py` | `.github/instructions/data-pipelines.instructions.md` |
   | `src/**/ml/**/*.py`, `src/**/models/**/*.py`, `src/**/registry/**/*.py` | `.github/instructions/ml.instructions.md` |
   | `src/**/*.py` (catch-all) | `.github/instructions/python.instructions.md` |
   | `tests/**/*.py` | `.github/instructions/testing.instructions.md` |
   | `.github/workflows/**/*.yml` | `.github/instructions/workflows.instructions.md` |
   | `terraform/**`, `helm/**`, `Dockerfile`, `docker-compose*.yml`, `monitoring/**` | `.github/instructions/infrastructure.instructions.md` |

1. Read the relevant instruction file(s) and apply their checklists to the changed code

Review priorities (in order):

1. **Security** — No hardcoded secrets, parameterised queries only, no PII in logs
1. **Correctness** — Specific exceptions, error context logged, type safety, no silent swallows
1. **Testing** — Tests exist for new code, cover edge cases, 80%+ coverage on new code
1. **Standards** — `from __future__ import annotations`, type hints, structlog only (never `print()`, never loguru)
1. **API contracts** — versioned routes (`/api/v1/`), `response_model=` on every endpoint, no silent breaking changes to existing endpoints
1. **Migrations** — DB migrations are reversible, include rollback, tested in isolation

Flag any red flags from CLAUDE.md. Be direct — no sugarcoating.
