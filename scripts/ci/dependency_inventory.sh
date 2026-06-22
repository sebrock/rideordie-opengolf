#!/usr/bin/env bash
set -euo pipefail

mkdir -p artifacts
out="artifacts/dependency-inventory.txt"
{
  echo "Ride or Die Scorecard dependency inventory"
  echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "Status: placeholder"
  echo "Reason: application package manager has not been selected yet."
  echo
  echo "When stack exists, replace this script with one or more of:"
  echo "- npm ls --all --json"
  echo "- pnpm licenses list --json"
  echo "- cargo deny check"
  echo "- go version -m plus go list -m all"
  echo "- pip-licenses / pip-audit"
  echo "- syft packages . -o table"
  echo
  echo "Minimum inventory fields required by the project:"
  echo "- dependency name"
  echo "- version"
  echo "- source URL"
  echo "- declared license"
  echo "- transitive/direct flag"
  echo "- known security advisory status"
  echo "- license-review status"
  echo "- security-review status"
} > "$out"

cat "$out"
