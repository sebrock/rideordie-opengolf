# Contributing to Ride or Die Scorecard

Thanks for considering a contribution. Ride or Die Scorecard is an open-source, Nostr-native, Bitcoin/Lightning-powered golf scoring and event platform. The first target deployment is the inaugural Ride or Die Cup, but the long-term goal is a reusable reference implementation for decentralized sporting events.

## Project thesis

We are building a Progressive Web App that lets players, organizers, scorekeepers, fans, sponsors, and developers coordinate a real-world golf tournament using open protocols and open-source software.

The core principles are:

- Open source by default
- Nostr-native identity and social data
- Bitcoin/Lightning-native payments, zaps, and rewards
- Non-custodial wallet architecture
- Community-editable golf course data
- Progressive Web App delivery
- Accessibility from the start
- No proprietary lock-in

## Who can contribute

You do not need to be a Bitcoin, Nostr, or golf expert to contribute. Useful contributions include:

- Product and user stories
- UX flows and accessibility improvements
- Frontend PWA work
- Backend APIs and scoring logic
- Nostr integration
- Lightning/Nostr Wallet Connect integration
- Course data ingestion and enrichment
- Security review
- License review
- Testing and QA
- Documentation
- Translation and localization
- Sponsor/developer onboarding material

## Getting started

1. Read `README.md` first.
2. Look for issues labeled `good-first-issue`.
3. Pick an issue with a matching `role/...` label.
4. Comment on the issue before starting larger work.
5. Keep pull requests small and focused.

Suggested first areas:

- Improve documentation
- Add tests
- Review accessibility of screens/components
- Help define course data schemas
- Review open-source licenses for dependencies
- Prototype simple Nostr login flows

## Development principles

### 1. Open-source components only

Every dependency must be compatible with the project’s open-source-first policy. Before adding a dependency, check:

- License type
- Commercial-use compatibility
- Copyleft implications
- Maintenance status
- Security history
- Whether a more open alternative exists

If the license is unclear, add the `license-review/required` label to the issue or pull request.

### 2. Non-custodial by design

The app must not hold user funds, wallet seed phrases, raw private keys, or unrestricted payment authority.

Wallet-related work should prefer:

- Nostr Wallet Connect / NIP-47
- User-controlled Lightning wallets
- Explicit permissions
- Revocable wallet connections
- Test payments before real flows
- Clear user-facing payment status

Any wallet, payment, key-management, or authentication work should carry `security-review/required`.

### 3. Nostr-native where useful, not dogmatic

Use Nostr for identity, public activity, zaps, score posts, badges, attestations, and social discovery where it makes the product stronger.

Do not force all internal state into relays if a conventional backend is safer or clearer for MVP operations. The architecture should keep tournament-critical data reliable while still publishing meaningful public events to Nostr.

### 4. Progressive Web App first

The MVP should be usable from modern browsers on desktop and mobile devices. Native apps are out of scope for the MVP unless separately approved.

PWA work should consider:

- Responsive layouts
- Offline-tolerant behavior where useful
- Installability
- Low-bandwidth usage
- Mobile scorekeeper workflows
- Accessibility

### 5. Accessibility is not optional

Contributions should aim for WCAG-aligned behavior:

- Keyboard navigation
- Screen-reader-friendly labels
- Semantic HTML
- Sufficient contrast
- Text resizing support
- Clear error messages
- Avoiding color-only meaning

## Branching and commits

Use short, descriptive branch names:

```text
feature/nostr-login
fix/scorecard-validation
docs/mvp-definition
security/wallet-permissions
```

Use clear commits:

```text
Add Nostr login user story
Validate scorekeeper hole input
Document NIP-47 wallet assumptions
```

## Pull request expectations

A pull request should include:

- What changed
- Why it changed
- Screenshots or screen recordings for UI changes
- Tests or a testing note
- Security considerations, if relevant
- License considerations, if new dependencies were added
- Linked issue number

### Pull request checklist

Before requesting review, confirm:

- [ ] The change is focused and understandable.
- [ ] The implementation follows the open-source-only principle.
- [ ] New dependencies have been license-checked.
- [ ] Security-sensitive areas are clearly marked.
- [ ] User-facing changes are accessible.
- [ ] Documentation has been updated where needed.
- [ ] Tests or manual verification steps are included.

## Labels

Common label families:

- `area/...` — product/technical area
- `priority/...` — sequencing importance
- `role/...` — likely contributor profile
- `license-review/required` — needs open-source license review
- `security-review/required` — needs security review
- `good-first-issue` — suitable for new contributors

## Definition of Done

An issue is done when:

- Acceptance criteria are met.
- The change is reviewed.
- Security implications are addressed.
- License implications are addressed.
- Documentation is updated.
- Relevant tests or manual verification steps are complete.
- The work does not create proprietary lock-in.

## Community conduct

All contributors are expected to follow `CODE_OF_CONDUCT.md`. Be direct, useful, and respectful. Debate ideas hard; treat people well.

## Security

Do not open public issues for vulnerabilities. Follow `SECURITY.md` instead.

## Support

For usage questions, setup help, and non-security problems, see `SUPPORT.md`.
