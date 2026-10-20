---
name: subagent-driven-development
description: "Subagent-Driven Development executes an implementation plan by spawning a fresh subagent for each independent task, then running spec-compliance review and code-quality review before marking that task complete. Use when you have a plan with mostly independent tasks, want to stay in the same session, and need subagent dispatch, task-by-task implementation, spec review, code review, or plan execution."
---

# Subagent‑Driven Development
Execute an implementation plan by dispatching a new subagent for each task. After the subagent finishes, run a spec‑compliance review and then a code‑quality review. Only when both reviews approve does the task become complete.

## When to Use
- You have a written implementation plan.
- Most tasks can be completed independently.
- You want to keep all work in the current session (no context switch).
- You need automatic quality gates without a human‑in‑the‑loop between tasks.

## Workflow
1. **Read the plan**
   - Extract every task with its full text and any required context.
   - Create a `TodoWrite` list that contains all tasks.
2. **For each task**
   1. **Dispatch implementer subagent** using `./implementer-prompt.md`.
      - Provide the task text and its context.
      - If the subagent asks questions, answer them clearly before it proceeds.
   2. **Implementer works**
      - Writes code, adds tests, runs them, and performs a self‑review.
      - Commits the changes.
   3. **Spec compliance review**
      - Dispatch the spec‑reviewer subagent (`./spec-reviewer-prompt.md`).
      - If the reviewer reports missing or extra behavior, return to step 2.6.
   4. **Fix spec gaps**
      - The same implementer subagent updates the code to satisfy the spec.
      - Re‑dispatch the spec reviewer until it returns ✅.
   5. **Code‑quality review**
      - Dispatch the code‑quality reviewer subagent (`./code-quality-reviewer-prompt.md`).
      - If the reviewer reports issues, return to step 2.6.
   6. **Fix quality issues**
      - The implementer subagent corrects the problems.
      - Re‑dispatch the quality reviewer until it returns ✅.
   7. **Mark task complete**
      - Record the task as done in `TodoWrite`.
3. **After all tasks**
   - Dispatch a final code‑reviewer subagent for the whole branch.
   - Run the `superpowers:finishing-a-development-branch` skill to merge the work.

## Prompt Templates
- `./implementer-prompt.md` – template for the implementation subagent.
- `./spec-reviewer-prompt.md` – template for the spec‑compliance reviewer.
- `./code-quality-reviewer-prompt.md` – template for the code‑quality reviewer.

## Example (short)
```
You: Start Subagent‑Driven Development for docs/plans/feature-plan.md.
[Extract 5 tasks → TodoWrite]

Task 1: Install hook script
[Dispatch implementer] → asks "user or system level?"
You: "User level (~/.config/superpowers/hooks/)"
Implementer: writes code, adds tests, self‑reviews, commits.
[Dispatch spec reviewer] → ✅
[Dispatch quality reviewer] → ✅
Mark Task 1 complete.

... repeat for remaining tasks ...

[Dispatch final reviewer] → all requirements met.
Run superpowers:finishing-a-development-branch.
```

## Advantages
- Fresh subagent per task prevents context leakage.
- Built‑in test‑driven development (subagents run tests before committing).
- Two‑stage review catches spec gaps early and enforces code quality.
- No human pause between tasks; iteration is fast.
- Works in a single session, avoiding hand‑offs.

## Red Flags (what to avoid)
- Skipping either the spec review or the quality review.
- Proceeding while a reviewer still reports issues.
- Running multiple implementation subagents for the same task in parallel.
- Letting the implementer read the plan file directly; always provide extracted text.
- Ignoring subagent questions or answering incompletely.
- Starting the code‑quality review before the spec review is ✅.
- Treating the implementer’s self‑review as a replacement for the formal reviewers.
- Manually fixing a failed task instead of dispatching a fix subagent.

## Integration
**Required workflow skills**
- `superpowers:writing-plans` – creates the plan that this skill executes.
- `superpowers:requesting-code-review` – supplies the review templates used by reviewer subagents.
- `superpowers:finishing-a-development-branch` – finalizes the branch after all tasks.

**Subagents should also use**
- `superpowers:test-driven-development` – ensures each task follows TDD.

**Alternative**
- Use `superpowers:executing-plans` for a parallel‑session workflow instead of staying in the same session.

## Checklist
- [ ] Plan is written and tasks are mostly independent.
- [ ] All tasks are extracted with full text and context.
- [ ] `TodoWrite` list is created.
- For each task:
  - [ ] Implementer subagent dispatched with task text.
  - [ ] All implementer questions answered.
  - [ ] Implementer self‑reviews and commits.
  - [ ] Spec reviewer returns ✅.
  - [ ] Code‑quality reviewer returns ✅.
  - [ ] Task marked complete in `TodoWrite`.
- [ ] Final code reviewer approves the whole branch.
- [ ] Run `superpowers:finishing-a-development-branch` to merge.

## Related skills

Load these when the task spans more than this skill.

- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`parallel-agents`](../parallel-agents/SKILL.md) — Parallel Agents skill lets you orchestrate multiple independent AI agents to work concurrently on separate pro…
- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`ai-cli-delegation`](../ai-cli-delegation/SKILL.md) — Delegates user requests to AI command‑line tools (Gemini CLI or Codex CLI). Choose the appropriate model, sand…
- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
