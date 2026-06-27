# Ride or Die Scorecard

**Ride or Die Scorecard** is an open-source, Nostr-native, Bitcoin-powered golf event platform, starting with the **Ride or Die Cup**.

The goal is simple: replace scattered spreadsheets, chats, manual payment reconciliation, and fragile score tracking with a field-ready PWA that can register players, manage teams, coordinate Bitcoin/Lightning fees, record scores, capture attestations, publish standings, and leave reusable event software behind.

> Current source of truth: **foundation document v0.4.1 - Nostash onboarding update** and the **foundation deck v0.4.1**. This repository is in implementation-prep mode: governance, ADRs, issue scaffolding, deck assets, and planning docs exist; generated ADRs and proposed stack decisions still need project-owner review before being treated as binding.

---

## Project Status

The project has moved from concept planning into executable scaffolding.

| Area | Current state |
| --- | --- |
| Product thesis | Stable: Ride or Die Scorecard is the platform; Ride or Die Cup is the first deployment. |
| Foundation document | Updated to v0.4.1 with Nostash onboarding, signer abstraction, Sprint 1 direction, and ADR status correction. |
| Pitch deck | Updated to v0.4.1 and rendered into README-ready images and thumbnails. |
| ADRs | ADRs 0001-0022 are represented. ADRs 0011-0022 should remain **Proposed** until reviewed. |
| Repo scaffolding | README, contribution docs, issue templates, PR template, ADR index, course-data registry, CI placeholder, and support/security docs are expected assets. |
| Implementation posture | Ready for Sprint 0 reconciliation and Sprint 1 kickoff after the live repo confirms committed assets, ADR status, issue import, and CI replacement commands. |

---

## MVP Definition

A successful MVP lets a real golf event complete the core tournament loop:

1. A participant enters as a guest and can browse public event information.
2. A player registers or is manually registered by an organizer.
3. A player joins or is assigned to a team.
4. Required fees or contributions are tracked through Bitcoin/Lightning payment status.
5. Scorekeepers and markers can enter, review, and attest scores.
6. Standings are visible in a responsive PWA during the event.
7. Score changes, role changes, attestations, disputes, and admin overrides are auditable.

### MVP Includes

- Guest-first PWA shell
- Nostr identity association
- NIP-07 signer detection
- Nostash onboarding for iOS/iPadOS Safari
- Signed authentication challenge
- Registration and team flows
- Organizer/admin view
- Course baseline and scorekeeper workflow
- Score attestations and dispute handling
- Bitcoin/Lightning payment-status tracking
- Accessibility baseline
- Operational logs and exportable data

### Not MVP

- Native mobile apps
- Custodial balances
- Asking users to paste raw `nsec` private keys
- Full social-client functionality
- Global course-data coverage
- Unmoderated scoring-critical course edits
- Betting or prediction markets

---

## Product Principles

| Principle | Meaning |
| --- | --- |
| Open source first | Core code, docs, scripts, and runtime dependencies should be open source unless an exception passes review. |
| Bitcoin only | Fees, contributions, rewards, and payment flows use Bitcoin. Lightning is preferred for UX. |
| Nostr native | Public keys, signed events, and relay publishing are part of the product architecture, not a bolt-on. |
| Non-custodial | The app coordinates payment intent/status and signing requests. It does not hold seed phrases, raw private keys, or user funds. |
| Guest first | Normal users can browse before learning anything about Nostr. Signing unlocks participation. |
| Scorekeeper first | The tournament must work even if some players never install or use the app. |
| Accessibility by default | Mobile, keyboard, screen-reader, contrast, focus, touch-target, and error states matter from Sprint 1. |
| No vendor lock-in | Services should sit behind adapters and have documented fallbacks where practical. |

---

## Nostr Onboarding

The v0.4.1 direction adds the missing normie on-ramp: **guests first, signing later**.

