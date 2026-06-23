# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for the Ride or Die Scorecard project.

ADRs capture important architecture, product, security, licensing, and operational decisions in a durable, reviewable format. They are especially important for this project because the app must remain open-source-first, Nostr-native, Bitcoin/Lightning-native, non-custodial, PWA-first, and suitable for real-world golf event operations.

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
0006-score-attestation-model.md
0016-wallet-connection.md
```

## ADR Template

Use the template in:

```text
docs/adr/0000-adr-template.md
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
- Follow-up decisions
- References

## ADR Register

| ADR | Title | Status | Category | Implementation Impact |
|---:|---|---|---|---|
| 0000 | ADR template | Template | Process | Defines the required ADR structure. |
| 0001 | Use Nostr for identity and signed user actions | Proposed | Identity / Nostr | Establishes Nostr pubkeys as the primary identity anchor. |
| 0002 | Use Nostr Wallet Connect for non-custodial Lightning wallet integration | Proposed | Wallet / Payments | Establishes the wallet integration direction for fees, zaps, and rewards. |
| 0003 | Build the app as a Progressive Web App | Proposed | Client / UX | Establishes PWA-first delivery across mobile, tablet, and desktop clients. |
| 0004 | Use open-source-only dependencies and mandatory license review gates | Proposed | Governance / Licensing | Establishes dependency intake and license-review rules. |
| 0005 | Use open map and course-data sources with community enrichment | Proposed | Course Data / Maps | Establishes open course-data sourcing, editing, provenance, and review workflow. |
| 0006 | Define score attestation model | Proposed | Scoring / Integrity | Separates scorecard validity attestation from timestamp anchoring. |
| 0007 | Publish public score posts, badges, and zaps through Nostr events | Proposed | Social / Engagement | Establishes public engagement primitives around scores and achievements. |
| 0008 | Keep Bitcoin/Lightning flows non-custodial | Proposed | Security / Payments | Establishes the rule that the app never holds funds, seed phrases, or raw private keys. |
| 0009 | Defer betting and prediction markets | Proposed | Product / Legal Risk | Keeps regulated betting functionality outside MVP pending legal review. |
| 0010 | Use GitHub issue labels and PR review gates for delivery governance | Proposed | Process / Delivery | Establishes issue/PR workflow, labels, and review gates. |
| 0011 | Use TypeScript and Express.js for backend API | Proposed | Backend Framework | Selects TypeScript, Node.js, Express, Prisma, REST, Vitest, and Supertest. |
| 0012 | Use React 18 with TypeScript for PWA frontend | Proposed | Frontend Framework | Selects React, TypeScript, Vite, shadcn/ui, Tamagui, Redux Toolkit, and Workbox. |
| 0013 | Use PostgreSQL with Prisma ORM for persistent storage | Proposed | Database | Selects PostgreSQL 15+ and Prisma for score, attestation, payment, and audit data. |
| 0014 | Use Railway or Render for hosting and deployment | Proposed | Infrastructure | Selects managed PaaS hosting and managed PostgreSQL for MVP deployment. |
| 0015 | Use relay discovery with primary relay fallback for Nostr event publishing | Proposed | Nostr Integration | Defines public relay discovery, primary relay fallback, retry, and read/write strategy. |
| 0016 | Use Nostr Wallet Connect as primary wallet integration with WebLN and BTCPay fallbacks | Proposed | Wallet / Payments | Defines NIP-47/NWC wallet connection and fallback payment paths. |
| 0017 | Use BTCPay Server for registration invoice generation and state tracking | Proposed | Payments | Defines invoice creation, payment confirmation, webhook handling, and reconciliation. |
| 0018 | Use custom Nostr event kinds for score submission and attestation | Proposed | Data Structure / Nostr | Defines custom score, attestation, and dispute event kinds and payload structure. |
| 0019 | Implement real-time role-based score attestation verification | Proposed | Verification / Scoring | Defines marker approval, organizer override, and MVP score state machine. |
| 0020 | Implement organizer-led dispute resolution for score challenges | Proposed | Governance / Scoring | Defines challenge windows, organizer decisions, appeals, and audit trail. |
| 0021 | Implement service-worker-based offline scorekeeper workflow | Proposed | PWA / Offline | Defines offline score submission, IndexedDB queue, sync, and conflict behavior. |
| 0022 | Use Workbox for service worker asset precaching and cache management | Proposed | PWA / Offline | Defines caching strategies, precaching, service worker lifecycle, and cache update handling. |

