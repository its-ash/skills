---
name: shopify
description: "Provides Shopify app extension theme patterns with CLI commands GraphQL queries for products orders metafields webhook config in shopify.app.toml Polaris UI and Liquid templates. Use when creating embedded apps checkout admin POS extensions custom themes via shopify cli shopify app init shopify theme dev graphql mutations access scopes metafields webhooks polaris react liquid handlebars deployment vercel railway docker node typescript nextjs stripe."
---

# Shopify Development

Create Shopify apps, extensions, and themes using the Shopify CLI, Polaris UI, App Bridge, and the GraphQL Admin API. Follow the patterns, commands, and best‑practice guidelines below to build secure, performant, and maintainable solutions.

## When to use
- You need a **Shopify app** (backend logic, billing, webhooks, embedded UI).
- You need a **Shopify extension** (checkout UI, admin UI, POS UI, Functions).
- You need a **Shopify theme** or custom Liquid snippets.
- You want to integrate external services, charge for features, or manage metafields.

---

## Project Types
| Type | Typical Use |
|------|--------------|
| **App** | Merchant tools, API integrations, billing, webhooks, embedded UI with App Bridge |
| **Extension** | Checkout UI, admin UI, POS UI, discount/payment Functions |
| **Theme** | Storefront design, Liquid templates, sections, snippets |
| **App + Extension** | Backend logic plus custom storefront UI |

---

## Setup and CLI
```bash
# Install the latest Shopify CLI globally
npm install -g @shopify/cli@latest
```

### Create and run an app
```bash
shopify app init          # Scaffold a new app (React Router template available)
shopify app dev           # Start dev server with tunnel (ngrok)
shopify app deploy        # Build and upload to the Partner Dashboard
```

### Generate extensions
```bash
shopify app generate extension --type checkout_ui_extension   # Checkout UI
shopify app generate extension --type admin_action          # Admin UI action
shopify app generate extension --type admin_block           # Admin UI block
shopify app generate extension --type pos_ui_extension      # POS UI
shopify app generate extension --type function              # Shopify Functions
```

### Theme development
```bash
shopify theme init        # Scaffold a new theme
shopify theme dev        # Local preview at http://localhost:9292
shopify theme pull --live   # Pull live theme files
shopify theme push --development   # Push to a development theme
```

---

## Access Scopes
Define required scopes in `shopify.app.toml`:
```toml
[access_scopes]
scopes = "read_products,write_products,read_orders,write_orders,read_customers"
```
Common scopes:
- `read_products`, `write_products`
- `read_orders`, `write_orders`
- `read_customers`, `write_customers`
- `read_inventory`, `write_inventory`
- `read_fulfillments`, `write_fulfillments`

---

## GraphQL Patterns (API version 2026-01)
### Query products
```graphql
query GetProducts($first: Int!, $query: String) {
  products(first: $first, query: $query) {
    edges {
      node {
        id
        title
        handle
        status
        variants(first: 5) {
          edges {
            node {
              id
              price
              inventoryQuantity
            }
          }
        }
      }
    }
    pageInfo { hasNextPage endCursor }
  }
}
```
### Query orders
```graphql
query GetOrders($first: Int!) {
  orders(first: $first) {
    edges {
      node {
        id
        name
        createdAt
        displayFinancialStatus
        totalPriceSet {
          shopMoney { amount currencyCode }
        }
      }
    }
  }
}
```
### Set metafields (mutation)
```graphql
mutation SetMetafields($metafields: [MetafieldsSetInput!]!) {
  metafieldsSet(metafields: $metafields) {
    metafields { id namespace key value }
    userErrors { field message }
  }
}
```
Variables example:
```json
{
  "metafields": [
    {
      "ownerId": "gid://shopify/Product/123",
      "namespace": "custom",
      "key": "care_instructions",
      "value": "Handle with care",
      "type": "single_line_text_field"
    }
  ]
}
```

---

## Checkout Extension Example (React)
```tsx
import {
  reactExtension,
  BlockStack,
  TextField,
  Checkbox,
  useApplyAttributeChange,
} from "@shopify/ui-extensions-react/checkout";
import { useState, useEffect } from "react";

export default reactExtension("purchase.checkout.block.render", () => (
  <GiftMessage />
));

function GiftMessage() {
  const [isGift, setIsGift] = useState(false);
  const [message, setMessage] = useState("");
  const applyAttributeChange = useApplyAttributeChange();

  useEffect(() => {
    if (isGift && message) {
      applyAttributeChange({
        type: "updateAttribute",
        key: "gift_message",
        value: message,
      });
    }
  }, [isGift, message]);

  return (
    <BlockStack spacing="loose">
      <Checkbox checked={isGift} onChange={setIsGift}>This is a gift</Checkbox>
      {isGift && (
        <TextField label="Gift Message" value={message} onChange={setMessage} multiline={3} />
      )}
    </BlockStack>
  );
}
```

---

