# ADR 0019: Implement Real-Time Role-Based Score Attestation Verification

## Status

Accepted

- **Date:** 2026-06-23
- **Decision owners:** sebrock
- **Reviewers:** sebrock

## Context

ADR-0006 (Score Attestation Model) defines the concept of peer attestation. This ADR defines the verification strategy: how many attestations are required, who can attest, and when scores are accepted.

Attestation verification choices impact:

- Trust model (how much do we trust submitted scores?)
- Operational load (how many attestors do we need?)
- User experience (how long do players wait for acceptance?)
- Fraud prevention (can dishonest players collude?)

## Decision

We will implement **real-time, role-based score attestation verification** with the following rules:

**For MVP**:

- Single marker (role: MARKER) approval required
- Marker can approve or reject submitted score
- Organizer can override marker decision
- Score state: SUBMITTED → APPROVED → ACCEPTED (or REJECTED)
- Real-time: Marker can approve as soon as score is submitted

**For Post-MVP**:

- Peer attestation: Multiple players can attest to score plausibility
- Reputation system: Attestors with high reputation carry more weight
- Consensus: 2+ peer attestations needed if no marker present

## Alternatives

- **Organizer-only verification**: Single point of failure, high manual burden
- **Auto-accept all**: No trust model, scores unverified
- **Consensus (multi-sig)**: High friction for MVP, too slow
- **Photo-only**: Requires OCR, post-MVP feature

## Trade-offs

**Pros**:

- Simple for MVP: Clear decision maker (marker)
- Scalable: Easy to add peer attestation later
- Flexible: Organizer can override for edge cases
- Audit trail: Every decision is recorded with who and when

**Cons**:

- Single marker is a bottleneck if they're not available
- Collusion risk: Marker and player could both be dishonest (mitigated by organizer override)
- Peer attestation post-MVP requires reputation system (complex)

## License Review

- No external dependencies required for MVP verification logic
- All verification is application-level, no license concerns

## Security Review

- Attestation must be signed by attestor's Nostr key (prevents impersonation)
- Marker role must be verified before accepting attestation
- Attestation must reference exact score hash (prevents tampering)
- Audit trail must be immutable (stored in database)
- Organizer override must be logged separately (for dispute resolution)

## Rollback Plan

If marker verification is too slow:

1. Auto-accept scores for first 24 hours
2. Organizer can later dispute and require marker review
3. Implement background marker notification system

## Implementation Plan

### Phase 1: Role Management

- [ ] Add MARKER, ORGANIZER roles to User model
- [ ] Create endpoint to assign/revoke marker role (organizer-only)
- [ ] Implement authorization checks (user can only submit own scores)

### Phase 2: Score State Machine

- [ ] Add ScoreStatus enum: SUBMITTED, APPROVED, REJECTED, ACCEPTED, DISPUTED
- [ ] Create score submission endpoint
- [ ] Create score approval endpoint (marker-only)

### Phase 3: Real-Time Verification

- [ ] Implement marker notification (WebSocket or polling)
- [ ] Create pending scores queue view for marker
- [ ] Implement approval/rejection with comment

### Phase 4: Organizer Override

- [ ] Implement override endpoint (organizer-only)
- [ ] Log override reason and timestamp
- [ ] Publish Nostr event for override (attestation kind 39002)

## Score State Machine

```
┌─────────────────────────────────────────────────────────────┐
│                    SUBMITTED                                │
│  (Player submits score, awaiting marker review)            │
└────────────┬──────────────────────────────────────────────┘
             │
             ├─ (Marker approves) ──────────┐
             │                              │
             ├─ (Marker rejects) ───────┐   │
             │                          │   │
             ├─ (Organizer overrides)   │   │
             │                          │   ▼
             │                      ┌──────────────┐
             │                      │  REJECTED    │
             │                      │(not eligible)│
             │                      └──────────────┘
             │
             ▼
        ┌──────────────┐
        │  APPROVED    │
        │ (by marker)  │
        └────┬─────────┘
             │
             ├─ (Player disputes) ──────────┐
             │                              │
             ├─ (Organizer accepts) ───┐   │
             │                         │   │
             │                         │   ▼
             │                     ┌──────────────┐
             │                     │  DISPUTED    │
             │                     │(under review)│
             │                     └──────────────┘
             │
             ▼
        ┌──────────────┐
        │  ACCEPTED    │
        │ (final)      │
        └──────────────┘
```

## Attestation Verification Logic

