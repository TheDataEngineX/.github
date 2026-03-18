---
applyTo: ".github/workflows/**/*.yml"
---

# GitHub Actions Workflow Standards

## Action versions — current pinned versions

| Action | Version |
| --- | --- |
| `actions/checkout` | `@v6` |
| `actions/setup-python` | `@v6` |
| `actions/upload-artifact` | `@v7` |
| `actions/download-artifact` | `@v8` |
| `astral-sh/setup-uv` | `@v7` |
| `codecov/codecov-action` | `@v5` |
| `github/codeql-action/*` | `@v4` |
| `actions/github-script` | `@v8` |

Always pin to the current major tag. Verify against actual workflow files before documenting.

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
- uses: astral-sh/setup-uv@v7
  with:
    version: "latest"
- uses: actions/setup-python@v6
  with:
    python-version: "3.13"
- run: uv sync
```

Never `pip install` in workflows.

## Coverage upload

```yaml
- uses: codecov/codecov-action@v5
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
