#!/usr/bin/env bash
set -euo pipefail

body="${PR_BODY:-}"

if [[ -z "$body" ]]; then
  echo "ERROR: Pull request body is empty. Use the project PR template." >&2
  exit 1
fi

missing=0

require_text() {
  local needle="$1"
  local message="$2"
  if ! grep -Fqi -- "$needle" <<< "$body"; then
    echo "ERROR: Missing PR metadata: $message" >&2
    missing=1
  fi
}

# These strings are intentionally broad so they survive small edits to the template.
require_text "license-review" "license-review checkbox/section"
require_text "security-review" "security-review checkbox/section"

# Require contributors to make an explicit review statement rather than omit the gate.
if ! grep -Eiq 'license-review[^\n]*(required|not required|n/a|not applicable|yes|no|\[[ xX]\])' <<< "$body"; then
  echo "ERROR: license-review must be explicitly marked required, not required, or N/A." >&2
  missing=1
fi

if ! grep -Eiq 'security-review[^\n]*(required|not required|n/a|not applicable|yes|no|\[[ xX]\])' <<< "$body"; then
  echo "ERROR: security-review must be explicitly marked required, not required, or N/A." >&2
  missing=1
fi

if [[ "$missing" -ne 0 ]]; then
  echo "Use .github/pull_request_template.md and fill out the review-gate section." >&2
  exit 1
fi

echo "PR governance metadata present."
