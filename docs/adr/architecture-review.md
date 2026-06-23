# Ride or Die Scorecard - Architecture Review

## Executive Summary

Ride or Die Scorecard is shaping up as a **Nostr-native, non-custodial Bitcoin/Lightning event platform**. The ADR foundation is strong and philosophically cohesive. The project is at a critical juncture where backend architecture, client framework, and attestation implementation need to be decided.

**Current Status**: 5 ADRs defined (1 Accepted, 4 Proposed)
**Critical Path**: Backend + Frontend frameworks → Nostr relay strategy → Attestation verification → Payment flows

---

## Architecture Decision Tree

```
┌─────────────────────────────────────────────────────────────────────┐
│ ADR-0001: Nostr Identity (ACCEPTED) ✓                              │
│ → Nostr pubkeys as primary identity anchor                         │
│ → No proprietary accounts; portable across clients                 │
└─────────────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│ ADR-0003: PWA Client (PROPOSED)                                    │
│ → Primary client: Progressive Web App                              │
│ → Mobile/desktop/tablet responsive                                 │
│ → Offline-capable scorekeeper flows                                │
│ → Browser extension signing support required                       │
└─────────────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│ ADR-0002: Nostr Wallet Connect (PROPOSED)                          │
│ → NIP-47 for Lightning wallet integration                          │
│ → Non-custodial: app connects to user wallet                       │
│ → Fallback: BTCPay Server invoices for registration                │
└─────────────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│ ADR-0008: Non-Custodial Payment Design (PROPOSED)                  │
│ → No fund custody, key storage, or seed phrases                    │
│ → App coordinates but does not execute payments                    │
│ → Robust payment state and failure handling                        │
└─────────────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│ ADR-0006: Score Attestation Model (PROPOSED)                       │
│ → Peer attestation of scores (plausibility/correctness)            │
│ → Nostr-signed attestation events                                  │
│ → Score state machine: submitted → attested → accepted/rejected    │
│ → Audit trail linked to Nostr identities                           │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Dependencies

1. **Nostr Identity** is the foundation for everything
   - Required by: PWA client (for signing), Wallet Connect (user auth), Attestation (who attested?)

2. **PWA Client** enables browser-extension-based signing
   - Enables: NWC flows (desktop → mobile wallet via extension), smooth UX

3. **NWC/Non-Custodial Payments** constrain backend design
   - Backend must NOT store keys/secrets, must track payment state only

4. **Score Attestation** drives database schema and API complexity
   - Requires: Strong audit trail, score hashing, state machine logic, conflict resolution

---

## Current Gaps & Next Critical Decisions

### Tier 1: Architecture Foundation (MUST DECIDE FOR MVP)

#### 1.1 Backend API Framework & Language
**Choices impact**: Developer velocity, Nostr library ecosystem, Bitcoin tooling, deployment complexity

**Recommendation: TypeScript + Node.js**
- **Why**: 
  - Strong Nostr library ecosystem (`nostr-tools`, `nostr-react`)
  - Bitcoin/Lightning libraries mature (LDK, BTCPay integration)
  - PWA + backend share TypeScript reduces context switching
  - Rapid iteration aligns with MVP timeline
  - Good for async payment state tracking

- **Framework options**:
  - **Express.js** (mature, well-known, large ecosystem) ✓
  - **Hono** (lightweight, Nostr-friendly, good for serverless)
  - **Fastify** (performance-focused, good for high-throughput)

- **Decision needed**: Express vs Hono vs Fastify? Self-hosted or serverless?

#### 1.2 Backend Database
**Choices impact**: Attestation audit trail, score state machine, query complexity, scalability

**Recommendation: PostgreSQL (managed)**
- **Why**:
  - Relational schema fits score attestation model perfectly
  - Strong support for audit trails, temporal queries, constraints
  - JSONB for flexible Nostr event storage
  - Mature ecosystem, good for operational complexity
  - Managed options (Supabase, Render, Railway) reduce ops burden

- **Alternatives considered**:
  - SQLite: Good for MVP, harder to scale, weaker audit support
  - Firebase/Firestore: Couples you to Google, slower for relational queries
  - MongoDB: Weaker for financial audit trails

- **Decision needed**: PostgreSQL (yes/no)? Which managed provider?

#### 1.3 Frontend Framework
**Choices impact**: PWA capabilities, offline support, signing UX, browser compatibility

**Recommendation: React + TypeScript**
- **Why**:
  - Large Nostr ecosystem (nostr-react, hooks)
  - Strong service-worker tooling (Workbox integration)
  - Excellent state management for offline scenarios
  - Strong PWA/mobile-first community
  - Same language as backend (TypeScript)

- **Alternatives considered**:
  - Vue: Strong, but smaller Nostr ecosystem
  - Svelte: Elegant, but fewer Bitcoin/Nostr libraries
  - Solid.js: Promising, but immature Nostr support

- **Decision needed**: React (yes/no)? UI component library? (shadcn/ui recommended)

#### 1.4 Nostr Relay Strategy
**Choices impact**: Event distribution, identity verification, payment proof, uptime

**Critical questions for next ADR**:
- Self-hosted relays or integrated relay discovery?
- Which relays are mandatory for MVP? (identity, payments, attestations)
- Fallback strategy if relay fails?
- How are user events published (app-published or user-published)?

**Recommendation**: Start with `nostr-tools` relay abstractions + relay.js, then evaluate self-hosting

---

### Tier 2: Payment & Wallet Integration (MUST DECIDE FOR MVP)

#### 2.1 Wallet Connection Flow
**Current ADR-0002 status**: Proposed but TBD

**Decisions needed**:
- NWC-only for MVP or include WebLN fallback?
- Which wallets are officially supported? (Alby, Mutiny, Breez, etc.)
- QR code connection or URI scheme deep linking?
- How are spending permissions shown to users?

**Recommendation**: NWC (primary) + WebLN fallback + BTCPay invoices (fallback)

#### 2.2 Registration Fee Payment
**Current plan**: Organize invoices via BTCPay, users pay via NWC or manual transfer

**Decisions needed**:
- Is BTCPay Server the backend? (vs custom invoice management)
- How are fees verified/confirmed in app state?
- Retry logic for failed payments?
- Free event support or always paid?

---

### Tier 3: Score Attestation & Verification (MUST DECIDE FOR MVP)

#### 3.1 Attestation Verification Strategy
**Current ADR-0006 status**: Proposed but TBD on verification details

**Decisions needed**:
- Real-time verification (verify on submit) or async (batch verify)?
- How many attestations required for score acceptance? (1, 2, consensus?)
- Reputation system for attestors or role-based (marker-only)?
- Dispute/challenge mechanism? Who adjudicates?

**Recommendation**: 
- Real-time verification (faster feedback)
- Role-based initially: organizer + marker approval for MVP
- Peer attestation post-MVP

#### 3.2 Score Attestation Payload & Signing
**Decisions needed**:
- Nostr event kind for score submission? (Custom kind?)
- Score payload format (JSON schema)?
- Attestation references score by hash or full payload?
- Are signed attestations published to relays immediately or only after acceptance?

**Recommendation**:
- Use `nip-23` (long-form content) or custom event kind for scores
- Hash-based reference for attestation (prevents tampering)
- Publish after acceptance, not before

---

### Tier 4: Supporting Architecture (DECIDE EARLY)

#### 4.1 Hosting & Deployment
**Decisions needed**:
- Self-hosted (costs + ops complexity) or managed PaaS?
- CI/CD pipeline (GitHub Actions?)
- Database backups and disaster recovery?

**Recommendation**: 
- **Railway** or **Render** (Node.js + PostgreSQL + GitHub integration)
- GitHub Actions for CI/CD
- Automated backups included

#### 4.2 Offline & Offline State Sync
**Current PWA ADR mentions**: Offline behavior must be deliberately designed

**Decisions needed**:
- Which features work offline? (Scorekeeper submit, view history?)
- Service worker caching strategy?
- State sync when connectivity restored?

**Recommendation**: 
- Scorekeeper can submit scores offline (cached)
- Sync on reconnect (conflict resolution via last-write-wins or marker approval)
- Redux or Zustand for offline state management

---

## Recommended Tech Stack (Comprehensive)

### Backend Stack
```
Language:        TypeScript 5.x
Runtime:         Node.js 20+ LTS
Framework:       Express.js 4.x (or Hono for lighter footprint)
Database:        PostgreSQL 15+ (managed: Supabase, Render, Railway)
ORM:             Prisma.io (type-safe, Nostr-friendly)
Signing:         nostr-tools
Lightning:       ldk-node or BTCPay Server integration
API:             REST (or tRPC for type safety)
Testing:         Vitest + Supertest
Linting:         ESLint + Prettier
```

### Frontend Stack
```
Language:        TypeScript 5.x
Framework:       React 18.x
Build:           Vite
PWA:             Workbox (service worker management)
State:           Redux Toolkit (or Zustand)
UI Library:      shadcn/ui + Tamagui
Nostr:           nostr-tools + nostr-react hooks
Signing:         NIP-07 (browser extension) + NWC
Icons:           Heroicons or Lucide
Testing:         Vitest + React Testing Library
Linting:         ESLint + Prettier
Offline:         Workbox + service worker
```

### Infrastructure Stack
```
Hosting:         Railway.app or Render
Database:        PostgreSQL 15+ (managed)
CI/CD:           GitHub Actions
Monitoring:      Railway/Render built-in + Sentry
Nostr Relays:    nostr-tools relay discovery + relay.js
Payment:         BTCPay Server (organizer) + NWC (user)
CDN:             Railway/Render built-in
Secrets:         GitHub Secrets + environment management
```

### Why This Stack?

| Criterion | Choice | Rationale |
|-----------|--------|-----------|
| **Nostr Ecosystem** | TypeScript + Node.js | Strongest libraries (nostr-tools, NIPs) |
| **Bitcoin/Lightning** | LDK or BTCPay | Mature, non-custodial patterns |
| **PWA + Offline** | React + Workbox | Best-in-class service worker tooling |
| **Type Safety** | TypeScript + Prisma | Catch bugs early, especially around payments |
| **Scalability** | PostgreSQL + Express | Audit trails, temporal queries, high-concurrency |
| **Developer Experience** | Vite + shadcn/ui | Fast iteration, accessible components |
| **Deployment** | Railway/Render | Simple scaling, automated backups, GitHub integration |
| **Non-Custodial** | Distributed design | Backend never touches keys or funds |

---

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USERS (Distributed)                        │
│      Scorekeepers, Players, Markers, Organizers, Sponsors          │
└─────────────────┬───────────────────────────────────────────────────┘
                  │ HTTPS/WSS
      ┌───────────┴──────────────┬──────────────────┐
      │                          │                  │
      │                    ┌─────▼─────┐    ┌──────▼──────┐
      │                    │ PWA Client │    │ Native/CLI? │
      │                    │ (React)    │    │ (Future)    │
      │                    │ + Nostr    │    └─────────────┘
      │                    │ Signing    │
      │                    │ (NIP-07)   │
      │                    └─────┬──────┘
      │                          │
      │            ┌─────────────▼────────────────┐
      │            │   Nostr Wallet Connect       │
      │            │   (NIP-47 Bridge)            │
      │            │   → Lightning Wallets        │
      │            └─────────────┬────────────────┘
      │                          │
      ▼                          ▼
┌──────────────────────────────────────────────────────┐
│              REST API (Node.js/Express)              │
│  - Auth (Nostr pubkey + NIP-98 message signing)     │
│  - Scores (submit, list, query)                     │
│  - Attestations (create, resolve, audit)            │
│  - Users & Roles (identity, permissions)            │
│  - Payments (invoice status, zap validation)        │
│  - Events & Relays (Nostr event publishing)         │
└──────────────────────────┬───────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌──────────┐      ┌──────────┐      ┌──────────┐
   │PostgreSQL│      │ Nostr    │      │BTCPay    │
   │ (Scores, │      │ Relays   │      │ Server   │
   │Attestns, │      │(Events)  │      │(Invoices)│
   │ Users)   │      │          │      │          │
   └──────────┘      └──────────┘      └──────────┘
```

