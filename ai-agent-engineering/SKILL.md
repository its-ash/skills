---
name: ai-agent-engineering
description: "Engineering operating model for work that AI agents do end to end: eval-first execution, task decomposition, model routing, session and context strategy, review gates, and cost control, plus agent harnesses, autonomous loops, multi-agent orchestration, MCP servers, agent security, and LLM cost. Use when planning or running agent-driven engineering, setting team process for code that agents write, designing an agent tool set or harness, building an autonomous or scheduled agent loop, writing evals or pass@k gates, debugging a failed agent run, coordinating parallel agents in worktrees or tmux, building or reviewing an MCP server or .mcp.json, hardening an agent against prompt injection, cutting LLM spend with model routing or prompt caching, or managing a context window. Sub-skills: agent-harness-construction, autonomous-loops, loop-design-check, autonomous-agent-harness, agentic-os, gan-style-harness, dynamic-workflow-mode, eval-harness, agent-architecture-audit, agent-introspection-debugging, agent-security-hardening, enterprise-agent-ops, mcp-server-patterns, mcp-dependency-review, council, santa-method, parallel-execution-optimizer, team-agent-orchestration, blueprint, recursive-decision-ledger, counterparty-channel-discipline, operator-approval-loop, llm-cost-optimization, regex-vs-llm-structured-text, token-budget-advisor, iterative-retrieval, strategic-compact, search-first."
---

# AI Agent Engineering

Use this skill when AI agents do most of the implementation work and humans control quality and risk.

## When to use

- You plan or run engineering work that agents do end to end.
- You set process, review gates, or ownership rules for a codebase that agents write.
- You design an agent, a harness, a loop, or a multi-agent workflow.
- You must measure agent output with evals before you trust it.

## Operating Principles

1. Define completion criteria before execution.
2. Break work into agent-sized units.
3. Route model tiers by task complexity.
4. Measure with evals and regression checks.
5. Planning quality matters more than typing speed. Eval coverage matters more than confidence.

## Eval-First Loop

1. Define a capability eval and a regression eval.
2. Run a baseline and record the failure signatures.
3. Do the implementation.
4. Run the evals again and compare the deltas.

See [references/eval-harness.md](references/eval-harness.md) for graders, pass@k, and regression suites.

## Task Decomposition

Use the 15-minute unit rule. Each unit must:
- be verifiable by itself
- have one dominant risk
- have a clear done condition

## Model Routing

- Small model: classification, boilerplate transforms, narrow edits
- Mid model: implementation and refactors
- Largest model: architecture, root-cause analysis, multi-file invariants

Go to a higher tier only when the lower tier fails because of a clear reasoning gap.

## Session Strategy

- Continue the session for closely coupled units.
- Start a new session after a major phase change.
- Compact after a milestone, not during active debugging. See [references/strategic-compact.md](references/strategic-compact.md).

## Agent-Friendly Architecture

Prefer:
- explicit boundaries
- stable contracts
- typed interfaces
- deterministic tests

Do not spread behavior across hidden conventions.

## Review Focus for AI-Generated Code

Review for:
- invariants and edge cases
- behavior regressions and data integrity
- error boundaries and failure handling
- security and auth assumptions
- hidden coupling and rollout risk

Do not spend review time on style when format and lint tools already enforce it.

## Testing Standard

Use a higher test bar for generated code:
- regression coverage for each touched domain
- explicit edge-case assertions
- integration checks at interface boundaries

## Interpret Tool Results Before You Compare Data

For document reads and processing loops, check three boundaries in this order:

1. Check the tool or transport envelope for an error or an unknown outcome.
2. Decode the response and check the operation status with the documented contract of that tool. An outer success flag or a payload does not prove that the operation succeeded. If the status is missing or unknown, keep it as unknown.
3. Only after confirmed success, validate the document shape and compare its fields. An operation failure is not a document mismatch.

Keep the operation name, request ID, status, error details, and the original response for diagnosis. Remove secrets and private data before you log or share them. If a write times out or its result is unknown, reconcile with a documented status or read-back before you retry. Do not repeat or overwrite a write only because a read failed or a field is different.

## Cost Discipline

Record per task:
- model
- token estimate
- retries
- wall-clock time
- success or failure

See [references/llm-cost-optimization.md](references/llm-cost-optimization.md) for routing, budgets, and prompt caching.

## Signals of a Strong Agent Engineer

