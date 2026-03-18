Generate a PR description for the current branch's changes.

## Branch Convention

Branch must follow `feature/<desc>` or `fix/<desc>` pattern.
Target must be `dev` — NEVER `main` directly.

## Steps

1. Verify branch naming: `git branch --show-current`
1. Run `git log --oneline dev..HEAD` to see commits
1. Run `git diff dev --stat` to see changed files
1. Run `git diff dev` for the actual changes
1. Categorize changes:
   - **What** — What changed and why
   - **How** — Implementation approach
   - **Testing** — How it was validated (include test results)
   - **Breaking Changes** — Any API contract changes
   - **Checklist** — Based on `.github/CHECKLISTS.md`

## Format

Format as a proper GitHub PR description with:

- Title following conventional commit format
- Summary paragraph
- Bullet-point change list
- Test evidence
- Reviewer notes

Reference related issues where applicable.

## Git Identity

All commits on this branch must use:
`git commit --author="jaymyaka <jayapal.myaka99@gmail.com>"`
