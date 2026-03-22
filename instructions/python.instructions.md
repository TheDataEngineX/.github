---
applyTo: "src/**/*.py"
---

# Python Standards

## Required in every source file

- `from __future__ import annotations` — first import, always
- Type hints on all public functions: parameters and return type
- `mypy --strict` must pass — no `# type: ignore` without a comment explaining why

## Style

- Ruff rules: E, F, I, B, UP, SIM, C90 · line length: 100
- Max function length: 50 lines · max parameters: 4
- Names must be descriptive — no `x`, `temp`, `data`, `result`
- Comments explain **why**, not what

## Logging

- All code: `structlog.get_logger()` → `logger.info("event", key=value)`
- Never: `print()`, `loguru`, `logging.getLogger()`, f-strings in log calls
- Never log PII, tokens, passwords, or raw request bodies

## Error handling

- Catch specific exceptions — never bare `except:`
- Log with full context before re-raising: `logger.error("failed", error=e, context=...)`
- Chain exceptions: `raise SomeError("descriptive message") from e`
- Stubs must `raise NotImplementedError("description")` — never return fake data

## Security

- No hardcoded secrets, API keys, tokens, or passwords — use env vars / Pydantic settings
- Validate all external input at boundaries (Pydantic models)
- Parameterised queries only — never string-concatenate SQL
- No `pickle.loads` on untrusted data

## Dependencies

- `uv` only — never `pip install` in code or docs
- New deps go in `pyproject.toml` with minimum version bounds
- Dev-only deps go in `[dependency-groups]`

## Checklist

- [ ] `from __future__ import annotations` present
- [ ] All public functions have type hints
- [ ] No `print()` calls
- [ ] No bare `except:`
- [ ] No hardcoded secrets
- [ ] mypy passes with `--strict`
