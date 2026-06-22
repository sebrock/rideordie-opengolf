# ADR 0006: Define Score Attestation Model

## Status

Proposed

## Context

Pre-event qualification and practice scoring require trust. A player may submit a home-course score before the event, but another player, marker, or approved individual should attest that the score is plausible or correct.

Nostr identity can anchor submissions and attestations, while the app enforces scoring workflow and review rules.

## Decision

TBD.

Proposed direction: create an application-specific score attestation flow signed by Nostr identities, while evaluating relevant NIPs for timestamping, badges, zaps, and application-specific data.

## Alternatives

- Organizer-only score verification.
- Unverified self-submitted scores.
- Photo-only scorecard upload.
- Centralized audit table without Nostr signatures.

## Trade-offs

- Peer attestation creates trust and social engagement.
- False attestations are possible and need reputation or moderation controls.
- No finalized universal Nostr score-attestation NIP may fit perfectly, so app-specific events may be necessary.

## License Review

- Review libraries used for signatures, timestamping, and event construction.
- Review any OCR/photo-processing components if used later.

## Security Review

- Prevent score tampering after attestation.
- Link attestation to exact score payload/hash.
- Track who attested, when, and under which role.
- Define dispute handling.

## Rollback Plan

If signed attestation is too complex for MVP, use app-level marker approval first and publish signed attestation events post-MVP.

## Implementation Plan

- Define score submission payload.
- Define attestation payload/hash.
- Add marker/attestor role.
- Add score state machine: submitted, attested, disputed, accepted, rejected.

## Validation

- A submitted score can be attested by another identity.
- Attestation references the exact score.
- Audit history is visible to organizers.

## Follow-up Decisions

- Which NIPs are used directly?
- How many attestations are required?
- Can fans attest or only approved markers?

## References

- Nostr NIPs
- Foundation Document v0.3
