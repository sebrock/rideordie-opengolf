# Pull Request

## Summary

<!-- Describe what this PR changes and why it matters. Keep it practical. -->

-
-
-

## Related issue(s)

<!-- Link related GitHub issues. Example: Closes #12 -->

Closes #

## Type of change

Check all that apply:

- [ ] Feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Refactor
- [ ] Test coverage
- [ ] Build / CI / tooling
- [ ] UX / accessibility
- [ ] Security-sensitive change
- [ ] License / dependency change
- [ ] Course-data ingestion or enrichment
- [ ] Nostr integration
- [ ] Bitcoin / Lightning / wallet integration

## Scope

### What changed?

<!-- Be specific. Mention affected modules, screens, APIs, or workflows. -->


### What is intentionally out of scope?

<!-- List anything that this PR does not solve, even if related. -->


## MVP alignment

Which MVP area does this support?

- [ ] Nostr identity
- [ ] Player / team registration
- [ ] Scorekeeping
- [ ] Course data
- [ ] Bitcoin / Lightning fee contribution
- [ ] Nostr Wallet Connect / light-wallet flow
- [ ] Live scoreboard
- [ ] Organizer/admin workflow
- [ ] PWA / offline-capable experience
- [ ] Accessibility
- [ ] Project foundation / governance
- [ ] Other:

## Review gates

### License review

- [ ] No new third-party dependency was added.
- [ ] New dependency/dependencies added and license compatibility was checked.
- [ ] New dependency/dependencies are open source.
- [ ] No proprietary SDK, map provider, scoring API, wallet SDK, analytics SDK, or closed-source component was introduced.
- [ ] Attribution requirements were documented where applicable.
- [ ] Data source license was reviewed if this PR imports, scrapes, stores, transforms, or displays external course/location data.
- [ ] This PR requires maintainer license review before merge.

Notes:

<!-- Mention package names, data sources, licenses, attribution obligations, and any concerns. -->


### Security review

- [ ] This PR does not touch authentication, authorization, identity, wallet, payment, score attestation, admin permissions, or external data ingestion.
- [ ] This PR touches security-sensitive functionality and requires maintainer security review before merge.
- [ ] No private keys, seed phrases, raw nsec values, wallet secrets, NWC connection strings, API keys, or tokens are logged, stored insecurely, or committed.
- [ ] User-controlled inputs are validated and sanitized.
- [ ] External data ingestion handles malformed, malicious, duplicate, and stale data safely.
- [ ] Payment/wallet flows remain non-custodial: the app does not hold user funds or raw signing keys.
- [ ] Nostr events/signatures are verified where relevant.
- [ ] Rate limiting, abuse prevention, or moderation considerations were addressed where relevant.

Notes:

<!-- Mention threat model considerations, sensitive flows, and any unresolved concerns. -->


## UX and accessibility checklist

- [ ] Works on mobile viewport.
- [ ] Works on desktop viewport.
- [ ] Keyboard navigation works for changed UI.
- [ ] Screen reader labels / semantic markup were considered.
- [ ] Color contrast is acceptable.
- [ ] Error states and empty states are clear.
- [ ] Loading states are clear.
- [ ] User-facing copy is understandable to players, scorers, organizers, and contributors.
- [ ] Not applicable.

## Testing

Describe how this was tested:

- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual browser test
- [ ] Mobile viewport test
- [ ] PWA/offline behavior test
- [ ] Nostr relay test
- [ ] Lightning/NWC test
- [ ] Course-data import test
- [ ] Not tested yet

Commands run:

```bash
# paste commands here
```

## Screenshots or recordings

<!-- Add screenshots, screen recordings, or before/after comparisons for UI changes. -->


## Data and migration impact

- [ ] No database/schema change.
- [ ] Database/schema change included.
- [ ] Data migration included.
- [ ] Course-data schema or normalization changed.
- [ ] Nostr event schema/kind changed.
- [ ] Backward compatibility considered.

Notes:


## Deployment notes

<!-- Include environment variables, service configuration, relay/wallet setup, migration steps, or rollout concerns. -->


## Contributor confirmation

- [ ] I have read `CONTRIBUTING.md`.
- [ ] I followed the project’s open-source-first policy.
- [ ] I avoided proprietary dependencies unless explicitly approved.
- [ ] I updated documentation where needed.
- [ ] I added or updated tests where practical.
- [ ] I am ready for review.
