# ADR 0016: Use Nostr Wallet Connect (NIP-47) as Primary Wallet Integration with WebLN and BTCPay Fallbacks

## Status

Accepted

- **Date:** 2026-06-23
- **Decision owners:** sebrock
- **Reviewers:** sebrock

## Context

Users need to pay registration fees and receive zaps/rewards via Lightning. ADR-0008 (Non-Custodial Payment Design) mandates that the app never custody funds or keys. Nostr Wallet Connect (NIP-47) enables direct wallet communication over Nostr-encrypted messaging.

Wallet integration choices impact:

- User onboarding friction (how easy is it to connect wallet?)
- Wallet support breadth (how many users have compatible wallets?)
- Non-custodial guarantees (does the app touch keys?)
- Error handling complexity (what if wallet connection fails?)

## Decision

We will use **Nostr Wallet Connect (NIP-47) as the primary wallet integration**, with **WebLN and BTCPay invoice fallbacks** for compatibility.

Additionally:

- **Connection Method**: QR code for mobile, URI scheme for desktop
- **Supported Wallets**: Alby, Mutiny, Breez (MVP targets these three)
- **Permissions Model**: Explicit user approval for spending limits
- **Fallback Flows**:
  - WebLN for users with older wallet integrations
  - BTCPay invoices for manual payment (worst case)
- **No Custody**: App coordinates payments but does not execute them

## Alternatives

- **WebLN-only**: Simpler but smaller wallet support, less Nostr-native
- **BTCPay-only**: Manual invoices only, poor UX
- **Custodial wallet**: Violates non-custodial principles, regulatory burden
- **LNURL-pay**: Good for tipping, not for registration fees
- **Direct Lightning Node**: Requires app to operate LND/Core Lightning (not suitable for MVP)

## Trade-offs

**Pros**:

- NWC is Nostr-native, aligns with ADR-0001 (Nostr identity)
- Users control their keys in their own wallets
- Works across different wallet implementations (Alby, Mutiny, etc.)
- Mobile and desktop support
- QR code connection is beginner-friendly
- Non-custodial by design

**Cons**:

- NWC wallet support is still emerging (not all wallets support it yet)
- Connection setup is multi-step (QR scan → approve → test)
- Error handling complex (wallet offline, insufficient funds, etc.)
- WebLN fallback requires older wallet support
- BTCPay fallback requires manual confirmation (poor UX)

## License Review

- **NWC Libraries**: Check `alby-js-sdk`, `nostr-wallet-connect` for licensing
- **WebLN**: Browser standard, no licensing concerns
- **BTCPay**: MIT, open-source ✓
- All open-source or standards-based

## Security Review

- **No Key Storage**: App never receives private keys ✓
- **Explicit Permissions**: User must approve spending limits
- **Connection Revocation**: User can disconnect wallet at any time
- **Event Signing**: All NWC requests signed (NIP-07 or app-managed keys)
- **Test Mode**: Support test/signet payments before mainnet
- **Spending Limits**: Enforce per-transaction limits (e.g., max 10k sats per zap)
- **Timeout**: Wallet response timeout 30s, retry once

## Rollback Plan

If NWC adoption is low:

1. Emphasize WebLN fallback for MVP
2. Make BTCPay invoice the primary flow
3. Post-MVP: Implement LNURL-pay for tips/rewards

## Implementation Plan

### Phase 1: NWC Connection Flow

- [ ] Install `alby-js-sdk` or `nostr-wallet-connect` library
- [ ] Create wallet connection dialog (QR code + manual URI)
- [ ] Implement connection persistence (encrypted storage)
- [ ] Add wallet connection status indicator

### Phase 2: NWC Payment Flow

- [ ] Implement pay_invoice RPC (send payment)
- [ ] Implement make_invoice RPC (receive payment)
- [ ] Create payment request UI
- [ ] Handle wallet response (success/failure)

### Phase 3: Fallbacks

- [ ] Add WebLN detection and fallback
- [ ] Implement BTCPay invoice generation
- [ ] Create manual payment confirmation UI
- [ ] Log all payment attempts for reconciliation

### Phase 4: Testing & UX

- [ ] Test with Alby, Mutiny, Breez
- [ ] Test connection loss recovery
- [ ] Test spending limit enforcement
- [ ] Create user documentation

## NWC Connection Flow (Pseudocode)

```typescript
import { requestProvider } from 'alby-js-sdk' // or nostr-wallet-connect

interface WalletState {
  connected: boolean
  provider?: NWCProvider
  pubkey?: string
  budget?: {
    maxSatsPerRequest: number
    totalBudget: number
  }
}

async function connectWallet(): Promise<WalletState> {
  // 1. Request wallet connection (shows QR or URI)
  const provider = await requestProvider({
    name: 'Ride or Die Scorecard',
    icon: 'https://example.com/icon.png',
    returnUrl: window.location.href,
  })

  // 2. Test connection
  const info = await provider.getInfo()
  
  // 3. Get spending permissions from user
  const budget = await askUserForBudget()
  
  // 4. Store connection (encrypted)
  await storage.set('wallet_connection', {
    provider: provider.serialize(),
    budget,
    connectedAt: Date.now(),
  })

  return {
    connected: true,
    provider,
    pubkey: info.pubkey,
    budget,
  }
}

async function sendPayment(amountSats: number, desc: string) {
  const state = await storage.get('wallet_connection')
  
  if (!state.connected) throw new Error('Wallet not connected')
  if (amountSats > state.budget.maxSatsPerRequest) {
    throw new Error('Amount exceeds spending limit')
  }

  try {
    const invoice = await generateInvoice(amountSats, desc)
    const response = await state.provider.payInvoice(invoice)
    return { success: true, preimage: response.preimage }
  } catch (err) {
    if (err.timeout) {
      // Fallback to WebLN
      return fallbackToWebLN(invoice)
    }
    throw err
  }
}
```

## Supported Wallets (MVP)

| Wallet | NWC | WebLN | Status |
|--------|-----|-------|--------|
| Alby | ✓ | ✓ | Primary |
| Mutiny | ✓ | - | Primary |
| Breez | ✓ | - | Primary |
| Blue Wallet | - | ✓ | Fallback |
| Strike | - | - | Not supported |

## User Permissions Model

```json
{
  "wallet": "nwc://...",
  "budgets": [
    {
      "purpose": "registration",
      "max_sats_per_request": 50000,
      "total_budget": 100000,
      "currency": "sats"
    },
    {
      "purpose": "zap",
      "max_sats_per_request": 1000,
      "total_budget": 10000
    }
  ],
  "expires_at": "2026-12-31T23:59:59Z"
}
```

## Validation

- [ ] User can connect wallet via QR code
- [ ] User can set spending limits
- [ ] Payment succeeds with NWC wallet
- [ ] Payment fails gracefully if wallet unavailable
- [ ] Spending limit is enforced
- [ ] Wallet can be disconnected
- [ ] Fallback to WebLN works
- [ ] Manual BTCPay invoice works

## Follow-up Decisions

- Should spending limits be per-session or persistent?
- Should we support payment retries on network failure?
- How do we handle zaps/rewards that are initiated by app (not user)?
- Should we implement a payment queue for offline users?

## References

- [NIP-47: Nostr Wallet Connect](https://github.com/nostr-protocol/nips/blob/master/47.md)
- [Alby SDK](https://github.com/getAlby/js-sdk)
- [WebLN Specification](https://www.webln.tech/)
- [BTCPay Server API](https://docs.btcpay.server/API/)
