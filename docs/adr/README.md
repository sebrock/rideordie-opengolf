# Architecture Decision Records

This directory contains Architecture Decision Records for Ride or Die Scorecard.

ADRs are used for decisions that shape architecture, data, security, licensing, wallet behavior, Nostr behavior, or contribution governance.

## How to use ADRs

1. Copy `0000-adr-template.md`.
2. Name the new file with the next number and a short kebab-case title.
3. Set status to `Proposed`, `Accepted`, `Rejected`, `Deprecated`, or `Superseded`.
4. Fill in context, decision, alternatives, trade-offs, license review, security review, and rollback plan.
5. Link related issues and PRs.

## ADR Index

| ADR | Title | Status |
| ---: | --- | --- |
| [0000](0000-adr-template.md) | ADR Template | Template |
| [0001](0001-use-nostr-for-identity.md) | Use Nostr for Identity | Proposed |
| [0002](0002-use-nostr-wallet-connect-for-lightning.md) | Use Nostr Wallet Connect for Lightning Wallet Integration | Proposed |
| [0003](0003-pwa-client-strategy.md) | Use a Progressive Web App as the Primary Client | Proposed |
| [0004](0004-open-source-license-review-gates.md) | Require License Review Gates for Dependencies and Data Sources | Proposed |
| [0005](0005-open-course-data-and-maps.md) | Use Open Course Data and Open Map Components | Proposed |
| [0006](0006-score-attestation-model.md) | Define Score Attestation Model | Proposed |
| [0007](0007-nostr-score-posts-badges-and-zaps.md) | Use Nostr Score Posts, Badges, and Zaps for Engagement | Proposed |
| [0008](0008-non-custodial-payment-design.md) | Enforce Non-Custodial Payment Design | Proposed |
| [0009](0009-defer-betting-and-prediction-markets.md) | Defer Betting and Prediction Markets | Proposed |
| [0010](0010-github-delivery-governance.md) | Use GitHub Delivery Governance for Issues, Reviews, and ADRs | Proposed |

## When to create or update an ADR

Create or update an ADR when a change affects:

- Nostr identity, event kinds, relays, or signing.
- Bitcoin/Lightning wallet flows, zaps, rewards, or payment verification.
- Course data licensing, ingestion, publication, or attribution.
- Security model, authentication, authorization, or score integrity.
- PWA client strategy or offline behavior.
- Open-source governance, review gates, or release policy.

Small implementation details do not need ADRs unless they change project direction.