## Liquid Template Example
```liquid
{% comment %} Product Card Snippet {% endcomment %}
<div class="product-card">
  <a href="{{ product.url }}">
    {% if product.featured_image %}
      <img src="{{ product.featured_image | img_url: 'medium' }}"
           alt="{{ product.title | escape }}"
           loading="lazy" />
    {% endif %}
    <h3>{{ product.title }}</h3>
    <p class="price">{{ product.price | money }}</p>
    {% if product.compare_at_price > product.price %}
      <p class="sale-badge">Sale</p>
    {% endif %}
  </a>
</div>
```

---

## Webhook Configuration (in `shopify.app.toml`)
```toml
[webhooks]
api_version = "2026-01"

[[webhooks.subscriptions]]
topics = ["orders/create", "orders/updated"]
uri = "/webhooks/orders"

[[webhooks.subscriptions]]
topics = ["products/update"]
uri = "/webhooks/products"

# GDPR mandatory webhooks (required for app approval)
[webhooks.privacy_compliance]
customer_data_request_url = "/webhooks/gdpr/data-request"
customer_deletion_url = "/webhooks/gdpr/customer-deletion"
shop_deletion_url = "/webhooks/gdpr/shop-deletion"
```
**Security tip:** Verify the HMAC signature of every incoming webhook before processing.

---

## Anti‑Patterns (avoid these)
- Using the REST API for new apps – prefer GraphQL.
- Processing a webhook before sending a `200 OK` response – respond immediately, then handle asynchronously.
- Polling the API for changes – use webhooks instead.

---

## Sharp Edges & Mitigations
| Issue | Severity | Mitigation |
|-------|----------|------------|
| Immediate webhook response required | High | Respond `200 OK` quickly; queue heavy work.
| Rate‑limit handling | High | Read `X-Shopify-Shop-Api-Call-Limit` header; implement exponential backoff.
| Access to protected customer data | High | Request only needed scopes; use GDPR handlers.
| TOML configuration format | Medium | Use TOML exclusively for app config.
| URL format variations | Medium | Accept both `https://example.com/webhook` and relative paths.
| Prefer GraphQL for new code | High | Migrate existing REST calls where possible.
| Use latest App Bridge via script tag | High | Include `@shopify/app-bridge` from CDN.
| GDPR compliance | High | Implement all required privacy‑compliance webhooks.

---

## Best Practices
### API Usage
- Use GraphQL over REST for new development.
- Request only the fields you need; reduces query cost.
- Implement cursor‑based pagination (`pageInfo.endCursor`).
- Use bulk operations for >250 items.
- Apply exponential backoff on `429` or `X-Shopify-Shop-Api-Call-Limit` limits.

### Security
- Store API keys and secrets in environment variables.
- Verify webhook HMAC signatures before any processing.
- Validate OAuth `state` parameter to prevent CSRF.
- Request the minimal set of access scopes.
- Use session tokens for embedded apps (App Bridge).

### Performance
- Cache immutable API responses (e.g., product catalogs).
- Lazy‑load heavy UI components in extensions.
- Optimize images with `img_url` filter and `loading="lazy"`.
- Monitor GraphQL query cost via `X-GraphQL-Cost` response header.

---

## Troubleshooting
- **Rate‑limit errors**: Implement exponential backoff; switch to bulk operations; monitor `X-Shopify-Shop-Api-Call-Limit`.
- **Authentication failures**: Confirm access token validity; ensure required scopes were granted; verify OAuth flow completed.
- **Extension not appearing**: Check target type; run `shopify app deploy`; confirm app is installed on the test store.
- **Webhook not receiving events**: Ensure URL is publicly reachable; verify HMAC validation logic; view webhook logs in the Partner Dashboard.
- **GraphQL query errors**: Validate query against schema (use GraphiQL); remove deprecated fields; confirm required scopes.

---

## Checklist
- [ ] Install Shopify CLI (`npm install -g @shopify/cli`).
- [ ] Choose project type: App, Extension, Theme, or combination.
- [ ] Scaffold project with `shopify app init` or `shopify theme init`.
- [ ] Define required access scopes in `shopify.app.toml`.
- [ ] Use GraphQL for data fetching and mutations.
- [ ] Verify webhook HMAC signatures.
- [ ] Implement immediate `200 OK` response for webhooks.
- [ ] Add GDPR compliance webhooks if the app handles customer data.
- [ ] Test rate‑limit handling with exponential backoff.
- [ ] Deploy with `shopify app deploy` and confirm installation on a development store.
- [ ] Run local dev server (`shopify app dev` or `shopify theme dev`).
- [ ] Use Polaris components for embedded UI; include App Bridge script.
- [ ] Optimize images and lazy‑load UI where possible.
- [ ] Monitor query costs and API call limits in logs.

## Related skills

Load these when the task spans more than this skill.

- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`react-state-management`](../react-state-management/SKILL.md) — A concise guide for choosing and implementing React state management solutions—Redux Toolkit, Zustand, Jotai,…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`stripe`](../stripe/SKILL.md) — Implements Stripe payments, subscriptions, billing portal, checkout sessions, and webhooks with idempotency, s…
