# Support

This document explains where to get help with Ride or Die Scorecard.

## What this project is

Ride or Die Scorecard is an open-source, Nostr-native, Bitcoin/Lightning-powered golf scoring and event platform. It is currently pre-MVP.

The project includes:

- Tournament registration
- Nostr identity
- Golf scorekeeping
- Live score visibility
- Bitcoin/Lightning fee contribution
- Nostr Wallet Connect / light-wallet integration
- Pre-event qualification scoring
- Score attestations
- Zaps and rewards
- Course data ingestion, correction, and enrichment
- Progressive Web App delivery

## Where to ask for help

Use GitHub issues or discussions once the repository is available.

### Use issues for

- Bugs
- Missing documentation
- Reproducible setup problems
- Feature proposals
- Accessibility problems
- Data quality problems
- Dependency/license concerns

### Use discussions for

- General questions
- Product ideas
- Architecture tradeoffs
- Sponsor or ecosystem collaboration ideas
- Contributor onboarding
- User research notes

### Use security reporting for

Do **not** open public issues for vulnerabilities. Follow `SECURITY.md` for:

- Wallet/payment vulnerabilities
- Authentication bugs
- Authorization bypasses
- Private key or secret exposure
- Score tampering risks
- Admin privilege issues
- Sensitive data leaks

## Before opening an issue

Please check:

1. Existing issues
2. `README.md`
3. `CONTRIBUTING.md`
4. The current MVP scope
5. Whether the issue is security-sensitive

## Good support requests

A good support request includes:

- What you tried
- What happened
- What you expected
- Your environment
- Screenshots or logs, if useful
- Relevant issue, branch, or commit

Example:

```text
I am running the GitHub issue import script in WSL through VS Code.
Command: bash ./github-import/scripts/04_run_all_wsl.sh
Expected: issues are created
Actual: gh auth command fails
Environment: Windows 11, Ubuntu WSL, VS Code Remote WSL
```

## Environment details to include

For setup problems, include:

```bash
git --version
gh --version
python3 --version
node --version
npm --version
pwd
git remote -v
```

For WSL users, also include:

```bash
cat /etc/os-release
uname -a
which gh
```

## Project status

The project is early-stage. Some areas are intentionally not final yet, including:

- Final tech stack
- Exact Nostr event model for score attestations
- Course data canonical schema
- Wallet provider assumptions
- Deployment architecture
- Legal treatment of betting/prediction features

This is normal. Use issues to make these decisions visible and reviewable.

## Contribution support

New contributors should look for:

- `good-first-issue`
- `role/frontend`
- `role/backend`
- `role/ux`
- `role/qa`
- `role/docs`
- `role/security`
- `role/license-review`

Comment on an issue before starting substantial work so others know you are taking it.

## Sponsor and ecosystem support

Potential sponsors can help through:

- Infrastructure credits
- Lightning node hosting
- Relay hosting
- Wallet integration support
- Security review
- Course data access
- Event prizes and rewards
- Developer bounties
- Design and UX support

Sponsor participation must remain compatible with the project’s open-source-first direction.

## Conduct

All support spaces follow `CODE_OF_CONDUCT.md`. Keep support requests direct, specific, and respectful.
