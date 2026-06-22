# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the Ride or Die Scorecard project.

ADRs are used to capture important technical and product architecture decisions in a durable, reviewable format. They are especially important for this project because the app must remain open-source-first, Nostr-native, Bitcoin/Lightning-native, non-custodial, PWA-first, and suitable for real-world event operations.

## ADR Status Values

Use one of the following status values:

- `Proposed` — under discussion, not yet accepted
- `Accepted` — approved and should guide implementation
- `Superseded` — replaced by a newer ADR
- `Rejected` — considered but not adopted
- `Deprecated` — still documented, but no longer recommended

## File Naming

Use the format:

```text
NNNN-short-title.md
```

Examples:

```text
0001-use-nostr-for-identity.md
0002-use-nostr-wallet-connect-for-lightning-wallets.md
0003-use-pwa-as-primary-client.md
```

## ADR Template

Use the template in:

```text
0000-adr-template.md
```

Every ADR should include:

- Context
- Decision
- Alternatives considered
- Trade-offs
- License review
- Security review
- Rollback plan
- Implementation plan
- Validation
- References

## Initial Placeholder ADRs

| ADR | Title | Status | Area | Notes |
|---:|---|---|---|---|
| 0001 | Use Nostr for identity and signed user actions | Proposed | Identity / Nostr | Covers login, profiles, signed score events, contributor provenance, and score attestations. |
| 0002 | Use Nostr Wallet Connect for non-custodial Lightning wallet integration | Proposed | Wallet / Payments | Covers fees, zaps, rewards, wallet permissions, revoke/disconnect, and test payments. |
| 0003 | Build the app as a Progressive Web App | Proposed | Client / UX | Covers installability, offline behavior, mobile-first scoring, and cross-device compatibility. |
| 0004 | Use open-source-only dependencies and mandatory license review gates | Proposed | Governance / Licensing | Covers dependency intake, SPDX metadata, incompatible licenses, and sponsor-provided services. |
| 0005 | Use open map and course-data sources with community enrichment | Proposed | Course Data / Maps | Covers OpenStreetMap-derived data, course editing, corrections, provenance, and review workflow. |
| 0006 | Use scorekeeper and peer-attestation workflows for submitted scores | Proposed | Scoring / Integrity | Covers official scorekeeper role, pre-event score verification, dispute handling, and audit trail. |
| 0007 | Publish public score posts and achievements through Nostr events | Proposed | Social / Engagement | Covers score posts, badges, zaps, public feeds, and relay strategy. |
| 0008 | Keep Bitcoin/Lightning flows non-custodial | Proposed | Security / Payments | Covers no custody of funds, no seed phrase handling, payment confirmation boundaries, and failure states. |
| 0009 | Separate MVP features from post-MVP betting/prediction markets | Proposed | Product / Legal Risk | Covers legal review requirement, jurisdiction risk, and keeping betting out of the initial MVP. |
| 0010 | Use GitHub issue labels and PR review gates for delivery governance | Proposed | Process / Delivery | Covers labels, milestones, issue templates, PR template, security-review, and license-review. |

## Current Decision Map

```text
Identity           -> ADR 0001
Wallets/Lightning -> ADR 0002, ADR 0008
Client strategy   -> ADR 0003
Licensing         -> ADR 0004
Course data/maps  -> ADR 0005
Scoring integrity -> ADR 0006
Nostr publishing  -> ADR 0007
Legal risk        -> ADR 0009
Delivery process  -> ADR 0010
```

## Contribution Guidance

When a pull request changes architecture, data model, security posture, wallet/payment behavior, licensing posture, or Nostr/Lightning protocol usage, the contributor should either:

1. Reference an existing ADR, or
2. Propose a new ADR in this directory.

Do not bury architecture decisions only in issues, PR comments, chat messages, or commit messages. If the decision will matter later, write an ADR.
