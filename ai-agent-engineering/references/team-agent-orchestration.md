# Team Agent Orchestration

Run many agents as a team: work items with owners and scope, agent Kanban state, branch or worktree isolation, a control pane, merge gates, and parallel terminal panes (tmux / dmux).

## When to use

- The task spans multiple agents, tools, harnesses, branches, or worktrees.
- The user mentions team orchestration, agent Kanban, squad, conductor, control pane, tmux, dmux, Zellij, Codex, Claude Code, or multi-agent work.
- The user says "run in parallel", "split this work", or "use dmux".
- A project needs shared workflow state across people and agents.
- Existing agent fan-out produces output but not a mergeable product.

For the dependency graph and lane matrix of one fast push, see [parallel-execution-optimizer.md](parallel-execution-optimizer.md). For a multi-PR plan, see [blueprint.md](blueprint.md).

## Operating model

Treat every agent as a teammate with a narrow contract:

- **Owner**: the person or agent accountable for the work item.
- **Scope**: files, branch, tool surface, and forbidden areas.
- **State**: backlog, ready, running, review, blocked, merged, or archived.
- **Evidence**: tests, screenshots, logs, review notes, or eval reports.
- **Merge gate**: the exact condition that allows integration.

## Agent Kanban

Use agent Kanban when work must be visible across sessions.

| Column | Meaning | Exit criteria |
| --- | --- | --- |
| Backlog | Candidate work item, not yet shaped | Acceptance criteria written |
| Ready | Shaped and assignable | Owner and branch/worktree assigned |
| Running | Agent is actively working | Handoff artifact and changed files exist |
| Review | Work is complete but not merged | Tests, diff review, and risk check pass |
| Blocked | Needs external input or failed gate | Blocker has owner and next action |
| Merged | Integrated into mainline | PR merged or local main updated |
| Archived | No longer relevant | Reason recorded |

Card schema:

```json
{
  "id": "agent-card-001",
  "title": "Build dynamic workflow skill",
  "owner": "codex",
  "state": "running",
  "branch": "feature/dynamic-workflow",
  "worktree": ".",
  "acceptance": [
    "Skill exists",
    "Tests cover required concepts"
  ],
  "merge_gate": "lint, focused tests, and catalog check pass",
  "handoff": "path/to/handoff.md"
}
```

## Orchestration flow

1. **Shape the board**: convert fuzzy ambition into work items with owners and merge gates.
2. **Pick execution mode**: single agent, in-process subagents, tmux/dmux panes, worktree fan-out, or an external desktop orchestrator.
3. **Assign boundaries**: one owner per card, clear file scope, no overlapping writes without an integrator.
4. **Run agents**: each agent writes evidence and handoff notes, not only code.
5. **Review in sequence**: tests first, then diff review, then security/risk checks, then content/product polish.
6. **Merge deliberately**: one integrator resolves conflicts and updates the control pane or status artifact.
7. **Extract a reusable skill**: if the card pattern repeats, promote it into a shared skill.

When a card uses a task-local harness, put the harness under the card owner, store inputs and outputs on the card, require an eval before Running moves to Review, and promote the harness to a shared skill only after repeat use.

## Control pane requirements

A useful control pane shows:

- Active work items and their Kanban state.
- Owner, harness, branch, worktree, and last heartbeat.
- Links to handoff artifacts, tests, screenshots, and PRs.
- Blockers grouped by owner and unblock action.
- Merge readiness by gate, not vibes.
- Reusable workflow candidates.

Do not add more automation until the operator can answer: who owns this, what changed, what gate failed, and what can safely merge?

## Parallel panes with dmux and tmux

dmux ([github.com/standardagents/dmux](https://github.com/standardagents/dmux)) is a third-party tmux pane manager for agent harnesses (Claude Code, Codex, OpenCode, Cline, Gemini, Qwen). Review the package before you install it.

- Press `n` to create a new pane with a prompt.
- Press `m` to merge pane output back to the main session.

```bash
dmux
# Pane 1: "Implement the auth middleware in src/auth/"
# Pane 2: "Write tests for the user service"
# Pane 3: "Update API documentation"
# Press 'm' to merge results back
```

### Pane patterns

| Pattern | Panes |
| --- | --- |
| Research + implement | Pane 1 researches and writes findings to a file; pane 2 builds a first version; merge findings into pane 2 after pane 1 completes |
| Multi-file feature | Schema/migrations, API endpoints, UI components in separate panes; integrate in the main pane |
| Test + fix loop | Watcher pane runs tests in watch mode and summarizes failures; fixer pane fixes them |
| Cross-harness | Different tools per task, e.g. Claude Code for security review, Codex for refactor |
| Review pipeline | Same directory reviewed for security, performance, and coverage gaps in parallel; merge into one report |

### Worktree isolation

For tasks that touch overlapping files, give each pane its own worktree:

```bash
git worktree add -b feat/auth ../feature-auth HEAD
git worktree add -b feat/billing ../feature-billing HEAD
# Pane 1: cd ../feature-auth && claude
# Pane 2: cd ../feature-billing && claude
git merge feat/auth
git merge feat/billing
```

A per-worker layout that works with any launcher: one branch-backed worktree per worker, plus `task.md`, `handoff.md`, and `status.md` per worker under `.orchestration/<session>/`, one tmux pane per worker, and the main pane free for the orchestrator.

### Pane rules

1. **Independent tasks only.** Do not parallelize tasks that depend on each other's output.
2. **Clear boundaries.** Each pane works on distinct files or concerns.
3. **Merge strategically.** Review pane output before you merge.
4. **Use git worktrees** for conflict-prone work.
5. **Resource awareness.** Each pane is a full agent session and uses tokens. Keep total panes under 5-6.

### Troubleshooting

- **Pane not responding:** switch to the pane, or inspect it with `tmux capture-pane -pt <session>:0.<pane-index>`.
- **Merge conflicts:** isolate file changes per pane with worktrees.
- **High token usage:** reduce the number of parallel panes.
- **tmux not found:** `brew install tmux` (macOS) or `apt install tmux` (Linux).

## Failure modes

- **Agent soup**: many agents running, no owner or merge gate.
- **Invisible work**: useful output exists only in a chat transcript.
- **Board theater**: a Kanban board exists but cards have no acceptance criteria.
- **Overlapping writes**: parallel agents edit the same files without worktrees.
- **No product artifact**: the process produces docs but no runnable or publishable surface.

## Output standard

Finish each orchestration pass with:

- Board/card changes.
- Merged or pending branches.
- Tests and eval evidence.
- Blockers with owner and next action.
- New shared skill candidates.
