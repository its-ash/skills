---
name: ai-maestro
description: "Manage AI Maestro agents, send AMP messages between agents, search memory, docs, and code graphs, and run structured planning. Use when starting, stopping, listing, or checking agent status; sending or reading AMP inbox messages; recalling prior context; looking up documentation or APIs; analyzing code dependencies; or breaking work into multi-step plans."
---

# AI Maestro

AI Maestro is a local platform for managing AI agents and their work context. It covers agent lifecycle management, signed inter-agent messaging, semantic memory search, documentation search, code-graph queries, and persistent planning files.

## When to use

- Create, list, show, update, rename, delete, hibernate, wake, or restart agents.
- Install, uninstall, list, or add marketplaces for agent plugins.
- Export or import agent configuration.
- Send, read, reply to, or delete messages between agents.
- Check an agent inbox or identity.
- Recall prior discussions, decisions, or context before starting work.
- Search codebase documentation for signatures, APIs, classes, or comments.
- Query component relationships, callers, callees, serializers, associations, or change impact.
- Plan, track, or resume complex multi-step tasks.

## Prerequisites

- AI Maestro runs locally.
- Agent management requires tmux 3.0 or later.
- Memory search uses CozoDB vector search.
- Documentation and graph queries require an indexed codebase.
- CLI tools must be available on PATH.

## Agent management

### Commands

| Command | Description |
| --- | --- |
| `aimaestro-agent.sh list` | List all agents with status |
| `aimaestro-agent.sh show <agent>` | Detailed agent information |
| `aimaestro-agent.sh create <name> --dir <path>` | Create new agent |
| `aimaestro-agent.sh update <agent> --task "..."` | Update task or tags |
| `aimaestro-agent.sh delete <agent> --confirm` | Delete agent |
| `aimaestro-agent.sh rename <old> <new>` | Rename agent |
| `aimaestro-agent.sh hibernate <agent>` | Save state and free resources |
| `aimaestro-agent.sh wake <agent>` | Resume hibernated agent |
| `aimaestro-agent.sh restart <agent>` | Hibernate then wake |
| `aimaestro-agent.sh plugin install <agent> <plugin>` | Install plugin |
| `aimaestro-agent.sh plugin uninstall <agent> <plugin>` | Remove plugin |
| `aimaestro-agent.sh plugin list <agent>` | List installed plugins |
| `aimaestro-agent.sh plugin marketplace add <agent> <source>` | Add marketplace |
| `aimaestro-agent.sh export <agent>` | Export agent config |
| `aimaestro-agent.sh import <file>` | Import agent from file |

### Statuses

| Status | Meaning |
| --- | --- |
| online | Running in tmux session |
| offline | Registered but no active session |
| hibernated | Saved state, session killed |

### Examples

```bash
aimaestro-agent.sh create backend-api \
  --dir ~/projects/backend \
  --task "Build REST API with TypeScript" \
  --tags "api,typescript"
aimaestro-agent.sh hibernate frontend-ui
aimaestro-agent.sh wake frontend-ui --attach
aimaestro-agent.sh plugin install backend-api my-plugin
aimaestro-agent.sh export backend-api -o backup.json
```

## Agent messaging (AMP)

### Quick start

```bash
amp-init --auto
amp-send alice "Hello" "How are you?"
amp-inbox
amp-read <message-id>
amp-reply <message-id> "Got it, working on it now"
```

### Address formats

| Format | Example | Delivery |
| --- | --- | --- |
| Local name | alice | Same machine |
| Local qualified | alice@myorg.aimaestro.local | Within mesh |
| External | alice@acme.crabmail.ai | Via provider (requires registration) |

### Commands

| Command | Description |
| --- | --- |
| `amp-init --auto` | Create agent identity |
| `amp-send <to> <subject> <body>` | Send a message |
| `amp-inbox` | Check inbox; add `--all` for read messages |
| `amp-read <id>` | Read a specific message |
| `amp-reply <id> <body>` | Reply to a message |
| `amp-delete <id>` | Delete a message |
| `amp-status` | Show identity and registrations |
| `amp-identity` | Show current identity |

### Message options

```bash
amp-send alice "Deploy" "Ready for prod" --priority urgent
amp-send alice "Review PR #42" "Please review" --type request
amp-send alice "Report" "See attached" --attach report.pdf
```

### Message types

| Type | Use case |
| --- | --- |
| notification | General info (default) |
| request | Asking for something |
| task | Assigned work |
| handoff | Transferring context |
| status | Progress update |

### Priorities

| Priority | When |
| --- | --- |
| normal | Standard (default) |
| urgent | Immediate attention |
| high | Respond soon |
| low | When convenient |

### Security

- Ed25519 signatures on every message.
- Private keys stay local and are never sent to providers.
- Each agent has a unique keypair.

## Memory search

### Core behavior

Receive instruction -> Search memory -> Then proceed.

### Commands

| Command | Description |
| --- | --- |
| `memory-search.sh "<query>"` | Hybrid search (recommended) |
| `memory-search.sh "<query>" --mode semantic` | Find conceptually related content |
| `memory-search.sh "<query>" --mode term` | Exact text matching |
| `memory-search.sh "<query>" --mode symbol` | Code symbol matching |
| `memory-search.sh "<query>" --role user` | Only user messages |
| `memory-search.sh "<query>" --role assistant` | Only assistant messages |

### Search modes

