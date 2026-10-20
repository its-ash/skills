---
name: api-integration
description: "Integrates third-party REST and GraphQL APIs with authentication, request handling, retries, rate limiting, webhook verification, response transformation, and monitoring. Use when building API clients, calling REST endpoints or GraphQL queries, handling OAuth 2.0, API keys, bearer tokens, webhooks, pagination, exponential backoff, 429 errors, JSON responses, or debugging request failures."
---

# API Integration

Provide production‑ready patterns for connecting external services. Focus on security, reliability, and observability.

## When to Use
- Adding a third‑party API (e.g., Stripe, Twilio, SendGrid).
- Building a reusable client library or wrapper.
- Implementing OAuth 2.0, API‑key, or JWT authentication.
- Receiving events through webhooks.
- Handling rate limits, retries, or circuit breakers.
- Transforming external responses to internal models.
- Debugging integration problems.

## Workflow
1. Store all secrets in environment variables or a secrets manager.
2. Initialise an authentication client (API key, OAuth, JWT).
3. Build a standard request helper that adds common headers.
4. Wrap the request in retry logic with exponential back‑off.
5. Apply a client‑side rate limiter before each call.
6. Verify webhook signatures on inbound requests.
7. Transform the raw response into the application’s data model.
8. Log request details and monitor latency, error rates, and quota usage.

## Authentication & Security
```javascript
// Load credentials from the environment – never hard‑code them
const apiClient = new APIClient({
  apiKey: process.env.SERVICE_API_KEY,
  baseURL: process.env.SERVICE_BASE_URL
});
```

### OAuth 2.0 Authorization Code Flow
```javascript
const oauth = new OAuth2Client({
  clientId: process.env.CLIENT_ID,
  clientSecret: process.env.CLIENT_SECRET,
  redirectUri: process.env.REDIRECT_URI,
  scopes: ['read:users', 'write:data']
});

// Step 1 – redirect user to consent screen
const authUrl = oauth.getAuthorizationUrl();

// Step 2 – exchange the returned code for tokens
const tokens = await oauth.exchangeCode(code);
```

## Request / Response Handling
```javascript
async function makeRequest(endpoint, options = {}) {
  const defaultHeaders = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${process.env.SERVICE_API_KEY}`,
    'User-Agent': 'MyApp/1.0.0'
  };

  const response = await fetch(`${process.env.SERVICE_BASE_URL}${endpoint}`, {
    ...options,
    headers: { ...defaultHeaders, ...options.headers }
  });

  if (!response.ok) {
    throw new APIError(response.status, await response.json());
  }
  return response.json();
}
```

### Response Transformation Example
```javascript
class APIClient {
  async getUser(userId) {
    const raw = await this.request(`/users/${userId}`);
    return {
      id: raw.user_id,
      email: raw.email_address,
      name: `${raw.first_name} ${raw.last_name}`,
      createdAt: new Date(raw.created_timestamp)
    };
  }
}
```

## Error Handling
```javascript
class APIError extends Error {
  constructor(status, body) {
    super(`API Error: ${status}`);
    this.status = status;
    this.body = body;
    this.isAPIError = true;
  }
  isRateLimited() { return this.status === 429; }
  isUnauthorized() { return this.status === 401; }
  isServerError() { return this.status >= 500; }
}
```

### Retry with Exponential Back‑off
```javascript
async function retryWithBackoff(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try { return await fn(); } catch (e) {
      if (!e.isAPIError || !e.isServerError()) throw e; // do not retry client errors
      if (i === maxRetries - 1) throw e;
      const delay = Math.pow(2, i) * 1000; // 1s, 2s, 4s
      await new Promise(r => setTimeout(r, delay));
    }
  }
}
```

## Rate Limiting
```javascript
class RateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.timestamps = [];
  }
  async acquire() {
    const now = Date.now();
    this.timestamps = this.timestamps.filter(t => now - t < this.windowMs);
    if (this.timestamps.length >= this.maxRequests) {
      const wait = this.windowMs - (now - this.timestamps[0]);
      await new Promise(r => setTimeout(r, wait));
      return this.acquire();
    }
    this.timestamps.push(now);
  }
}

const limiter = new RateLimiter(100, 60000); // 100 requests per minute

async function rateLimitedRequest(endpoint, opts) {
  await limiter.acquire();
  return makeRequest(endpoint, opts);
}
```

## Webhook Handling
```javascript
function verifyWebhookSignature(payload, signature, secret) {
  const expected = crypto.createHmac('sha256', secret)
                         .update(payload)
                         .digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
}

