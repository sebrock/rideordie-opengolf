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

---

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

---

## Getting started

1. Read `README.md` first.
2. Read `CODE_OF_CONDUCT.md`, `SECURITY.md`, and `SUPPORT.md`.
3. Look for issues labeled `good-first-issue`.
4. Pick an issue with a matching `role/...` label.
5. Comment on the issue before starting larger work.
6. Keep pull requests small and focused.

Suggested first areas:

- Improve documentation
- Add tests
- Review accessibility of screens/components
- Help define course data schemas
- Review open-source licenses for dependencies
- Prototype simple Nostr login flows
- Improve GitHub issue templates and project automation

---

## Development environment

Use the development environment that matches your operating system, but keep scripts portable.

### Windows users: use WSL

For Windows development, prefer **VS Code with WSL**.

Do this from the VS Code WSL terminal, not Windows PowerShell:

```bash
cd ~/code/ride-or-die-scorecard
git status
python3 --version
gh --version
```

Authenticate GitHub CLI inside WSL:

```bash
gh auth login
gh auth status
```

If a shell script fails because of Windows line endings, run:

```bash
find . -name "*.sh" -exec sed -i 's/\r$//' {} \;
find . -name "*.sh" -exec chmod +x {} \;
```

### GitHub CLI

Several project setup scripts may use the official GitHub CLI, `gh`.

The real GitHub CLI supports:

```bash
gh auth login
gh issue list
gh label list
```

If `gh auth login` says `No such command "auth"`, the wrong `gh` package is installed. Install the official GitHub CLI from GitHub's package repository for your environment.

---

## Issue workflow

Use GitHub issues as the source of truth for implementation work.

Before starting work:

1. Find or create an issue.
2. Make sure it has clear acceptance criteria.
3. Add the correct labels.
4. Ask for clarification in the issue if the scope is unclear.
5. Keep the issue small enough to complete and review.

### Required label families

Use these label families consistently:

- `area/...` — product or technical area
- `priority/...` — sequencing importance
- `role/...` — likely contributor profile
- `license-review/required` — needs open-source license review
- `security-review/required` — needs security review
- `good-first-issue` — suitable for new contributors

Examples:

```text
area/identity
area/scoring
area/payments
area/course-data
priority/p0
priority/p1
role/frontend
role/backend
role/ux
role/security
license-review/required
security-review/required
good-first-issue
```

---

## Issue templates

Use the structured templates under `.github/ISSUE_TEMPLATE/`:

- `feature_request.yml` — new feature or capability
- `bug_report.yml` — broken behavior or regression
- `security_report.yml` — security-sensitive work or vulnerability report placeholder
- `license_review.yml` — dependency, dataset, map layer, hosted service, or tool review
- `ux_review.yml` — usability, accessibility, role-specific flows, mobile/PWA review

Do not use a blank issue if one of the templates fits. Structured issues make the backlog easier to triage.

---

## Development principles

### 1. Open-source components only

Every dependency must be compatible with the project’s open-source-first policy. Before adding a dependency, check:

- License type
- Commercial-use compatibility
- Copyleft implications
- Attribution requirements
- Data license compatibility
- Maintenance status
- Security history
- Whether a more open alternative exists

If the license is unclear, add `license-review/required` to the issue or pull request.

### 2. Non-custodial by design

The app must not hold user funds, wallet seed phrases, raw private keys, or unrestricted payment authority.

Wallet-related work should prefer:

- Nostr Wallet Connect / NIP-47
- User-controlled Lightning wallets
- Explicit permissions
- Revocable wallet connections
- Test payments before real flows
- Clear user-facing payment status

Any wallet, payment, key-management, authentication, or authorization work should carry `security-review/required`.

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

Use the UX review template for accessibility or usability concerns.

---

## Branching and commits

Use short, descriptive branch names:

```text
feature/nostr-login
fix/scorecard-validation
docs/mvp-definition
security/wallet-permissions
license/course-data-source-review
ux/mobile-scorekeeper-flow
```

Use clear commits:

```text
Add Nostr login user story
Validate scorekeeper hole input
Document NIP-47 wallet assumptions
Add license review template
Improve mobile scorekeeper form labels
```

---

## Pull request expectations

A pull request should include:

- What changed
- Why it changed
- Screenshots or screen recordings for UI changes
- Tests or a testing note
- Security considerations, if relevant
- License considerations, if new dependencies or data sources were added
- Accessibility considerations, if user-facing behavior changed
- Linked issue number

### Pull request checklist

Before requesting review, confirm:

- [ ] The change is focused and understandable.
- [ ] The implementation follows the open-source-only principle.
- [ ] New dependencies have been license-checked.
- [ ] External data sources have attribution and license notes.
- [ ] Security-sensitive areas are clearly marked.
- [ ] User-facing changes are accessible.
- [ ] Documentation has been updated where needed.
- [ ] Tests or manual verification steps are included.
- [ ] The pull request links to a GitHub issue.

---

## Review gates

Some work should not merge without explicit review.

### License review required

Add `license-review/required` for:

- New dependencies
- Open map components
- Golf course datasets
- Data imports or scrapers
- Hosted services offered by sponsors
- Code copied or adapted from other projects
- Assets, fonts, icons, images, or templates

### Security review required

Add `security-review/required` for:

- Nostr key handling
- Authentication or authorization
- Role permissions
- Wallet connections
- Lightning payments
- Zaps and rewards
- Admin operations
- Data integrity and score attestation
- Infrastructure, deployment, secrets, or environment variables

### UX review recommended

Use the UX review template for:

- Registration flows
- Scorekeeper workflows
- Mobile-first screens
- Payment status flows
- Course correction flows
- Accessibility concerns
- Event-day operational workflows

---

## Definition of Done

An issue is done when:

- Acceptance criteria are met.
- The change is reviewed.
- Security implications are addressed.
- License implications are addressed.
- Accessibility implications are addressed for user-facing changes.
- Documentation is updated.
- Relevant tests or manual verification steps are complete.
- The work does not create proprietary lock-in.
- The feature can be demoed or explained by someone other than the original author.

---

## Community conduct

All contributors are expected to follow `CODE_OF_CONDUCT.md`. Be direct, useful, and respectful. Debate ideas hard; treat people well.

---

## Security

Do not open public issues for exploitable vulnerabilities. Follow `SECURITY.md` instead.

For security-sensitive design work that is not an active vulnerability, use the security issue template and label it `security-review/required`.

---

## Support

For usage questions, setup help, and non-security problems, see `SUPPORT.md`.
