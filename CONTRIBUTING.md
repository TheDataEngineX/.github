# Contributing to TheDataEngineX

Thank you for your interest in contributing to TheDataEngineX! This guide covers
the org-wide contribution process. Individual repos may have additional guidelines.

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/orgs/TheDataEngineX/issues) first
2. Use the **Bug Report** issue template
3. Include reproduction steps, expected vs. actual behavior, and environment details

### Suggesting Features

1. Open a **Feature Request** issue
2. Describe the problem it solves and the proposed solution
3. Tag with the relevant component (api, data, ml, config, cli)

### Submitting Pull Requests

1. Fork the repo and create a feature branch: `feature/<description>` or `fix/<description>`
2. Follow [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`
3. Ensure all checks pass before requesting review
4. Reference related issues: `feat: add drift detection (#42)`

## Development Setup

All repos use the same toolchain:

```bash
# Prerequisites
python >= 3.12  # 3.13+ recommended
uv  # Package manager (https://docs.astral.sh/uv/)

# Clone and setup
git clone https://github.com/TheDataEngineX/<repo>
cd <repo>
uv sync

# Quality checks
uv run poe lint           # Ruff lint
uv run poe typecheck      # mypy --strict
uv run poe test           # pytest
```

## Coding Standards

- **Type hints** on all public functions (params + return)
- **`from __future__ import annotations`** in all source files
- **Ruff** for linting (E, F, I, B, UP, SIM, C90)
- **mypy --strict** for type checking
- **pytest** for testing (80%+ coverage target)
- **Structured logging** — never `print()` or f-strings in log calls

## Code Review Process

1. All PRs require at least one approval
2. CI must pass (lint, typecheck, test)
3. Breaking changes require discussion in the PR
4. Maintainers may request changes or suggest alternatives

## Community

- [GitHub Discussions](https://github.com/orgs/TheDataEngineX/discussions) — questions, ideas, show & tell
- [Issue Tracker](https://github.com/orgs/TheDataEngineX/issues) — bugs, features, tasks

## License

By contributing, you agree that your contributions will be licensed under the
same license as the project (MIT).
