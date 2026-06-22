# ADR 0008: Enforce Non-Custodial Payment Design

## Status
Proposed

## Context
The project handles Bitcoin/Lightning-adjacent flows including registration fees, zaps, rewards, and possibly sponsor contributions. The app must not become a custodian of funds or user secrets.

## Decision
TBD.

Proposed direction: the app coordinates payments but does not custody user funds, private keys, wallet seed phrases, or raw spending credentials.

## Alternatives
- Custodial in-app balances.
- Organizer-managed shared wallet.
- Third-party custodial wallet integration.
- Manual payment confirmation outside the app.

## Trade-offs
- Non-custodial design reduces regulatory and security burden.
- UX can be harder for new users.
- Payment failure states need careful handling.
- Rewards may require a sponsor/organizer funding wallet or payment service.

## License Review
- Review payment infrastructure dependencies.
- Review hosted service terms for sponsor-provided infrastructure.
- Ensure optional paid services do not become hard dependencies.

## Security Review
- No private key storage.
- No seed phrase capture.
- No custodial balances.
- Explicit wallet permissions.
- Payment confirmation must be robust.

## Rollback Plan
If automated Lightning payment flows are not ready, use manual invoice/payment confirmation for MVP registration and postpone automated zaps/rewards.

## Implementation Plan
- Document non-custodial constraints.
- Define invoice lifecycle.
- Define payment status states.
- Add safe logging rules for payment metadata.

## Validation
- Security review confirms no custody of funds.
- Users can complete fee payment externally/through wallet connection.
- Payment state can be reconciled by organizers.

## Follow-up Decisions
- Which payment backend is used for organizer invoices?
- Who funds rewards?
- What is the minimum wallet support matrix?

## References
- NIP-47
- BTCPay Server docs
- SECURITY.md
