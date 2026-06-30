# ADR 0020: Implement Organizer-Led Dispute Resolution for Score Challenges

## Status

Proposed

## Context

Scores can be disputed after approval if a player questions validity or a marker changes their mind. The project needs a clear dispute resolution process that maintains fairness and audit trail.

Dispute resolution choices impact:

- Trust in leaderboards (are all scores validated?)
- Player satisfaction (can they appeal?)
- Operational complexity (who decides disputes?)
- Finality (are decisions reversible?)

## Decision

We will implement **organizer-led dispute resolution** with the following process:

1. **Challenge Phase**: Any player or marker can challenge an ACCEPTED score within 48 hours
2. **Review Phase**: Organizer investigates with full audit trail and evidence
3. **Decision Phase**: Organizer accepts challenge (score reverted to SUBMITTED) or dismisses
4. **Appeal Phase**: Limited appeal to event organizer or tournament committee
5. **Finality**: Final organizer decision is binding

Additionally:

- All disputes logged with full audit trail (who, what, when, why)
- Disputes published as Nostr events (kind 39002) for transparency
- Evidence attachments supported (photos, scorecards, witness statements)
- Appeal period: 7 days after decision

## Alternatives

- **Automated consensus**: Require 3+ peer attestations for acceptance (complex, insufficient for MVP)
- **Player-only appeal**: Removes organizer authority, can lead to stalemate
- **No dispute mechanism**: Unfair to players, trust erosion
- **External arbitration**: Too complex for MVP

## Trade-offs

**Pros**:

- Clear authority (organizers decide)
- Simple process (easy to understand)
- Fair (players have right to appeal)
- Transparent (published on Nostr)
- Scalable (works for small and large events)

**Cons**:

- Centralizes decision-making (goes against decentralized ethos)
- Requires active organizer involvement
- Can be slow (organizer may be busy)
- Appeal creates extra work

## License Review

- No external dependencies required
- All dispute logic is application-level

## Security Review

- Dispute must reference score by hash (prevent tampering)
- Challenger identity must be verified (Nostr signature)
- All decisions logged with timestamp and actor
- Disputes cannot be deleted (immutable audit trail)
- Evidence must be signed or uploaded to immutable store

## Rollback Plan

If organizer gets overwhelmed:

1. Auto-dismiss disputes without evidence (within SLA)
2. Escalate to tournament committee for major events
3. Implement peer voting post-MVP

## Implementation Plan

### Phase 1: Challenge Mechanism

- [ ] Add ScoreChallenge model
- [ ] Create POST /api/scores/{id}/challenge endpoint
- [ ] Implement 48-hour challenge window
- [ ] Store challenge reason and evidence

### Phase 2: Dispute Resolution

- [ ] Create organizer dispute review UI
- [ ] Implement investigation tools (audit trail viewer)
- [ ] Create POST /api/disputes/{id}/accept endpoint
- [ ] Create POST /api/disputes/{id}/dismiss endpoint

### Phase 3: Appeals

- [ ] Create POST /api/disputes/{id}/appeal endpoint
- [ ] Implement 7-day appeal window
- [ ] Route appeals to tournament committee
- [ ] Create appeal decision endpoint

### Phase 4: Nostr Publishing

- [ ] Implement kind 39002 (challenge/dispute event)
- [ ] Publish challenge when created
- [ ] Publish decision when made

## Dispute State Machine

```text
ACCEPTED (score status)
    ↓
    ├─ (Player/marker challenges) ──┐
    │                               │
    │                            ┌──▼──────────┐
    │                            │  CHALLENGED │
    │                            │  (30 min)   │
    │                            └──┬──────────┘
    │                               │
    │                    ┌──────────┼──────────┐
    │                    │                     │
    ├─ (Organizer       ├─ (Organizer       ├─ (Auto-dismiss
    │  accepts)         │  dismisses)        │  after 48h)
    │                   │                    │
    ▼                   ▼                    ▼
┌──────────┐       ┌──────────┐        ┌──────────┐
│ REVERTED │       │ DISPUTED │        │ ACCEPTED │
│(back to  │       │ REJECTED │        │(final)   │
│SUBMITTED)│       │(final)   │        └──────────┘
└────┬─────┘       └────┬─────┘
     │                  │
     │                  ├─ (Player appeals
     │                  │  within 7 days)
     │                  │
     │                  ▼
     │            ┌──────────┐
     │            │  APPEAL  │
     │            │  PENDING │
     │            └────┬─────┘
     │                 │
     │       ┌─────────┼─────────┐
     │       │                   │
     │  ┌────▼──────┐       ┌────▼──────┐
     │  │APPEAL     │       │APPEAL     │
     │  │ACCEPTED   │       │DISMISSED  │
     │  │(upheld)   │       │(final)    │
     │  └────┬──────┘       └───────────┘
     │       │
     └───────┘
        │
        ▼
   Re-evaluate at
   different appeal level
```

## Challenge & Dispute Models

