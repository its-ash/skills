---
name: secure-coding
description: "Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL injection, XSS, CSRF, API security, rate limiting, and deployment hardening. Use when writing or reviewing security-sensitive code, APIs, auth, payments, or producing a security report in Python (.py), JavaScript/TypeScript (.js, .ts), or Go (.go), or when handling JWT, OAuth, SQL queries, env vars, API keys, npm, pip, or go modules. Sub-skills: web-vulnerability-testing, data-privacy-compliance, security-bounty-hunter, cloud-infrastructure-security."
---

# Secure Coding

Secure coding protects trust boundaries: validate input, protect secrets, enforce authorization, prevent injection, and avoid leaking data. Apply these patterns when writing or reviewing security-sensitive code.

## When to use

- Implementing or reviewing authentication, authorization, sessions, or tokens.
- Handling user input, file uploads, database queries, or third-party API data.
- Designing or securing REST, GraphQL, or WebSocket APIs.
- Working with secrets, credentials, payments, or sensitive data.
- Producing a security report or secure-by-default code in Python, JavaScript/TypeScript, or Go.
- Do not use for general code review, debugging, or non-security tasks.

## Review workflow

- Identify frontend and backend languages and frameworks; record evidence from manifests and imports.
- Apply project-specific security documentation or approved overrides before generic rules.
- Choose a mode:
  - Secure by default: apply these rules while writing new code.
  - Passive detection: flag critical issues while editing and ask before fixing.
  - Full review: produce a prioritized report.
- For a full review, write `security_best_practices_report.md` or a user-specified path. Include:
  - Executive summary.
  - Findings grouped by severity, each with a numeric ID.
  - One-sentence impact for critical findings.
  - File paths and line numbers for referenced code.
  - Summary of findings and report location.
- Fix one finding at a time. Add concise comments that cite the security practice and why it matters. Run configured tests and check for regressions. Use clear commit messages and avoid mixing unrelated findings.
- If a practice must be bypassed, document the reason and follow that documented exception.

## General rules

- Use long random public IDs such as UUID4 or random hex strings. Do not expose small auto-incrementing IDs.
- Treat TLS as deployment-specific. Do not report missing TLS in local development by default. Set `Secure` cookies only when the app runs over TLS; provide an environment flag to disable them for local development. Avoid recommending HSTS unless deployment and rollback are understood.
- Prefer allowlists over blocklists.
- Validate at trust boundaries and never trust client data.
- Fail closed: deny by default.

## Secrets management

- Never hardcode API keys, tokens, passwords, or connection strings.
- Load secrets from environment variables and fail startup if required values are missing.
- Keep `.env.local` and secret files out of version control.
- Rotate and remove secrets from history if they are exposed.
- Store production secrets in the hosting platform secret manager.

```ts
const apiKey = process.env.OPENAI_API_KEY;
if (!apiKey) throw new Error('OPENAI_API_KEY not configured');
```

Generate a strong secret:

```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

## Input validation

- Validate all user input with schemas before processing.
- Validate type, format, range, length, and allowed values.
- Validate file uploads by size, MIME type, and extension.
- Return generic validation errors.
- Sanitize HTML with an allowlist of tags and attributes.

```ts
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150).optional(),
});
```

```ts
const maxSize = 5 * 1024 * 1024;
const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
if (file.size > maxSize) throw new Error('File too large (max 5MB)');
if (!allowedTypes.includes(file.type)) throw new Error('Invalid file type');
```

```ts
import DOMPurify from 'isomorphic-dompurify';

const clean = DOMPurify.sanitize(html, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
  ALLOWED_ATTR: [],
});
```

## SQL and data access

- Never concatenate user input into SQL.
- Use parameterized queries or a correctly used ORM/query builder.
- Select only needed columns; do not return password hashes or secrets.
- Enable row-level security for multi-tenant data stores such as Supabase.

```ts
const { data } = await supabase.from('users').select('*').eq('email', userEmail);