Users should not be forced to understand relays, NIPs, keys, or wallet protocols before they can see the event. The PWA should allow public browsing first, then ask for secure signing only when the user takes a meaningful action.

### Guest-access actions

- Browse the Cup homepage
- View schedule and venue information
- View public course information
- View public standings and announcements
- Read sponsor and contributor information

### Signer-gated actions

- Join or register
- Submit profile or roster information
- Enter or attest scores
- Publish event updates
- Claim a role, badge, reward, or identity-linked status
- Use encrypted/private features

### iOS/iPadOS Safari path: Nostash

[Nostash](https://github.com/tyiu/nostash) is the guided iPhone/iPad Safari path for NIP-07 signing.

Recommended UX copy:

> Your key stays on your device. Ride or Die asks your signer to approve actions. We never see your private key.

Expected flow:

1. User browses as a guest.
2. User taps a gated action such as **Join**, **Register**, **Attest**, or **Publish**.
3. The PWA checks for `window.nostr`.
4. If `window.nostr` is missing on iOS/iPadOS Safari, show the Nostash install/enable modal.
5. User installs Nostash, opens it once, enables the Safari extension, returns, and taps **Connect**.
6. The app requests the public key and signs a server-issued auth challenge.
7. The server verifies the signature and opens role-appropriate features.

Implementation notes:

- Do not ask normal users to paste raw `nsec` keys.
- Keep NIP-07 as the MVP browser-signer adapter.
- Keep NIP-46 remote signing and NIP-55 Android signing staged behind the same internal signer interface.
- Detect NIP-44 encryption support before exposing encrypted/private features.
- Explicitly test iOS Home Screen PWA mode. If the signer is unavailable there, show **Open in Safari to connect securely**.

---

## Technical Architecture

The proposed implementation stack is coherent but should remain reviewable through ADRs before being locked in.

| Layer | Proposed direction |
| --- | --- |
| Frontend | React + Vite installable PWA, mobile-first scorekeeper UX, accessibility tests, Workbox service worker, IndexedDB offline queue. |
| Backend | Node.js + Express + TypeScript APIs for registration, teams, roles, score state, payment state, audit logs, and admin workflows. |
| Database | PostgreSQL as the MVP operational source of truth, with Prisma as the ORM. |
| Nostr | NIP-07 signer adapter, signed auth challenge, relay publishing, score/attestation event schemas, future NIP-46/NIP-55 fallback paths. |
| Payments | Bitcoin only. Lightning-first UX through NWC/NIP-47 direction, with BTCPay Server for invoices/reconciliation and adapter-based fallbacks. |
| Course data | Provenance-aware registry and normalized course/hole/tee records, with moderated corrections and organizer-approved scoring data separated from public suggestions. |
| Offline | Workbox + IndexedDB queue for scorekeeper behavior under weak course connectivity. |
| Hosting | Railway or Render are proposed options; deployment must remain replaceable and documented. |

### Signer Adapter Shape

The app should not be hardcoded to Nostash, even if Nostash is the recommended iOS Safari path.

```ts
export interface SignerAdapter {
  type: "nip07" | "nip46" | "nip55" | "local-dev";
  getPublicKey(): Promise<string>;
  signEvent(event: UnsignedNostrEvent): Promise<SignedNostrEvent>;
  nip44Encrypt?(pubkey: string, plaintext: string): Promise<string>;
  nip44Decrypt?(pubkey: string, ciphertext: string): Promise<string>;
}
```

---

## Score Integrity

Score validity and timestamp anchoring are separate concepts.

| Mechanism | What it proves | What it does not prove |
| --- | --- | --- |
| Marker or signer attestation | A scorecard was reviewed or approved under event rules. | It does not prove the event existed at a specific external timestamp. |
| Timestamp anchoring | A scorecard hash or attestation existed at or before a time. | It does not prove the score is valid. |
| Zaps, likes, badges, or popularity | Social engagement. | They never prove a score is valid. |

MVP verification should start with marker approval, organizer override, dispute handling, signed references, and an audit trail.

---

## Roadmap

| Phase | Scope |
| --- | --- |
| Phase 0: Foundation | Reconcile repo governance files, ADRs, issue templates, PR template, CI skeleton, WSL scripts, data registry, and deck assets. |
| Phase 1: MVP tournament loop | Nostr identity, Nostash/NIP-07 onboarding, registration, teams, roles, course baseline, scorekeeper flow, payment state, standings. |
| Phase 2: Live event polish | Offline scorekeeping, public scoreboard, maps, announcements, dry run, QA, operational runbook. |
| Phase 3: Ecosystem integration | Nostr publishing, NWC refinement, zaps, badges, sponsor dashboards, community course tools. |
| Phase 4: Reusable platform | Multiple events, configurable formats, plugin surface, data exports, legally reviewed future regulated features. |

### Sprint Sequence

| Sprint | Primary outcomes |
| --- | --- |
| Sprint 0: Project foundation | Review and commit generated governance files, ADRs, issue templates, PR template, CI skeleton, data registry, labels, milestones, and issue import. |
| Sprint 1: Identity and registration slice | PWA shell, guest-first entry, NIP-07 signer detection, Nostash onboarding modal, signed auth challenge, registration form, player/team model, organizer admin view, accessibility checks. |
| Sprint 2: Course data and scorekeeper prototype | Course import/manual entry, course selection, basic score entry, standings calculation, initial attestation state. |
| Sprint 3: Bitcoin/Lightning fee contribution | BTCPay adapter, NWC spike, payment status, registration confirmation, reconciliation view, failure/expiry states. |
| Sprint 4: Live event readiness | Offline score entry, sync rules, public scoreboard, venue maps, event dry run, QA plan, operational runbook. |
| Sprint 5: Wallet/course hardening | Wallet revocation/rotation, zaps/rewards controls, course correction queue, moderation, data-quality display. |

---

## Development Environment

This section reflects the v0.4.1 proposed implementation direction. Treat it as the working baseline until Sprint 0 confirms the committed repo layout and package scripts.

### Recommended Local Tools

| Tool | Purpose |
| --- | --- |
| Git | Source control and contribution workflow. |
| Node.js LTS | TypeScript, React/Vite PWA, Express API, build/test tooling. |
| PostgreSQL | Local MVP data store for registration, roles, payments, scores, audit logs, and course data. |
| Prisma CLI | Database schema, migrations, and generated client. |
| GitHub CLI | Optional but useful for importing generated labels, milestones, and issues. |
| WSL2 on Windows | Recommended Windows development path for GitHub import scripts and Unix-style tooling. |
| LibreOffice CLI | Optional; used to render the pitch deck to PDF during docs/asset refreshes. |
| Poppler `pdftoppm` | Optional; used to render pitch-deck PDF pages into PNG slide images. |
| Python + Pillow | Optional; used to generate pitch-deck thumbnails. |

### Expected Repo Layout

The exact implementation layout should be confirmed in Sprint 0. A practical starting point is:

```text
.
├── apps/
│   ├── web/                 # React/Vite PWA
│   └── api/                 # Node/Express/TypeScript API
├── packages/
│   ├── shared/              # Shared types, validation, Nostr event helpers
│   └── signer-adapters/     # NIP-07, NIP-46, NIP-55, local-dev adapters
├── docs/
│   ├── adr/                 # ADR template and ADR register
│   ├── data-sources/        # Course-data registry
│   ├── foundation/          # Foundation documents
│   └── pitch-deck/          # Deck, PDF, rendered slides, thumbnails
├── scripts/
│   ├── ci/                  # CI placeholder/replacement scripts
│   └── render_pitch_deck_assets.py
└── .github/
    ├── ISSUE_TEMPLATE/
    ├── workflows/
    └── pull_request_template.md
```

### Environment Variables

Create `.env.local` or service-specific env files from the eventual `.env.example`. Do not commit secrets.

```bash
# Database
DATABASE_URL="postgresql://ride_or_die:ride_or_die@localhost:5432/ride_or_die_scorecard"

# Public app configuration
APP_BASE_URL="http://localhost:5173"
API_BASE_URL="http://localhost:3000"

# Nostr
NOSTR_DEFAULT_RELAYS=""
NOSTR_AUTH_CHALLENGE_TTL_SECONDS="300"

# Payments - placeholders only
BTCPAY_URL=""
BTCPAY_STORE_ID=""
BTCPAY_API_KEY=""
NWC_RELAY_URL=""

# Operational mode
NODE_ENV="development"
```

Security rules:

- Never store raw `nsec` keys, seed phrases, wallet secrets, or user private keys in the app database.
- Never ask users to paste raw `nsec` keys in the primary onboarding flow.
- Keep BTCPay/NWC credentials server-side only.
- Keep signer capability checks client-side, but verify signed auth challenges server-side.

### First Local Setup

Commands will need to be finalized when the app packages land. No package manager is locked in by v0.4.1; the example below uses npm placeholders until Sprint 0 confirms the repo scripts:

```bash
# 1. Clone the repository
git clone <repo-url>
cd ride-or-die-scorecard

# 2. Install dependencies once package manifests exist
npm install

# 3. Prepare local env files
cp .env.example .env.local

# 4. Start PostgreSQL locally, then run migrations once Prisma is initialized
npx prisma migrate dev

# 5. Run local development services
npm run dev

# 6. Run quality checks before opening a PR
npm run format
npm run lint
npm test
```

Until the package scripts are real, CI should stay explicit about placeholder commands so contributors do not mistake scaffolding for a passing implementation.

### Local Nostr Signer Testing

For Sprint 1, test these paths directly:

| Case | Expected behavior |
| --- | --- |
| Desktop browser with NIP-07 signer | `window.nostr` is detected; user can sign auth challenge. |
| Desktop browser without signer | User stays in guest mode and sees signer guidance only on gated actions. |
| iOS/iPadOS Safari with Nostash enabled | `window.nostr` is detected; user can connect and sign. |
| iOS/iPadOS Safari without Nostash | User sees guided Nostash install/enable modal. |
| iOS Home Screen PWA | Verify whether `window.nostr` exists. If not, show **Open in Safari to connect securely**. |
| Android | Keep NIP-55 and/or NIP-46 paths behind the signer-adapter abstraction until ready. |

### Refresh Pitch Deck Images

The rendered slide images and thumbnails in this package were generated from the v0.4.1 deck. To refresh them after editing the deck:

```bash
python scripts/render_pitch_deck_assets.py \
  docs/pitch-deck/ride_or_die_scorecard_pitch_deck_v0_4_1_updated.pptx \
  docs/pitch-deck
```

The script writes:

- Full-size PNG slides to `docs/pitch-deck/images/`
- README thumbnails to `docs/pitch-deck/thumbnails/`
- A PDF export beside the deck

---

## Backlog Themes

| Theme | Epic scope |
| --- | --- |
| Identity and access | Guest-first entry, Nostr login/association, NIP-07 signer detection, Nostash onboarding, signed auth challenge, role permissions, admin access, fallback registration. |
| Registration and teams | Player forms, team manager flows, roster status, rules acceptance, exports. |
| Payments and wallets | BTCPay invoices, NWC wallet connection, WebLN fallback, fee status, zaps, rewards, reconciliation. |
| Course data | Source registry, importers, normalization, benchmark regions, corrections, ratings. |
| Maps and locations | OpenStreetMap venue display, hotels, meeting points, course maps, attribution. |
| Scoring engine | Golf scoring format, hole-by-hole entry, validation, corrections, audit trail, state machine. |
| Attestation and disputes | Validity attestations, marker review, organizer override, challenge/appeal windows, timestamp anchoring. |
| Live scoreboard | Public standings, refresh strategy, score snapshots, Nostr events, fan display. |
| PWA and offline | Installability, service worker, IndexedDB queue, sync, mobile-first outdoor UX. |
| Accessibility and QA | WCAG-oriented acceptance criteria, keyboard/screen-reader testing, automated tests, dry runs. |
| Governance and community | Contributor guide, code of conduct, issue templates, ADRs, bounties, sponsor policy. |
| Future regulated features | Prediction/betting research only; legal gate before implementation. |

---

## Contribution Entry Points

| Contributor | Strong first contribution |
| --- | --- |
| Developer | Read this README, `CONTRIBUTING.md`, and the ADR index. Pick a good-first-issue after Sprint 0 status is clean. |
| UX specialist | Review guest-to-unlock onboarding, Nostash signer modal, scorekeeper flow, wallet states, course corrections, and accessibility states. |
| Nostr engineer | Review NIP-07/Nostash onboarding, signer abstraction, auth challenge, relay strategy, event kinds, NIP-46 fallback, and NIP-55 Android path. |
| Lightning engineer | Review NWC/NIP-47, BTCPay invoices/webhooks, payment state machine, non-custodial UX, revocation, expiry, and reconciliation. |
| Security reviewer | Focus on signing, wallet permissions, admin actions, payment status, audit logs, and CI metadata gates. |
| License reviewer | Focus on dependency licenses, course-data licenses, ODbL mixing, attribution, and redistribution risk. |
| Course data steward | Benchmark target regions, define field-level provenance, and separate raw imports, normalized records, user suggestions, and organizer-approved scoring data. |
| Sponsor | Fund replaceable rails: hosting credits, wallet testing, security review, bounties, prizes, media, or course-data enrichment. |
| Organizer | Validate the real event loop: registration, role assignment, scorekeeping, disputes, payment reconciliation, and event-day fallback procedures. |

---

## Risk Register Highlights

| Risk | Severity | Control |
| --- | --- | --- |
| Generated-artifact drift | High | Confirm what is actually committed to the live repo and update docs when local artifacts diverge. |
| ADR status confusion | High | Keep ADRs 0011-0022 Proposed until reviewed and accepted by PR. |
| Course-data license conflict | High | Require license review before publishing or combining datasets. |
| Offline score sync bugs | High | Test under real course connectivity conditions and force sync-failure scenarios. |
| Scope creep | High | Protect the register/pay/score/attest loop before adding fan features. |
| Regulatory exposure | High | Keep betting/prediction markets out of scope unless a separate legal ADR clears them. |
| Signer onboarding friction | High | Keep guest mode open, guide iOS/iPadOS Safari users to Nostash, detect `window.nostr`, and keep fallback signer paths behind adapters. |

---

## Pitch Deck

The current pitch deck is **foundation deck v0.4.1**. It reflects the latest foundation-document direction: guest-first onboarding, Nostash on iOS/iPadOS Safari, signer adapters, proposed ADR discipline, score-integrity separation, Sprint 1 scope, wallet/payment direction, and updated risks.

- [Download the editable PowerPoint](docs/pitch-deck/ride_or_die_scorecard_pitch_deck_v0_4_1_updated.pptx)
- [Open the PDF export](docs/pitch-deck/ride_or_die_scorecard_pitch_deck_v0_4_1_updated.pdf)
- [Browse full-size slide images](docs/pitch-deck/images/)
- [Browse README thumbnails](docs/pitch-deck/thumbnails/)

### Slide Gallery

| 1 | 2 | 3 | 4 |
| --- | --- | --- | --- |
| [![Slide 1: Title](docs/pitch-deck/thumbnails/slide-01-thumb.png)](docs/pitch-deck/images/slide-01.png)<br>Title | [![Slide 2: Current Status](docs/pitch-deck/thumbnails/slide-02-thumb.png)](docs/pitch-deck/images/slide-02.png)<br>Current Status | [![Slide 3: What Changed in v0.4.1](docs/pitch-deck/thumbnails/slide-03-thumb.png)](docs/pitch-deck/images/slide-03.png)<br>v0.4.1 Update | [![Slide 4: Vision](docs/pitch-deck/thumbnails/slide-04-thumb.png)](docs/pitch-deck/images/slide-04.png)<br>Vision |
| [![Slide 5: Governance](docs/pitch-deck/thumbnails/slide-05-thumb.png)](docs/pitch-deck/images/slide-05.png)<br>Governance | [![Slide 6: Roles](docs/pitch-deck/thumbnails/slide-06-thumb.png)](docs/pitch-deck/images/slide-06.png)<br>Roles | [![Slide 7: Product UX](docs/pitch-deck/thumbnails/slide-07-thumb.png)](docs/pitch-deck/images/slide-07.png)<br>Product + UX | [![Slide 8: Nostr Onboarding](docs/pitch-deck/thumbnails/slide-08-thumb.png)](docs/pitch-deck/images/slide-08.png)<br>Nostr Onboarding |
| [![Slide 9: MVP Definition](docs/pitch-deck/thumbnails/slide-09-thumb.png)](docs/pitch-deck/images/slide-09.png)<br>MVP Definition | [![Slide 10: Technical Architecture](docs/pitch-deck/thumbnails/slide-10-thumb.png)](docs/pitch-deck/images/slide-10.png)<br>Architecture | [![Slide 11: Signer Adapters](docs/pitch-deck/thumbnails/slide-11-thumb.png)](docs/pitch-deck/images/slide-11.png)<br>Signer Adapters | [![Slide 12: Data Architecture](docs/pitch-deck/thumbnails/slide-12-thumb.png)](docs/pitch-deck/images/slide-12.png)<br>Course Data |
| [![Slide 13: Score Integrity](docs/pitch-deck/thumbnails/slide-13-thumb.png)](docs/pitch-deck/images/slide-13.png)<br>Score Integrity | [![Slide 14: Wallet and Payments](docs/pitch-deck/thumbnails/slide-14-thumb.png)](docs/pitch-deck/images/slide-14.png)<br>Wallet + Payments | [![Slide 15: Security and Accessibility](docs/pitch-deck/thumbnails/slide-15-thumb.png)](docs/pitch-deck/images/slide-15.png)<br>Security + A11y | [![Slide 16: Roadmap and Sprints](docs/pitch-deck/thumbnails/slide-16-thumb.png)](docs/pitch-deck/images/slide-16.png)<br>Roadmap |
| [![Slide 17: Backlog](docs/pitch-deck/thumbnails/slide-17-thumb.png)](docs/pitch-deck/images/slide-17.png)<br>Backlog | [![Slide 18: Risks](docs/pitch-deck/thumbnails/slide-18-thumb.png)](docs/pitch-deck/images/slide-18.png)<br>Risks | [![Slide 19: Call to Action](docs/pitch-deck/thumbnails/slide-19-thumb.png)](docs/pitch-deck/images/slide-19.png)<br>Call to Action |  |

---

## Foundation Documents

- [Foundation document v0.4.1 - Nostash onboarding update](docs/foundation/ride_or_die_cup_foundation_document_v0_4_1_nostash_onboarding.docx)

---

## Governance Notes

- Architecture-impacting changes should reference an accepted ADR or create/update one.
- ADRs 0011-0022 are proposed until the maintainers explicitly accept or revise them.
- Betting and prediction-market features are outside MVP and require separate legal/compliance review.
- Course-data imports must preserve source, license, timestamp, transformation, and provenance metadata.
- Releases should include changelog, migration notes, known limitations, and an event-readiness checklist.

---

## License

Open-source is the project direction. Confirm the repository license before redistribution, dependency lock-in, or external data publishing.
