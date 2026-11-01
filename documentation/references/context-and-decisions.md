# Domain Context and Decision Handoff

Keep stable domain language (what business terms mean) in one narrowly scoped glossary, separate from decisions (why an option was chosen), which go to ADRs. Do not create an empty shell when there is no stable content.

## When to use

- Domain terms need repeated explanation, or unclear language causes implementation drift or module-boundary mistakes.
- One term has more than one meaning.
- The project needs a stable domain-language entry point and has no equivalent document.
- Context work finds a durable decision that belongs in an ADR.

Using established vocabulary during an ordinary bug fix does not need a modeling session or new documentation.

## Domain context artifact: domain language only

1. Reuse the existing glossary or domain-model document of the repository, or the context role in the project map (see [documentation](../SKILL.md)). If a context map names separate business contexts, follow its links to the correct glossary. Ask when the owner of a topic is unclear.
2. Different contexts can use the same word differently. Do not make a glossary for each directory, and do not force one meaning across unrelated contexts.
3. Only when no equivalent exists and a term is resolved, propose a new `CONTEXT.md` from the template below. Get explicit user approval to create that new artifact before you write it. General permission to update documentation does not approve a new artifact. An authorized edit to an existing mapped glossary does not need new-artifact approval.

Record only:
- Domain terms and precise definitions
- Relationships among core concepts
- Confirmed ambiguities and the chosen interpretation
- Ambiguities still waiting for a domain owner

Do not include implementation details, current state, schedules, full requirements, decision rationale, or history. Those belong in code and the map, the status page or issue tracker, the spec, the ADR, and the history log. Each term must trace to code, contracts, or business evidence. Mark unconfirmed items `needs confirmation`; do not guess.

## Refine language during the conversation

This is an active modeling workflow, not a duty to rewrite the glossary each time something reads it.

- **Challenge contradictions.** If "cancellation" already means cancelling a whole order but the request allows cancelling one line, explain the difference and ask which meaning is intended. Do not silently redefine the term.
- **Separate overloaded concepts.** For "account", find out if the speaker means the customer organization, a person's login, or a billing relationship. Propose a precise term for each concept. Record rejected synonyms only where they really mean the same concept in this context.
- **Probe relationships with concrete scenarios.** Ask, for example, if one customer can have more than one login, or what happens to an invoice when only part of an order is cancelled. Scenarios are questions, not invented business rules.
- **Check claims against evidence.** Inspect code, tests, contracts, and records. If the implementation cancels only whole orders, show the mismatch with the proposed partial-cancellation rule. Code shows current behavior, not the business owner's intent; do not decide which is correct yourself.
- **Capture confirmed terms as they settle.** Within an authorized documentation edit, update the existing glossary at that point. Keep each definition to one or two sentences, with a source and context-specific avoided synonyms. Do not change code, contracts, or accepted decisions only to match a proposed term. In discussion-only or read-only work, show the proposed wording and do not write files.

Include business-specific concepts only, not generic programming words such as timeouts or utility functions.

## Template: `CONTEXT.md`

Omit sections that have no real content.

```markdown
# CONTEXT.md — Domain Language

{One or two sentences identifying the business context this vocabulary describes.}

## Core Terms

| Term | Precise definition | Avoid in this context | Evidence/source |
|---|---|---|---|
| `{canonical term}` | `{one or two sentences that define the concept and separate it from adjacent concepts}` | `{confirmed synonyms to avoid; not names for distinct concepts}` | `{business source, contract, or code location}` |

## Concept Relationships

- `{Concept A}` and `{Concept B}`: `{one-to-many / state transition / containment / constraint}`.

## Resolved Ambiguities

- `{old expression}` now means `{adopted interpretation}`; stop using `{deprecated expression}`.

## Needs Confirmation

- `{term or relationship}`: waiting for `{owner/domain role}`; do not change the implementation until confirmed.
```

## ADR handoff

Do not define a second ADR directory, numbering scheme, lifecycle, or template. When a decision is hard to reverse, would confuse a future reader without context, and involves a real tradeoff:

1. Use [software-architecture/references/architecture-decision-records.md](../../software-architecture/references/architecture-decision-records.md). Keep the existing ADR location, format, and approval gates of the repository.
2. If no convention exists, let that workflow choose the minimum location.
3. Link to the ADR from `CONTEXT.md`, the project map, or the relevant spec or issue. Do not copy the decision body.
4. When a decision is accepted, superseded, or deprecated, add an event to project history under the living-docs rules.

Routine implementation details, easily reversible changes, and short experiments do not need ADRs.

## Scheduling and task boundary

Keep tasks, status, blockers, and schedules in the existing tracker (for example GitHub Issues or Linear). Use a local `.scratch/` only when no tracker exists and the project adopts it. Never put schedules in `CONTEXT.md`, ADRs, or status and history documents.

## Anti-patterns

- Copying tasks, schedules, full requirements, or implementation details into `CONTEXT.md`.
- Creating empty context files or a second ADR system for completeness.
- Treating unconfirmed interpretations as facts, or copying ADR bodies into maps and logs.
- Treating distinct business concepts as synonyms, or forcing separate contexts into one universal glossary.
- Treating a glossary update as permission to change implementation, or treating code as proof of the intended business rule.

## Attribution

The terminology-refinement workflow adapts [Matt Pocock's domain-modeling skill](https://github.com/mattpocock/skills/tree/c55ee46073ed923f86ce59a5eb3b6d895095d1b7/skills/engineering/domain-modeling) (MIT license).
