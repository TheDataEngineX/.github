# Long-Term Memory

> Promoted from recent-memory.md when patterns appear ≥2 times or facts are confirmed.
> Updated weekly by consolidate-memory skill.
> Reference by path — not inlined at startup to preserve context budget.

## Confirmed Preferences

_Nothing yet — will be promoted from recent-memory.md._

## Established Patterns

_Nothing yet._

## Architectural Decisions

_Nothing yet._

## Research Findings

_Nothing yet._

## new_learnings

### 2026-03-19 — FastAPI 0.132.0 strict Content-Type enforcement (BREAKING)

- **Source:** <https://fastapi.tiangolo.com/release-notes/>
- **Finding:** v0.132.0 (Feb 23, 2026) enforces strict `Content-Type: application/json` on JSON requests by default; requests without it return 422. Disable with `FastAPI(strict_content_type=False)`.
- **Impact:** Audited dex — all TestClient calls are GET-only. No POST/PUT tests missing headers. No action required.
- **Status:** confirmed — no action needed

### 2026-03-19 — FastAPI ORJSONResponse / UJSONResponse deprecated

- **Source:** <https://fastapi.tiangolo.com/release-notes/>
- **Finding:** v0.131.0 deprecates `ORJSONResponse` and `UJSONResponse`; native Pydantic/Rust serialization (2x+ faster) is now the default when `response_model=` is declared.
- **Impact:** Audited dex — no `ORJSONResponse` usage found. No action required.
- **Status:** confirmed — no action needed

### 2026-03-19 — FastAPI 0.133.0 Starlette 1.0.0 support

- **Source:** <https://fastapi.tiangolo.com/release-notes/>
- **Finding:** FastAPI 0.133.0 (Feb 24, 2026) adds support for Starlette 1.0.0+, a major version jump.
- **Impact:** Starlette is not a direct dependency in dex — it's transitive via FastAPI. No action required.
- **Status:** confirmed — no action needed

### 2026-03-19 — PySpark 4.0 ANSI SQL mode enabled by default (BREAKING)

- **Source:** <https://spark.apache.org/releases/spark-release-4-0-0.html>
- **Finding:** PySpark 4.0 enables `spark.sql.ansi.enabled=true` by default — division by zero, invalid type coercions, and other silent null behaviors now throw runtime exceptions.
- **Impact:** dex already pins `pyspark>=4.1.1`. Added explicit `.config("spark.sql.ansi.enabled", "true")` to all 3 SparkSession factory functions in examples/08, 09, 10. No ANSI-unsafe SQL patterns found.
- **Status:** fixed — 2026-03-19

### 2026-03-19 — PySpark 4.0 dependency floor raises (BREAKING)

- **Source:** <https://spark.apache.org/releases/spark-release-4-0-0.html>
- **Finding:** PySpark 4.0 requires JDK 17+, Scala 2.13+, Python 3.9+, PyArrow ≥ 11.0.0, Pandas 2.x.
- **Impact:** dex pins PyArrow >=23.0.1, Pandas >=3.0. All floors already satisfied.
- **Status:** confirmed — no action needed

### 2026-03-19 — Anthropic model retirements (1 retiring Apr 19 2026)

- **Source:** <https://platform.claude.com/docs/en/release-notes/overview>
- **Finding:** `claude-3-opus-20240229` retired Jan 5; `claude-3-7-sonnet-20250219` and `claude-3-5-haiku-20241022` retired Feb 19. `claude-3-haiku-20240307` retiring Apr 19, 2026.
- **Impact:** Audited agentdex — only `claude-sonnet-4-6` used (current). No deprecated model IDs found.
- **Status:** confirmed — no action needed

### 2026-03-19 — Anthropic API: budget\_tokens deprecated, output\_config.format

- **Source:** <https://platform.claude.com/docs/en/release-notes/overview>
- **Finding:** Opus 4.6 (Feb 2026) replaces `budget_tokens` with `effort` param + `thinking: {type: "adaptive"}`. `output_format` param moved to `output_config.format`. Opus 4.6 does not support prefilling assistant messages.
- **Impact:** Audited agentdex — no `budget_tokens` usage, no assistant prefilling. Anthropic provider is a stub (NotImplementedError). Track when stubs are implemented.
- **Status:** confirmed — no action needed (stubs not yet implemented)

### 2026-03-19 — Anthropic beta headers no longer required for GA features

- **Source:** <https://platform.claude.com/docs/en/release-notes/overview>
- **Finding:** Web search, programmatic tool calling, code execution, tool search, and memory tool all went GA Feb 17, 2026. Beta headers are no longer needed.
- **Impact:** Audited agentdex — no `anthropic-beta` headers used anywhere.
- **Status:** confirmed — no action needed

### 2026-03-19 — Airflow 3.0 — FAB removed, metadata DB blocked, SequentialExecutor dropped

- **Source:** <https://airflow.apache.org/docs/apache-airflow/3.0.0/release_notes.html>
- **Finding:** Airflow 3.x (stable 3.1.x) removes SequentialExecutor, Flask AppBuilder UI, and direct metadata DB access from task code. UI is now React + FastAPI.
- **Impact:** dex correctly pins `apache-airflow>=2.8.0,<4.0.0`. The `<4.0.0` cap is intentional — Airflow 3.x is a replatform. Cap must be lifted consciously as a dedicated migration project.
- **Status:** confirmed — cap intentional, migration deferred

### 2026-03-19 — Ruff 0.15 — 16 preview rules stable, RUF103 catches invalid noqa

- **Source:** <https://astral.sh/blog/ruff-v0.15.0>
- **Finding:** Ruff 0.15 promotes 16 rules from preview to stable (including ASYNC212, B912). `RUF103` catches malformed `# noqa` comments.
- **Impact:** `preview = true` is not set in any of the 6 repos. New stable rules do not fire. No action required.
- **Status:** confirmed — no action needed

### 2026-03-19 — uv 0.10.x — Astral mirrors default; raw curl installs in CI replaced

- **Source:** <https://github.com/astral-sh/uv/releases>
- **Finding:** uv 0.10.8 switches default binary/CPython mirror from python.org to Astral mirrors. Raw `curl | sh` uv installs in CI are unpinned.
- **Impact:** Replaced `curl -LsSf https://astral.sh/uv/install.sh | sh` with `astral-sh/setup-uv@v7` in `.github/workflows/ci.yml` (both jobs) and `.github/workflows/package-validation.yml`.
- **Status:** fixed — 2026-03-19