await db.query(
  'SELECT id, email, name FROM users WHERE email = $1',
  [userEmail]
);
```

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);
CREATE POLICY "Users update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

## Authentication and authorization

- Require authentication for protected endpoints.
- Store bearer tokens in `httpOnly`, `Secure`, `SameSite` cookies, not `localStorage`.
- Use strong JWT secrets (at least 256 bits), short access-token expiry (about 1 hour), and server-side refresh tokens.
- Validate JWT issuer and audience. Do not store sensitive data in JWT payloads.
- Hash passwords with bcrypt and salt rounds of at least 10.
- Enforce authorization for every object and function: ownership, role, or policy checks.
- Implement RBAC when roles differ.
- For blockchain flows, verify wallet signatures and validate transaction recipient, amount, and balance.

```js
const token = jwt.sign(
  { userId: user.id, email: user.email, role: user.role },
  process.env.JWT_SECRET,
  { expiresIn: '1h', issuer: 'app', audience: 'app-users' }
);
```

```js
jwt.verify(token, process.env.JWT_SECRET, {
  issuer: 'app',
  audience: 'app-users',
}, (err, user) => {
  if (err) return res.status(403).json({ error: 'Invalid token' });
  req.user = user;
  next();
});
```

```ts
if (post.userId !== requesterId && requester.role !== 'admin') {
  return NextResponse.json({ error: 'Unauthorized' }, { status: 403 });
}
```

```ts
const isValid = verify(
  Buffer.from(message),
  Buffer.from(signature, 'base64'),
  Buffer.from(publicKey, 'base64')
);
```

## API security

- Use HTTPS/TLS for all production traffic.
- Authenticate and authorize every endpoint; default deny.
- Validate request bodies against schemas.
- Use parameterized queries for all database access.
- Implement rate limiting per user and IP. Use stricter limits for login, registration, search, and expensive operations.
- Return standard rate-limit headers and `429` with retry guidance.
- Use Redis or another shared store for distributed limits.
- Add security headers with Helmet or equivalent: CSP, frame protection, MIME sniffing protection. Enable HSTS only when TLS is understood.
- Configure CORS for trusted origins only.
- Sanitize errors: log details server-side and return generic messages.
- Do not expose stack traces or database details.
- Implement refresh and revocation for logout.
- Apply the same controls to GraphQL and WebSocket APIs.

```js
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);
```

```js
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  frameguard: { action: 'deny' },
  noSniff: true,
}));
```

## XSS and CSRF

- Sanitize user HTML before rendering.
- Use framework escaping and avoid unsafe HTML injection.
- Set a Content Security Policy.
- Start with a strict CSP. Do not use `'unsafe-inline'` or `'unsafe-eval'` by default. If you must use them, record them as temporary debt with a removal plan.
- Use CSRF tokens for state-changing requests. Use the double-submit cookie pattern when the server keeps no session state.
- Set cookies with `SameSite=Strict`.

```ts
// next.config.js
const securityHeaders = [{
  key: 'Content-Security-Policy',
  value: `
    default-src 'self';
    base-uri 'self';
    object-src 'none';
    frame-ancestors 'none';
    script-src 'self';
    style-src 'self';
    img-src 'self' data: https:;
    font-src 'self';
    connect-src 'self' https://api.example.com;
  `.replace(/\s{2,}/g, ' ').trim(),
}];
```

```ts
if (!csrf.verify(request.headers.get('X-CSRF-Token'))) {
  return NextResponse.json({ error: 'Invalid CSRF token' }, { status: 403 });
}
```

## Rate limiting and abuse protection

- Rate-limit all API endpoints.
- Use stricter limits for expensive operations.
- Rate-limit by IP and by authenticated user.
- Use tiered limits by account plan when applicable.

```js
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true,
});
app.use('/api/auth/login', authLimiter);
```

## Sensitive data exposure

- Do not log passwords, tokens, card numbers, or secrets.
- Redact sensitive fields in logs.
- Return generic errors to users; keep detailed errors server-side.
- Do not store sensitive data in JWTs.
- Encrypt sensitive data at rest and in transit.

```ts
console.log('User login:', { email, userId });
```

## File uploads

- Validate size, type, and extension.
- Store uploads outside the web root or in object storage.
- Generate random filenames; do not trust user filenames.
- Validate content where possible.

## Dependencies

- Run `npm audit`.
- Fix automatically fixable issues with `npm audit fix`.
- Update dependencies and check `npm outdated`.
- Commit lock files and use `npm ci` in CI.
- Enable Dependabot or equivalent.

```bash
npm audit
npm audit fix
npm update
npm outdated
npm ci
```

## Blockchain (Solana)

- Verify wallet ownership with signatures.
- Validate transaction recipient, amount, and balance before signing or accepting.
- Do not sign transactions blindly.

```ts
async function verifyTransaction(transaction, expectedRecipient, maxAmount) {
  if (transaction.to !== expectedRecipient) throw new Error('Invalid recipient');
  if (transaction.amount > maxAmount) throw new Error('Amount exceeds limit');
  const balance = await getBalance(transaction.from);
  if (balance < transaction.amount) throw new Error('Insufficient balance');
  return true;
}
```

## Security testing

- Test unauthenticated access returns `401`.
- Test unauthorized access returns `403`.
- Test invalid input returns `400`.
- Test rate limits return `429`.
- Run dependency audits.

```ts
test('requires authentication', async () => {
  const response = await fetch('/api/protected');
  expect(response.status).toBe(401);
});
```

## Common pitfalls

- Hardcoded JWT secret: load from environment and fail if missing.
- Weak passwords: require length and character classes, or score with a password-strength library.
- Missing authorization: check ownership or role after authentication.
- Verbose errors: log full errors server-side and return generic messages.
- SQL injection: use parameterized queries or ORM methods.
- XSS: sanitize HTML and use CSP.
- Token storage: use httpOnly cookies, not `localStorage`.

```js
// Bad
const JWT_SECRET = 'my-secret-key';

