# Release

Release is fully automated via **release-please**. Claude's role is to verify readiness and monitor the pipeline — never to create tags, bump versions manually, or trigger workflows directly.

## How it works

```text
conventional commits merged to main
  → release-please opens Release PR (bumps pyproject.toml + CHANGELOG + uv.lock)
  → Developer reviews and merges PR
  → release-please creates tag v{version} + GitHub Release automatically
  → release.yml publishes to PyPI and attaches SBOM  (dex only)
```

## Prerequisites

- All tests passing: `uv run poe check-all`
- PRs merged to `main` (feature branch → main)
- Commits follow conventional commit format (`feat:`, `fix:`, `chore:`, etc.)

## Steps

1. **Verify release-please app triggered**

   ```bash
   gh pr list --label "autorelease: pending" --limit 5
   ```

1. **Review the Release PR**

   - Confirm version bump level matches commit types
   - Confirm CHANGELOG entries are accurate
   - Merge when satisfied

1. **Monitor post-merge pipeline** (dex only)

   ```bash
   gh run list --workflow=release.yml --limit 5
   ```

1. **Verify release**

   ```bash
   VERSION=$(uv run poe version)
   gh release view "v${VERSION}"
   ```

## Version bump reference

| Commit type                                     | Bump  |
| ----------------------------------------------- | ----- |
| `feat:`                                         | minor |
| `feat!:` / `BREAKING CHANGE:`                   | major |
| `fix:`, `perf:`                                 | patch |
| `chore:`, `refactor:`, `test:`, `ci:`, `docs:`  | none  |

## Pre-commit hook

The pre-commit hook (`uv run poe install-hooks`) auto-bumps patch version on every commit if you did not manually change `pyproject.toml`. This keeps the manifest in sync regardless of commit type.
