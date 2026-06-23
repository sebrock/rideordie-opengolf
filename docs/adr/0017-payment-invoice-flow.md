# ADR 0017: Use BTCPay Server for Registration Invoice Generation and State Tracking

## Status

Accepted

- **Date:** 2026-06-23
- **Decision owners:** sebrock
- **Reviewers:** sebrock

## Context

Registration fees must be collected from event participants. ADR-0008 (Non-Custodial Payment Design) mandates that the app does NOT custody funds. BTCPay Server is a Nostr-friendly, self-hosted or managed Bitcoin payment processor that generates invoices and tracks payment state without custodying funds.

Payment infrastructure choices impact:

- Non-custodial guarantees (does processor custody funds?)
- Operational burden (self-hosted vs managed)
- Payment state tracking (can we reconcile who paid?)
- Compliance and auditing (do we have an audit trail?)
- UX for payment confirmation (how do users prove payment?)

## Decision

We will use **BTCPay Server as the invoice generator and payment state tracker** for registration fees and organizer payouts.

Additionally:

- **Deployment**: Managed BTCPay (Voltage, LNBits, or self-hosted if ops capacity)
- **Payment Method**: On-chain Bitcoin (immediate) + Lightning (optional)
- **Invoice Workflow**: Generate → user pays → webhook confirmation
- **State Machine**: PENDING → CONFIRMED → COMPLETED
- **No Custody**: App never receives funds, BTCPay forwards to organizer wallet
- **Webhook Integration**: BTCPay notifies app when payment confirmed

## Alternatives

- **Stripe/Square**: Custodial, regulatory burden, not Bitcoin-native
- **LNURL-pay only**: Works for tips, inadequate for registration fees
- **Manual invoice copy/paste**: Poor UX, hard to track
- **Lightning Node direct**: Requires app to operate node, high ops burden
- **Voltage/LNBits**: Good, but less feature-complete than BTCPay

## Trade-offs

**Pros**:

- Fully non-custodial: Funds go directly to organizer wallet
- Open-source: Full transparency and auditability
- Bitcoin + Lightning support: Users can pay however they prefer
- Webhook integration: App automatically notified of payment
- Self-hosted option: Maximum control and privacy
- Excellent audit trail for financial records
- Nostr-friendly: Can integrate Nostr signing if needed

**Cons**:

- Operational complexity if self-hosted (requires DevOps)
- Managed services add cost (Voltage ~$20/mo)
- Users need to understand Bitcoin/Lightning (onboarding friction)
- Invoice expiration management (remind users to pay)
- Organizer needs Bitcoin wallet (not an issue for this project)

## License Review

- **BTCPay Server**: MIT, open-source ✓
- **Voltage**: Proprietary SaaS (manages BTCPay hosting)
- **LNBits**: MIT, open-source ✓
- All compatible with project license

## Security Review

- App never receives private keys or funds ✓
- BTCPay creates and signs invoices
- App verifies invoice state via API before accepting user
- Webhook signature validation (prevent spoofing)
- Use HTTPS for all communication
- Store BTCPay API key in environment variables
- Implement idempotent payment confirmation (prevent duplicate credits)
- Verify invoice amount matches expected fee before confirming

## Rollback Plan

If BTCPay becomes a blocker:

1. Fall back to LNBits (simpler, less feature-rich)
2. Generate invoices manually (worst case, requires organizer copy/paste)
3. Defer payment collection to post-MVP

## Implementation Plan

### Phase 1: BTCPay Setup

- [ ] Deploy BTCPay Server (Voltage for managed, or self-host)
- [ ] Create store in BTCPay
- [ ] Generate API key
- [ ] Configure webhook endpoint (app.example.com/webhooks/btcpay)

### Phase 2: Invoice Generation

- [ ] Create endpoint: POST /api/registrations/checkout
- [ ] Call BTCPay CreateInvoice API
- [ ] Store invoice ID in database (PENDING state)
- [ ] Return invoice URL to user

### Phase 3: Payment Confirmation

- [ ] Implement webhook handler: POST /webhooks/btcpay
- [ ] Verify webhook signature
- [ ] Update invoice state in database (CONFIRMED)
- [ ] Mark user as registered
- [ ] Publish Nostr event (user registered)

### Phase 4: State Reconciliation

- [ ] Implement invoice status checker (background job)
- [ ] Poll BTCPay for expired/unpaid invoices
- [ ] Remind users to pay (send notifications)
- [ ] Generate payment report for organizers

## BTCPay Integration (TypeScript)