// Good
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) throw new Error('JWT_SECRET environment variable is required');
```

```js
const passwordSchema = z.string()
  .min(12, 'Password must be at least 12 characters')
  .regex(/[A-Z]/, 'Must contain uppercase letter')
  .regex(/[a-z]/, 'Must contain lowercase letter')
  .regex(/[0-9]/, 'Must contain number')
  .regex(/[^A-Za-z0-9]/, 'Must contain special character');
```

```js
// Bad
app.delete('/api/posts/:id', authenticateToken, async (req, res) => {
  await prisma.post.delete({ where: { id: req.params.id } });
});

// Good
app.delete('/api/posts/:id', authenticateToken, async (req, res) => {
  const post = await prisma.post.findUnique({ where: { id: req.params.id } });
  if (!post) return res.status(404).json({ error: 'Post not found' });
  if (post.userId !== req.user.userId && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Not authorized' });
  }
  await prisma.post.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});
```

```js
catch (error) {
  console.error('User creation error:', error);
  if (error.code === 'P2002') {
    return res.status(400).json({ error: 'Email already exists' });
  }
  return res.status(500).json({ error: 'An error occurred while creating user' });
}
```

## Pre-deployment checklist

- No hardcoded secrets; all secrets in environment variables.
- All user inputs validated.
- All database queries parameterized.
- User content sanitized.
- CSRF protection enabled.
- Authentication uses secure token handling.
- Authorization checks present.
- Rate limiting enabled on all endpoints.
- HTTPS enforced in production.
- Security headers configured.
- Error messages are generic.
- Sensitive data is not logged.
- Dependencies updated with no known vulnerabilities.
- Row-level security enabled where applicable.
- CORS configured for trusted origins.
- File uploads validated.
- Wallet signatures verified when blockchain is used.

## OWASP API Security Top 10

- Broken object-level authorization.
- Broken authentication.
- Broken object property-level authorization.
- Unrestricted resource consumption.
- Broken function-level authorization.
- Unrestricted access to sensitive business flows.
- Server-side request forgery.
- Security misconfiguration.
- Improper inventory management.
- Unsafe consumption of APIs.

## Additional resources

- OWASP API Security Top 10: https://owasp.org/www-project-api-security/
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- JWT best practices: https://tools.ietf.org/html/rfc8725
- Next.js security: https://nextjs.org/docs/security
- Supabase auth security: https://supabase.com/docs/guides/auth
- PortSwigger Web Security Academy: https://portswigger.net/web-security

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/web-vulnerability-testing.md](references/web-vulnerability-testing.md) | Test web applications and APIs for OWASP vulnerabilities including SQL injection, XSS, CSRF, SSRF, IDOR, authentication bypass, path traversal, insecure headers, and misconfiguration. Use when running authorized penetration tests, security audits, bug bounty triage, vulnerability scanning, Burp Suite, OWASP ZAP, Nikto, nuclei, ffuf, curl, HTTP requests, JWT tokens, session cookies, REST endpoints, GraphQL, or remediation planning. |
| [references/data-privacy-compliance.md](references/data-privacy-compliance.md) | Implement and audit privacy compliance for GDPR, DSGVO, CCPA, CPRA, and HIPAA covering lawful basis, consent, data subject rights, DPIA, privacy by design, minimization, breach response, international transfers, and audits. Use when implementing GDPR DSGVO CCPA CPRA HIPAA requirements, documenting lawful basis, handling access deletion portability objection requests, managing consent, running DPIAs, enforcing minimization, responding to breaches, configuring SCC BCR transfers, reviewing DPAs, or preparing compliance audits. |
| [references/security-bounty-hunter.md](references/security-bounty-hunter.md) | Hunt for remotely reachable, exploitable vulnerabilities for responsible disclosure or bug bounty reports (Huntr, HackerOne). Use for scope checks, SSRF, auth bypass, RCE, SQLi, path traversal triage, PoC proof, and report writing. |
| [references/cloud-infrastructure-security.md](references/cloud-infrastructure-security.md) | Secure cloud deployments, IAM least privilege, MFA, secrets managers, network isolation, logging and monitoring, CI/CD pipeline security, CDN and WAF, backup and disaster recovery on AWS, Vercel, Railway, or Cloudflare. |

## Related skills

Load these when the task spans more than this skill.

- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`web-vulnerability-testing`](references/web-vulnerability-testing.md) — Test web applications for OWASP-aligned vulnerabilities across injection, authentication, access control, API,…
- [`golang`](../golang/SKILL.md) — Provides expert guidance for Go 1.21+ development, covering concurrency patterns, performance tuning, microser…
