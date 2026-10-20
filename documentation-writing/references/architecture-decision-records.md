# Architecture Decision Records (ADRs)

Capture the why, what, and impact of major architectural choices. Use ADRs to preserve knowledge, guide future work, and onboard team members.

## When to use
- Introducing a new framework, database, or infrastructure component
- Defining API contracts, security models, or integration patterns
- Making trade‑off decisions that affect multiple services
- Deprecating or superseding an existing technology

## When **not** to use
- Documenting routine bug fixes or minor patches
- Recording implementation details that do not affect architecture
- Capturing one‑off scripts or configuration tweaks

---

## ADR Workflow
1. **Identify need** – Recognise a decision that influences system design or cross‑team work.
2. **Create ADR file** – Use a standard template (see below) and store the file under `docs/adr/`.
3. **Populate sections** – Fill Context, Decision Drivers, Considered Options, Decision, Rationale, Consequences, and any Implementation Notes.
4. **Peer review** – Follow the ADR Review Checklist (section *Review Process*). At least two senior engineers and affected team representatives must approve.
5. **Merge** – Add the ADR via pull request. Update the ADR index (`docs/adr/README.md`).
6. **Track status** – Mark the ADR as *Proposed*, *Accepted*, *Rejected*, *Deprecated*, or *Superseded*.
7. **Maintain** – When circumstances change, create a new ADR that supersedes the old one; never edit an accepted ADR.

---

## Core ADR Structure
```markdown
# ADR-<NNNN>: <Title>

## Status
<Proposed | Accepted | Rejected | Deprecated | Superseded>

## Context
Why the decision is required. Include business goals, constraints, and drivers.

## Decision Drivers
- List mandatory (must‑have) and desirable (should‑have) criteria.

## Considered Options
### Option 1: <Name>
- **Pros**: …
- **Cons**: …

### Option 2: <Name>
- **Pros**: …
- **Cons**: …

## Decision
State the chosen option clearly.

## Rationale
Explain how the decision satisfies the drivers and why alternatives were rejected.

## Consequences
### Positive
- …
### Negative
- …
### Risks & Mitigations
- …

## Implementation Notes (optional)
- Technical steps required to realize the decision.

## Related Decisions
- ADR‑<NNNN>: <Title>

## References
- Links to external docs, benchmarks, or standards.
```

### Lightweight ADR (for quick decisions)
```markdown
# ADR-<NNNN>: <Title>

**Status**: Accepted
**Date**: YYYY‑MM‑DD
**Deciders**: @alice, @bob

## Context
Brief problem description.

## Decision
One‑sentence decision.

## Consequences
- **Good**: …
- **Bad**: …
- **Mitigations**: …
```

### Y‑Statement ADR (single‑sentence format)
```markdown
# ADR-<NNNN>: <Title>

In the context of **<situation>**, facing **<need>**, we decided for **<choice>** and against **<alternatives>**, to achieve **<goal>**, accepting that **<trade‑off>**.
```

---

## Directory Layout
```
docs/
└── adr/
    ├── README.md          # Index and guidelines
    ├── template.md        # Preferred ADR template (copy for new ADRs)
    ├── 0001-use-postgresql.md
    ├── 0002-caching-strategy.md
    ├── 0003-mongodb-user-profiles.md   # [DEPRECATED]
    └── 0020-deprecate-mongodb.md       # Supersedes 0003
```

### ADR Index (`docs/adr/README.md`)
```markdown
# Architecture Decision Records

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| 0001 | Use PostgreSQL as Primary Database | Accepted | 2024‑01‑10 |
| 0002 | Caching Strategy with Redis | Accepted | 2024‑01‑12 |
| 0003 | MongoDB for User Profiles | Deprecated | 2023‑06‑15 |
| 0020 | Deprecate MongoDB | Accepted | 2024‑01‑15 |
```

---

## Automation (adr‑tools)
```bash
# Install adr‑tools (macOS example)
brew install adr-tools

# Initialise ADR directory (run once)
adr init docs/adr

# Create a new ADR (opens editor with template)
adr new "Use PostgreSQL as Primary Database"

# Create a superseding ADR (references ADR 3)
adr new -s 3 "Deprecate MongoDB in Favor of PostgreSQL"

# Regenerate the index table of contents
adr generate toc > docs/adr/README.md

# Link related ADRs (optional)
adr link 2 "Complements" 1 "Is complemented by"
```

---

## Review Process
### ADR Review Checklist
#### Before Submission
- [ ] Context explains the problem and constraints.
- [ ] All viable options are listed.
- [ ] Pros and cons are balanced and honest.
- [ ] Positive and negative consequences are documented.
- [ ] Related ADRs are linked.

#### During Review
- [ ] At least two senior engineers have approved.
- [ ] Affected product or platform teams consulted.
- [ ] Security implications evaluated.
- [ ] Cost impact recorded.
- [ ] Reversibility or migration path assessed.

#### After Acceptance
- [ ] ADR index (`README.md`) updated.
- [ ] Team communication (Slack, email, or meeting) sent.
- [ ] Implementation tickets created in the project tracker.
- [ ] Any downstream documentation (API specs, runbooks) updated.

---

## Best Practices
- **Write early** – Draft the ADR before any code is written.
- **Stay concise** – Aim for 1–2 pages; use tables for pros/cons.
- **Be specific** – Name concrete technologies, versions, and configurations.
- **Link decisions** – Build a graph of related ADRs for traceability.
- **Never edit an accepted ADR** – Create a new ADR that supersedes it.
- **Include failures** – Record rejected options; they provide valuable context.
- **Update status** – Mark as *Deprecated* or *Superseded* when the decision changes.

---

## Resources
- Michael Nygard, *Documenting Architecture Decisions* – https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- MADR template – https://adr.github.io/madr/
- ADR GitHub organization – https://adr.github.io/
- adr‑tools – https://github.com/npryce/adr-tools
