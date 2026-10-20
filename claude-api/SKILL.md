---
name: claude-api
description: "Build, debug, and optimize Claude API applications with the Anthropic SDK or raw HTTP, covering model selection, thinking and effort settings, prompt caching, compaction, tool use, Managed Agents, and model migration. Use when integrating Claude, Anthropic API, messages.create, tool calling, function calling, prompt caching, extended thinking, beta headers, SDK setup, API errors, rate limits, or migrating between Claude model versions."
---

# Claude API (Anthropic SDK)

Create reliable Claude‑powered applications. Use the official Anthropic SDK for your language (or raw HTTP when required). The skill covers model defaults, thinking/effort settings, prompt caching, compaction, tool use, Managed Agents, and migration between model versions.

## When to Use
- You need to call Claude via `anthropic` (Python), `@anthropic-ai/sdk` (TypeScript/JavaScript), or the Java/Ruby/Go/C# SDKs.
- You want prompt caching, compaction, or tool‑calling support.
- You are migrating code from older Claude models (e.g., 4.5 → 4.6/4.7).
- You need Managed Agents (stateful, Anthropic‑hosted tool execution).
- You are building batch, file‑upload, or streaming workflows.

---

## Language Detection & SDK Choice
1. Detect the project language from file extensions or lock files.
2. **Preferred SDK**: use the official Anthropic SDK for the detected language.
3. **Raw HTTP**: only when the user explicitly asks for cURL/REST or the language lacks an SDK.
4. Never mix SDK and raw HTTP in the same file.
5. If the language is unsupported, suggest cURL examples and offer Python/TypeScript reference code.

### Quick Language Map
| Language | SDK Package | Example Import |
|----------|--------------|----------------|
| Python   | `anthropic`  | `from anthropic import Anthropic` |
| TypeScript/JS | `@anthropic-ai/sdk` | `import { Anthropic } from "@anthropic-ai/sdk";` |
| Java     | `com.anthropic` | `import com.anthropic.AnthropicClient;` |
| Go       | `github.com/anthropic/anthropic-go` | `import "github.com/anthropic/anthropic-go"` |
| Ruby     | `anthropic` | `require "anthropic"` |
| C#       | `Anthropic` (official) | `using Anthropic;` |
| PHP      | `anthropic/anthropic-php` | `use Anthropic\Client;` |
| cURL/raw HTTP | — | `curl https://api.anthropic.com/v1/messages ...` |

---

## Model Defaults & Selection
- **Default model**: `claude-opus-4-7` (model string `claude-opus-4-7`).
- Use this model unless the user explicitly requests another model ID.
- Do **not** downgrade for cost; let the user decide.
- Model IDs must be used exactly as listed; do not add date suffixes.

## Thinking & Effort Settings
| Parameter | Recommended Value (Opus 4.7) | Notes |
|-----------|-----------------------------|-------|
| `thinking` | `{"type": "adaptive"}` | Adaptive thinking is the only supported mode on Opus 4.7. |
| `effort`   | `"xhigh"` (inside `output_config`) | Provides strong reasoning for coding/agent tasks. Use `high` for most cases, `max` only when correctness outweighs cost. |
| `budget_tokens` | **Never** on Opus 4.7; deprecated on Opus 4.6/ Sonnet 4.6. | If migrating old code, keep the field only as a temporary escape hatch on Opus 4.6. |

### Example (Python)
```python
from anthropic import Anthropic
client = Anthropic()
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Summarize the following text..."}],
    thinking={"type": "adaptive"},
    output_config={"effort": "xhigh"},
    stream=False,
)
print(response.content)
```
---

## Prompt Caching
- Use **prefix match** caching. Any change in the cached prefix invalidates later cache entries.
- Stable order: `tools → system → messages`. Keep immutable parts (system prompt, tool definitions) at the start.
- Enable top‑level auto‑caching with:
```python
client.messages.create(
    ...,
    cache_control={"type": "ephemeral"},
)
```
- Maximum of **4 breakpoints** per request.
- Verify cache hits via `usage.cache_read_input_tokens` in the response.
- Minimum cacheable prefix ≈ 1024 tokens; shorter prefixes silently skip caching.

## Compaction (Long Conversations)
- Activate server‑side compaction for contexts approaching the 1 M token window.
- Add beta header `compact-2026-01-12` (SDK adds it automatically when `compact` is true).
- **Important**: Append the full `response.content` (including compaction blocks) to the next request's message list. Dropping compaction metadata loses state.

### Example (TypeScript)
```ts
import { Anthropic } from "@anthropic-ai/sdk";
const client = new Anthropic({
  // SDK adds required beta header automatically when compact is true
});
const resp = await client.messages.create({
  model: "claude-opus-4-7",
  messages: [{ role: "user", content: "..." }],
  compact: true,
});
// Append full response.content to next call
messages.push(...resp.content);
```
---

