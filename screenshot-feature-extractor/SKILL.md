---
name: screenshot-feature-extractor
description: "Extract product features, user interactions, and business functions from UI screenshots, design mockups, competitor app screens, or wireframes and convert them into a structured development task checklist with acceptance criteria. Use when analyzing competitor screenshots, reviewing Figma or Sketch mockups, auditing existing app interfaces, reverse-engineering UI patterns, planning sprint backlogs from visual specs, or converting design handoffs into actionable tickets for frontend, mobile, or fullstack development."
---

# Screenshot Feature Extractor

Extract product features from UI screenshots and produce a development‑task checklist. The skill coordinates five specialized agents to analyze UI components, user interactions, and business logic, then synthesises and reviews the results.

## When to use
- Analyzing competitor product screenshots to identify features.
- Turning UI mock‑ups or design screenshots into a product requirements document.
- Batch processing many app screens to build a comprehensive feature list.
- Conducting visual competitive analysis for gaps and opportunities.

## Workflow
1. **Collect screenshots**
   - Read each screenshot file supplied by the user.
   - Record the file path and any contextual notes.
   - Determine whether the screenshots belong to the same product.
2. **Parallel analysis** (run three agents simultaneously using the Task tool)
   ```
   // UI Analyzer
   Analyze the screenshot for UI components, layout, and design patterns.
   Return JSON.

   // Interaction Analyzer
   Analyze the screenshot for user interactions, navigation flows, and state transitions.
   Return JSON.

   // Business Analyzer
   Analyze the screenshot for business functions, data entities, and domain logic.
   Return JSON.
   ```
3. **Synthesis** (single sequential agent)
   ```
   // Synthesizer
   Combine the three JSON results into a unified development‑task list.
   Output file: docs/plans/<YYYY-MM-DD>-<product>-features.md
   ```
4. **Review** (single sequential agent)
   ```
   // Reviewer
   Check the task list for completeness and quality.
   If issues exist, provide corrected items.
   ```
5. **Output**
   - Write the final checklist to the markdown file shown above.
   - Use a markdown task‑list format (`- [ ]`).
   - Present a short summary to the user.

## Guidelines
- List each task as a markdown checkbox (`- [ ]`).
- Keep tasks small and executable; describe **what** to build, not **how**.
- Focus on user‑visible features and interactions; omit implementation details such as libraries or frameworks.
- When multiple screenshots are processed, deduplicate overlapping features.
- For competitive analysis, flag features that are unique to the target product and note any gaps compared to competitors.

## Pitfalls to avoid
- Do not include technology stack or code‑level decisions in the task list.
- Do not assume missing context; request clarification if a screenshot lacks description.
- Avoid overly generic tasks (e.g., "Improve UI")—make them specific (e.g., "Add filter dropdown to product list view").
- Ensure the reviewer validates that every extracted feature appears in the final checklist.

## Checklist
- [ ] Gather all screenshot files and note their context.
- [ ] Verify that screenshots belong to the same product (or label each product separately).
- [ ] Invoke UI, Interaction, and Business analyzers in parallel via the Task tool.
- [ ] Receive three JSON analysis results.
- [ ] Run the synthesizer to create a unified task list.
- [ ] Run the reviewer to validate completeness and quality.
- [ ] Write the final checklist to `docs/plans/<date>-<product>-features.md`.
- [ ] Provide the user with a concise summary of extracted features.

## Related skills

Load these when the task spans more than this skill.

- [`ux-research`](../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
- [`product-management`](../product-management/SKILL.md) — A comprehensive product‑management skill that guides product managers, strategists, and agile owners through d…
- [`feature-brainstorming`](../feature-brainstorming/SKILL.md) — Feature‑brainstorming skill turns a vague feature idea into a clear design, requirements, and implementation p…
- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
