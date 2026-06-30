# ADR 0010: Use GitHub Delivery Governance for Issues, Reviews, and ADRs

## Status

Accepted

- **Date:** 2026-06-30
- **Decision owners:** sebrock
- **Reviewers:** sebrock


## Context

The project needs a contributor-friendly open-source workflow for planning, code review, license review, security review, UX review, and architectural decisions.

The repo already includes README, CONTRIBUTING, issue templates, PR template, ADR template, labels, and generated issue backlog.

## Decision

The project will use GitHub issues, labels, milestones, PR templates, and ADRs as the primary delivery governance system.

## Alternatives

- External project management tool only.
- Chat-based planning only.
- Minimal GitHub issues without templates.
- Private planning documents outside the repo.

## Trade-offs

- GitHub-native governance is transparent and contributor-friendly.
- It requires discipline to keep issues and ADRs updated.
- Labels and templates add overhead but make contribution easier at scale.

## License Review

- License review labels and PR checkboxes are required for dependencies, datasets, generated assets, and third-party integrations.

## Security Review

- Security review labels and PR checkboxes are required for identity, wallet, payment, scoring integrity, authentication, authorization, and data ingestion changes.

## Rollback Plan

If templates become too heavy, simplify forms while preserving required license/security gates.

## Implementation Plan

- Maintain issue templates.
- Maintain PR template.
- Maintain ADR index and numbered ADRs.
- Use milestones for sprint planning.
- Use labels consistently.

## Validation

- New contributors can find where to start.
- PRs expose license/security review needs before merge.
- Major decisions have ADRs.

## Follow-up Decisions

- Branch protection rules.
- Required CI checks.
- Maintainer approval rules.

## References

- README.md
- CONTRIBUTING.md
- `.github/ISSUE_TEMPLATE/`
- `.github/pull_request_template.md`
