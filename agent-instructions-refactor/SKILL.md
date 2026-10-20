---
name: agent-instructions-refactor
description: "Refactor a bloated AGENTS.md, CLAUDE.md, or similar agent instruction file into a minimal root file plus linked topic files. Use when an instruction file is long, contradictory, mixes unrelated guidelines, needs splitting, deduplication, reorganization, markdown cleanup, or consolidation for coding agents, agent rules, system prompts, developer instructions, repository conventions, and coding standards."
---

# Agent Instructions Refactor

Refactor a large agent instruction file into a minimal root file and a set of linked, topic‑specific files. Follow progressive disclosure: keep only universal information in the root and move detailed guidance to separate documents.

## When to use
- The file is longer than a few dozen lines.
- Instructions conflict or repeat.
- You need clearer navigation for the agent.
- You want to separate language, testing, style, and architecture guidelines.

## Workflow
### Phase 1 – Find contradictions
1. Scan the file for conflicting statements.
2. Record each pair in the format:
   ```markdown
   ## Contradiction
   **A:** …
   **B:** …
   ```
3. Ask the user which rule should win before continuing.

### Phase 2 – Identify essentials for the root
1. Keep only items that apply to **every** task.
2. Typical essentials:
   - One‑sentence project description.
   - Package manager if not `npm`.
   - Custom build, test, or type‑check commands.
   - Critical overrides that must always be applied.
   - Universal rules that never change.
3. Move all other content to separate files.

### Phase 3 – Group remaining instructions
1. Choose logical categories (e.g., `typescript.md`, `testing.md`, `code-style.md`).
2. Place each instruction in the appropriate file.
3. Aim for 3‑8 topic files. Do not create a file for a single rule.

### Phase 4 – Create the file structure
1. Create a folder (e.g., `.claude/` or `docs/agent/`).
2. Place each topic file inside the folder.
3. Add links from the root file to each topic file.

### Phase 5 – Flag for deletion
1. Mark instructions that are redundant, vague, or outdated.
2. List them in a table with a short reason.
3. Remove them from all files after confirmation.

## Rules for the Root File
- Include only universal information.
- Keep the file under 50 lines.
- Provide a quick reference table for commands.
- Add a **Detailed Instructions** section that contains only links to topic files.

## Categorization Guidelines
| Category file | Typical contents |
|---|---|
| `typescript.md` | strict mode, compiler options, type patterns |
| `testing.md` | test framework, coverage thresholds, mocking |
| `code-style.md` | formatter settings, naming conventions, comment style |
| `git-workflow.md` | branch model, commit message format, PR process |
| `architecture.md` | folder layout, dependency rules, module boundaries |
| `api-design.md` | REST/GraphQL conventions, error handling |
| `security.md` | authentication, input validation, secret handling |
| `performance.md` | caching, lazy loading, bundle size limits |

## File Structure Template
```
project-root/
├── CLAUDE.md          # Minimal root file
└── .claude/           # Folder for linked files
    ├── typescript.md
    ├── testing.md
    ├── code-style.md
    ├── git-workflow.md
    └── architecture.md
```
### Root file example
```markdown
# Project Name

One‑sentence description.

## Quick Reference
- **Package Manager:** pnpm
- **Build:** `pnpm build`
- **Test:** `pnpm test`
- **Typecheck:** `pnpm typecheck`

## Detailed Instructions
- [TypeScript Guidelines](.claude/typescript.md)
- [Testing Guidelines](.claude/testing.md)
- [Code Style](.claude/code-style.md)
- [Git Workflow](.claude/git-workflow.md)
- [Architecture Patterns](.claude/architecture.md)
```
### Linked file example (any topic)
```markdown
# {Topic} Guidelines

## Overview
Brief context for when the guidelines apply.

## Rules
- Specific, actionable instruction
- Another specific instruction

## Examples
### Good
```typescript
// Correct pattern
```
### Avoid
```typescript
// Incorrect pattern
```
```
## Deletion Criteria
- Redundant: the instruction repeats known defaults.
- Vague: the instruction lacks concrete action.
- Obsolete: the instruction refers to deprecated APIs.
- Overly obvious: the instruction states a universal best practice.

## Checklist
- [ ] All contradictions identified and resolved.
- [ ] Root file contains only universal essentials.
- [ ] Remaining instructions placed in logical topic files.
- [ ] File hierarchy created and links added.
- [ ] Redundant or vague instructions flagged and removed.
- [ ] Each linked file is self‑contained.
- [ ] Root file is under 50 lines.
- [ ] All links resolve correctly.

## Pitfalls (Anti‑Patterns)
- **Keeping everything in the root** – makes the file hard to read. Split into linked files.
- **Creating too many categories** – fragments guidance. Consolidate related topics.
- **Using vague rules** – waste tokens. Replace with specific actions or delete.
- **Duplicating defaults** – the agent already knows standard behavior. Override only when needed.
- **Deep nesting of folders** – hard to navigate. Use a flat folder with clear file names.

## Related skills

Load these when the task spans more than this skill.

- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
- [`skill-authoring`](../skill-authoring/SKILL.md) — Skill Authoring guides you through designing, writing, testing, evaluating, and refining Claude skills. Use it…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`file-organization`](../file-organization/SKILL.md) — Organizes files and folders intelligently: analyzes directory structure, finds duplicates, proposes logical fo…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`behavioral-modes`](../behavioral-modes/SKILL.md) — Defines AI behavioral modes (brainstorm, implement, debug, review, teach, ship) that adapt the AI’s approach,…
