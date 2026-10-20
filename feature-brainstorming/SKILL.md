---
name: feature-brainstorming
description: "Feature-brainstorming converts a rough feature concept into a complete design specification, requirements checklist, and prioritized task list by running context discovery, structured clarification, optional think-tank debate, and multi-approach exploration. Use when drafting a PRD, defining scope, writing a design doc, specifying acceptance criteria, decomposing epics, comparing technical options, aligning stakeholders, planning sprint work, or preparing implementation for frontend, backend, API, database, or fullstack features."
---

# Feature‑Brainstorming

Turn an initial feature idea into a validated design, concrete requirements, and an actionable implementation plan. Use this skill before any coding starts.

## When to use
- You have a high‑level request (e.g., “add a login page”, “create a dashboard”).
- Requirements are unclear, ambiguous, or span multiple teams.
- The feature will take more than a couple of days or touches several layers of the system.
- You need to compare alternative approaches before committing to a design.
- You want a design document and a ready‑to‑execute task list.

---

## Workflow
The process consists of six phases. Move to the next phase only after the current one is validated.

### Phase 1 – Context Discovery
1. Scan the repository for recent commits, architecture docs, and existing patterns.
2. Summarize the tech stack, coding conventions, and related modules.
3. Record this context for later reference.

### Phase 2 – Structured Clarification
Ask up to four focused questions per round. Use multiple‑choice options when possible. Collect the following groups of information:

**Round 1 – Core Requirements**
- Primary goal (new functionality, enhancement, bug‑fix, refactor).
- Primary users (end‑users, admins, developers, system).
- Expected scope (small, medium, large, unsure).
- Hard deadlines or constraints (urgent, sprint, flexible, planning only).

**Round 2 – Technical Requirements**
- System layers touched (data model, business logic, API, UI).
- Key quality attributes (performance, security, reliability, maintainability).
- Preferred error‑handling strategy (fail fast, graceful degrade, retry, context‑dependent).
- Testing approach (TDD, test‑after, minimal, none).

**Round 3 – Integration & Dependencies**
- External integrations needed (database, third‑party API, message queue, none).
- Dependencies on other features or teams.
- Backwards‑compatibility expectations.
- Documentation needed (API, user guide, dev guide, none).

**Round 4 – Context‑Specific Follow‑ups**
Ask targeted follow‑up questions based on earlier answers, e.g.:
- UI framework if UI layer selected.
- Security measures if high security is required.

After each round, update a **Clarity Score** (0‑100) using the rubric from the Requirements‑Clarity skill. Continue until the score is ≥ 90.

### Phase 3 – Quick Think‑Tank (optional but recommended for decisions)
If the feature involves a strategic choice (e.g., monolith vs micro‑services, custom auth vs SaaS), run a short think‑tank:
1. **Frame the decision** – ask the user for the problem statement, constraints, and success criteria.
2. **Assemble personas** – Moderator, 2‑3 domain experts with opposing views, 1 wildcard thinker, optional practitioner.
3. **Debate** – Opening statements, moderator‑driven rounds, user interjections, wildcard reframing.
4. **Summarize** – Capture consensus points, core trade‑offs, conditional recommendations, risks, and open questions.
5. **Validate with user** – Ensure the summary reflects their context.

The think‑tank output becomes input for the next phase.

### Phase 4 – Approach Exploration
Based on clarified requirements (and think‑tank insights), propose 2‑3 concrete approaches:
- Name each option.
- List pros, cons, and best‑fit scenarios.
- Recommend one option and explain why.
Ask the user to select an approach.

### Phase 5 – Design Presentation
Present the chosen design in 300‑500‑word sections. After each section, ask the user to confirm or request changes.

**Design sections** (include only those that apply):
1. **Architecture Overview** – high‑level components and data flow.
2. **Data Model** – entities, relationships, schema changes.
3. **API Design** – endpoints, request/response contracts.
4. **Component Design** – internal modules, interfaces, UI layout.
5. **Error Handling** – error categories and recovery strategies.
6. **Testing Strategy** – unit, integration, performance, security tests.

### Phase 6 – Documentation & Task Generation
1. **Write Design Document** to `docs/designs/YYYY-MM-DD-<feature>-design.md`.
2. **Create Implementation Tasks** – a checklist with priority, phase, estimated time, and file references. Example:
   ```markdown
   - [ ] **Write failing test for login endpoint** `priority:1` `phase:api` `time:15min`
     - files: src/api/login.py, tests/test_login.py
   - [ ] **Implement login handler** `priority:1` `phase:api` `deps:Write failing test` `time:30min`
   ```
3. **Commit** the design and task list to git.
4. **Ask next step** – Execute now, start a new session, or postpone.

---

## Rules & Principles
- **One question at a time** – avoid overwhelming the user.
- **Prefer multiple‑choice** – easier for the user to answer.
- **YAGNI** – discard features that are not required for the core goal.
- **KISS** – keep the design as simple as possible.
- **Explore alternatives** – always present at least two viable approaches.
- **Incremental validation** – confirm each design section before moving on.
- **Batch questions** – fill all four slots in a round when possible.
- **Score‑driven clarification** – continue until clarity ≥ 90.
- **Think‑tank only for strategic choices** – skip if the decision is trivial.
- **Document everything** – context, decisions, trade‑offs, and open questions.

---

## Common Patterns
### Question Template
```json
{
  "question": "<text>",
  "header": "<category>",
  "multiSelect": <true|false>,
  "options": [
    {"label": "<option>", "description": "<explain>"}
  ]
}
```
Use this JSON format with the `AskUserQuestion` tool.

### Design Section Skeleton
```markdown
## <Section Title>
- **Goal**: <short statement>
- **Key Elements**:
  - <item 1>
  - <item 2>
- **Risks**: <brief list>
- **Open Questions**: <if any>
```

---

## Pitfalls to Avoid
- Asking all questions at once.
- Ignoring user‑provided constraints.
- Skipping the think‑tank when a decision has clear trade‑offs.
- Finalizing a design before the clarity score reaches 90.
- Over‑engineering; add only what the core goal needs.
- Forgetting to commit the design document.

---

## Checklist
- [ ] Scan repository and note tech stack.
- [ ] Run Structured Clarification rounds until score ≥ 90.
- [ ] If a strategic choice exists, run a Think‑Tank.
- [ ] Propose 2‑3 approaches and get user selection.
- [ ] Present design in validated sections.
- [ ] Write design document to `docs/designs/…`.
- [ ] Generate task checklist with priorities and estimates.
- [ ] Commit design and tasks.
- [ ] Confirm next step with the user.

## Related skills

Load these when the task spans more than this skill.

- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`product-management`](../product-management/SKILL.md) — A comprehensive product‑management skill that guides product managers, strategists, and agile owners through d…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`ux-research`](../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`screenshot-feature-extractor`](../screenshot-feature-extractor/SKILL.md) — Extract product features from UI screenshots and generate a development task checklist. Use when you need to t…
- [`behavioral-modes`](../behavioral-modes/SKILL.md) — Defines AI behavioral modes (brainstorm, implement, debug, review, teach, ship) that adapt the AI’s approach,…
