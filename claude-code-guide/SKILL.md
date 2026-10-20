---
name: claude-code-guide
description: "Configures Claude Code projects with CLAUDE.md instructions, commands, code style, workflow, prompting cues, debugging steps, best-practice rules, and checklists. Use when setting up Claude Code, writing or editing CLAUDE.md, tuning agent behavior, fixing agent loops, choosing thinking keywords, applying incremental code-change rules, troubleshooting Claude Code prompts, defining coding conventions, refining agent instructions, or debugging the coding agent."
---

# Claude Code Guide

A concise reference for setting up Claude Code, prompting it effectively, debugging its responses, and following safe development habits.

## When to use
- Starting a new repository that will be edited with Claude Code.
- Adding or refactoring code where you want the agent to respect project conventions.
- When the agent produces unexpected output or seems stuck.
- To keep interactions small, repeatable, and easy to review.

## Configuration file (`CLAUDE.md`)
Create a **CLAUDE.md** at the repository root. It tells Claude Code the project’s commands, style, and workflow.

```markdown
# Project Guidelines

## Commands
- Run app: `npm run dev`
- Test: `npm test`
- Build: `npm run build`

## Code style
- Use TypeScript for all new code.
- Write React components as functional components with Hooks.
- Apply Tailwind CSS for styling.
- Use early returns for error handling.

## Workflow
- Read `README.md` first to understand context.
- Before editing, view the target file.
- After editing, run the test suite.
```

Update the file whenever conventions change. Claude Code reads it at the start of each session.

## Prompting keywords ("Thinking" cues)
Insert these phrases to make the agent reason before acting:
- **Think step‑by‑step** – forces a multi‑step plan.
- **Analyze the root cause** – useful for bug fixes.
- **Plan before executing** – generates a short outline first.
- **Verify your assumptions** – asks the model to check premises.

Use one cue per request; combine only if the prompt remains clear.

## Debugging the agent
If Claude Code produces wrong code or appears confused:
1. **Clear context** – start a new session or ask the model to *forget previous instructions*.
2. **Give explicit details** – specify exact file paths, function names, and desired behavior.
3. **Request logs** – say *check the logs* or *run the command with verbose output*.
4. **Limit the scope** – narrow the request to a single file or function.
5. **Iterate** – ask for a minimal change, verify, then request the next step.

## Best‑practice rules
- **Small contexts** – never paste the whole repository. Use `grep`, `find`, or the file tree to locate relevant files and include only those.
- **Iterative development** – request a tiny modification, run tests, then proceed.
- **Immediate feedback** – correct mistakes as soon as they appear; ask the model to *add a lesson* to its memory or update `CLAUDE.md`.
- **Explicit success criteria** – state how you will verify the change (e.g., *all unit tests must pass*).
- **Version control** – commit after each verified change.

## Common pitfalls
| Pitfall | Why it hurts | Remedy |
|---|---|---|
| Dumping the entire codebase into the prompt | Exceeds token limits, dilutes focus | Use file‑specific queries; reference only needed snippets |
| Vague instructions | Model guesses, leading to incorrect code | Include concrete file names, function signatures, and expected output |
| Skipping tests after a change | Bugs go unnoticed, future merges break | Run the test suite immediately; treat passing tests as a gate |
| Ignoring style guidelines | Inconsistent code, harder reviews | Keep `CLAUDE.md` up‑to‑date; remind the model of style rules each session |

## Checklist
- [ ] Create or update `CLAUDE.md` with current commands and style.
- [ ] Identify the exact file(s) to modify before prompting.
- [ ] Add a *thinking* keyword to the prompt.
- [ ] Request a small, testable change.
- [ ] Run the relevant tests or lint checks.
- [ ] Commit the change if tests pass.
- [ ] If the output is wrong, clear context and give a more explicit prompt.

## Related skills

Load these when the task spans more than this skill.

- [`agent-instructions-refactor`](../agent-instructions-refactor/SKILL.md) — Refactor a bloated AGENTS.md, CLAUDE.md, or similar file into a minimal root file and a set of linked topic fi…
- [`hook-development`](../hook-development/SKILL.md) — Guide for creating, configuring, and debugging Claude Code plugin hooks and Hookify rules. Use when you need t…
- [`slash-command-development`](../slash-command-development/SKILL.md) — Defines how to create, configure, and organize Claude Code slash commands. Covers file locations, YAML frontma…
- [`subagent-driven-development`](../subagent-driven-development/SKILL.md) — Subagent‑Driven Development runs an implementation plan by creating a fresh subagent for each independent task…
- [`skill-authoring`](../skill-authoring/SKILL.md) — Skill Authoring guides you through designing, writing, testing, evaluating, and refining Claude skills. Use it…
- [`mcp-development`](../mcp-development/SKILL.md) — Guide for building, testing, and integrating Model Context Protocol (MCP) servers. Use when creating a new MCP…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
