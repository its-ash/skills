# Secure code patterns

One good example per control. TypeScript/Node; port the idea to other stacks.

## Secrets

```ts
const key = process.env.OPENAI_API_KEY;
if (!key) throw new Error('OPENAI_API_KEY not configured');
```

Generate a strong secret: `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`

## Input validation

```ts
import { z } from 'zod';
const CreateUser = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150).optional(),
});
const Password = z.string().min(12)
  .regex(/[A-Z]/).regex(/[a-z]/).regex(/[0-9]/).regex(/[^A-Za-z0-9]/);
```

File upload:

```ts
const MAX = 5 * 1024 * 1024;
const TYPES = ['image/jpeg', 'image/png', 'image/gif'];
if (file.size > MAX) throw new Error('File too large (max 5MB)');
if (!TYPES.includes(file.type)) throw new Error('Invalid file type');
```

- Store uploads outside the web root or in object storage. Use random filenames. Check content (magic bytes) where possible.

HTML sanitize (allowlist):

```ts
import DOMPurify from 'isomorphic-dompurify';
const clean = DOMPurify.sanitize(html, { ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'], ALLOWED_ATTR: [] });
```

## SQL and row-level security

```ts
await db.query('SELECT id, email, name FROM users WHERE email = $1', [email]); // select only needed columns
await supabase.from('users').select('id,email').eq('email', email);
```

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own_select" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "own_update" ON users FOR UPDATE USING (auth.uid() = id);
```

## JWT

```js
const token = jwt.sign({ userId: u.id, role: u.role }, process.env.JWT_SECRET,
  { expiresIn: '1h', issuer: 'app', audience: 'app-users' });
jwt.verify(token, process.env.JWT_SECRET, { issuer: 'app', audience: 'app-users' }, (err, user) => {
  if (err) return res.status(403).json({ error: 'Invalid token' });
  req.user = user; next();
});
```

- Secret ≥ 256 bits, from env, fail if missing. Access token ~1 h; refresh token server-side with revocation on logout. No sensitive data in payload.

## Object-level authorization

```js
// Bad: any authenticated user deletes any post
app.delete('/api/posts/:id', auth, async (req, res) => {
  await prisma.post.delete({ where: { id: req.params.id } });
});
// Good
app.delete('/api/posts/:id', auth, async (req, res) => {
  const post = await prisma.post.findUnique({ where: { id: req.params.id } });
  if (!post) return res.status(404).json({ error: 'Post not found' });
  if (post.userId !== req.user.userId && req.user.role !== 'admin')
    return res.status(403).json({ error: 'Not authorized' });
  await prisma.post.delete({ where: { id: req.params.id } });
  res.json({ success: true });
});
```

## Rate limiting

```js
app.use('/api/', rateLimit({ windowMs: 15 * 60_000, max: 100, standardHeaders: true, legacyHeaders: false }));
app.use('/api/auth/login', rateLimit({ windowMs: 15 * 60_000, max: 5, skipSuccessfulRequests: true }));
```

- Limit per IP and per user. Stricter for login, registration, search, expensive ops. Tier by plan if needed. Shared store (Redis) for distributed limits. Return `429` + retry headers.

## Headers, CSP, CSRF

```js
app.use(helmet({
  contentSecurityPolicy: { directives: { defaultSrc: ["'self'"], scriptSrc: ["'self'"], imgSrc: ["'self'", 'data:', 'https:'] } },
  frameguard: { action: 'deny' }, noSniff: true,
}));
```

Next.js CSP (`next.config.js`):

```ts
const csp = `default-src 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'none';
  script-src 'self'; style-src 'self'; img-src 'self' data: https:; font-src 'self';
  connect-src 'self' https://api.example.com;`.replace(/\s{2,}/g, ' ').trim();
const securityHeaders = [{ key: 'Content-Security-Policy', value: csp }];
```

```ts
if (!csrf.verify(req.headers.get('X-CSRF-Token')))
  return NextResponse.json({ error: 'Invalid CSRF token' }, { status: 403 });
```

## Errors and logging

```js
catch (e) {
  console.error('User creation error:', e);            // full detail server-side
  if (e.code === 'P2002') return res.status(400).json({ error: 'Email already exists' });
  return res.status(500).json({ error: 'An error occurred while creating user' });
}
console.log('User login:', { email, userId });          // never log password/token/card
```

## Dependencies

```bash
npm audit && npm audit fix && npm outdated && npm ci   # commit lock files; npm ci in CI; enable Dependabot
```

## Blockchain (Solana)

```ts
const ok = verify(Buffer.from(msg), Buffer.from(sig, 'base64'), Buffer.from(pubKey, 'base64'));
async function verifyTx(tx, recipient, maxAmount) {
  if (tx.to !== recipient) throw new Error('Invalid recipient');
  if (tx.amount > maxAmount) throw new Error('Amount exceeds limit');
  if ((await getBalance(tx.from)) < tx.amount) throw new Error('Insufficient balance');
  return true;
}
```

## Security tests

```ts
test('requires authentication', async () => {
  expect((await fetch('/api/protected')).status).toBe(401);
});
```

- Expect `401` unauthenticated, `403` unauthorized, `400` invalid input, `429` over limit.
