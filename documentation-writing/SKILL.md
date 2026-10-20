---
name: documentation-writing
description: "Provides ready-to-use templates and a co-authoring workflow for READMEs, API documentation, changelogs, architecture decision records, and AI-friendly docs, including REST, GraphQL, or WebSocket endpoint specs, parameters, authentication, errors, data models, validation, business rules, examples, code comments, and frontend handoff files. Use when writing or updating README, API docs, changelog, ADR, release notes, JSDoc, TSDoc, endpoint documentation, developer docs, technical documentation, or reviewing documentation from git commits."
---

# Documentation Writing

Create clear, maintainable documentation for any software project. Use this skill when you need to write a new README, API reference, changelog, ADR, or any structured spec, or when you want a guided co‑authoring process that iterates through context gathering, drafting, and reader testing.

---

## When to Use
- **Creating** a brand‑new document (README, spec, decision record).
- **Adding** a new section to an existing doc.
- **Updating** outdated information after a release.
- **Reviewing** a document for accuracy and completeness.
- **Co‑authoring** a technical spec, proposal, or design doc with a team.

---

## Workflow Overview
1. **Identify the documentation task** (create, add, update, review).  
2. **Select the appropriate template** (README, API, ADR, etc.).  
3. **Gather context** – answer a short questionnaire and provide any relevant files or links.  
4. **Draft sections** – work through each section with clarifying questions, brainstorming, and curation.  
5. **Iterate** – make focused edits until three consecutive passes produce no substantial changes.  
6. **Reader testing** – simulate a fresh reader (or a sub‑agent) asking realistic questions; fix any gaps.  
7. **Final review** – verify licensing, last‑reviewed date, and overall flow.

---

## 1. Identify the Documentation Task
| Task | When |
|------|------|
| **Creating** | New project has no documentation. |
| **Adding** | Need to document a new feature, endpoint, or decision. |
| **Updating** | Existing docs are stale after a release or refactor. |
| **Reviewing** | Periodic audit or before a major version bump. |

Ask yourself: *Who will read this and what do they need?* Use the answers to pick the right template and level of detail.

---

## 2. Choose a Template
Below are ready‑to‑copy markdown snippets. Replace placeholder text with your project‑specific values.

### README Template
```markdown
# Project Name

One‑line description of the project.

## Quick Start

1. Install dependencies
2. Run `npm start`
3. Open http://localhost:3000

## Features

- Feature 1
- Feature 2

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port | 3000 |

## Documentation

- [API Reference](./docs/api.md)
- [Architecture](./docs/architecture.md)

## License

MIT
```

### API Endpoint Template
```markdown
## GET /users/:id

Retrieve a user by their unique identifier.

**Parameters**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id   | string | Yes | User ID |

**Responses**
- `200` – User object
- `404` – User not found

**Example**
```http
GET /users/12345 HTTP/1.1
Host: api.example.com
```
```json
{ "id": "12345", "name": "Alice" }
```
```

### Code Comment (JSDoc/TSDoc) Template
```typescript
/**
 * Brief description of the function.
 *
 * @param input - Description of the input parameter.
 * @returns Description of the return value.
 * @throws Error - When an error condition occurs.
 *
 * @example
 * const result = myFunction('value');
 */
function myFunction(input: string): string {
  // implementation
}
```

### Changelog Template (Keep a Changelog)
```markdown
# Changelog

## [Unreleased]
### Added
- New feature description

## [1.0.0] - 2025-01-01
### Added
- Initial release
### Changed
- Updated dependency X to version 2.0
### Fixed
- Fixed crash on startup
```

### Architecture Decision Record (ADR) Template
```markdown
# ADR-001: Title of Decision

## Status
Accepted / Deprecated / Superseded

## Context
Why the decision is needed. Include constraints, stakeholder concerns, and relevant history.

## Decision
What was decided and the chosen approach.

## Consequences
Positive and negative impacts, trade‑offs, and follow‑up actions.
```

### AI‑Friendly Documentation Snippet
```markdown
# Project Name
> One‑line objective.

## Core Files
- `src/index.ts` – Main entry point
- `src/api/` – API route handlers
- `docs/` – All documentation files

## Key Concepts
- **Concept 1** – Brief explanation
- **Concept 2** – Brief explanation
```

---

## 3. Co‑authoring Workflow
### Stage 1 – Context Gathering
1. Answer the following questions:
   - Document type (spec, decision, proposal, etc.)
   - Primary audience
   - Desired impact when read
   - Required template or format
   - Any constraints (length, compliance, etc.)
