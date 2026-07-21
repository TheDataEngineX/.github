# GitHub Actions Workflows

CI/CD automation for the DataEngineX `.github` meta-repo.
Reusable workflows shared across all repos are also in this directory (prefixed `reusable-`).

## Workflows (run in `.github`)

### `security.yml` — Security Scans
**Triggers**: Push/PR to `main`/`dev`

Runs Trivy (misconfig + secret scan). CodeQL is handled by GitHub's default setup.

### `sync-labels.yml` — Label Synchronization
**Triggers**: Push to `main` on `labels.yml` changes, manual dispatch

Syncs labels from `labels.yml` to all repos (dataenginex, dex-studio, infradex).

### `project-automation.yml` — Project Intake Automation
**Triggers**: Issue/PR opened/reopened events, manual dispatch

Adds new issues/PRs to org project board. Requires `ORG_PROJECT_URL` variable + `ORG_PROJECT_TOKEN` secret.

### `stale-issues.yml` — Stale Issue Management
**Triggers**: Scheduled (daily at 6 AM UTC)

Marks issues/PRs stale after 60 days, closes after 30 more.

## Reusable Workflows (called by other repos)

| Workflow | Callers | Purpose |
|----------|---------|---------|
| `reusable-security.yml` | dataenginex, dex-studio, infradex | Trivy scan + Slack notifications |
| `reusable-auto-pr-to-main.yml` | dataenginex, dex-studio | Auto-create PR from feature/fix → main |
| `reusable-auto-pr-to-dev.yml` | (available) | Auto-create PR from feature/fix → dev + auto-merge |
| `reusable-auto-pr-dev-to-main.yml` | (available) | Auto-create PR from dev → main |
| `reusable-enforce-dev-to-main.yml` | (available) | Verify PRs to main come from dev |
| `reusable-claude.yml` | (available) | Claude Code action for @claude mentions |
| `reusable-release-please.yml` | (available) | Release please automation |

## Quick Reference

```bash
# Check CI status
gh pr checks <pr-number>

# View workflow runs
gh run list --workflow security.yml

# Trigger manual label sync
gh workflow run sync-labels.yml
```

## Required Secrets

| Secret | Used by |
|--------|---------|
| `GITHUB_TOKEN` | Auto-provided |
| `ORG_PROJECT_TOKEN` | project-automation.yml |
| `LABELS_SYNC_TOKEN` | sync-labels.yml |
| `SLACK_WEBHOOK` | security.yml (optional) |
