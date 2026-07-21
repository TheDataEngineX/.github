---
description: "Generate a PR description from staged/changed files"
tools: ["search/codebase", "execute/runInTerminal", "execute/getTerminalOutput", "read/terminalLastCommand", "read/terminalSelection", "web/githubRepo"]
---

Generate a pull request description for the current changes using the project's PR template.

## Steps

1. Check which files have been changed (staged or modified)
2. Analyze the changes to understand what was done and why
3. Fill in the PR template from `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Summary

<!-- Brief description of what this PR does -->

## Related Issues

<!-- Link to issues: Closes #123, Fixes #456 -->

## Changes

- [ ] New feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation
- [ ] CI/CD

## Checklist

- [ ] Tests added/updated
- [ ] Documentation updated (if applicable)
- [ ] `uv run poe lint` passes
- [ ] `uv run poe typecheck` passes
- [ ] `uv run poe check-all` passes
- [ ] No breaking changes (or documented in description)
```

4. Check the appropriate boxes based on actual changes
5. Write a concise but complete description
6. Use conventional commit style for the summary line
