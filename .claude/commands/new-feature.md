# New Feature

Scaffold a new feature for the current repo. Ask for the feature name and description if not provided as $ARGUMENTS.

Steps:

1. **Identify repo** — Determine which repo this is (dex, agentdex, datadex, careerdex, dex-studio, infradex) and its package name (`dataenginex`, `agentdex`, `datadex`, `careerdex`, `dex_studio`, `infradex`)
1. **Plan** — Write the implementation plan to `tasks/todo.md` with checkable items. Check in before implementing.
1. **Explore** — Search `src/<package>/` for related patterns and existing code to build on. Search online for up-to-date API/library docs before designing.
1. **Design** — Identify the right module:
   - API endpoint → `src/<package>/api/` — must have `response_model=`, type hints, auth check
   - Service/business logic → `src/<package>/core/` or `src/<package>/<domain>/`
   - CLI command → `src/<package>/cli.py` (Click group)
   - Plugin integration → `src/<package>/plugin.py`
   - Data pipeline → Medallion pattern (bronze → silver → gold)
   - ML feature → `ModelRegistry` lifecycle pattern
1. **Implement** — Follow existing patterns in the target module. Type hints everywhere. No print() — use structlog or loguru.
1. **Test** — Write tests in `tests/unit/` and/or `tests/integration/`. Aim for 80%+ coverage on new code.
1. **Validate** — Run `/validate` to verify everything passes
1. **Update** — Mark items complete in `tasks/todo.md`; update `TODO.md` if the feature closes a planned item

Follow all coding standards from CLAUDE.md. Include `from __future__ import annotations`, type hints, structured logging, specific exception handling.