2. Provide an **info dump** of all relevant material:
   - Project background, architecture diagrams, prior discussions, stakeholder concerns, timelines.
   - Links to shared files or paste excerpts directly.
3. The assistant will ask 5‑10 clarifying questions to fill gaps.

### Stage 2 – Refinement & Structure
1. **Agree on section order** – suggest a default based on document type, e.g.,
   - Summary → Problem → Proposed Solution → Alternatives → Implementation → Risks → Open Questions.
2. For each section:
   - Ask targeted clarifying questions.
   - Brainstorm 5‑20 possible bullet points or paragraphs.
   - Let the user keep, remove, or combine items.
   - Check for missing critical points.
   - Draft the section and present it for feedback.
   - Apply focused edits (use `str_replace`‑style replacements, not full rewrites).
3. Continue until three consecutive passes produce no substantive changes.

### Stage 3 – Reader Testing
1. Predict 5‑10 realistic reader questions (e.g., “How do I install this?”, “What does this error mean?”).
2. Run each question against a **fresh Claude instance** with only the document content.
3. Record where the model fails: ambiguous wording, missing context, contradictions.
4. Fix the identified gaps and repeat testing until the model answers correctly.

---

## 4. Documentation Guidelines
- **Scannable layout**: Use clear H1‑H3 hierarchy, bullet lists, and tables.
- **Progressive detail**: Start with a high‑level overview, then dive deeper.
- **Examples first**: Show a usage example before explaining parameters.
- **Keep up to date**: Mark the last‑reviewed date; update when code changes.
- **Comment wisely**:
  - ✅ Explain *why* a piece of code exists or its business rule.
  - ❌ Comment obvious *what* (e.g., `i++`).
  - ✅ Document public APIs, complex algorithms, and edge‑case handling.
- **Alt‑text for images**: Provide descriptive alt text; otherwise AI readers cannot interpret visuals.
- **Mermaid diagrams**: Include for flow or architecture diagrams; keep them self‑contained.

---

## 5. Common Pitfalls
- Duplicating information across README, API docs, and ADRs – keep each source focused.
- Over‑commenting every line – leads to noise.
- Leaving placeholder sections (`[TODO]`) in released docs.
- Forgetting to update configuration tables after default changes.
- Missing licensing or contribution guidelines for open‑source projects.

---

## 6. Checklist
- [ ] Identify the documentation task (create, add, update, review).
- [ ] Select the correct template.
- [ ] Gather all context and answer the initial questionnaire.
- [ ] Draft each section following the refinement steps.
- [ ] Perform at least three iteration cycles with no major edits.
- [ ] Run reader‑testing questions and resolve all failures.
- [ ] Verify licensing, contribution guide, and last‑reviewed date are present.
- [ ] Publish the document in the appropriate location (repo root, `docs/` folder, etc.).

---

**Remember**: Documentation is a living artifact. Re‑run this workflow whenever major code changes occur or when feedback indicates gaps.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/api-documentation.md](references/api-documentation.md) | Generate full API documentation and a concise handoff file for frontend integration. Use for new or updated REST, GraphQL, or WebSocket APIs to describe endpoints, parameters, authentication, errors, data models, validation, business rules, and usage examples. |
| [references/architecture-decision-records.md](references/architecture-decision-records.md) | Provides a complete workflow, templates, and best‑practice checklist for creating, maintaining, and managing Architecture Decision Records (ADRs) to capture context, rationale, and consequences of significant technical decisions. |
| [references/changelog-generator.md](references/changelog-generator.md) | Generate a customer‑friendly changelog from git commits. Use it when you need release notes, update summaries, or public changelog entries for a specific version, date range, or time period. |

## Related skills

Load these when the task spans more than this skill.

- [`clear-writing`](../clear-writing/SKILL.md) — The clear‑writing skill helps you edit any human‑focused prose—documentation, commit messages, UI copy, report…
- [`content-writing`](../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`git-commit`](../git-commit/SKILL.md) — Generate conventional commit messages by analyzing staged changes, suggesting type, scope, and wording, and gu…
- [`agent-instructions-refactor`](../agent-instructions-refactor/SKILL.md) — Refactor a bloated AGENTS.md, CLAUDE.md, or similar file into a minimal root file and a set of linked topic fi…
- [`mermaid-diagrams`](../mermaid-diagrams/SKILL.md) — Generates Mermaid diagram code for flowcharts, sequence diagrams, class diagrams, ERDs, C4 architecture, state…