## Tool Use & Function Calling
1. Define tools using SDK decorators (Python) or Zod schemas (TypeScript).
2. The SDK’s **tool runner** handles the request‑response loop automatically.
3. For manual control, implement the loop:
   - Send `messages.create` with `tools`.
   - Detect `tool_use` calls in the response.
   - Execute the local function.
   - Send `tool_result` back and repeat until `assistant` finishes.
4. Use `client.messages.parse()` to validate structured outputs against your schema.

### Python Tool Example
```python
from anthropic import Anthropic, tool
client = Anthropic()

@tool
def add(a: int, b: int) -> int:
    return a + b

response = client.messages.create(
    model="claude-opus-4-7",
    messages=[{"role": "user", "content": "Add 7 and 5"}],
    tools=[add],
    stream=False,
)
print(response.content)
```
---

## Managed Agents (Beta)
- **Purpose**: Anthropic hosts the agent loop and a per‑session container for tool execution (bash, file ops, code).
- **Workflow**:
  1. **Create an Agent** (`POST /v1/agents`). Store the returned `agent_id`.
  2. **Start a Session** (`POST /v1/sessions` with the `agent_id`).
  3. **Stream events** from the session. Send tool results back as they arrive.
- Agents are **persistent**; reuse the same `agent_id` across sessions.
- Managed Agents are **not available** on Bedrock, Vertex AI, or Microsoft Foundry.
- Use SDK beta namespace: `client.beta.agents`, `client.beta.sessions`, etc.
- C# lacks Managed Agents support; use raw HTTP/cURL for those cases.

### Python Managed Agent Skeleton
```python
from anthropic import Anthropic
client = Anthropic()
# 1. Create agent (run once)
agent = client.beta.agents.create(
    model="claude-opus-4-7",
    system="You are a helpful coding assistant.",
    tools=[...],
)
agent_id = agent.id
# 2. Start a session
session = client.beta.sessions.create(agent_id=agent_id)
# 3. Stream messages
for event in client.beta.sessions.stream(session_id=session.id):
    if event.type == "message":
        print(event.message.content)
    elif event.type == "tool_use":
        # Execute tool and send result back
        result = run_tool(event.tool_name, event.input)
        client.beta.sessions.tool_result(
            session_id=session.id,
            tool_use_id=event.id,
            content=result,
        )
```
---

## Model Migration Checklist
- Update `model` field to the exact new ID (`claude-opus-4-7`).
- Replace any `budget_tokens` with `thinking: {"type": "adaptive"}`.
- Move `effort` into `output_config` if not already present.
- Verify beta headers for compaction, task budgets, or Managed Agents are set by the SDK.
- Run a quick test request and check `usage.model` to confirm the new model is in effect.
---

## Common Pitfalls & How to Avoid Them
| Pitfall | Symptom | Fix |
|---------|----------|-----|
| Mixing SDK and raw HTTP | Duplicate imports, inconsistent headers | Stick to one approach per file. |
| Using deprecated `budget_tokens` on Opus 4.7 | 400 error `invalid_parameter` | Switch to `thinking: {"type": "adaptive"}`. |
| Forgetting to append full `response.content` after compaction | Context loss, repeated prompts | Append the entire `content` array, not just `text`. |
| Placing volatile data (timestamps, IDs) before the cache breakpoint | Cache hit rate drops to 0 | Move volatile parts after the last `cache_control` breakpoint. |
| Not storing `agent_id` before creating sessions | New agent each request, higher cost | Create the agent once, reuse its ID. |
| Using Managed Agents on unsupported providers | API 404 or permission errors | Switch to Claude API + tool use for those providers. |
---

## Checklist
- [ ] Detect project language and select the official Anthropic SDK.
- [ ] Use model `claude-opus-4-7` unless user specifies otherwise.
- [ ] Set `thinking: {"type": "adaptive"}` and `output_config.effort` (`"xhigh"` default).
- [ ] Enable streaming for large inputs/outputs when appropriate.
- [ ] Add `cache_control` breakpoints; verify cache hits via `usage.cache_read_input_tokens`.
- [ ] Enable compaction (`compact: true`) for long conversations; preserve full response content.
- [ ] Define tools with SDK decorators or schemas; use the tool runner unless manual loop needed.
- [ ] For Managed Agents: create agent once, store `agent_id`, start sessions, stream events, handle tool results.
- [ ] Review migration steps: model ID, thinking, effort, beta headers.
- [ ] Test a single request end‑to‑end and inspect the response for correct fields.

## Related skills

Load these when the task spans more than this skill.

- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`mcp-development`](../mcp-development/SKILL.md) — Guide for building, testing, and integrating Model Context Protocol (MCP) servers. Use when creating a new MCP…
- [`llm-evaluation-observability`](../llm-evaluation-observability/SKILL.md) — Provides a complete workflow to benchmark LLMs with lm-evaluation-harness, accelerate runs with vLLM, track tr…
- [`llm-advanced-techniques`](../llm-advanced-techniques/SKILL.md) — Advanced LLM Techniques for compressing models with knowledge distillation, extending transformer context wind…
