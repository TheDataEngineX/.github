# Promote Changes
For each repo in the workspace:
1. Merge feature branch → dev using squash merge
2. Merge dev → main using squash merge
3. Never rebase branches with >5 commits — use squash
4. If workflow files changed, split into separate PR
5. Verify GitHub Actions triggered after main merge
