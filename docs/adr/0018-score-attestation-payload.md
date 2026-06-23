# ADR 0018: Use Custom Nostr Event Kinds for Score Submission and Attestation

## Status

Accepted

- **Date:** 2026-06-23
- **Decision owners:** sebrock
- **Reviewers:** sebrock

## Context

Score submissions and attestations are core to the platform. Scores must be published to Nostr relays to create an immutable, decentralized audit trail. The project must decide which Nostr event structure and NIP to use.

Nostr event design choices impact:
- Interoperability with other Nostr apps (should we use standard NIPs?)
- Event discoverability on relays (which filters to use?)
- Data integrity (how to prevent tampering?)
- Privacy (what information is public?)
- Future compatibility (what if requirements change?)

## Decision

We will use **custom Nostr event kinds** (39000-39999 range) for score submission and attestation, rather than forcing compatibility with existing NIPs.

Additionally:
- **Score Submission**: Kind 39000
- **Score Attestation**: Kind 39001
- **Score Challenge/Dispute**: Kind 39002
- **Payload Format**: JSON, hashed for integrity verification
- **Event Tags**: Use standardized tag format for filtering and references
- **Long-form**: Consider NIP-23 for detailed scoring rules/metadata (post-MVP)

## Alternatives

- **NIP-23 (Long-form content)**: Good for scoring rules, not ideal for structured data
- **NIP-58 (Badges)**: Good for achievement attestation, doesn't fit score data structure
- **NIP-34 (Git events)**: Too specialized, overkill for golf scoring
- **Generic Kind 1 (Note)**: Lacks structure, hard to filter and parse
- **NIP-31 (Marketplace)**: Designed for commerce, not scores

## Trade-offs

**Pros**:
- Custom kinds give maximum flexibility for score data structure
- No compatibility constraints from existing NIPs
- Clear semantics: kind 39000 = score submission, kind 39001 = attestation
- Can evolve schema without breaking other Nostr apps
- Easy to filter on relays (by kind)
- Future Nostr apps can integrate if they adopt the kinds

**Cons**:
- Less interoperability than standard NIPs
- Future changes require migration planning
- Other Nostr apps won't understand the events without explicit support
- Relay filtering less standardized (each relay may have different limits)

## License Review

- Nostr event format is public standard, no licensing concerns
- Custom kinds are unencumbered by any licenses

## Security Review

- Score payload must be SHA256 hashed for integrity verification
- Attestation must reference the exact score hash (prevent tampering)
- Event signature must be verified on both publication and reading
- Include timestamp to prevent replay attacks
- Include event unique ID for idempotency
- Do not include sensitive data (player phone, address, etc.)

## Rollback Plan

If custom kinds cause relay compatibility issues:
1. Migrate to NIP-23 (long-form) for detailed scores
2. Use kind 1 (note) as fallback with structured JSON payload
3. Keep current database schema (independent of Nostr format)

## Implementation Plan

- [ ] Define JSON schema for score submission payload
- [ ] Define JSON schema for attestation payload
- [ ] Implement event signing and publishing
- [ ] Implement event parsing and validation on read
- [ ] Document event structure in project README
- [ ] Create migration guide for future format changes

## Score Submission Event Structure (Kind 39000)

```json
{
  "id": "event_id_sha256",
  "pubkey": "player_nostr_pubkey",
  "created_at": 1687123456,
  "kind": 39000,
  "tags": [
    ["event_id", "golf-event-uuid"],
    ["course_id", "course-data-uuid"],
    ["score_value", "72"],
    ["payload_hash", "sha256_hash_of_score_payload"],
    ["nonce", "unique-submission-id"]
  ],
  "content": "{...score_payload_json...}",
  "sig": "signature"
}
```

## Score Submission Payload

```typescript
interface ScoreSubmissionPayload {
  // Metadata
  eventId: string        // Golf event UUID
  courseId: string       // Golf course identifier
  playerId: string       // Nostr pubkey of player
  submittedAt: ISO8601   // Submission timestamp
  
  // Score Data
  scoreValue: number     // Total strokes
  courseRating: number   // Course rating (decimal)
  courseSlope: number    // Slope rating
  handicapIndex: number  // Player handicap index
  holes: Hole[]          // Per-hole breakdown
  
  // Metadata
  source: 'app' | 'import' | 'manual'  // How was score entered?
  notes: string          // Any comments from player
  
  // Verification
  timestamp: ISO8601     // When was this score shot?
  verified: boolean      // Already verified by marker?
}

interface Hole {
  number: 1..18
  par: 3..5
  handicap: 1..18
  strokes: number
  putts?: number
  fairway?: boolean
  greensInRegulation?: boolean
}
```