---

## Risk Analysis & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Nostr relay downtime** | Score attestations cannot be published | Start with multiple relay connections, fallback to app-only state until relay recovers |
| **NWC wallet support fragmentation** | Users can't pay | Offer BTCPay invoice fallback, document supported wallets |
| **Attestation dispute handling** | Scores challenged but unresolved | Define clear ADR for dispute process (arbitration, role hierarchy) |
| **PWA iOS limitations** | Some users can't use app | Plan thin native wrapper post-MVP if needed |
| **Payment state sync fails** | App thinks payment failed but it succeeded | Implement idempotent invoice handling, organizer reconciliation UI |
| **Compromised Nostr key** | User's identity stolen | Document key recovery process, support key rotation, reputation system |
| **Score tampering after attestation** | Integrity broken | Hash-based references, immutable event publishing, audit trail |

---

## Next Steps: Recommended Decision Order

### Phase 1: Core Framework (Week 1-2)
- [ ] **ADR-0011**: Decide backend language & framework (TypeScript + Express vs Hono?)
- [ ] **ADR-0012**: Decide frontend framework (React vs Vue?)
- [ ] **ADR-0013**: Decide database strategy (PostgreSQL + Prisma)
- [ ] **ADR-0014**: Decide hosting & deployment (Railway vs Render vs self-hosted)

