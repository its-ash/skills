# Agent Memory and Context

Agents fail when they cannot retrieve the right information at the right time. Memory is storage plus retrieval. Context is a finite budget. Long-running work needs durable state. This skill covers memory types, chunking and retrieval, context-window budgeting, persistent conversation memory, versioned project memory, and session handoffs.

## When to use

- Design memory for an agent that must remember users, facts, decisions, or procedures across turns or sessions.
- Fix inconsistent answers, forgotten constraints, or retrieval misses.
- Manage token limits, context rot, or long prompts.
- Persist project state across agent sessions or handoffs.
- Choose between in-context, vector, entity, or file-based memory.

## Memory types

Use the smallest memory that fits the lifetime and query pattern.

- Short-term memory: current conversation or task state in the context window. Fast, volatile, limited.
- Working memory: active plan, intermediate results, and current tool outputs. Keep it explicit and compact.
- Episodic memory: events, interactions, and outcomes with timestamps. Use it for "what happened" questions.
- Semantic memory: stable facts, concepts, and domain knowledge. Use it for "what is true" questions.
- Procedural memory: workflows, rules, prompts, and tool-use patterns. Use it for "how to do" questions.
- Long-term memory: durable store outside the context window, usually vector or structured storage.

Do not use one memory type for all data. Match lifetime, update frequency, and retrieval query.

Memory type architecture:

- Put volatile task state in working memory.
- Put user facts and preferences in entity memory.
- Put documents and knowledge in semantic or vector memory.
- Put decisions and milestones in versioned project memory.
- Put only the currently relevant subset in the context window.

## Retrieval and chunking

Retrieval quality determines memory quality. Store facts in chunks that can be found independently.

Chunking rules:

- Chunk by semantic boundaries, not fixed character counts alone.
- Keep each chunk self-contained. Include title, source, date, and enough context to stand alone.
- Test retrieval with real queries before choosing a chunk size.
- Try multiple sizes and compare recall and precision.
- Use contextual chunking: prepend a short document or section summary to each chunk.
- Avoid chunks that are too small to answer a question or too large to fit the budget.

Metadata rules:

- Store source, document ID, section, timestamp, owner, user ID, tags, and embedding model.
- Filter by metadata before vector search when the query implies a scope.
- Track the embedding model in metadata. Re-embed when the model changes.
- Add temporal scoring so recent or currently valid memories rank higher.
- Detect conflicts on storage. If a new fact contradicts an existing fact, mark, version, or resolve it instead of silently overwriting it.

Retrieval rules:

- Retrieve by meaning plus metadata, not meaning alone.
- Budget tokens separately for system instructions, working memory, retrieved memories, and user input.
- Return fewer high-relevance memories rather than many weak ones.
- Re-rank or filter retrieved items before adding them to the prompt.
- Include source and timestamp in retrieved memory so the agent can judge trust.

## Vector store selection

Choose a store by operational constraints, not feature lists alone.

Consider:

- Scale: number of vectors, growth rate, and required latency.
- Filtering: metadata filters, hybrid search, and tenant isolation.
- Durability: backups, replication, and recovery.
- Deployment: managed service, self-hosted, or embedded.
- Cost: storage, query, and egress.
- Ecosystem: client libraries, framework integrations, and observability.

Selection pattern:

- Start with an embedded or simple store for prototypes.
- Move to a managed or self-hosted store when scale, filtering, or multi-tenant isolation matters.
- Use hybrid search when exact terms and semantic similarity both matter.
- Keep vector IDs stable and map them to source records.

## Context window management

Context is finite and has diminishing returns. Curate, do not accumulate.

Rules:

- Count tokens before sending. Do not estimate by characters.
- Reserve budget for instructions, retrieved memory, working state, and output.
- Place critical information at the beginning and end of the prompt. Avoid burying it in the middle.
- Summarize by importance, not only recency.
- Trim low-value history, tool output, and repeated context.
- Route large or specialized content to retrieval instead of inline context.
- Watch for context rot: stale, contradictory, or excessive context reduces answer quality.

Tiered context strategy:

- Small context: include full relevant history and retrieved facts.
- Medium context: summarize older turns, keep recent turns verbatim, retrieve facts.
- Large context: keep system instructions and current task, retrieve facts, summarize or drop low-value history.

Summarization rules:

- Preserve decisions, constraints, open questions, and next steps.
- Preserve identifiers, file paths, and error messages when they matter.
- Drop pleasantries, repeated explanations, and superseded plans.
- Mark summaries as derived context, not source truth.

Trimming rules:

- Remove tool outputs after extracting the needed result.
- Collapse repeated similar messages.
- Keep the latest version of a plan or decision.
- Never trim safety, permission, or user constraints.

## Persistent conversation memory

Conversation memory should remember selectively and retrieve relevantly.

Patterns:

- Tiered memory: short-term buffer, summarized history, and long-term store.
- Entity memory: store facts about people, projects, tools, and preferences. Update them when new information arrives.
- Memory-aware prompting: retrieve only memories relevant to the current query and inject them with source and timestamp.

Rules:

- Do not remember everything. Store durable facts, decisions, preferences, and outcomes.
- Do not store secrets, credentials, or unnecessary personal data.
- Scope memory by user, project, and tenant. Never mix users.
- Implement lifecycle management: decay, archive, update, or delete stale memories.
- Retrieve before answering when prior context may matter.
- Consolidate repeated observations into one updated memory instead of many duplicates.

