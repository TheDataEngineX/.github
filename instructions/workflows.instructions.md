---
applyTo: ".github/workflows/**/*.yml"
---

# GitHub Actions Workflow Standards

## Action versions — current pinned versions

| Action | Version |
| --- | --- |
| `actions/checkout` | `@v4` |
| `actions/setup-python` | `@v5` |
| `actions/upload-artifact` | `@v4` |
| `actions/download-artifact` | `@v4` |
| `astral-sh/setup-uv` | `@v5` |
| `codecov/codecov-action` | `@v4` |
| `github/codeql-action/*` | `@v3` |

Never use `@latest`, `@main`, or non-existent versions (`@v6`, `@v7`, `@v8`).

## Permissions

Declare minimal permissions on every workflow:

```yaml
permissions:
  contents: read
```

Add only what the job needs. Never `permissions: write-all`.

## Job dependencies

Standard CI order:

```yaml
typecheck:
  needs: lint
test:
  needs: [lint, typecheck]
```

## Python setup (always use uv)

```yaml
- uses: astral-sh/setup-uv@v5
  with:
    version: "latest"
- uses: actions/setup-python@v5
  with:
    python-version: "3.12"
- run: uv sync
```

Never `pip install` in workflows.

## Coverage upload

```yaml
- uses: codecov/codecov-action@v4
  with:
    flags: <repo-name>
    fail_ci_if_error: false
  env:
    CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

## Checklist

- [ ] All action versions pinned to major tag (not `@latest`)
- [ ] `permissions:` block with minimal scope
- [ ] Jobs have correct `needs:` chain
- [ ] No hardcoded secrets — uses `${{ secrets.NAME }}`
- [ ] Python installed with `uv sync`
- [ ] Coverage uploaded with `fail_ci_if_error: false`
