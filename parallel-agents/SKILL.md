---
name: parallel-agents
description: "Orchestrates multiple independent AI agents to execute concurrently on isolated problem domains such as unrelated test failures, multi-discipline code reviews, or parallel unit test suites. Use when tasks have no shared state, require concurrent execution, involve independent domains, need parallel processing, dispatch subagents, run simultaneous analyses, execute isolated workloads, scale agent throughput across separate contexts, handle unrelated failures, perform multi-area reviews, or run independent test batches."
---

# Parallel Agents

**Purpose** – Run several AI agents at the same time, each with a narrow, self‑contained goal. This speeds up debugging, multi‑discipline analysis, and large test suites while avoiding conflicts.

---

## When to Use
- 2 + failures or bugs that belong to different files, subsystems, or domains.
- Feature work that requires distinct expertise (backend, frontend, security, performance, etc.).
- Large test suites where each test file can be executed independently.
- No shared mutable state between the tasks (agents must not edit the same file or resource).

**Do NOT use** when:
- Failures are causally related and fixing one may fix the others.
- Tasks need a global view of the system to be understood.
- Agents would need to modify the same code or database concurrently.

---

## Workflow
### 1. Identify Independent Domains
Group the work by logical boundaries.
```
Domain A – Tool‑approval flow (src/tests/approval.test.ts)
Domain B – Batch‑completion behavior (src/tests/batch.test.ts)
Domain C – Abort functionality (src/tests/abort.test.ts)
```
### 2. Create Focused Agent Tasks
For each domain define:
- **Scope** – exact file(s) or component.
- **Goal** – what success looks like (e.g., all tests pass).
- **Constraints** – do not modify code outside the scope.
- **Output** – a short summary of findings and changes.
### 3. Dispatch in Parallel
Use Claude Code’s `Task` tool. Set `run_in_background=true` to start agents concurrently.
```typescript
Task("Fix src/tests/approval.test.ts failures", run_in_background=true);
Task("Fix src/tests/batch.test.ts failures",   run_in_background=true);
Task("Fix src/tests/abort.test.ts failures",   run_in_background=true);
```
### 4. Review & Integrate
1. Read each agent’s summary.
2. Verify that no files overlap.
3. Run the full test suite.
4. Merge the non‑conflicting changes.

---

## Agent Prompt Structure
Provide a clear, self‑contained prompt.
```
## Goal
Fix the three failing tests in src/tests/abort.test.ts.

## Context
- Test "should abort tool with partial output" expects "interrupted at".
- Test "should handle mixed completed and aborted tools" fails due to race condition.
- Test "should properly track pendingToolCount" reports 0 results.

## Constraints
- Do NOT modify production code outside src/tests/abort.test.ts.
- Do NOT increase time‑outs; find the real cause.

## Output
Return a markdown summary:
- Root cause for each failure.
- Code changes made.
- Any remaining open questions.
```
**Tips**
- Keep the prompt to one problem domain.
- Include error messages and file snippets.
- State the exact output format you expect.

---

## Orchestration Patterns (Native Claude Agents)
### Pattern 1 – Comprehensive Analysis
```
explorer-agent → security-auditor → backend-specialist → frontend-specialist → test-engineer → synthesis
```
1. Explorer maps the codebase.
2. Each domain specialist analyses its area.
3. Test‑engineer validates the findings.
4. Synthesis produces a single report.

### Pattern 2 – Feature Review
```
Identify affected domains → relevant domain agents → test-engineer → synthesis
```
Use when a change touches multiple layers (e.g., API + UI).

### Pattern 3 – Security Audit
```
security-auditor → penetration-tester → synthesis
```
First a static review, then an active test, then a consolidated remediation plan.

---

## Available Agents
| Agent | Expertise | Typical Trigger |
|-------|-----------|-----------------|
| explorer-agent | Codebase discovery | "explore", "map structure" |
| security-auditor | Security review | "security", "vulnerabilities" |
| penetration-tester | Active security testing | "pentest", "exploit" |
| backend-specialist | Server / API | "API", "Node.js", "Express" |
| frontend-specialist | UI / React | "React", "components" |
| test-engineer | Test generation & verification | "tests", "coverage", "TDD" |
| performance-optimizer | Profiling & speed | "slow", "optimize" |
| devops-engineer | CI/CD & infra | "deploy", "CI/CD" |
| database-architect | Schema & migrations | "Prisma", "migrations" |
| documentation-writer | Docs creation | "write docs", "README" |
| orchestrator | Coordination | "comprehensive", "multi‑perspective" |

---

## Synthesis Protocol
After all agents finish, run a single synthesis step.
```markdown
## Orchestration Synthesis

### Task Summary
[One‑sentence description of the overall work]

### Agent Contributions
| Agent | Finding |
|-------|---------|
| security-auditor | X vulnerability |
| backend‑specialist | API endpoint missing validation |
| test‑engineer | 12 new unit tests added |

### Consolidated Recommendations
1. **Critical** – Fix X vulnerability.
2. **Important** – Add input validation to /login.
3. **Nice‑to‑have** – Refactor utility module.

### Action Items
- [ ] Implement recommendation 1.
- [ ] Add tests from recommendation 2.
- [ ] Update documentation.
```

---

## Best Practices
- **One domain per agent** – prevents overlapping edits.
- **Explicit constraints** – always state what the agent must not change.
- **Uniform output format** – makes automated aggregation easy.
- **Run a full verification step** after integration (full test suite, lint, type‑check).
- **Resume support** – if an agent hits a context limit, capture its `agent_id` and resume later.
- **Model selection** – use Haiku for fast, lightweight tasks (unit tests, lint); Sonnet for development work; Opus only for high‑level planning or security audits.
- **Direct routing vs. supervisor mode** – simple single‑file tasks can be sent directly to a specialist agent; complex multi‑step work should use the supervisor/orchestrator pattern.

---

## Common Mistakes
- **Too broad a scope** – "Fix all tests" confuses the agent.
- **Missing context** – omit error messages or file snippets.
- **No constraints** – agent may refactor unrelated code.
- **Vague output request** – ask for a specific summary format.
- **Overlapping file edits** – assign each file to only one agent.

---

## Checklist
- [ ] Identify independent problem domains.
- [ ] Write a focused prompt for each domain (goal, context, constraints, output).
- [ ] Dispatch agents with `run_in_background=true`.
- [ ] Monitor that each agent receives a unique `agent_id` (for possible resume).
- [ ] Verify no overlapping file edits.
- [ ] Run full test suite after all agents return.
- [ ] Synthesize findings into a single report.
- [ ] Apply recommended changes and commit atomically.
- [ ] Update documentation and continuity logs.

## Related skills

Load these when the task spans more than this skill.

- [`subagent-driven-development`](../subagent-driven-development/SKILL.md) — Subagent‑Driven Development runs an implementation plan by creating a fresh subagent for each independent task…
- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`ai-maestro`](../ai-maestro/SKILL.md) — Manage AI Maestro agents, send AMP messages, search memory/docs/code graph, and run structured planning. Use f…
- [`ai-cli-delegation`](../ai-cli-delegation/SKILL.md) — Delegates user requests to AI command‑line tools (Gemini CLI or Codex CLI). Choose the appropriate model, sand…