### Phase 2: Nostr & Payment Integration (Week 3-4)
- [ ] **ADR-0015**: Define Nostr relay strategy (which relays, fallback behavior)
- [ ] **ADR-0016**: Finalize NWC wallet integration (supported wallets, error handling)
- [ ] **ADR-0017**: Define payment invoice flow (BTCPay backend, state machine)

### Phase 3: Score Attestation (Week 5-6)
- [ ] **ADR-0018**: Score attestation payload & event kinds (JSON schema, Nostr NIP)
- [ ] **ADR-0019**: Attestation verification strategy (real-time, role-based, consensus)
- [ ] **ADR-0020**: Dispute resolution & conflict handling (organizer adjudication)

### Phase 4: PWA & Offline (Week 7-8)
- [ ] **ADR-0021**: PWA offline strategy (which features, state sync, caching)
- [ ] **ADR-0022**: Service worker caching & update strategy

---

## Questions for Project Owners

1. **Timeline**: MVP target date? (Affects framework/tech choices)
2. **Event scale**: Typical event size? (10 players vs 100 vs 1000?)
3. **Team size**: How many developers? (Affects deployment complexity, ops burden)
4. **Self-hosting vs SaaS**: Willing to manage infrastructure?
5. **Bitcoin network**: Mainnet, testnet, or signet for MVP?
6. **Key decision: Nostr relay operations**: Self-hosted relays or rely on public relays?

---

## Summary

The Ride or Die Scorecard architecture is **philosophically strong** and well-aligned around Nostr identity, non-custodial payments, and score attestation. The tech stack recommendation (**TypeScript + React + Node.js + PostgreSQL + Railway**) is cohesive, proven for fintech/payment scenarios, and has a strong Nostr ecosystem.

**Next action**: Create ADRs 0011-0022 to lock in backend/frontend/database choices, then implementation can proceed rapidly with clear constraints and dependencies mapped.