## Score Attestation Event (Kind 39001)

```json
{
  "id": "event_id_sha256",
  "pubkey": "attestor_nostr_pubkey",
  "created_at": 1687123500,
  "kind": 39001,
  "tags": [
    ["e", "submission_event_id", "relay_hint"],
    ["p", "player_pubkey"],
    ["score_hash", "sha256_hash"],
    ["status", "approved|disputed|withdrawn"],
    ["role", "marker|organizer|peer"]
  ],
  "content": "Attestation comment or dispute reason",
  "sig": "signature"
}
```

## Score Attestation Payload

```typescript
interface ScoreAttestationPayload {
  // References
  submissionEventId: string    // Kind 39000 event ID
  submissionHash: string       // SHA256(submission_payload)
  playerId: string             // Nostr pubkey
  attestorId: string           // Nostr pubkey of attestor
  
  // Status
  status: 'approved' | 'disputed' | 'withdrawn'
  reason?: string              // Why disputed/withdrawn?
  
  // Metadata
  role: 'marker' | 'organizer' | 'peer'
  timestamp: ISO8601
  
  // Optional
  alternateScore?: number      // If disputed, what should it be?
  evidence?: string            // Link to photo/scorecard
}
```

## Event Validation

```typescript
function validateScoreSubmissionEvent(event: Event): ScoreSubmissionPayload {
  if (event.kind !== 39000) throw new Error('Wrong event kind')
  
  // Verify signature
  if (!verifyEventSignature(event)) throw new Error('Invalid signature')
  
  // Verify hash matches payload
  const payload = JSON.parse(event.content)
  const hash = sha256(JSON.stringify(payload))
  const hashTag = event.tags.find(t => t[0] === 'payload_hash')?.[1]
  if (hash !== hashTag) throw new Error('Payload hash mismatch')
  
  // Verify timestamp is recent (within 24 hours)
  const age = Date.now() / 1000 - event.created_at
  if (age > 86400) throw new Error('Event too old')
  
  return payload
}

function validateScoreAttestationEvent(
  event: Event,
  submissionEvent: Event
): ScoreAttestationPayload {
  if (event.kind !== 39001) throw new Error('Wrong event kind')
  
  // Verify signature
  if (!verifyEventSignature(event)) throw new Error('Invalid signature')
  
  // Verify references correct submission
  const eTag = event.tags.find(t => t[0] === 'e')?.[1]
  if (eTag !== submissionEvent.id) throw new Error('Wrong submission')
  
  // Verify hash references submission
  const expectedHash = sha256(submissionEvent.content)
  const hashTag = event.tags.find(t => t[0] === 'score_hash')?.[1]
  if (expectedHash !== hashTag) throw new Error('Hash mismatch')
  
  const payload = JSON.parse(event.content)
  return payload
}
```

## Nonce Generation (Prevent Duplicates)

```typescript
function generateScoreSubmissionEvent(
  player: User,
  score: Score,
  keypair: Keypair
): Event {
  const nonce = crypto.randomBytes(16).toString('hex')
  const payload = { ...score.payload, timestamp: new Date().toISOString() }
  const payloadHash = sha256(JSON.stringify(payload))

  const event: Event = {
    kind: 39000,
    pubkey: player.nostrPubkey,
    created_at: Math.floor(Date.now() / 1000),
    tags: [
      ['event_id', score.eventId],
      ['course_id', score.courseId],
      ['score_value', score.scoreValue.toString()],
      ['payload_hash', payloadHash],
      ['nonce', nonce],
    ],
    content: JSON.stringify(payload),
  }

  event.id = getEventHash(event)
  event.sig = signEvent(event, keypair)
  return event
}
```

## Validation

- [ ] Score submission event can be published to relays
- [ ] Score submission event can be read and parsed
- [ ] Payload hash matches actual payload
- [ ] Event signature is valid
- [ ] Attestation event references correct submission
- [ ] No duplicate submissions (nonce prevents)
- [ ] Events can be archived and replayed

## Follow-up Decisions

- Should we add encryption for sensitive fields? (E.g., player address)
- Should we support batch score submissions? (For organizers importing scores)
- How do we handle score corrections? (New event or amendment tag?)
- Should we standardize handicap calculation? (USGA vs other systems)

## References

- [Nostr NIP-01: Basic Protocol](https://github.com/nostr-protocol/nips/blob/master/01.md)
- [Nostr NIP-23: Long-form Content](https://github.com/nostr-protocol/nips/blob/master/23.md)
- [Custom Event Kinds](https://github.com/nostr-protocol/nips/blob/master/README.md#event-kinds)
- [Event Signature Verification](https://github.com/nostr-protocol/nips/blob/master/01.md#events-and-signatures)
