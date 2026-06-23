# ADR 0011: Use TypeScript and Express.js for Backend API

## Status

Accepted

- **Date:** 2026-06-23
- **Decision owners:** sebrock
- **Reviewers:** sebrock

## Context

The backend API must support Nostr identity verification, score attestation workflows, non-custodial payment state tracking, and Nostr event publishing. The project prioritizes rapid MVP delivery while maintaining type safety and Bitcoin/Lightning integration.

Backend choices significantly impact:
- Time to MVP
- Developer experience and hiring
- Library ecosystem for Nostr and Bitcoin integration
- Scalability and operational complexity

## Decision

We will use **TypeScript 5.x as the language** and **Express.js 4.x as the HTTP framework** for the backend API.

Additionally:
- **ORM**: Prisma.io for database abstraction and type safety
- **HTTP Protocol**: REST with planned migration to tRPC for end-to-end type safety
- **Package Manager**: npm or pnpm (recommend pnpm for lockfile)
- **Testing**: Vitest for unit tests, Supertest for API integration tests

## Alternatives

- **Go** (Gin, Echo): Strong for concurrency, weak Nostr library ecosystem
- **Rust** (Actix, Axum): Excellent for safety, steep learning curve, slow MVP
- **Node.js (JavaScript)**: Fast, but loses type safety for complex payment logic
- **Python** (FastAPI, Django): Good framework ecosystem, weaker Bitcoin/Lightning libraries
- **Hono.js**: Lightweight, excellent for serverless, but smaller ecosystem
- **NestJS**: Opinionated, excellent DX, heavier dependency tree

## Trade-offs

**Pros**:
- TypeScript provides strong type safety for payment and attestation workflows
- nostr-tools ecosystem is TypeScript-native and well-maintained
- Express.js is mature, battle-tested, and widely understood
- Rapid iteration and good library coverage for OAuth, JWT, validation
- Can share TypeScript with frontend (React), reducing context switching
- Excellent support for async/await patterns (payments often involve async waits)
- Prisma ORM generates type-safe database queries, reducing audit trail bugs

**Cons**:
- Node.js single-threaded model requires careful async management for high-concurrency scenarios
- Less mature than Go or Rust for distributed systems (not critical for MVP)
- Requires attention to memory management under sustained load
- TypeScript compilation adds build step (negligible with Vite/ESBuild)

## License Review

- **Express.js**: MIT licensed, well-maintained ✓
- **TypeScript**: Apache 2.0, backed by Microsoft ✓
- **Prisma**: Apache 2.0, open-source ✓
- **nostr-tools**: MIT, community-maintained ✓
- **Vitest & Supertest**: MIT and MIT respectively ✓
- All dependencies are open-source compatible with project license

## Security Review

- TypeScript's type system prevents several classes of injection attacks (when used correctly)
- Express.js middleware ecosystem (helmet, cors, rate-limiting) is mature
- Prisma parameterized queries prevent SQL injection
- Will require security review of Nostr signing and key management
- Payment state mutations must be thoroughly tested and audited

## Rollback Plan

If TypeScript/Express complexity becomes a blocker:
1. Migrate to JavaScript (same Express.js codebase, lose type safety)
2. Migrate to Hono.js if serverless deployment becomes requirement

## Implementation Plan

- Set up Node.js 20 LTS development environment
- Initialize Express.js + TypeScript project with tsconfig.json
- Add Prisma schema and database migrations
- Implement Nostr identity middleware (NIP-98 message signing)
- Create API routes for scores, attestations, users, payments
- Add Vitest unit tests and Supertest integration tests
- Document API with OpenAPI/Swagger

## Validation

- API responds to HTTP requests with correct status codes
- TypeScript compilation succeeds with strict mode enabled
- All financial/payment mutations are covered by tests
- Nostr signature verification works end-to-end
- Development cycle is faster than rejected alternatives

## Follow-up Decisions

- Should we migrate to tRPC for end-to-end type safety with the frontend?
- Which validation library? (zod, joi, or Prisma validation?)
- How is request/response logging structured for audit trails?
- Rate limiting strategy for registration and payment endpoints?

## References

- [Express.js Documentation](https://expressjs.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Prisma Documentation](https://www.prisma.io/docs/)
- [nostr-tools GitHub](https://github.com/nbd-wtf/nostr-tools)
- [Node.js LTS Schedule](https://nodejs.org/en/about/previous-releases)
