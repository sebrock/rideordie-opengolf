# ADR Creation Summary: 0011-0022

## Overview

Created 12 new Architecture Decision Records to lock in framework, database, and deployment choices for Ride or Die Scorecard MVP.

## ADRs Created

| # | Title | Status | Category |
|---|-------|--------|----------|
| 0011 | Use TypeScript and Express.js for Backend API | Accepted | Framework |
| 0012 | Use React 18 with TypeScript for PWA Frontend | Accepted | Framework |
| 0013 | Use PostgreSQL with Prisma ORM for Persistent Storage | Accepted | Database |
| 0014 | Use Railway or Render for Hosting and Deployment | Accepted | Infrastructure |
| 0015 | Use Relay Discovery with Primary Relay Fallback for Nostr Event Publishing | Accepted | Nostr Integration |
| 0016 | Use Nostr Wallet Connect (NIP-47) as Primary Wallet Integration | Accepted | Payments |
| 0017 | Use BTCPay Server for Registration Invoice Generation | Accepted | Payments |
| 0018 | Use Custom Nostr Event Kinds for Score Submission and Attestation | Accepted | Data Structure |
| 0019 | Implement Real-Time Role-Based Score Attestation Verification | Accepted | Verification |
| 0020 | Implement Organizer-Led Dispute Resolution for Score Challenges | Accepted | Governance |
| 0021 | Implement Service-Worker-Based Offline Scorekeeper Workflow | Accepted | PWA/Offline |
| 0022 | Use Workbox for Service Worker Asset Precaching and Cache Management | Accepted | PWA/Offline |

## Technology Stack Summary

### Backend
- **Language**: TypeScript 5.x
- **Runtime**: Node.js 20+ LTS
- **Framework**: Express.js 4.x
- **ORM**: Prisma.io
- **Database**: PostgreSQL 15+
- **Testing**: Vitest + Supertest

### Frontend
- **Language**: TypeScript 5.x
- **Framework**: React 18.x
- **Build**: Vite
- **State**: Redux Toolkit
- **UI**: shadcn/ui + Tamagui
- **PWA**: Workbox
- **Testing**: Vitest + React Testing Library

### Infrastructure
- **Hosting**: Railway.app or Render
- **Database**: Managed PostgreSQL
- **CI/CD**: GitHub Actions
- **Nostr Relays**: damus.io, nostr.band (discovery-based)
- **Payments**: BTCPay Server + NWC

## Key Architectural Decisions Locked In

### 1. Backend Framework (ADR-0011)
✅ **TypeScript + Express.js** - strong Nostr ecosystem, rapid iteration
- Prisma ORM for type-safe database queries
- REST API (with migration path to tRPC)

### 2. Frontend Framework (ADR-0012)
✅ **React 18 + TypeScript + Vite** - PWA-native, Nostr library ecosystem
- shadcn/ui for accessible components
- Redux Toolkit for offline state management

### 3. Database (ADR-0013)
✅ **PostgreSQL 15+ with Prisma** - strong audit trails, JSONB support
- Full schema includes: users, scores, attestations, payments
- Foreign key constraints for data integrity

### 4. Hosting (ADR-0014)
✅ **Railway.app or Render** - minimal ops overhead, zero-config scaling
- Managed PostgreSQL included
- GitHub Actions for CI/CD
- Auto-deploy on push

### 5. Nostr Integration (ADR-0015)
✅ **Relay discovery + primary relay fallback** - decentralized, non-custodial
- Primary relays: damus.io, nostr.band
- Exponential backoff retry logic

### 6. Wallet Integration (ADR-0016)
✅ **NWC (NIP-47) as primary** with WebLN and BTCPay fallbacks
- Non-custodial: app coordinates but doesn't execute payments
- Supported wallets: Alby, Mutiny, Breez (MVP)

### 7. Payment Infrastructure (ADR-0017)
✅ **BTCPay Server for invoices** - open-source, Bitcoin/Lightning native
- Non-custodial: funds go directly to organizer
- Webhook-based payment confirmation
- State machine: PENDING → CONFIRMED → SETTLED