```typescript
interface AttestationRequest {
  scoreId: string
  status: 'approved' | 'rejected'
  comment: string
  role: 'marker' | 'organizer'
}

async function verifyScoreAttestation(
  user: User,
  request: AttestationRequest
): Promise<Score> {
  // 1. Verify user has marker role
  if (!user.roles.includes(request.role)) {
    throw new Error('User is not authorized to attest')
  }

  // 2. Fetch score
  const score = await db.scores.findById(request.scoreId)
  if (!score) throw new Error('Score not found')

  // 3. Verify score is in SUBMITTED state
  if (score.status !== 'SUBMITTED') {
    throw new Error('Score must be in SUBMITTED state')
  }

  // 4. Update score status
  const newStatus = request.status === 'approved' ? 'APPROVED' : 'REJECTED'
  await db.scores.update(request.scoreId, {
    status: newStatus,
    approvedBy: user.id,
    approvedAt: new Date(),
    approverComment: request.comment,
  })

  // 5. Publish attestation Nostr event
  const submissionEvent = await getNostrEvent(score.nostrEventId)
  const attestationEvent = await createAttestationEvent(
    user,
    submissionEvent,
    request.status,
    request.comment
  )
  await publishNostrEvent(attestationEvent)

  // 6. Notify organizers if rejected
  if (newStatus === 'REJECTED') {
    await notifyOrganizers(`Score ${scoreId} rejected: ${request.comment}`)
  }

  return score
}

async function acceptApprovedScore(
  user: User,
  scoreId: string
): Promise<Score> {
  // Only organizer can accept
  if (!user.roles.includes('ORGANIZER')) {
    throw new Error('Only organizers can accept scores')
  }

  const score = await db.scores.findById(scoreId)
  if (!score || score.status !== 'APPROVED') {
    throw new Error('Score must be in APPROVED state')
  }

  // Update to ACCEPTED
  await db.scores.update(scoreId, {
    status: 'ACCEPTED',
    acceptedBy: user.id,
    acceptedAt: new Date(),
  })

  // Publish acceptance event
  await publishNostrEvent(
    createAcceptanceEvent(user, score)
  )

  return score
}
```

## Real-Time Marker Notification

```typescript
// Option 1: WebSocket (real-time, but requires server upgrade)
io.on('connection', (socket) => {
  socket.on('join-marker-queue', (data) => {
    socket.join('markers')
  })
})

// When score submitted, notify all markers
async function notifyMarkersOfNewScore(score: Score) {
  io.to('markers').emit('new_score', {
    scoreId: score.id,
    playerId: score.playerId,
    courseId: score.courseId,
    scoreValue: score.scoreValue,
  })
}

// Option 2: Polling (simpler, but slight latency)
// GET /api/markers/pending-scores
async function getPendingScores(user: User) {
  if (!user.roles.includes('MARKER')) {
    throw new Error('Not authorized')
  }

  return db.scores.findMany({
    where: { status: 'SUBMITTED' },
    orderBy: { createdAt: 'asc' },
  })
}
```

## Organizer Override Endpoint

```typescript
async function overrideScoreDecision(
  user: User,
  scoreId: string,
  newStatus: 'ACCEPTED' | 'REJECTED',
  reason: string
) {
  // Organizer-only
  if (!user.roles.includes('ORGANIZER')) {
    throw new Error('Not authorized')
  }

  const score = await db.scores.findById(scoreId)
  
  // Log override
  await db.auditLog.create({
    action: 'SCORE_OVERRIDE',
    userId: user.id,
    scoreId,
    oldStatus: score.status,
    newStatus,
    reason,
    timestamp: new Date(),
  })

  // Update score
  await db.scores.update(scoreId, {
    status: newStatus,
    overriddenBy: user.id,
    overrideReason: reason,
  })

  // Publish override event
  const overrideEvent = createOverrideEvent(user, score, newStatus, reason)
  await publishNostrEvent(overrideEvent)
}
```

## Validation

- [ ] Marker can approve submitted score
- [ ] Marker cannot approve scores out of state
- [ ] Organizer can override marker decision
- [ ] Approval publishes Nostr attestation event
- [ ] Score in APPROVED state can be accepted
- [ ] Audit trail records who approved/rejected/overrode
- [ ] Real-time notification works for markers

## Follow-up Decisions

- Should markers be able to approve their own scores? (No, recommend)
- Should we implement score appeal/dispute after acceptance? (Post-MVP)
- Should reputation affect peer attestation weight post-MVP?
- Should there be a timeout for marker response?

## References

- ADR-0006: Score Attestation Model
- ADR-0018: Score Attestation Payload & Event Kinds
