# Strategic Compact

Compact the session context manually at logical task boundaries, not at arbitrary auto-compaction points.

## When to use

- Long sessions that approach context limits (200K+ tokens)
- Multi-phase tasks (research → plan → implement → test)
- Switching between unrelated tasks within the same session
- After a major milestone, before new work starts
- When responses slow down or become less coherent (context pressure)

## Why strategic compaction

Auto-compaction triggers at arbitrary points:
- Often mid-task, so important context is lost
- No awareness of logical task boundaries
- Can interrupt complex multi-step operations

Strategic compaction at logical boundaries:
- **After exploration, before execution** — compact research context, keep the implementation plan
- **After a milestone** — fresh start for the next phase
- **Before major context shifts** — clear exploration context before a different task

## Signals to watch

1. **Context size (primary)** — Sum `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` of the latest turn. That is the true context size. Consider compaction near 80% of the window (for example 160k on a 200k window), then again after each further 60k of growth.
2. **Tool-call count (secondary)** — Many tool calls (for example 50+) can be a hint. Tool count alone is a weak proxy: a few large file reads can fill the window, and many small calls can leave it nearly empty.

## Compaction decision guide

| Phase transition | Compact? | Why |
|-----------------|----------|-----|
| Research → Planning | Yes | Research context is bulky; the plan is the distilled output |
| Planning → Implementation | Yes | The plan is in a file; free up context for code |
| Implementation → Testing | Maybe | Keep if tests reference recent code; compact if focus changes |
| Debugging → Next feature | Yes | Debug traces pollute context for unrelated work |
| Mid-implementation | No | Losing variable names, file paths, and partial state is costly |
| After a failed approach | Yes | Clear the dead-end reasoning before a new approach |

## What survives compaction

| Persists | Lost |
|----------|------|
| CLAUDE.md instructions | Intermediate reasoning and analysis |
| Files on disk | File contents you read before |
| Memory files | Multi-step conversation context |
| Git state (commits, branches) | Tool call history and counts |
| The task list, only if todo tools are enabled | Nuanced user preferences stated verbally |

Do not rely on the task list. Some Claude Code versions and models disable the todo/task tools by default. **Write the plan to a file before you compact.** A file persists on every version and every model.

## Best practices

1. **Compact after planning** — when the plan is final **and written to a file**
2. **Compact after debugging** — clear error-resolution context before you continue
3. **Do not compact mid-implementation** — keep context for related changes
4. **Write before compacting** — save important context to files or memory
5. **Use `/compact` with a summary** — for example `/compact Focus on implementing auth middleware next`

## Token optimization patterns

### Trigger-table lazy loading

Do not load full skill content at session start. Use a trigger table that maps keywords to skill paths. Skills load only when triggered, which reduces baseline context by 50% or more.

| Trigger | Skill | Load when |
|---------|-------|-----------|
| "test", "tdd", "coverage" | testing skill | User mentions testing |
| "security", "auth", "xss" | security skill | Security-related work |
| "deploy", "ci/cd" | deployment skill | Deployment context |

### Context composition awareness

- **CLAUDE.md files** — always loaded; keep them lean
- **Loaded skills** — each skill adds 1-5K tokens
- **Conversation history** — grows with each exchange
- **Tool results** — file reads and search results add bulk

### Duplicate instruction detection

- Same rules in both user-level and project-level rule files
- Skills that repeat CLAUDE.md instructions
- Multiple skills that cover overlapping domains
