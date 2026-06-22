# ADR 0007: Use Nostr Score Posts, Badges, and Zaps for Engagement

## Status

Proposed

## Context

The app should create public engagement before and during the Ride or Die Cup. Players can post scores, earn badges, receive sats rewards, and get zapped by fans or teammates.

## Decision

TBD.

Proposed direction: publish selected score and achievement events to Nostr, support NIP-57 zaps, and explore NIP-58 badges for achievements.

## Alternatives

- Keep all scoring private inside the app.
- Use centralized social sharing only.
- Implement points without Nostr badges.
- Delay all engagement features until after MVP.

## Trade-offs

- Public posts increase excitement and discoverability.
- Privacy and consent must be designed carefully.
- Zaps and rewards add wallet complexity.
- Badges need clear issuing authority and revocation/update policy.

## License Review

- Review libraries for Nostr events, zaps, badge rendering, and media generation.
- Review generated visual assets for reuse rights.

## Security Review

- Users must opt into public score posts.
- Do not leak private tournament data accidentally.
- Zap handling must be non-custodial.
- Badge issuance must prevent spoofing.

## Rollback Plan

If Nostr publishing is unstable, keep score posts internal and provide manual export/share links until the Nostr integration is ready.

## Implementation Plan

- Define public/private score visibility rules.
- Add zap-enabled score post prototype.
- Define badge categories.
- Add achievement event model.

## Validation

- A public score post can be viewed from a Nostr client.
- A user can zap a score post.
- Badge issuance is traceable to project identity.

## Follow-up Decisions

- Which achievements earn badges?
- Which achievements earn sats?
- Who controls badge issuer keys?

## References

- NIP-57
- NIP-58
