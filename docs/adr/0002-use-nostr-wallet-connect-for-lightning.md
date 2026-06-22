# ADR 0002: Use Nostr Wallet Connect for Lightning Wallet Integration

## Status
Proposed

## Context
The app needs Bitcoin/Lightning payments for registration fees, zaps, rewards, and possibly future payouts. The project should remain non-custodial and avoid holding user funds, private keys, or wallet seed phrases.

Nostr Wallet Connect can connect a client application to a user-controlled wallet through Nostr-based messaging and permissions.

## Decision
TBD.

Proposed direction: use Nostr Wallet Connect / NIP-47 as the primary light-wallet connection layer for Lightning payments and wallet interactions.

## Alternatives
- BTCPay Server invoice-only flow.
- Direct LND/Core Lightning node integration.
- WebLN-only wallet flow.
- Custodial in-app wallet.
- Manual invoice copy/paste.

## Trade-offs
- NWC supports the Nostr-native thesis and non-custodial model.
- NWC wallet support may vary across user wallets.
- Additional UX work is required for permissions, connection status, revocation, and failed payments.
- BTCPay Server may still be useful for organizer/sponsor payments.

## License Review
- Review licenses for NWC libraries, wallet SDKs, and QR/deep-link utilities.
- Ensure payment libraries are open source and compatible.
- Avoid proprietary wallet SDK lock-in for MVP-critical flows.

## Security Review
- App must not custody funds.
- App must not store wallet secrets beyond encrypted connection metadata where required.
- Users must be able to revoke/disconnect wallet access.
- Spending permissions and budgets should be explicit.
- Test payments should be supported before real funds are used.

## Rollback Plan
If NWC is not reliable enough for MVP, fall back to BTCPay Server invoice generation for registration fees and keep zaps/rewards post-MVP.

## Implementation Plan
- Define wallet connection flow.
- Add wallet status component.
- Add invoice payment flow.
- Add zap/reward flow as separate story.
- Add disconnect/revoke UX.

## Validation
- User can connect a compatible wallet.
- User can pay a registration fee.
- User can disconnect wallet access.
- The app never receives custody of funds.

## Follow-up Decisions
- Which wallets are officially supported for MVP?
- Should BTCPay Server be the organizer payment backend?
- How are sats rewards funded and distributed?

## References
- NIP-47
- Nostr Wallet Connect docs
- BTCPay Server docs
