# ADR 0001: Use Nostr for Identity

## Status

Accepted

- **Date:** 2026-06-22
- **Decision owners:** sebrock
- **Reviewers:** sebrock


## Context

Ride or Die Scorecard aims to be a Nostr-native, Bitcoin-native event platform. Users need portable identity for players, scorekeepers, team managers, organizers, fans, contributors, and sponsors.

The project wants to avoid proprietary account systems and vendor lock-in. Identity should work across the web/PWA client and future clients without requiring users to create a project-specific username and password.

## Decision

We will use Nostr public keys as the primary identity anchor for user accounts, profile references, score posts, attestations, zaps, badges, and contribution provenance.

## Alternatives


- Hybrid account system with optional Nostr linking.
- Consider Hybrid account system with optional Nostr linking

## Trade-offs

- Nostr identity aligns strongly with the project thesis and ecosystem, but user onboarding may be harder for non-Nostr users.
- Key management and account recovery require careful UX.
- Nostr identity can reduce central dependency but does not remove the need for local application authorization and role management.

## License Review

- Review Nostr client libraries and signing tools before adoption.
- Confirm dependency licenses are compatible with the project license.
- Avoid proprietary SDKs for core identity flows.

## Security Review

- Do not store user private keys or raw seed material.
- Support browser extension signing where possible.
- Define session expiration and replay protection.
- Document risks around compromised Nostr keys.

## Rollback Plan

If Nostr identity blocks MVP delivery, keep the user model flexible enough to support temporary local test accounts while preserving Nostr public key fields for migration.

## Implementation Plan

- Define user identity model.
- Select signing and login flow.
- Add onboarding path for users who already have Nostr keys.
- Add beginner path for users who do not.

## Validation

- Users can log in using a Nostr-compatible flow.
- User roles can be assigned to Nostr identities.
- Score posts and attestations can be traced back to the submitting identity.

## Follow-up Decisions

- Which Nostr login/signing flow is mandatory for MVP?
- How are lost keys handled?
- How are team roles delegated?

## References

- Nostr NIPs
- Project Foundation Document