```typescript
interface ScoreChallenge {
  id: string
  scoreId: string
  challengerId: string      // Nostr pubkey
  reason: string            // Why challenge?
  evidence: string          // Link to photo/document
  createdAt: Date
  status: 'PENDING' | 'ACCEPTED' | 'DISMISSED' | 'EXPIRED'
}

interface ScoreDispute {
  id: string
  scoreId: string
  challengeId: string
  status: 'CHALLENGED' | 'UNDER_REVIEW' | 'REJECTED' | 'UPHELD' | 'APPEAL_PENDING'
  
  // Investigation
  reviewedBy: string        // Organizer Nostr pubkey
  reviewNotes: string
  reviewedAt: Date
  
  // Decision
  decision: 'UPHELD' | 'DISMISSED'
  decisionReason: string
  decidedAt: Date
  
  // Appeal
  appealerId?: string
  appealReason?: string
  appealedAt?: Date
  
  // Nostr
  eventId?: string          // Kind 39002 event
}
```

## Challenge Endpoint

```typescript
async function challengeScore(
  user: User,
  scoreId: string,
  body: { reason: string; evidence?: string }
) {
  // Verify score exists and is ACCEPTED
  const score = await db.scores.findById(scoreId)
  if (!score || score.status !== 'ACCEPTED') {
    throw new Error('Score must be ACCEPTED to challenge')
  }

  // Check 48-hour window
  const hoursSinceAcceptance = 
    (Date.now() - score.acceptedAt.getTime()) / (1000 * 60 * 60)
  if (hoursSinceAcceptance > 48) {
    throw new Error('Challenge window closed (48 hours)')
  }

  // Create challenge
  const challenge = await db.scoreChallenges.create({
    scoreId,
    challengerId: user.nostrPubkey,
    reason: body.reason,
    evidence: body.evidence,
    status: 'PENDING',
  })

  // Publish Nostr event
  const eventId = await publishChallengeEvent(user, score, challenge)
  await db.scoreChallenges.update(challenge.id, { eventId })

  // Notify organizers
  await notifyOrganizers(`Score ${scoreId} challenged: ${body.reason}`)

  return challenge
}
```

## Organizer Resolution Endpoint

```typescript
async function resolveDispute(
  user: User,
  disputeId: string,
  body: {
    decision: 'UPHELD' | 'DISMISSED'
    reason: string
  }
) {
  // Verify organizer
  if (!user.roles.includes('ORGANIZER')) {
    throw new Error('Not authorized')
  }

  const dispute = await db.scoreDisputes.findById(disputeId)
  if (!dispute || dispute.status !== 'UNDER_REVIEW') {
    throw new Error('Dispute must be under review')
  }

  // Update dispute
  await db.scoreDisputes.update(disputeId, {
    status: body.decision === 'UPHELD' ? 'UPHELD' : 'DISMISSED',
    decision: body.decision,
    decisionReason: body.reason,
    reviewedBy: user.nostrPubkey,
    reviewedAt: new Date(),
  })

  // If upheld, revert score to SUBMITTED
  if (body.decision === 'UPHELD') {
    await db.scores.update(dispute.scoreId, {
      status: 'SUBMITTED',
      note: `Score reverted due to upheld challenge: ${body.reason}`,
    })
  }

  // Publish decision event
  const eventId = await publishDisputeDecisionEvent(user, dispute)

  // Notify challenger and score owner
  await notifyUser(dispute.scoreId, `Dispute decision: ${body.decision}`)

  return dispute
}
```

## Appeal Endpoint

```typescript
async function appealDisputeDecision(
  user: User,
  disputeId: string,
  body: { reason: string }
) {
  const dispute = await db.scoreDisputes.findById(disputeId)
  if (!dispute || (dispute.status !== 'UPHELD' && dispute.status !== 'DISMISSED')) {
    throw new Error('Dispute must have a decision to appeal')
  }

  // Check 7-day appeal window
  const daysSinceDecision = 
    (Date.now() - dispute.decidedAt.getTime()) / (1000 * 60 * 60 * 24)
  if (daysSinceDecision > 7) {
    throw new Error('Appeal window closed (7 days)')
  }

  // Update dispute
  await db.scoreDisputes.update(disputeId, {
    status: 'APPEAL_PENDING',
    appealerId: user.nostrPubkey,
    appealReason: body.reason,
    appealedAt: new Date(),
  })

  // Notify tournament committee
  await notifyCommittee(`Appeal submitted for dispute ${disputeId}`)

  return dispute
}
```

## Nostr Dispute Event (Kind 39002)

```json
{
  "id": "event_id_sha256",
  "pubkey": "organizer_pubkey",
  "created_at": 1687123600,
  "kind": 39002,
  "tags": [
    ["e", "score_submission_event_id"],
    ["p", "challenger_pubkey"],
    ["decision", "upheld|dismissed"],
    ["appeal_available", "true|false"]
  ],
  "content": "Decision reason and notes",
  "sig": "signature"
}
```

## Validation

- [ ] Player can challenge score within 48 hours
- [ ] Organizer can review challenge
- [ ] Organizer decision reverts score or dismisses challenge
- [ ] Decision published as Nostr event
- [ ] Player can appeal within 7 days
- [ ] Audit trail is complete and immutable
- [ ] Challenged scores marked visibly in leaderboards

## Follow-up Decisions

- Should committee appeals be required for major events?
- Should disputes be public or private until resolved?
- Should there be evidence requirements (photo mandatory)?
- Should challengers have standing restrictions (own score only)?

## References

- ADR-0006: Score Attestation Model
- ADR-0008: Non-Custodial Payment Design (payment dispute patterns)
- ADR-0018: Score Attestation Payload & Event Kinds
