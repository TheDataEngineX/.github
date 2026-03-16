#!/usr/bin/env bash
# Push pre-written wiki content to all DataEngineX GitHub wiki repos.
# PREREQUISITE: Visit each repo's /wiki tab in the browser and create
# any first page (saves the placeholder) before running this script.
#
# Usage: bash /home/jay/workspace/DataEngineX/.github/wiki-content/push-all-wikis.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GH_TOKEN=$(gh auth token)
BOT_EMAIL="github-actions[bot]@users.noreply.github.com"
BOT_NAME="github-actions[bot]"

push_wiki() {
  local repo=$1
  local src_dir="$2"
  local wiki_dir="/tmp/push-wiki-${repo}"

  echo "--- Cloning ${repo} wiki ---"
  rm -rf "$wiki_dir"
  git clone "https://x-access-token:${GH_TOKEN}@github.com/TheDataEngineX/${repo}.wiki.git" "$wiki_dir" 2>&1 \
    || { echo "SKIP: ${repo} wiki not initialized (visit https://github.com/TheDataEngineX/${repo}/wiki)"; return; }

  cp -r "${src_dir}"/*.md "$wiki_dir/"
  cd "$wiki_dir"
  git config user.email "$BOT_EMAIL"
  git config user.name "$BOT_NAME"
  git add .
  git diff --cached --quiet && { echo "OK: ${repo} (no changes)"; return; }
  git commit -m "docs: update wiki content"
  git push origin HEAD 2>&1 && echo "OK: ${repo}" || echo "FAILED: ${repo}"
}

push_wiki dex         "${SCRIPT_DIR}"
push_wiki datadex     "${SCRIPT_DIR}/wiki-datadex"
push_wiki agentdex    "${SCRIPT_DIR}/wiki-agentdex"
push_wiki careerdex   "${SCRIPT_DIR}/wiki-careerdex"
push_wiki dex-studio  "${SCRIPT_DIR}/wiki-dex-studio"
push_wiki infradex    "${SCRIPT_DIR}/wiki-infradex"