| Mode | Best for |
| --- | --- |
| hybrid (default) | General search, most cases |
| semantic | Related concepts, different wording |
| term | Exact function or class names |
| symbol | Code identifiers across contexts |

### Examples

```bash
memory-search.sh "authentication"
memory-search.sh "PaymentService" --mode term
memory-search.sh "error handling patterns" --mode semantic
memory-search.sh "processPayment" --mode symbol
```

### Combining capabilities

```bash
memory-search.sh "feature"
docs-search.sh "feature"
graph-describe.sh ComponentName
```

## Documentation search

### Core behavior

Receive instruction -> Search docs -> Then implement.

### Commands

| Command | Description |
| --- | --- |
| `docs-search.sh <query>` | Semantic documentation search |
| `docs-search.sh --keyword <term>` | Exact keyword matching |
| `docs-find-by-type.sh <type>` | Find by type (function, class, module) |
| `docs-get.sh <doc-id>` | Get full document content |
| `docs-index.sh [path]` | Full index from project |
| `docs-index-delta.sh [path]` | Delta index (new or modified files only) |
| `docs-list.sh` | List all indexed documents |
| `docs-stats.sh` | Index statistics |

### Document types

| Type | Sources |
| --- | --- |
| function | JSDoc, RDoc, docstrings |
| class | Class-level comments |
| module | Module or namespace comments |
| interface | TypeScript interfaces |
| component | React or Vue component comments |
| readme | README files |
| guide | docs/ folder content |

### Examples

```bash
docs-search.sh "authentication flow"
docs-search.sh --keyword "UserController"
docs-find-by-type.sh class
docs-get.sh doc-abc123
docs-index.sh /path/to/project
docs-index-delta.sh
```

## Code graph query

### Core behavior

Read file -> Query graph -> Then proceed.

### Commands

#### Query

| Command | Description |
| --- | --- |
| `graph-describe.sh <name>` | Describe a component or function |
| `graph-find-callers.sh <fn>` | Find all callers of a function |
| `graph-find-callees.sh <fn>` | Find all functions called by this function |
| `graph-find-related.sh <component>` | Find related components |
| `graph-find-by-type.sh <type>` | Find all components of a type |
| `graph-find-serializers.sh <model>` | Find serializers for a model |
| `graph-find-associations.sh <model>` | Find model associations |
| `graph-find-path.sh <from> <to>` | Find call path between functions |

#### Index

| Command | Description |
| --- | --- |
| `graph-index-delta.sh [path]` | Index or update the code graph |

### Component types

Use with `graph-find-by-type.sh`: `model`, `serializer`, `controller`, `service`, `job`, `concern`, `component`, `hook`.

### Why query before modifying

- Avoid breaking callers when changing a function signature.
- Avoid missing serializers that need updating with a model change.
- Avoid overlooking child classes that inherit your modifications.

### Examples

```bash
graph-describe.sh User
graph-find-serializers.sh User
graph-find-associations.sh User
graph-find-callers.sh process_payment
graph-find-callees.sh process_payment
graph-find-path.sh handleRequest sendResponse
graph-index-delta.sh /path/to/project
```

## Planning

Planning uses local markdown files and has no external dependencies.

### When to use

- Multi-step tasks (3 or more steps).
- Research projects.
- Building features requiring more than 5 tool calls.
- Any task where you might lose track of the goal.

### Three-file pattern

| File | Purpose | Update when |
| --- | --- | --- |
| task_plan.md | Goals, phases, decisions, errors | After each phase |
| findings.md | Research, discoveries, resources | During research |
| progress.md | Session log, test results | Throughout session |

### Quick start

```bash
PLAN_DIR="${AIMAESTRO_PLANNING_DIR:-docs_dev}"
mkdir -p "$PLAN_DIR"
```

### Plan template

```markdown
# Task: [Goal]

## Phases
- [ ] Phase 1: Research
- [ ] Phase 2: Design
- [ ] Phase 3: Implement
- [ ] Phase 4: Test

## Decisions
| Decision | Rationale | Date |
|----------|-----------|------|

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
```

### Rules

- Create plan first. Never start complex work without `task_plan.md`.
- Read before decide. Re-read the plan before any major decision.
- Update after act. Mark phases complete and log what changed.
- 2-action rule. After every 2 search or browse operations, save findings to `findings.md`.
- Log all errors. Every error goes in the plan with attempt number and resolution.
- Never repeat failures. If an action failed, change your approach.

### Three-strike protocol

| Strike | Action |
| --- | --- |
| 1 | Diagnose root cause and apply targeted fix |
| 2 | Try a different approach entirely |
| 3 | Question assumptions and search for similar issues |
| After 3 | Escalate to user with all attempts documented |

### Five-question reboot

- Where am I? (current phase in `task_plan.md`)
- Where am I going? (remaining phases)
- What's the goal? (goal section)
- What have I learned? (`findings.md`)
- What have I done? (`progress.md`)

## Checklist

- Verify agent status before hibernate, wake, or delete.
- Initialize identity before first message.
- Search memory before starting work.
- Search docs before implementing changes.
- Query graph after reading code and before modifying.
- Create `task_plan.md` before complex work and update it after each phase.

## Related skills

Load these when the task spans more than this skill.

- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`context7-docs`](../context7-docs/SKILL.md) — Fetch up‑to‑date library or framework documentation using the Context7 API within Claude Code sessions. Use wh…
- [`parallel-agents`](../parallel-agents/SKILL.md) — Parallel Agents skill lets you orchestrate multiple independent AI agents to work concurrently on separate pro…