## Decision Map

```text
Identity and signing
  ADR 0001 -> ADR 0015 -> ADR 0018 -> ADR 0019

Wallets, fees, zaps, and rewards
  ADR 0002 -> ADR 0008 -> ADR 0016 -> ADR 0017

Client and offline experience
  ADR 0003 -> ADR 0012 -> ADR 0021 -> ADR 0022

Backend and persistence
  ADR 0011 -> ADR 0013 -> ADR 0014

Scoring integrity and disputes
  ADR 0006 -> ADR 0018 -> ADR 0019 -> ADR 0020

Course data and maps
  ADR 0005 -> future ingestion/data-quality ADRs

Governance, licensing, and delivery
  ADR 0004 -> ADR 0010 -> CI/license/security review gates

Legal-risk boundary
  ADR 0009 -> future legal/compliance ADRs before any betting-market work
```

## MVP Critical Path

The MVP implementation should not start major feature work until these decisions are reviewed:

1. **Backend framework** — ADR 0011
2. **Frontend framework** — ADR 0012
3. **Database strategy** — ADR 0013
4. **Hosting and deployment** — ADR 0014
5. **Nostr relay strategy** — ADR 0015
6. **Wallet connection** — ADR 0016
7. **Registration invoice flow** — ADR 0017
8. **Score event payloads** — ADR 0018
9. **Attestation verification** — ADR 0019
10. **Offline scorekeeper workflow** — ADR 0021
11. **Service worker caching** — ADR 0022

ADR 0020 can be finalized shortly after the core score state machine is reviewed, but dispute handling should still be specified before any public event deployment.

## Review Workflow

New ADRs should usually begin as `Proposed`.

A `Proposed` ADR can become `Accepted` when:

- The decision owner is identified.
- The relevant project participants have had a chance to review it.
- License-review concerns are resolved or explicitly accepted.
- Security-review concerns are resolved or explicitly accepted.
- Rollback plan is realistic.
- The implementation team agrees the decision is actionable.

A pull request that changes architecture, data model, security posture, wallet/payment behavior, licensing posture, Nostr protocol usage, Lightning behavior, or offline behavior should either:

1. Reference an existing ADR, or
2. Propose a new ADR in this directory.

Do not bury architecture decisions only in issues, PR comments, chat messages, or commit messages. If the decision will matter later, write an ADR.

## Review Gates

Every ADR that introduces or changes dependencies, infrastructure, payment logic, wallet flows, Nostr signing, score verification, course-data licensing, or user data handling must include explicit review notes for:

- License review
- Security review
- Rollback plan

The review notes do not need to be long, but they must be concrete enough for maintainers to decide whether the change is safe to implement.

## Relationship to Issues and Pull Requests

- Issues describe work to be done.
- Pull requests propose concrete changes.
- ADRs explain durable decisions behind the work.

Use ADR links in issues and PRs when implementation depends on an architecture decision.

Example:

```md
Related ADRs:
- docs/adr/0016-wallet-connection.md
- docs/adr/0017-payment-invoice-flow.md
```

## Missing or Future ADRs

Create new ADRs when the project needs to decide topics such as:

- Course-data ingestion pipeline and ODbL handling
- Data provenance and contributor reputation
- Sponsor infrastructure boundaries
- Mainnet/testnet/signet strategy
- Key rotation and compromised-key recovery
- Admin permissions and organizer governance
- Observability, backups, and incident response
- Future native wrapper strategy if PWA limitations become material
