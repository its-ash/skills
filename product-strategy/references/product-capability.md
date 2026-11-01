# Product Capability

Turn product intent (PRD, roadmap item, discussion, founder note) into an implementation-ready capability plan that shows constraints, invariants, interfaces, and open decisions before multi-service work starts.

Use it when the question is not "what must we build?" but "what exactly must be true before implementation starts?"

## When to use

- A PRD, roadmap item, discussion, or founder note exists, but the implementation constraints are still implicit.
- A feature crosses several services, repos, or teams and needs a capability contract before coding.
- The product intent is clear, but architecture, data, lifecycle, or policy effects are not.
- Senior engineers keep restating the same hidden assumptions during review.
- You need a reusable artifact that survives across tools and sessions.
- The product diagnostic in [product-strategy](../SKILL.md) returned "build this".

## Canonical artifact

If the repo has a durable product-context file such as `PRODUCT.md`, `docs/product/`, or a program-spec directory, update it there. If no capability manifest exists, ask the user where to create one (default: `docs/product/<capability>.md`) and use the output format below.

The goal is not another planning stack. The goal is to make hidden capability constraints durable and reusable.

## Rules

- Do not invent product truth. Mark open questions explicitly.
- Keep user-visible promises separate from implementation details.
- Label each item as fixed policy, architecture preference, or still open.
- If the request conflicts with existing repo constraints, say so clearly. Do not smooth it over.
- Prefer one reusable capability artifact to scattered notes.

## Inputs

Read only what is necessary:

1. Product intent: issue, discussion, PRD, roadmap note, founder message.
2. Current architecture: repo docs, contracts, schemas, routes, existing workflows.
3. Existing capability context: `PRODUCT.md`, design docs, RFCs, migration notes, operating-model docs.
4. Delivery constraints: auth, billing, compliance, rollout, backward compatibility, performance, review policy.

## Workflow

### 1. Restate the capability

Compress the ask into one precise statement:
- Who the user or operator is
- What new capability exists after this ships
- What outcome changes because of it

If this statement is weak, the implementation will drift.

### 2. Resolve capability constraints

Extract what must be true before implementation:
- Business rules
- Scope boundaries
- Invariants
- Trust boundaries
- Data ownership
- Lifecycle transitions
- Rollout and migration requirements
- Failure and recovery expectations

These often live only in the memory of senior engineers.

### 3. Define the implementation-facing contract

Produce an SRS-style plan with:
- Capability summary
- Explicit non-goals
- Actors and surfaces
- Required states and transitions
- Interfaces, inputs, and outputs
- Data model effects
- Security, billing, and policy constraints
- Observability and operator requirements
- Open questions that block implementation

### 4. Translate into execution

End with the exact handoff:
- Ready for direct implementation
- Needs architecture review first (see [software-architecture](../../software-architecture/SKILL.md))
- Needs product clarification first

For acceptance criteria per behavior, continue with [software-architecture/references/intent-driven-development.md](../../software-architecture/references/intent-driven-development.md). For cross-service interfaces, use [backend-development/references/contract-first.md](../../backend-development/references/contract-first.md). For test-first delivery, use [unit-testing-patterns](../../unit-testing-patterns/SKILL.md).

## Output format

```text
CAPABILITY
- one-paragraph restatement

CONSTRAINTS
- fixed rules, invariants, and boundaries

IMPLEMENTATION CONTRACT
- actors
- surfaces
- states and transitions
- interface/data implications

NON-GOALS
- what this plan explicitly does not own

OPEN QUESTIONS
- blockers or product decisions still required

HANDOFF
- what happens next and which workflow takes it
```

## Good outcomes

- The product intent is concrete enough to implement without finding hidden constraints mid-PR.
- Engineering review has a durable artifact instead of memory or chat context.
- The plan is reusable across coding agents and planning tools.
