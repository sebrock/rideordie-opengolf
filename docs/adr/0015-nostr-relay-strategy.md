# ADR 0015: Use Relay Discovery with Primary Relay Fallback for Nostr Event Publishing

## Status

Proposed

## Context

Score attestations, badge issuance, and user identity verification are published as Nostr events. The app must reliably publish and read events from Nostr relays. Relay availability, latency, and content filtering all impact event delivery.

Relay strategy choices impact:

- Event delivery reliability (what if a relay goes down?)
- User privacy (which relays to publish attestations to?)
- Query performance (which relays to read from?)
- Operational overhead (do we run our own relays?)
- Non-custodial principles (app cannot control relays)

## Decision

We will use **public Nostr relay discovery with one or two primary relays as fallback**, rather than operating our own relays.

Additionally:

- **Relay Client**: Use `nostr-tools` relay abstraction + `relay.js` library
- **Primary Relays**: damus.io and nostr.band (mature, stable, good uptime)
- **Read Strategy**: Query from multiple relays, deduplicate results
- **Write Strategy**: Publish to primary relays + user's inbox relays (if available)
- **Fallback**: If primary relay fails, retry with exponential backoff
- **Event Kinds**: Use NIP-23 (long-form) or custom kind for score attestation

## Alternatives

- **Self-hosted relays**: Full control, high operational burden, not suitable for MVP
- **Single relay dependency**: Simple but fragile, violates non-custodial principles
- **Relay pool (many relays)**: Complex redundancy, high query latency
- **Centralized indexer**: Couples app to third-party service, reduces censorship resistance

## Trade-offs

**Pros**:

- Decentralized: No single relay dependency, reduces censorship risk
- Low operational burden: No relay infrastructure to maintain
- User choice: Users can configure preferred relays in their Nostr clients
- Privacy: Attestations visible on multiple relays, harder to censor
- Aligns with Nostr ethos and non-custodial principles

**Cons**:

- Relay availability unpredictable (some go down, some change policies)
- Latency varies (damus.io slower than local relays)
- Event filtering inconsistent across relays (some filter spam)
- No guaranteed event delivery (relays can reject events)
- Query performance requires careful relay selection

## License Review

- **nostr-tools**: MIT ✓
- **relay.js**: MIT ✓
- Relays themselves (damus.io, nostr.band): Run by community, no licensing concerns for publication

## Security Review

- Do NOT publish Nostr private keys or session tokens to relays
- Score attestation events should be published as-is (no sensitive data)
- Verify relay certificates (use WSS, not WS)
- Implement rate limiting to prevent spam publication
- Sign all events with user's Nostr key (NIP-98 or NIP-07)
- Implement event replay protection (check timestamp, refuse old events)

## Rollback Plan

If relay publishing becomes unreliable:

1. Cache events locally and retry on background worker
2. Add fallback to centralizing events in app database (user can always re-publish)
3. Implement optional user-provided relay list (advanced feature, post-MVP)

## Implementation Plan

### Phase 1: Relay Client Setup

- [ ] Install `nostr-tools` and `relay.js`
- [ ] Create relay manager abstraction (handles multi-relay publish/read)
- [ ] Configure primary relays (damus.io, nostr.band)
- [ ] Implement exponential backoff retry logic

### Phase 2: Event Publishing

- [ ] Create Score Attestation event payload (decide on NIP kind)
- [ ] Implement score submission → Nostr event publishing
- [ ] Implement attestation signing and publishing
- [ ] Add error handling and user feedback

### Phase 3: Event Reading

- [ ] Implement Nostr event subscription (read attestations)
- [ ] Cache events locally for offline access
- [ ] Deduplicate events from multiple relays
- [ ] Implement query filters (kind, author, timestamp)

## Relay Configuration (TypeScript)

```typescript
import { relay, SimplePool } from 'nostr-tools'

const PRIMARY_RELAYS = [
  'wss://relay.damus.io',
  'wss://relay.nostr.band',
]

const relayPool = new SimplePool()

// Publish score attestation to primary relays
async function publishScoreAttestation(event: Event) {
  const relayPromises = PRIMARY_RELAYS.map(relayUrl =>
    relay(relayUrl)
      .publish(event)
      .catch(err => console.error(`Relay ${relayUrl} failed:`, err))
  )
  
  await Promise.allSettled(relayPromises)
}

// Read attestations from multiple relays
async function readAttestations(filters: Filter[]) {
  const events = await relayPool.querySync(PRIMARY_RELAYS, filters)
  return Array.from(new Set(events)) // Deduplicate
}
```

## Event Kind Decision

**Options for Score Attestation**:

1. **NIP-23 (Long-form content)**: Kind 30023, good for detailed attestations
2. **Custom kind**: e.g., kind 39999, for app-specific events
3. **NIP-58 (Badges)**: Kind 8, for achievement attestation

**Recommendation**: Use custom kind `39000` for score submission, kind `39001` for attestation to avoid conflicts with other apps.

```typescript
const SCORE_SUBMISSION_KIND = 39000
const SCORE_ATTESTATION_KIND = 39001

interface ScoreSubmissionEvent extends Event {
  kind: 39000
  tags: [
    ['event_id', 'golf-event-uuid'],
    ['course_id', 'course-uuid'],
    ['score_value', '72'],
    ['payload_hash', 'sha256-hash'],
  ]
  content: JSON.stringify({ score_details })
}

interface ScoreAttestationEvent extends Event {
  kind: 39001
  tags: [
    ['e', 'score-submission-event-id'],
    ['p', 'attesting-user-pubkey'],
    ['status', 'approved|disputed|withdrawn'],
  ]
  content: 'attestation_comment'
}
```

## Relay Health Monitoring

```typescript
// Monitor relay connectivity
async function healthCheck(relayUrl: string) {
  try {
    const r = await relay(relayUrl)
    await r.close()
    return { url: relayUrl, status: 'ok', latency: 0 }
  } catch (err) {
    return { url: relayUrl, status: 'down', error: err.message }
  }
}

// Run periodic checks
setInterval(async () => {
  const health = await Promise.all(PRIMARY_RELAYS.map(healthCheck))
  console.log('Relay health:', health)
}, 60000) // Every minute
```

## Validation

- [ ] Score attestation event publishes successfully to primary relays
- [ ] Event is readable from relays within 5 seconds
- [ ] If one relay fails, event still publishes to other relays
- [ ] Event signature is valid (verified by relay)
- [ ] Duplicate events deduplicated on read
- [ ] Relay health monitoring works

## Follow-up Decisions

- Should we support user-configured relay lists? (Post-MVP feature)
- Should we run our own relay for events? (Only if primary relays prove unreliable)
- What event metadata (course, player, score) should be public on-chain?
- Should attestations be published immediately or only after acceptance?

## References

- [Nostr Protocol Specification](https://github.com/nostr-protocol/nips)
- [NIP-23: Long-form Content](https://github.com/nostr-protocol/nips/blob/master/23.md)
- [nostr-tools Documentation](https://github.com/nbd-wtf/nostr-tools)
- [relay.js](https://github.com/nostr-protocol/nostr-relay-tester)
- [Damus Relay](https://relay.damus.io/)
- [Nostr Band](https://relay.nostr.band/)