### 8. Score Data Structure (ADR-0018)
✅ **Custom Nostr event kinds (39000-39001)** - flexibility, auditability
- Kind 39000: Score submission
- Kind 39001: Score attestation
- SHA256 payload hashing for integrity

### 9. Attestation Verification (ADR-0019)
✅ **Real-time role-based verification** - simple MVP, scalable to peer attestation
- MVP: Single marker approval required
- Post-MVP: Peer attestation + reputation system
- Organizer override for disputes

### 10. Dispute Resolution (ADR-0020)
✅ **Organizer-led with appeal** - fair, auditable, transparent
- 48-hour challenge window
- Organizer decision with audit trail
- 7-day appeal period

### 11. Offline Strategy (ADR-0021)
✅ **Service-worker-based offline queue** - transparent to user
- Offline submissions saved to IndexedDB
- Automatic sync when online
- Last-write-wins conflict resolution

### 12. Cache Management (ADR-0022)
✅ **Workbox for service worker** - battle-tested, minimal complexity
- NetworkFirst for API
- CacheFirst for static assets
- StaleWhileRevalidate for HTML

## Implementation Path

### Week 1: Foundation
- [ ] Initialize backend: Express + TypeScript + Prisma
- [ ] Initialize frontend: React + Vite
- [ ] Create Prisma schema (users, scores, attestations)
- [ ] Deploy to Railway/Render

### Week 2: Auth & Identity
- [ ] Implement Nostr identity verification (NIP-98)
- [ ] User model + role management
- [ ] Login/signup flow

### Week 3: Scores & Attestation
- [ ] Score submission endpoint
- [ ] Marker approval workflow
- [ ] Nostr event publishing
- [ ] Score state machine

### Week 4: Payments
- [ ] BTCPay integration
- [ ] NWC wallet connection
- [ ] Registration fee flow
- [ ] Webhook handling

### Week 5: PWA & Offline
- [ ] Service worker setup (Workbox)
- [ ] Offline queue (IndexedDB)
- [ ] Sync engine
- [ ] Mobile UI

### Week 6: Testing & Polish
- [ ] Integration tests
- [ ] E2E testing
- [ ] Performance optimization
- [ ] Documentation

## Files Created

All ADRs saved to session folder and ready to copy to `/docs/adr/`:

```
0011-backend-language-framework.md
0012-frontend-framework.md
0013-database-strategy.md
0014-hosting-deployment.md
0015-nostr-relay-strategy.md
0016-wallet-connection.md
0017-payment-invoice-flow.md
0018-score-attestation-payload.md
0019-attestation-verification.md
0020-dispute-resolution.md
0021-offline-strategy.md
0022-service-worker-caching.md
```

## Next Steps

1. **Review ADRs** - Share with team, gather feedback
2. **Update Index** - Add all 12 ADRs to `/docs/adr/README.md`
3. **Initialize Repositories** - Create backend and frontend repos
4. **Set Up Development Environment** - Node.js, TypeScript, Vite
5. **Database Design** - Complete Prisma schema
6. **CI/CD Pipeline** - GitHub Actions workflow
7. **MVP Planning** - Break down into sprints/tickets

## Decision Quality

- ✅ All decisions are **specific** (not TBD)
- ✅ All decisions are **motivated** (pros/cons documented)
- ✅ All decisions are **coherent** (form a unified tech stack)
- ✅ All decisions are **implementable** (code examples provided)
- ✅ All decisions are **reversible** (rollback plans documented)

## Risk Mitigation

| Risk | ADR | Mitigation |
|------|-----|-----------|
| Node.js scaling limits | 0011 | Can migrate to Go/Rust post-MVP |
| PWA iOS limitations | 0012 | Native wrapper as fallback |
| PostgreSQL complexity | 0013 | Prisma ORM abstracts, start simple |
| Relay downtime | 0015 | Multiple relay fallbacks |
| NWC wallet support gaps | 0016 | WebLN + BTCPay fallbacks |
| Marker bottleneck | 0019 | Escalate to peer attestation post-MVP |
| Service worker bugs | 0021, 0022 | Workbox battle-tested, good debugging |

---

**Created**: 2026-06-23  
**Creator**: Copilot  
**Status**: Ready for team review and MVP planning
