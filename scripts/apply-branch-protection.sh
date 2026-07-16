#!/usr/bin/env bash
#
# Apply branch-protection rulesets to the GitHub repository (BEP §1.3).
#
# Branch protection is a server-side GitHub setting; this repository stores it as
# code (.github/rulesets/*.json) and activates it idempotently via this script.
# Run once by a repository admin after the repo is pushed to GitHub, and again
# whenever a ruleset JSON changes.
#
# Requirements: gh CLI authenticated with admin rights on the target repo.
# Usage:        REPO="owner/name" ./scripts/apply-branch-protection.sh
#
set -euo pipefail

: "${REPO:?Set REPO=owner/name}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

apply() {
  local file="$1" name
  name="$(jq -r '.name' "$file")"
  echo "Applying ruleset '$name' to $REPO ..."
  # Update in place if a ruleset with this name already exists, else create.
  local existing
  existing="$(gh api "repos/$REPO/rulesets" --jq \
    ".[] | select(.name==\"$name\") | .id" 2>/dev/null || true)"
  if [ -n "$existing" ]; then
    gh api -X PUT "repos/$REPO/rulesets/$existing" --input "$file" >/dev/null
    echo "  updated (id=$existing)"
  else
    gh api -X POST "repos/$REPO/rulesets" --input "$file" >/dev/null
    echo "  created"
  fi
}

apply "$ROOT/.github/rulesets/main.json"
apply "$ROOT/.github/rulesets/release.json"

echo "Branch protection applied. Verify: gh api repos/$REPO/rulesets --jq '.[].name'"