Anti-patterns:

- Remember everything and overwhelm the context window.
- Store memories but never retrieve them.
- Use one store for all memory types.
- Let memory grow unbounded.

Sharp edges:

- Unbounded stores slow retrieval and increase cost.
- Retrieved memories may be irrelevant. Improve query construction and filters.
- Cross-user leakage is critical. Enforce strict isolation.

## Persistent memory bank (MCP-style)

A memory bank can run as an MCP server and expose read, write, search, and stats operations.

Typical operations:

- memory_search(query, type?, tags?): find memories.
- memory_write(key, type, content, tags?): record knowledge or decisions.
- memory_read(key): retrieve one memory.
- memory_stats(): inspect usage.

Setup pattern:

- Requires Node.js 18 or later.
- Install dependencies and compile the server.
- Start with a project ID and absolute workspace path.
- Use a dashboard only for inspection, not as the source of truth.

Commands:

```bash
npm install
npm run compile
npm run start-server <project_id> <absolute_path_to_target_workspace>
npm run start-dashboard <absolute_path_to_target_workspace>
```

Use this pattern when agents need shared, searchable project knowledge. Keep keys stable and types consistent, such as decision, pattern, architecture, bug, or preference.

## Versioned project memory (GCC)

For multi-step projects, store memory as a versioned file system under `.GCC/`.

Structure:

```text
.GCC/
├── main.md
├── metadata.yaml
├── commit.md
├── log.md
└── branches/<branch-name>/
    ├── commit.md
    ├── log.md
    └── summary.md
```

Operations:

- COMMIT: persist a milestone. Append a sequential commit entry with date, branch, purpose, previous progress, and current contribution. Update logs and metadata.
- BRANCH: create an isolated workspace for an alternative approach. Register it in metadata and the main roadmap.
- MERGE: synthesize a branch into main. Record what was tried, learned, and integrated or abandoned.
- CONTEXT: recover history at a chosen resolution.

CONTEXT flags:

- `--branch [name]`: high-level summary and latest commits.
- `--log [n]`: recent OTA execution entries.
- `--metadata`: project structure, file tree, dependencies, and branches.
- `--full`: complete roadmap, milestones, and active branches.

Configuration:

- `proactive_commits: true` suggests commits after coherent sub-tasks.
- `proactive_commits: false` commits only on request.

OTA logging:

- Record Observation, Thought, and Action at meaningful decision points.
- Keep at most 50 entries. Remove the oldest when exceeded.
- Include sequential ID, timestamp, and branch.

Cross-session recovery:

1. Read metadata.yaml.
2. Read main.md.
3. Read active branch commits and logs.
4. Resume with known completed work and remaining objectives.

Natural language mapping:

| User says | Command |
|---|---|
| "save/checkpoint/persist this" | COMMIT |
| "try a different approach" | BRANCH |
| "that experiment worked, integrate it" | MERGE |
| "where were we?" | CONTEXT --full |

## Session handoffs

Use handoff documents when context is exhausted, work pauses, or a new agent must continue.

Handoff location: `.claude/handoffs/`
Naming: `YYYY-MM-DD-HHMMSS-[slug].md`

Create workflow:

1. Generate a scaffold with timestamp, project path, git branch, recent commits, and modified files.
2. Fill all placeholder sections.
3. Validate completeness, required sections, referenced files, and secrets.
4. Do not finalize if secrets are detected or quality is low.
5. Report location, score, warnings, and first action item.

Resume workflow:

1. List available handoffs.
2. Check staleness by time, commits, changed files, branch divergence, and missing files.
3. Read the handoff completely. Read predecessor handoffs if chained.
4. Verify project directory, branch, blockers, assumptions, and conflicts.
5. Start with the first immediate next step.
6. Update completed items and chain new handoffs for long sessions.

Handoff sections to include:

- Current state summary.
- Important context.
- Immediate next steps.
- Decisions made with rationale.
- Critical files.
- Key patterns discovered.
- Potential gotchas.
- Pending work.

Staleness levels:

- FRESH: safe to resume.
- SLIGHTLY_STALE: review changes, then resume.
- STALE: verify context carefully.
- VERY_STALE: consider a fresh handoff.

Chaining:

- Link each handoff to its predecessor.
- Read the newest first, then predecessors as needed.

## Anti-patterns

- Store everything forever.
- Chunk without testing retrieval.
- Use a single memory type for all data.
- Remember everything and overwhelm context.
- Store memories but never retrieve them.
- Use one store for all memory types.
- Let memory grow unbounded.
- Truncate context naively.
- Ignore token costs.
- Use one context strategy for all tasks.

## Checklist

- [ ] Memory type matches data lifetime and query pattern.
- [ ] Chunks are self-contained and retrieval-tested.
- [ ] Metadata includes source, time, owner, tags, and embedding model.
- [ ] Retrieval filters by metadata before semantic search.
- [ ] Token budget is explicit and enforced.
- [ ] Critical context is at the start or end of the prompt.
- [ ] Summaries preserve decisions and constraints.
- [ ] Memory is scoped by user, project, and tenant.
- [ ] Stale or conflicting memories are detected or versioned.
- [ ] Long-running work has versioned commits or handoff documents.
- [ ] Handoffs are validated and checked for staleness before resume.
