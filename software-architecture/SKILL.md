---
name: software-architecture
description: "Software architecture decisions: choose Clean Architecture, Hexagonal, DDD, CQRS, or event sourcing, document trade-offs, validate designs. Use when designing a system, splitting a monolith, writing an ADR, defining bounded contexts, choosing microservices or a modular monolith, writing acceptance criteria for risky changes, ports and adapters refactors, module ownership docs, or cross-module regression ledgers. Sub-skills: architecture-decision-records, hexagonal-architecture, intent-driven-development, module-governance, module-regression."
---

# Software Architecture

Pick the simplest architecture that meets the constraints, and record why.

## Core rules

- Capture functional goals, non-functional constraints, and business priorities before you choose a pattern.
- List real constraints: regulation, existing infrastructure, team skills, budget, timeline.
- Compare at least two alternatives in a trade-off table (pros, cons, risk, effort).
- Choose the simplest pattern that meets the constraints. Do not apply full DDD or microservices to simple CRUD.
- Write an ADR for each significant decision ([architecture-decision-records.md](references/architecture-decision-records.md)).
- Point dependencies inward. Keep business logic out of UI and controllers; put infrastructure behind domain-owned interfaces.
- Name modules by domain (`OrderCalculator`), never `utils`/`helpers`/`common`.
- Search for a maintained library or service before you write custom infrastructure code.
- For risky changes (security, data, migration, integration), write acceptance criteria first ([intent-driven-development.md](references/intent-driven-development.md)).
- Run the validation checklist before you finalize ([patterns-and-ddd.md](references/patterns-and-ddd.md#validation-checklist)).

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Complex business rules, testability needed | Clean Architecture | Logic in controllers |
| Core must not depend on DB/UI choice; many adapters | Hexagonal (ports and adapters) | Framework types in the domain |
| Rich, changing domain; many teams; ubiquitous language needed | DDD (pass viability check below) | DDD for CRUD |
| Large read/write imbalance; scale reads and writes apart | CQRS | One model for both under heavy load |
| Audit, replay, complex state transitions | Event Sourcing + aggregates | Mutable rows when history is required |
| Long-running multi-service transaction | Saga with compensation actions | Distributed 2PC |
| Independent deploys, team autonomy, varied scaling | Microservices, each owning its data and API | Shared database across services |
| Small team, unclear boundaries | Modular monolith; split later by slice | Early microservices |

**DDD viability**: adopt full DDD only if >= 2 are true:
- Business rules are complex, change often, or need explicit invariants.
- Several teams work on overlapping domains and models collide.
- Integration contracts are unstable or need versioning.
- Audit, traceability, or regulatory compliance is critical.

## Load on demand

| Need | Read |
|---|---|
| Decision steps, trade-off table, pattern traits, DDD strategic/tactical patterns, structure rules, anti-patterns, validation checklist, Mermaid diagram | [patterns-and-ddd.md](references/patterns-and-ddd.md) |
| Numbered ADRs in `docs/adr/`, ADR status, index, "why did we choose X?" | [architecture-decision-records.md](references/architecture-decision-records.md) |
| Ports and adapters in TS, Java, Kotlin, Go; composition root; migration by slice | [hexagonal-architecture.md](references/hexagonal-architecture.md) |
| Ambiguous or high-risk change to scoped acceptance criteria and brief | [intent-driven-development.md](references/intent-driven-development.md) |
| Local module instructions, domain-context links, interface ownership | [module-governance.md](references/module-governance.md) |
| `REGRESSION.md` ledger of consumers; gate changes on their exit codes | [module-regression.md](references/module-regression.md) |

## Related skills

- [`clean-code`](../clean-code/SKILL.md) - naming, function design, deslop
- [`code-review`](../code-review/SKILL.md) - review changes before merge
- [`cloud-architecture`](../devops-iac/references/cloud-architecture.md) - cloud service design on AWS, Azure, GCP
- [`database-design`](../database-design/SKILL.md) - data layer and schema modeling
- [`documentation`](../documentation/SKILL.md) - living docs, glossaries, decision logs
- [`product-strategy`](../product-strategy/SKILL.md) - capability plans before architecture work
- [`backend-development`](../backend-development/SKILL.md) - APIs, services, messaging, resilience