- Breaks ambiguous work into clean units
- Defines measurable acceptance criteria
- Writes high-signal prompts and evals
- Keeps risk controls under delivery pressure

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/agent-harness-construction.md](references/agent-harness-construction.md) | You define or revise an agent's tool set, action space, observation format, error recovery contract, or context budget. |
| [references/autonomous-loops.md](references/autonomous-loops.md) | You choose, build, or recover a continuous agent loop, from a sequential `claude -p` pipeline to an RFC-driven DAG with merge queue, quality gates, evals, and recovery controls. |
| [references/loop-design-check.md](references/loop-design-check.md) | You design or review a goal-oriented agent loop for machine-decidable goals, loop type, plan/build/judge skeleton, and runaway failure modes such as spinning or Goodhart-gaming. |
| [references/autonomous-agent-harness.md](references/autonomous-agent-harness.md) | You set up continuous or scheduled autonomous operation with persistent memory, crons, CI or webhook dispatch, computer use, and a task queue. |
| [references/agentic-os.md](references/agentic-os.md) | You build a persistent multi-agent system on Claude Code with a kernel CLAUDE.md, specialist agents, slash commands, file-based memory, and external scheduling. |
| [references/gan-style-harness.md](references/gan-style-harness.md) | You build an app autonomously through planner, generator, and strict evaluator iterations until a weighted quality score passes a threshold. |
| [references/dynamic-workflow-mode.md](references/dynamic-workflow-mode.md) | You build a task-local harness with eval gates, tool and entity boundaries, and handoff checkpoints, or promote repeated ad-hoc work into a shared skill. |
| [references/eval-harness.md](references/eval-harness.md) | You define pass/fail evals for agent tasks, measure pass@k, build regression suites for prompt or agent changes, compare coding agents on cost, time, and pass rate, or self-score a deliverable. |
| [references/agent-architecture-audit.md](references/agent-architecture-audit.md) | An agent or LLM feature misbehaves and the failing layer is unknown, or before you ship an agent stack: audit 12 layers for wrapper regression, memory pollution, tool discipline failures, hidden repair loops, and rendering corruption. |
| [references/agent-introspection-debugging.md](references/agent-introspection-debugging.md) | An agent run fails, loops, or burns tokens with no progress, and you need a reproducible diagnosis (capture, diagnose, contained recovery, report) instead of a retry. |
| [references/agent-security-hardening.md](references/agent-security-hardening.md) | You build or review an agent runtime, tool gateway, memory service, or multi-tenant agent deployment that handles untrusted content, files, or credentials, or a coding agent needs guard modes against destructive commands. |
| [references/enterprise-agent-ops.md](references/enterprise-agent-ops.md) | You run long-lived or cloud-hosted agent fleets on PM2, systemd, or containers that need lifecycle control, observability, kill switches, rollout gates, or incident response. |
| [references/mcp-server-patterns.md](references/mcp-server-patterns.md) | You build or debug an MCP server: tools, resources, prompts, Zod validation, or the choice between stdio and Streamable HTTP. |
| [references/mcp-dependency-review.md](references/mcp-dependency-review.md) | You review .mcp.json, Cursor, VS Code, Claude, or Windsurf MCP config for mutable package references before approval or CI, without running the servers. |
| [references/council.md](references/council.md) | A decision has several credible paths and needs structured disagreement before a go/no-go call, or a feature proposal needs PM, Architect, Developer, and QA views in one session. |
| [references/santa-method.md](references/santa-method.md) | You gate publishing, production deploys, compliance- or brand-sensitive content, or hallucination-prone claims: two independent reviewers with the same rubric must both pass, with a fix-and-re-review loop and a human escalation cap. |
| [references/parallel-execution-optimizer.md](references/parallel-execution-optimizer.md) | A task must go much faster through parallel lanes, batched tool calls, isolated worktrees, or shared preparation across similar records, with no loss of correctness. |
| [references/team-agent-orchestration.md](references/team-agent-orchestration.md) | Several agents work in parallel across branches, worktrees, or tmux/dmux panes and need owners, agent Kanban state, a control pane, and merge gates. |
| [references/blueprint.md](references/blueprint.md) | You plan a large feature, refactor, or migration across several PRs or sessions as one-PR-sized steps with cold-start context briefs, a dependency graph, and an adversarial review gate. |
| [references/recursive-decision-ledger.md](references/recursive-decision-ledger.md) | You run repeated rollouts, stochastic search, or ensemble comparison that need an append-only ledger of trials, marks, and promotion gates, so recursive confidence never approves live actions by itself. |
| [references/counterparty-channel-discipline.md](references/counterparty-channel-discipline.md) | An agent sits in group chats, shared channels, or DMs with external counterparties and must speak only when addressed, never leak internal context, and send risky content to draft-only approval. |
| [references/operator-approval-loop.md](references/operator-approval-loop.md) | An agent drafts messages to external counterparties and a human operator must approve, reject, or steer each exact draft before it is sent, with hashed drafts, epoch-keyed decisions, and durable delivery receipts. |
| [references/llm-cost-optimization.md](references/llm-cost-optimization.md) | LLM spend must come down or the prompt cache hit rate must go up: model routing by task complexity, budget tracking, narrow retries, and prompt caching with stable prefixes. |
| [references/regex-vs-llm-structured-text.md](references/regex-vs-llm-structured-text.md) | You parse structured text (quizzes, forms, invoices, receipts, tables) and choose between regex and LLM, with a regex-first pipeline, confidence scoring, and an LLM validator for edge cases. |
| [references/token-budget-advisor.md](references/token-budget-advisor.md) | The user wants to control response length or token budget with a choice of depth (25%/50%/75%/100%) and token estimates before the answer. |
| [references/iterative-retrieval.md](references/iterative-retrieval.md) | A subagent does not have the context it needs, or agent tasks fail with missing or too-large context: refine retrieval in a dispatch-evaluate-refine loop. |
| [references/strategic-compact.md](references/strategic-compact.md) | A long session approaches its context limit or moves to a new task phase, and you must compact manually at a logical boundary after you save the plan to a file. |
| [references/search-first.md](references/search-first.md) | You start a feature, add a dependency, create or find a skill, or need current library and API behavior: search the repo, registries, MCP servers, skills, GitHub, and current docs before you write custom code. |

## Related skills

Load these when the task spans more than this skill.

- [`machine-learning`](../machine-learning/SKILL.md) — Production ML workflow: data contracts, training, evaluation, serving, and monitoring.
- [`secure-coding`](../secure-coding/SKILL.md) — Secrets, auth, injection, and API security for agent tools and gateways.
- [`software-architecture`](../software-architecture/SKILL.md) — Boundaries, contracts, and ADRs that make a codebase agent-friendly.
- [`code-review`](../code-review/SKILL.md) — Review gates for AI-generated changes.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — Regression tests and TDD for generated code.
