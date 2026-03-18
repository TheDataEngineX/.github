# Validate

Run the full validation pipeline for the current repo. Stop and report on first failure — do not skip steps.

1. **Lint**

   ```bash
   uv run poe lint
   # fallback: uv run ruff check src/ tests/
   ```

1. **Format check**

   ```bash
   uv run ruff format --check src/ tests/
   ```

1. **Typecheck**

   ```bash
   uv run poe typecheck
   # fallback: uv run mypy src/<package>/ --strict
   ```

1. **Tests**

   ```bash
   uv run poe test
   # fallback: uv run pytest tests/ -x --tb=short -q
   ```

1. **Dev server smoke test** *(dex only)*

   ```bash
   uv run poe dev &
   sleep 3
   curl -sf http://localhost:8000/health && echo "health OK"
   curl -sf http://localhost:8000/metrics | head -5 && echo "metrics OK"
   kill %1
   ```

1. **Import check** — verify the package loads without hidden import-time errors

   ```bash
   uv run python -c "import <package>; print('OK', <package>.__file__)"
   ```

Report pass/fail for each step with the exact error output. If a step fails, diagnose the root cause before stopping.
