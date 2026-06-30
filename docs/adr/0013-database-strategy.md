# ADR 0013: Use PostgreSQL with Prisma ORM for Persistent Storage

## Status

Proposed

## Context

The backend must durably store:

- User identities and roles (Nostr pubkeys, permissions)
- Score submissions and revisions (audit trail required)
- Score attestations and disputes (who attested, when, outcome)
- Payment invoices and state (registration fees, zaps, rewards)
- Events and metadata (courses, tournaments, participants)

Database choice impacts:

- Query complexity for audit trails and temporal data
- Ability to enforce referential integrity (payment → user → attestation)
- Transactional guarantees for financial correctness
- Scalability to handle concurrent score submissions
- Ease of backup and disaster recovery

## Decision

We will use **PostgreSQL 15+ as the primary database** with **Prisma.io as the ORM**.

Additionally:

- **Managed Provider**: Supabase (recommended for MVP) or Railway/Render
- **Migrations**: Prisma migrate for schema versioning and rollback
- **Backups**: Daily automated backups managed by provider
- **Replication**: Provider handles, no manual setup required
- **Indexes**: Prisma schema + manual query optimization as needed

## Alternatives

- **SQLite**: Good for prototyping, weak audit trail support, poor concurrency, not suitable for production
- **MongoDB**: Flexible schema, but poor support for financial audit trails and complex queries
- **Firebase/Firestore**: Vendor lock-in, slower for relational queries, weak temporal support
- **Cassandra**: Overkill for MVP, operational complexity
- **MySQL**: Similar to PostgreSQL, but PostgreSQL has better JSONB and window functions

## Trade-offs

**Pros**:

- PostgreSQL's JSONB column type allows flexible Nostr event storage alongside structured data
- Strong window functions and temporal query support for audit trails
- Foreign keys and constraints enforce data integrity (critical for payments)
- Prisma generates type-safe queries in TypeScript
- Mature ecosystem with excellent tooling
- Managed providers (Supabase, Railway) eliminate ops burden
- Excellent support for complex queries (score rankings, leaderboards)
- ACID transactions guarantee payment correctness

**Cons**:

- Slightly more operational complexity than MongoDB for simple use cases (not applicable with managed services)
- Requires thoughtful schema design upfront (good practice anyway)
- Pricing can scale with data size (mitigated for MVP with managed providers)

## License Review

- **PostgreSQL**: PostgreSQL License (permissive, GPL-compatible) ✓
- **Prisma**: Apache 2.0, open-source ✓
- Supabase/Railway: Proprietary SaaS but data is portable ✓
- All open-source database components compatible with project license

## Security Review

- PostgreSQL's row-level security (RLS) can enforce access control (user can only see own scores)
- Prisma parameterized queries prevent SQL injection
- Managed provider handles security updates
- Must NOT store Nostr private keys or seed phrases (application enforces)
- Implement audit logging for sensitive mutations (score changes, payment status)
- Use environment variables for database credentials (GitHub Secrets)
- Encrypt backups in transit and at rest (managed provider responsibility)

## Rollback Plan

If PostgreSQL becomes a blocker:

1. Migrate to SQLite for development, scale to PostgreSQL later
2. Use Firebase/Firestore if schema flexibility becomes critical issue
3. Keep Prisma ORM (works with multiple databases)

## Implementation Plan

- Initialize Prisma project: `npx prisma init`
- Design schema for users, scores, attestations, payments (see schema appendix)
- Create migrations: `prisma migrate dev --name init`
- Set up Supabase or Railway PostgreSQL instance
- Configure DATABASE_URL environment variable
- Implement seed script for test data
- Add database indexes for query performance
- Create backup and restore documentation

## Database Schema (High-Level)

```prisma
model User {
  id          String    @id  // Nostr pubkey (hex)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  // Profile
  name        String?
  image       String?    // Avatar URL
  role        UserRole   @default(PLAYER)  // PLAYER, MARKER, ORGANIZER, ADMIN
  
  // Relations
  submittedScores  Score[]
  attestations     Attestation[]
  payments         Payment[]
}

model Score {
  id          String    @id @default(uuid())
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  // Content
  eventId     String    // Reference to golf event/course
  courseId    String
  playerId    String    // Nostr pubkey
  scoreValue  Int       // Stroke count
  payload     Json      // Full score details (holes, handicap, etc.)
  payloadHash String    // SHA256 hash for integrity
  
  // State
  status      ScoreStatus  @default(SUBMITTED)  // SUBMITTED, ATTESTED, ACCEPTED, REJECTED
  
  // Relations
  player      User      @relation(fields: [playerId], references: [id])
  attestations Attestation[]
  
  @@index([eventId])
  @@index([playerId])
  @@index([status])
}

model Attestation {
  id          String    @id @default(uuid())
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  // Reference
  scoreId     String
  attestorId  String    // Nostr pubkey who attested
  
  // Content
  status      AttestationStatus @default(APPROVED)  // APPROVED, DISPUTED, WITHDRAWN
  comment     String?
  
  // Nostr
  eventKind   Int       // NIP event kind
  eventHash   String    // Reference to published Nostr event
  
  // Relations
  score       Score     @relation(fields: [scoreId], references: [id], onDelete: Cascade)
  attestor    User      @relation(fields: [attestorId], references: [id])
  
  @@index([scoreId])
  @@index([attestorId])
}

model Payment {
  id          String    @id @default(uuid())
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  // Amount
  amountSats  Int
  amountUsd   Decimal?
  
  // State
  status      PaymentStatus @default(PENDING)  // PENDING, CONFIRMED, FAILED, REFUNDED
  
  // Invoice
  invoiceId   String?   // BTCPay invoice ID
  invoiceUrl  String?
  
  // Reference
  userId      String
  purpose     String    // "registration", "zap", "reward"
  
  // Relations
  user        User      @relation(fields: [userId], references: [id])
  
  @@index([userId])
  @@index([status])
}

enum UserRole {
  PLAYER
  MARKER
  ORGANIZER
  ADMIN
}

enum ScoreStatus {
  SUBMITTED
  ATTESTED
  ACCEPTED
  REJECTED
  DISPUTED
}

enum AttestationStatus {
  APPROVED
  DISPUTED
  WITHDRAWN
}

enum PaymentStatus {
  PENDING
  CONFIRMED
  FAILED
  REFUNDED
}
```

## Validation

- `prisma migrate deploy` succeeds without errors
- Sample queries return correct results
- Audit trail is complete (updatedAt tracks all mutations)
- Foreign key constraints prevent orphaned records
- Payment state machine is enforced at database level
- Backup and restore cycle works end-to-end

## Follow-up Decisions

- Should we implement row-level security (RLS) for user data isolation?
- Which indexes are required beyond primary keys? (Performance profiling)
- How long should audit logs be retained?
- What is the backup retention policy?

## References

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Prisma Documentation](https://www.prisma.io/docs/)
- [Supabase Documentation](https://supabase.com/docs)
- [Railway Postgres](https://railway.app/)
- [Render Postgres](https://render.com/docs/databases)