```typescript
import axios from 'axios'
import crypto from 'crypto'

interface BTCPayConfig {
  baseUrl: string       // https://btcpay.voltage.cloud
  storeId: string       // BTCPay store ID
  apiKey: string        // API key from environment
  webhookSecret: string // Secret for webhook signature
}

async function generateInvoice(
  config: BTCPayConfig,
  amount: number, // sats
  email: string
) {
  const response = await axios.post(
    `${config.baseUrl}/api/v1/stores/${config.storeId}/invoices`,
    {
      amount: amount / 100_000_000, // Convert to BTC
      currency: 'BTC',
      orderId: `reg-${Date.now()}`,
      buyer: { email },
      itemDesc: 'Event Registration',
      notificationUrl: `${process.env.APP_BASE_URL}/webhooks/btcpay`,
      redirectUrl: `${process.env.APP_BASE_URL}/registration/success`,
    },
    {
      headers: { 'X-API-Key': config.apiKey },
    }
  )

  return {
    invoiceId: response.data.id,
    checkoutLink: response.data.checkoutLink,
    expiresAt: new Date(response.data.expiresAt),
  }
}

function verifyWebhookSignature(
  body: string,
  signature: string,
  secret: string
): boolean {
  const hash = crypto
    .createHmac('sha256', secret)
    .update(body)
    .digest('hex')
  return hash === signature
}

async function handlePaymentWebhook(
  req: Request,
  config: BTCPayConfig
) {
  const signature = req.headers['btcpay-sig'] as string
  const body = JSON.stringify(req.body)

  if (!verifyWebhookSignature(body, signature, config.webhookSecret)) {
    throw new Error('Invalid webhook signature')
  }

  const event = req.body
  const { invoiceId, status } = event

  if (status === 'settled') {
    // Payment confirmed!
    const user = await getUserByInvoiceId(invoiceId)
    await markUserAsRegistered(user.id)
    await publishUserRegisteredEvent(user)
  } else if (status === 'expired') {
    await expireInvoice(invoiceId)
  }
}
```

## Invoice State Machine

```
PENDING
  ├─ (user pays)    → CONFIRMED
  ├─ (expires)      → EXPIRED
  └─ (error)        → FAILED

CONFIRMED
  ├─ (webhook received) → SETTLED
  └─ (timeout, no webhook) → PENDING (retry)

SETTLED
  └─ (user registered) → COMPLETED

EXPIRED, FAILED, COMPLETED
  └─ (final states)
```

## Payment Confirmation Workflow

```
1. User clicks "Register"
   ↓
2. App creates invoice via BTCPay API
   Invoice state: PENDING
   ↓
3. User scans QR or clicks link
   ↓
4. User pays (Bitcoin or Lightning)
   ↓
5. BTCPay broadcasts payment
   ↓
6. App receives webhook (payment confirmed)
   Invoice state: CONFIRMED
   ↓
7. App marks user as registered
   ↓
8. App publishes Nostr event
```

## Invoice Status Reconciliation

```typescript
async function reconcileInvoices() {
  // Run every 5 minutes via background job
  
  const pendingInvoices = await db.invoices.findMany({
    where: { status: 'PENDING', createdAt: { before: -15min } }
  })

  for (const invoice of pendingInvoices) {
    const btcpayStatus = await checkInvoiceStatus(
      config,
      invoice.invoiceId
    )

    if (btcpayStatus.settled) {
      await db.invoices.update(invoice.id, { status: 'SETTLED' })
      await registerUser(invoice.userId)
    } else if (btcpayStatus.expired) {
      await db.invoices.update(invoice.id, { status: 'EXPIRED' })
      await sendReminderEmail(invoice.userId)
    }
  }
}
```

## Fee Structure

| Item | Amount | Notes |
|------|--------|-------|
| Registration Fee | Organizer-defined | Suggested: 10,000-50,000 sats |
| BTCPay Fee | 1% | Depends on managed service |
| Network Fee | Dynamic | Included in invoice |

## Validation

- [ ] Invoice created successfully in BTCPay
- [ ] User can pay invoice (Bitcoin or Lightning)
- [ ] Webhook confirms payment
- [ ] User is marked as registered
- [ ] Invoice state reconciliation works
- [ ] Organizer can view payment report
- [ ] Can handle payment timeout/retry

## Follow-up Decisions

- Should we support multiple currencies (USD, EUR)? (Consider for future)
- Should organizer payout be automatic or manual? (Manual for MVP)
- How long should invoices remain valid? (Recommend 24 hours)
- Should we support partial payments? (No, require full amount)

## References

- [BTCPay Server Documentation](https://docs.btcpay.server/)
- [BTCPay API Reference](https://docs.btcpay.server/API/)
- [Voltage BTCPay Hosting](https://voltage.cloud/)
- [Webhook Signature Verification](https://docs.btcpay.server/API/Webhooks/)
