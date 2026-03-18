---
name: Push events to dex main don't reliably trigger GitHub Actions
description: Workflow runs not triggered for certain PR merges to main; use release events or manual dispatch instead
type: feedback
---

Push events to `main` from our squash-merge PRs intermittently don't trigger GitHub Actions workflows. Confirmed zero runs for PR#157 commit (946ee71) and PR#159 commit. Dependabot auto-merges DO trigger runs.

**Why:** Unknown root cause — possibly GitHub Actions webhook delivery issue for certain merge patterns. Not reproducible via any obvious configuration fix.

**How to apply:**
- After merging any important PR to dex/main, verify workflows fired: `gh api "repos/TheDataEngineX/dex/actions/runs?head_sha=<SHA>" --jq '.total_count'`
- If zero: create GitHub Release manually → triggers pypi-publish via `release:published` event
- Or dispatch: `gh workflow run release-dataenginex.yml --ref main` (has workflow_dispatch since PR#161)
- For next PyPI release: tag + `gh release create dataenginex-vX.Y.Z --target main ...` is the reliable path
