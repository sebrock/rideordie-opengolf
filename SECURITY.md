# Security Policy

Ride or Die Scorecard handles identity, tournament data, score attestations, Lightning payments, zaps, rewards, and community-contributed course data. Security is a core requirement, not an afterthought.

## Supported versions

The project is pre-MVP. Until the first tagged release, only the `main` branch and active milestone branches are considered in scope for security review.

| Version | Supported |
| --- | --- |
| `main` | Yes |
| Active MVP milestone branches | Yes |
| Old prototypes or abandoned branches | No |

## Reporting a vulnerability

Do not create a public GitHub issue for security vulnerabilities.

Report vulnerabilities privately through the maintainer security contact listed in the repository. If no dedicated security contact exists yet, contact the repository owner/maintainers directly and mark the message clearly as:

```text
SECURITY REPORT: Ride or Die Scorecard
```

Include:

- Description of the issue
- Affected component
- Steps to reproduce
- Potential impact
- Suggested fix, if known
- Whether the issue is already public

## Security-sensitive areas

The following areas require security review before release:

- Nostr login and signature verification
- Private key handling assumptions
- Nostr Wallet Connect / NIP-47 integration
- Lightning payment requests and callbacks
- Zaps and rewards
- Fee contribution flows
- Score attestation and anti-cheating logic
- Admin and organizer permissions
- Scorekeeper permissions
- Course data moderation
- API authentication and authorization
- Webhook handling
- Dependency changes
- Deployment and secrets management

Issues or pull requests touching these areas should use:

```text
security-review/required
```

## Wallet and payment security principles

The application must be non-custodial.

The app must not:

- Hold user funds
- Store wallet seed phrases
- Store raw private keys
- Request broad wallet permissions without user intent
- Hide payment destination details
- Auto-spend without explicit user-approved limits

The app should:

- Use Nostr Wallet Connect / NIP-47-style permissioned connections where appropriate
- Allow users to disconnect/revoke wallet access
- Display payment destination, amount, and status clearly
- Support test payments before real payments
- Minimize retained payment metadata
- Treat all webhook data as untrusted until verified

## Nostr identity security principles

The app should:

- Prefer external signing where possible
- Avoid collecting raw private keys
- Verify signatures server-side where needed
- Clearly separate public Nostr activity from private tournament/admin state
- Avoid leaking private event or payment metadata into public relays
- Treat relay data as untrusted input

## Score integrity principles

Tournament-critical scores should not rely on one unaudited submission path.

The MVP should consider:

- Scorekeeper role separation
- Marker/peer attestation for pre-event scores
- Audit logs
- Clear correction workflows
- Dispute handling
- Tamper-evident public posting where useful

## Course data integrity principles

Community-edited course data should include:

- Contributor identity/provenance
- Review status
- Evidence links where possible
- Moderation capability
- Revert capability
- Data quality flags

## Dependency security

Before adding dependencies, contributors should check:

- License compatibility
- Maintenance activity
- Known vulnerabilities
- Whether the dependency is necessary
- Whether it introduces proprietary lock-in

Use open-source dependencies only unless the project explicitly documents an exception.

## Secrets management

Never commit:

- Private keys
- Wallet credentials
- API tokens
- NWC connection secrets
- Database passwords
- Webhook secrets
- Production config files

Use environment variables or secret managers for local and deployment secrets.

## Disclosure process

The maintainers will aim to:

1. Confirm receipt of the report.
2. Assess severity.
3. Develop and test a fix.
4. Release the fix.
5. Credit the reporter if desired.
6. Publish a security advisory when appropriate.

Because this is an early-stage project, exact response times may vary. Serious reports will be prioritized.

## Safe harbor

Good-faith security research is welcome when it avoids:

- Accessing data that is not yours
- Disrupting services
- Social engineering contributors or users
- Exfiltrating secrets
- Publicly disclosing vulnerabilities before maintainers can respond

If you act in good faith and report responsibly, the project will not treat your research as hostile.
