---
name: kaizen
description: "Kaizen guides incremental code quality improvement, error-proofing by design, standardized patterns, and building only needed features. Use when refactoring, code review, writing TypeScript, adding tests, fixing bugs, enforcing types, validating inputs, reducing complexity, linting, guard clauses, boundary validation, pull requests, or defining team coding standards."
---

# Kaizen: Continuous Improvement

**Purpose** – Apply small, verifiable changes to make code safer, clearer, and more maintainable. Prevent errors early, reuse proven patterns, and avoid unnecessary complexity.

## When to Use
- Adding a new feature or fixing a bug.
- Refactoring existing code.
- Designing an API, library, or configuration.
- Defining or updating team processes.
- Conducting code reviews.

---
## Pillar 1 – Incremental Improvement
### Rules
- Make the smallest change that adds value.
- Verify the change before adding the next one.
- Keep the code in a working state after each commit.
- Stop when the improvement yields diminishing returns.

### Workflow
1. Write the simplest version that works.
2. Run tests and confirm the change does not break anything.
3. Add a single improvement (e.g., validation, naming, performance).
4. Repeat steps 2‑3 until the task is complete or "good enough".

### Pattern Example (TypeScript)
```typescript
// 1️⃣ Make it work
export const calculateTotal = (items: {price: number; quantity: number}[]) => {
  let total = 0;
  for (const i of items) total += i.price * i.quantity;
  return total;
};

// 2️⃣ Make it clear
export const calculateTotal = (items: {price: number; quantity: number}[]) =>
  items.reduce((t, i) => t + i.price * i.quantity, 0);

// 3️⃣ Make it robust
export const calculateTotal = (items: {price: number; quantity: number}[]) => {
  if (!items?.length) return 0;
  return items.reduce((t, i) => {
    if (i.price < 0 || i.quantity < 0) throw new Error('Negative values');
    return t + i.price * i.quantity;
  }, 0);
};
```

### Pitfalls
- Trying to add many improvements at once.
- Refactoring without running tests.
- Declaring "good enough" too early and never revisiting the code.

---
## Pillar 2 – Error Proofing (Poka‑Yoke)
### Rules
- Use the type system to make invalid states unrepresentable.
- Validate inputs at the system boundary.
- Guard against null or unexpected values early.
- Fail fast with clear error messages.

### Type‑Safety Example
```typescript
// Constrain status values
type OrderStatus = 'pending' | 'processing' | 'shipped' | 'delivered';
interface Order {
  status: OrderStatus;
  total: number;
}
```

### Validation at Boundary Example
```typescript
type PositiveNumber = number & { readonly __brand: 'Positive' };

const toPositive = (n: number): PositiveNumber => {
  if (n <= 0) throw new Error('Must be positive');
  return n as PositiveNumber;
};

const processPayment = (amount: PositiveNumber) => {
  const fee = amount * 0.03; // safe, amount is positive
  // …
};

// In request handler
const amount = toPositive(req.body.amount);
processPayment(amount);
```

### Guard Example
```typescript
const handleUser = (user: User | null) => {
  if (!user) throw new Error('User missing');
  if (!user.email) throw new Error('Email missing');
  // Main logic – user and email are guaranteed
};
```

### Pitfalls
- Performing validation after the value is already used.
- Allowing optional configuration without required checks.
- Swallowing errors instead of failing fast.

---
## Pillar 3 – Standardized Work
### Rules
- Follow existing code‑base patterns.
- Document "why" decisions next to the code.
- Keep linters, type checks, and CI gates enabled.
- Introduce new patterns only after a clear benefit.

### Consistency Example
```typescript
// Existing pattern for API clients
class UserAPIClient {
  async getUser(id: string): Promise<User> {
    return this.fetch(`/users/${id}`);
  }
}

// New client follows the same pattern
class OrderAPIClient {
  async getOrder(id: string): Promise<Order> {
    return this.fetch(`/orders/${id}`);
  }
}
```

