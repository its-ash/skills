---
name: stripe
description: "Implements Stripe payments, subscriptions, billing portal, checkout sessions, and webhooks with idempotency keys, signature verification, and dunning handling for reliable payment processing. Use when integrating stripe-node or stripe-python SDKs, creating checkout.session.completed or invoice.payment_failed webhook handlers, configuring subscription schedules with trial periods, setting up customer portal for self-service billing, handling payment_intent.succeeded events, managing metered billing with usage records, processing refunds and disputes, or debugging webhook signature verification failures and idempotency key conflicts."
---

# Stripe Integration

Implement Stripe payments, subscriptions, and billing reliably. Follow the patterns below to avoid duplicate charges, missed events, and revenue loss.

## When to use
- You need to accept one‑time or recurring payments.
- You want a hosted checkout page or a custom payment flow.
- You need a billing portal for customers to manage their subscriptions.
- You must handle failed payments, dunning, and refunds.
- You are using Stripe Connect for marketplace payouts.

## Core workflow
1. **Set API keys** – Store `STRIPE_SECRET_KEY` and `STRIPE_PUBLISHABLE_KEY` in environment variables. Use separate keys for test and live mode.
2. **Create a Checkout Session** – Call `stripe.checkout.sessions.create` with line items, success/cancel URLs, and optional `metadata`.
3. **Redirect the customer** – Send the client to the URL returned by the Checkout Session.
4. **Listen for webhooks** – Verify the signature, then process events such as `checkout.session.completed`, `invoice.payment_succeeded`, `invoice.payment_failed`, and subscription lifecycle events.
5. **Update local state** – Store the Stripe object IDs (customer, subscription, payment intent) in your database. Refresh state from Stripe on each webhook to avoid drift.
6. **Handle dunning** – When `invoice.payment_failed` fires, attempt a retry or pause the subscription according to your policy.
7. **Refund or cancel** – Use the appropriate Stripe API calls, passing the original `payment_intent` ID.

## Idempotency keys
- Generate a unique key for every payment‑related request (e.g., `order-12345-at-2023-10-01T12:00:00Z`).
- Pass the key in the `Idempotency-Key` header.
- Re‑use the same key if the client retries the request after a network error.
- Do not reuse keys for different operations.

```js
// Node.js example
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
await stripe.paymentIntents.create(
  { amount: 2000, currency: 'usd', payment_method: pmId },
  { idempotencyKey: `order-${orderId}` }
);
```

## Webhook verification
- Configure the endpoint URL in the Stripe Dashboard.
- Retrieve the `Stripe-Signature` header from the request.
- Use the endpoint’s signing secret to verify the payload.
- Reject any request that fails verification with `400 Bad Request`.

```js
// Express.js verification example
const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
app.post('/webhook', express.raw({type: 'application/json'}), (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.error('Webhook signature verification failed.', err);
    return res.sendStatus(400);
  }
  // Process event
  handleEvent(event);
  res.json({received: true});
});
```

### Common webhook events to handle
| Event | Action |
|-------|--------|
| `checkout.session.completed` | Mark order as paid, create a subscription if needed |
| `invoice.payment_succeeded` | Record successful payment, reset dunning counters |
| `invoice.payment_failed` | Increment dunning count, send reminder email, optionally pause subscription |
| `customer.subscription.updated` | Sync subscription status and plan changes |
| `customer.subscription.deleted` | Cancel local subscription record |
| `payment_intent.payment_failed` | Log failure, notify user, allow retry |

## Subscription management
- Create subscriptions via `stripe.subscriptions.create` or through Checkout Session with `mode: 'subscription'`.
- Store the `subscription.id` and the current `status`.
- Listen to `customer.subscription.*` events to keep local state in sync.
- Use `proration_behavior` to control billing when changing plans.
- Include `metadata` (e.g., internal order ID) in the subscription for later lookup.

## Dunning and failed payments
- Set `payment_settings.payment_method_options.card.request_three_d_secure` to `any` to improve success rates.
- Configure `payment_settings.dunning` in the Dashboard or via API to define retry schedule.
- In `invoice.payment_failed` webhook, decide whether to:
  - Retry automatically (Stripe will follow the retry schedule).
  - Pause the subscription (`subscription.pause_collection`).
  - Cancel the subscription after a configurable number of attempts.
- Notify the customer after each failure with a clear call‑to‑action.

## Metered billing
- Define usage‑recorded price items in the Stripe Dashboard.
- Record usage with `stripe.usageRecords.create`.
- Use `billing_thresholds` to trigger invoices when usage exceeds a limit.
- Ensure you create usage records before the billing period ends.

## Stripe Connect (optional)
- Choose account type: **Standard**, **Express**, or **Custom**.
- Use OAuth flow (`/oauth/authorize`) for Standard/Express accounts.
- For Custom accounts, create a `Connect` account via `stripe.accounts.create`.
- When creating a payment, set `transfer_data[destination]` to the connected account ID.
- Handle `account.updated` and `account.application.deauthorized` webhooks to keep account status current.

## Anti‑patterns to avoid
- **Never trust the API response** for payment status. Always confirm with a webhook.
- **Never skip signature verification** on webhook endpoints.
- **Never store subscription status without listening to all related webhooks** – state will drift.
- **Never use the same idempotency key for different operations** – it will block legitimate requests.
- **Never mix test and live keys** in the same environment.

## Sharp edges and mitigations
| Issue | Mitigation |
|-------|------------|
| JSON body parsed before signature verification (e.g., in Next.js) | Use `express.raw` or `nextjs` `api` route with `bodyParser: false` to access raw payload |
| Missing metadata in Checkout Session | Add `metadata` field with internal IDs when creating the session |
| Duplicate charges after retries | Always send an idempotency key; store the key with the order for debugging |
| Subscription state drift | Process **all** subscription‑related events; periodically reconcile with Stripe API |
| Different behavior between test and live mode | Keep separate environment variables; run integration tests in both modes |

## Checklist
- [ ] Set separate test and live API keys in environment variables.
- [ ] Generate and attach an idempotency key to every payment‑related request.
- [ ] Verify webhook signatures on every endpoint.
- [ ] Include `metadata` (order ID, user ID) in Checkout Sessions and Subscriptions.
- [ ] Listen to and process all subscription and invoice events.
- [ ] Implement dunning logic for `invoice.payment_failed`.
- [ ] Record usage for metered billing before the billing period ends.
- [ ] If using Connect, handle OAuth flow and `account.*` webhooks.
- [ ] Test all flows with Stripe test cards and the Stripe CLI (`stripe listen`).
- [ ] Deploy with the correct mode (test vs. live) and verify that no test keys remain in production.

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`fastapi`](../fastapi/SKILL.md) — FastAPI skill for building production‑ready async endpoints with FastAPI, Pydantic v2, SQLAlchemy 2.0, depende…
- [`shopify`](../shopify/SKILL.md) — Provides expert patterns, CLI commands, GraphQL queries, webhook setup, Polaris UI, and best‑practice checklis…
