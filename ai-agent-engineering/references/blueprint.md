# Blueprint: Construction Plan Generator

Turn a one-line objective into a step-by-step construction plan that any coding agent can execute cold, across multiple sessions, PRs, and agents.

## When to use

- Break a large feature into multiple PRs with clear dependency order.
- Plan a refactor or migration that spans multiple sessions.
- Coordinate parallel workstreams across subagents.
- Any task where context loss between sessions would cause rework.

**Do not use** for tasks that fit in a single PR, need fewer than 3 tool calls, or when the user says "just do it."

## How it works

Run a 5-phase pipeline:

1. **Research**: pre-flight checks (git, `gh auth`, remote, default branch), then read the project structure, existing plans, and memory files to gather context.
2. **Design**: break the objective into one-PR-sized steps (3–12 typical). Assign dependency edges, parallel/serial order, model tier (strongest vs default), and rollback strategy per step.
3. **Draft**: write a self-contained Markdown plan file to `plans/<project>-<objective-slug>.md`. Every step includes a context brief, task list, verification commands, and exit criteria, so a fresh agent can execute any step without reading prior steps.
4. **Review**: delegate adversarial review to a strongest-model subagent against a checklist (completeness, dependency correctness, anti-patterns). Fix all critical findings before you finalize.
5. **Register**: save the plan, update the memory index, and show the step count and parallelism summary to the user.

Detect git/gh availability. With git and GitHub CLI, generate full branch/PR/CI workflow plans. Without them, use direct mode (edit in place, no branches).

## Step template

```markdown
### Step N: <title>
- Depends on: <step ids or none>   Parallel with: <step ids or none>
- Model tier: strongest | default
- Branch: <branch name>            Rollback: <how to revert>

**Context brief:** <what a cold agent must know: goal, files, invariants, decisions so far>

**Tasks:**
1. ...

**Verification:**
    <commands that prove the step works>

**Exit criteria:** <observable conditions; invariants still hold>
```

## Examples

Objective "migrate database to PostgreSQL" produces `plans/myapp-migrate-database-to-postgresql.md` with steps such as:
- Step 1: Add PostgreSQL driver and connection config
- Step 2: Create migration scripts for each table
- Step 3: Update repository layer to use new driver
- Step 4: Add integration tests against PostgreSQL
- Step 5: Remove old database code and config

Objective "extract LLM providers into a plugin system" produces parallel steps after the interface step (for example, "implement Anthropic plugin" and "implement OpenAI plugin"), the strongest tier for the interface design step, the default tier for implementation, and invariants that you verify after every step ("all existing tests pass", "no provider imports in core").

## Key features

- **Cold-start execution**: every step has a self-contained context brief.
- **Adversarial review gate**: a strongest-model subagent reviews every plan.
- **Branch/PR/CI workflow** in every step, with direct mode when git/gh is absent.
- **Parallel step detection**: the dependency graph finds steps with no shared files or output dependencies.
- **Plan mutation protocol**: split, insert, skip, reorder, or abandon steps, and record each change with its reason in an audit trail in the plan file.

Inspired by antbotlab/blueprint.