### Result‑Type Error Handling Example
```typescript
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

const fetchUser = async (id: string): Promise<Result<User, Error>> => {
  try {
    const user = await db.users.findById(id);
    return user ? { ok: true, value: user } : { ok: false, error: new Error('Not found') };
  } catch (e) {
    return { ok: false, error: e as Error };
  }
};

const r = await fetchUser('123');
if (!r.ok) {
  console.error(r.error);
  return;
}
const user = r.value; // safe to use
```

### Documentation Standard Example
```typescript
/**
 * Retries an async operation with exponential back‑off.
 *
 * Why: Network calls can fail temporarily.
 * When: External API calls, DB queries.
 * When not: Pure computation, user input validation.
 */
async function retry<T>(op: () => Promise<T>, attempts = 3, delay = 1000): Promise<T> {
  // implementation omitted for brevity
}
```

### Pitfalls
- Introducing a new style without team consensus.
- Ignoring existing utilities and re‑implementing them.
- Missing documentation of intent.

---
## Pillar 4 – Just‑In‑Time Development (JIT)
### Rules
- Implement only the current requirement (YAGNI).
- Choose the simplest solution that works.
- Profile before optimizing.
- Abstract only after the pattern appears in three or more places.

### Minimal Implementation Example
```typescript
// Requirement: log errors to console
export const logError = (e: Error) => console.error(e.message);
```

### Evolving When Needed Example
```typescript
// Step 1 – simple formatter
export const formatCurrency = (amt: number) => `$${amt.toFixed(2)}`;

// Step 2 – add currency code
export const formatCurrency = (amt: number, cur: string) => {
  const symbols: Record<string, string> = { USD: '$', EUR: '€', GBP: '£' };
  return `${symbols[cur] ?? cur}${amt.toFixed(2)}`;
};

// Step 3 – full localization (added after demand)
export const formatCurrency = (amt: number, locale: string) =>
  new Intl.NumberFormat(locale, { style: 'currency', currency: locale }).format(amt);
```

### Premature Abstraction Pitfall
```typescript
// Bad: generic CRUD base for a single table
abstract class BaseService<T> { /* many methods */ }
```
*Fix*: Write concrete functions first; extract a shared helper only after three services need it.

### Performance Optimization Workflow
1. Measure the current implementation.
2. Identify a bottleneck that exceeds a defined threshold.
3. Write a targeted optimization.
4. Re‑measure to confirm improvement.
5. Keep the simple version in version control for comparison.

### Pitfalls
- Adding layers for "future" use cases.
- Optimizing without data.
- Over‑abstracting after a single use.

---
## Checklist
- [ ] Write the simplest version that passes the test suite.
- [ ] Run the test suite after each change.
- [ ] Add one improvement (validation, naming, performance) per commit.
- [ ] Use type definitions to make illegal states impossible.
- [ ] Validate all external input at the entry point.
- [ ] Guard against null/undefined early in functions.
- [ ] Follow existing file layout, naming, and error‑handling patterns.
- [ ] Document the reason for each non‑obvious change.
- [ ] Profile before any performance tweak.
- [ ] Abstract only after the same logic appears in ≥ 3 places.
- [ ] Review the change with a teammate for consistency.

---
## Red Flags to Avoid
- Declaring "I'll refactor later" and never returning.
- Writing code that is more complex than the current requirement.
- Skipping validation or allowing optional configuration without checks.
- Introducing a new pattern without team discussion.
- Optimizing code that has not been measured as a bottleneck.

---
## Summary
Kaizen means **small, verified improvements**, **error‑proof design**, **consistent standards**, and **building only what is needed now**. Apply the four pillars continuously to keep code clean, safe, and maintainable.

## Related skills

Load these when the task spans more than this skill.

- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
- [`learning-to-action`](../learning-to-action/SKILL.md) — Creates a concrete Ship‑Learn‑Next action plan from any learning material (transcript, article, tutorial). Use…
