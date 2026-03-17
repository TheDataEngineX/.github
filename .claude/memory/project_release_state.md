---
name: DataEngineX release and repo state (2026-03-15)
description: Current state of all repos, PyPI releases, and known CI issues after March 2026 session
type: project
---

dataenginex 0.6.1 is on PyPI (published 2026-03-15). Includes: SentenceTransformerEmbedder, RAGPipeline.answer(), Node.js 24 action bumps, examples/05_rag_demo.py update.

Tag: dataenginex-v0.6.1 on main. GitHub Release: https://github.com/TheDataEngineX/dex/releases/tag/dataenginex-v0.6.1

**Why:** 0.6.0 was published from pre-RAG code (timing issue with manual dispatch). 0.6.1 has the full feature set.

**How to apply:** When publishing next version (0.6.2, 0.7.0), trigger `gh workflow run release-dataenginex.yml --ref main` if push event doesn't fire automatically.

## Known CI/CD issue
Push events to main from our PRs intermittently do NOT trigger GitHub Actions workflows. Confirmed zero runs for PR#157 and PR#159 merge commits. Workaround: create GitHub Release manually (`gh release create`) which triggers pypi-publish.yml via `release:published` event. Added `workflow_dispatch` to release-dataenginex.yml (merged via PR#161) for future use.

## Repo sync state (2026-03-15)
All repos synced:
- dex: main has 0.6.1 + airflow fix (apache-airflow>=2.8.0,<3.0.0)
- datadex, agentdex, careerdex, infradex: dev and main synced; GitHub Actions bumped to Node.js 24 on both branches
- dex-studio: in sync (no changes needed)

## Pre-existing CI failures (datadex, agentdex, careerdex)
CI fails with `uv sync` because dataenginex is declared as local editable path dep (`../dex`) which doesn't resolve in GitHub Actions runners. Not introduced by recent changes — pre-existing monorepo path dep issue.

## Remaining Dependabot alerts (dex)
- apache-airflow #5: should auto-close (our pin is <3.0.0, alert affects >=3.1.0)
- flask #14: flask 2.3.3 pinned by airflow 2.x, needs 3.1.3 — can't upgrade without removing airflow
- flask-appbuilder #12, #13: same root cause — transitive dep of airflow 2.x
All are in optional `data` dep group, not installed by default.

## Wiki pages
Content written and committed at /home/jay/workspace/DataEngineX/.github/wiki-content/
Push script: /home/jay/workspace/DataEngineX/.github/wiki-content/push-all-wikis.sh
Requires one-time browser initialization per repo wiki tab before the script can push.
