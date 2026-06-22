# CI Pipeline

This directory documents the initial CI baseline for Ride or Die Scorecard.

The current pipeline is intentionally lightweight because application framework decisions are still pending. It establishes the governance structure before feature work begins.

## Current CI jobs

| Job | Purpose | Current behavior |
|---|---|---|
| Governance metadata | Ensure PRs include review-gate metadata | Fails PRs missing `license-review` or `security-review` metadata |
| Formatter placeholder | Reserve a formatter gate | Passes with a documented placeholder |
| Linter placeholder | Reserve a linter gate | Passes with a documented placeholder |
| Unit test placeholder | Reserve a test gate | Passes with a documented placeholder |
| Dependency inventory | Reserve dependency/license/security inventory | Produces a placeholder artifact |

## Why placeholders are acceptable for Sprint 0

The project has not yet committed to a final frontend/backend package manager or language stack. The CI baseline still matters because it establishes:

- required CI entry points;
- PR metadata enforcement;
- review gates for license and security work;
- a documented dependency inventory path;
- a clean replacement point once the app stack is chosen.

## Required follow-up once the stack is selected

Replace the placeholder scripts in `scripts/ci/` with real commands:

```bash
scripts/ci/format_check.sh
scripts/ci/lint_check.sh
scripts/ci/unit_tests.sh
scripts/ci/dependency_inventory.sh
```

Recommended future gates:

- formatter check;
- linter check;
- unit tests;
- type checks;
- dependency license inventory;
- vulnerability scan;
- PWA build check;
- accessibility smoke test;
- Nostr/NWC security-specific test suite.

## Review metadata enforcement

Pull requests must use `.github/pull_request_template.md` and explicitly mention whether these gates apply:

- `license-review`
- `security-review`

CI checks for these strings in the PR body. This is intentionally simple and transparent. It does not replace human review.