app.post('/webhooks/stripe', express.raw({ type: 'application/json' }), (req, res) => {
  const sig = req.headers['stripe-signature'];
  if (!verifyWebhookSignature(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET)) {
    return res.status(401).send('Invalid signature');
  }
  const event = JSON.parse(req.body);
  handleWebhookEvent(event);
  res.status(200).send('Received');
});
```

## Integration Patterns
### REST API Client Skeleton
```javascript
class ServiceAPIClient {
  constructor({ apiKey, baseURL, timeout = 30000 }) {
    this.apiKey = apiKey;
    this.baseURL = baseURL;
    this.timeout = timeout;
  }
  async request(method, endpoint, data = null) {
    const opts = {
      method,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      },
      timeout: this.timeout
    };
    if (data) opts.body = JSON.stringify(data);
    const fn = () => fetch(`${this.baseURL}${endpoint}`, opts);
    const response = await retryWithBackoff(fn);
    return response.json();
  }
  // CRUD helpers
  get(id) { return this.request('GET', `/resources/${id}`); }
  create(data) { return this.request('POST', '/resources', data); }
  update(id, data) { return this.request('PUT', `/resources/${id}`, data); }
  delete(id) { return this.request('DELETE', `/resources/${id}`); }
}
```

### Pagination Helper (Async Generator)
```javascript
async function* fetchAllPages(endpoint, pageSize = 100) {
  let cursor = null;
  do {
    const params = new URLSearchParams({ limit: pageSize, ...(cursor && { cursor }) });
    const resp = await apiClient.request('GET', `${endpoint}?${params}`);
    yield resp.data;
    cursor = resp.pagination?.next_cursor;
  } while (cursor);
}
```

## Best Practices
### Security
- Store keys in environment variables or a secrets manager.
- Use HTTPS for every request.
- Verify signatures on inbound webhooks.
- Rotate API keys regularly.
- Apply request signing when the provider requires it.

### Reliability
- Implement exponential‑backoff retries for transient failures.
- Respect the provider’s rate‑limit headers.
- Set explicit timeouts on all network calls.
- Use a circuit‑breaker pattern for repeatedly failing services.
- Log request and response metadata for debugging.

### Performance
- Cache immutable responses when appropriate.
- Batch multiple operations into a single request if the API supports it.
- Stream large payloads instead of loading them fully in memory.
- Re‑use HTTP connections (keep‑alive) or a connection pool.
- Monitor usage to avoid unexpected cost spikes.

### Monitoring
- Record latency for each endpoint.
- Alert when error rates exceed a threshold.
- Track quota consumption and remaining limits.
- Include request IDs in logs to correlate client and server events.
- Deploy health‑check endpoints that perform a lightweight API call.

## Common Integration Snippets
### Stripe – Create Payment Intent
```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
async function createPaymentIntent(amount, currency = 'usd') {
  return await stripe.paymentIntents.create({ amount, currency, automatic_payment_methods: { enabled: true } });
}
```
### SendGrid – Send Email
```javascript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);
async function sendEmail(to, subject, html) {
  await sgMail.send({ to, from: process.env.FROM_EMAIL, subject, html });
}
```
### Twilio – Send SMS
```javascript
const twilio = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
async function sendSMS(to, body) {
  await twilio.messages.create({ to, from: process.env.TWILIO_PHONE_NUMBER, body });
}
```

## Troubleshooting Checklist
- **Authentication**: Verify environment variables, token expiry, OAuth scopes, and signature generation.
- **Rate Limits**: Check `Retry-After` header, ensure client‑side limiter is active, consider batch endpoints.
- **Timeouts**: Increase timeout values, enable request cancellation, test network latency.
- **Invalid Responses**: Confirm `Content-Type`, validate JSON schema, log raw payloads.
- **Webhook Failures**: Confirm raw body is used for signature verification, ensure endpoint is publicly reachable, check timestamp tolerance.
- **Unexpected Errors**: Review logs for stack traces, enable debug mode on the HTTP client, reproduce with a minimal request.

## Checklist for a New Integration
- [ ] Store all secrets in environment variables.
- [ ] Choose appropriate authentication method (API key, OAuth, JWT).
- [ ] Implement `makeRequest` with standard headers.
- [ ] Wrap requests with `retryWithBackoff`.
- [ ] Add `RateLimiter` and use `rateLimitedRequest`.
- [ ] Create response‑transformation functions.
- [ ] Set up webhook endpoint with signature verification.
- [ ] Log request ID, latency, status, and error details.
- [ ] Add health‑check that performs a cheap API call.
- [ ] Write unit tests for success, client error, server error, and rate‑limit scenarios.

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`stripe`](../stripe/SKILL.md) — Implements Stripe payments, subscriptions, billing portal, checkout sessions, and webhooks with idempotency, s…
- [`web-scraping-apis`](../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
