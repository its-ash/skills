---
name: ai-agent-architecture
description: "Design and build autonomous AI agents with ReAct and Plan-Execute loops, tool registries, schema-driven function calling, approval gates, sandboxed execution, multi-model routing, and persistent memory with conversation history, entity facts, and session handoffs. Use when implementing agent loop, ReAct pattern, Plan-Execute workflow, reflection cycle, tool registry, function schema, permission manager, approval workflow, sandbox environment, memory retrieval, context window management, token budget, cross-session continuity, context versioning, GCC state, model orchestration, fallback routing, or guardrail configuration for autonomous assistants, coding agents, or research bots."
---

# AI Agent Architecture
Design, implement, and operate autonomous AI agents that act reliably while remaining controllable. This skill covers core loops, tool design, safety mechanisms, memory handling, multi‑model setups, and production guardrails.

## When to Use
- Building an autonomous AI agent or assistant.
- Designing function‑calling APIs for LLMs.
- Implementing permission, approval, or sandboxing for risky tools.
- Orchestrating multiple agents or models for complex tasks.
- Adding reliable logging, tracing, and checkpointing to long‑running agents.

---

## Core Agent Loops
### 1. ReAct Loop (Reason‑Act‑Observe)
1. **Reason** – Prompt LLM for next thought and possible tool use.
2. **Act** – If a tool call is returned, invoke the tool.
3. **Observe** – Append tool result to the conversation history.
4. **Repeat** – Continue until the LLM returns a final answer or a hard iteration limit is hit.

```python
class ReActAgent:
    def __init__(self, llm, tools, max_iters=30):
        self.llm = llm
        self.tools = {t.name: t for t in tools}
        self.max_iters = max_iters
        self.history = []

    def run(self, task: str) -> str:
        self.history.append({"role": "user", "content": task})
        for _ in range(self.max_iters):
            resp = self.llm.chat(messages=self.history, tools=self._tool_schema(), tool_choice="auto")
            if resp.tool_calls:
                for call in resp.tool_calls:
                    result = self._exec(call)
                    self.history.append({"role": "tool", "tool_call_id": call.id, "content": str(result)})
            else:
                return resp.content
        return "[Error] Max iterations reached"

    def _tool_schema(self):
        return [t.schema for t in self.tools.values()]

    def _exec(self, call):
        tool = self.tools[call.name]
        args = json.loads(call.arguments)
        return tool.execute(**args)
```

### 2. Plan‑Execute Loop
1. **Plan** – LLM decomposes the goal into ordered steps.
2. **Execute** – Agent runs each step, optionally invoking tools.
3. **Re‑plan** – If a step fails or produces unexpected output, request a new plan.
4. Separate planner and executor models can reduce token cost.

```python
planner = LLM(model="gpt-3.5-turbo")
executor = LLM(model="gpt-4-turbo")

plan = planner.chat(messages=[{"role": "user", "content": "Break down: " + goal}])
steps = json.loads(plan.content)
for step in steps:
    result = executor.chat(messages=[{"role": "user", "content": step}])
    if "error" in result.content.lower():
        plan = planner.chat(messages=[{"role": "assistant", "content": result.content}, {"role": "user", "content": "Re‑plan"}])
        steps = json.loads(plan.content)
        continue
```

### 3. Reflection Pattern
After each major milestone, ask the agent to evaluate its own output against ground‑truth criteria and suggest corrections.
```python
reflection = llm.chat(messages=[{"role": "assistant", "content": latest_output},
                               {"role": "user", "content": "Rate correctness (0‑100) and list fixes."}])
```

---

## Tool Design & Registry
### Schema Design
- Use JSON Schema with explicit `type`, `description`, and `required` fields.
- Keep parameter names short and snake_case.
- Provide **examples** in the schema to guide the LLM.
```json
{
  "name": "read_file",
  "description": "Read a text file.",
  "parameters": {
    "type": "object",
    "properties": {
      "path": {"type": "string", "description": "Absolute file path"},
      "encoding": {"type": "string", "enum": ["utf-8", "latin1"], "default": "utf-8"}
    },
    "required": ["path"]
  },
  "examples": [{"path": "/tmp/data.txt"}]
}
```
### Registration Pattern
```python
class ToolRegistry:
    def __init__(self):
        self._tools = {}
        self._usage = collections.Counter()

    def register(self, tool):
        self._tools[tool.name] = tool

    def get_schema(self):
        return [t.schema for t in self._tools.values()]

    def select(self, task_desc):
        # Simple heuristic: match keywords in description to tool names
        for name, tool in self._tools.items():
            if name in task_desc.lower():
                return tool
        return None
```
### Essential Tool Set (example)
- `read_file`, `write_file`, `edit_file`
- `list_directory`, `search_files`
- `run_command`, `read_output`
- `open_browser`, `click_element`, `type_text`, `screenshot`
- `ask_user`, `search_web`

---

## Permission & Safety Patterns
| Level | Description | When to use |
|------|-------------|------------|
| **AUTO** | No user approval required. | Low‑risk read‑only actions (e.g., `read_file`). |
| **ASK_ONCE** | Prompt once per session. | Moderate‑risk writes (`write_file`, `edit_file`). |
| **ASK_EACH** | Prompt for every call. | High‑risk commands (`run_command`, `delete_file`). |
| **NEVER** | Block permanently. | Dangerous operations (`sudo`, `format_disk`). |

### Approval Manager (simplified)
```python
class ApprovalManager:
    def __init__(self, ui, config):
        self.ui = ui
        self.config = config
        self.session_approvals = {}

    def allowed(self, tool, args):
        level = self.config.get(tool, PermissionLevel.ASK_EACH)
        if level == PermissionLevel.AUTO:
            return True
        if level == PermissionLevel.NEVER:
            self.ui.error(f"Tool {tool} is prohibited")
            return False
        if level == PermissionLevel.ASK_ONCE:
            if tool in self.session_approvals:
                return self.session_approvals[tool]
        # ASK_EACH or first ASK_ONCE
        approved = self.ui.confirm(f"Allow {tool} with args {args}?")
        if level == PermissionLevel.ASK_ONCE:
            self.session_approvals[tool] = approved
        return approved
```
### Sandboxed Execution
```python
class SandboxedRunner:
    def __init__(self, workspace):
        self.workspace = os.path.abspath(workspace)
        self.allowed = {"npm", "python", "git", "ls", "cat"}

    def _in_workspace(self, path):
        return os.path.abspath(path).startswith(self.workspace)

    def run(self, cmd: str) -> ToolResult:
        base = shlex.split(cmd)[0]
        if base not in self.allowed:
            return ToolResult(False, error=f"Command {base} not allowed")
        proc = subprocess.run(cmd, cwd=self.workspace, capture_output=True, text=True, timeout=30)
        return ToolResult(proc.returncode == 0, output=proc.stdout, error=proc.stderr if proc.returncode else None)
```
---

## Memory & Context Management
- **Selective Memory** – Store only high‑value facts (e.g., file paths, API tokens). Discard raw transcript after a configurable window (e.g., last 10 steps).
- **Chunked Context Injection** – When sending large files, embed them as `@file` blocks with a short header.
- **Checkpoint / Resume** – Serialize `history`, `context`, and workspace state to JSON after each iteration; reload on restart.
```python
class Checkpoint:
    def __init__(self, dir):
        os.makedirs(dir, exist_ok=True)
        self.dir = dir

    def save(self, id, state):
        path = os.path.join(self.dir, f"{id}.json")
        with open(path, "w") as f:
            json.dump(state, f, indent=2)
        return path

    def load(self, path):
        with open(path) as f:
            return json.load(f)
```
---

## Multi‑Model Orchestration
- **Fast model** for planning or routing (e.g., `gpt-3.5-turbo`).
- **Smart model** for deep reasoning (e.g., `gpt-4-turbo`).
- **Specialized model** for code generation or vision (e.g., `claude-3-sonnet`).
```python
def select_model(task_type):
    mapping = {"planning": "gpt-3.5-turbo", "analysis": "gpt-4-turbo", "code": "claude-3-sonnet"}
    return mapping.get(task_type, "gpt-4-turbo")
```
---

## Guardrails & Sharp Edges
| Issue | Severity | Mitigation |
|-------|----------|------------|
| Unlimited loop iterations | Critical | Enforce `max_iterations` (default ≤ 30). |
| Vague tool description | High | Provide full JSON schema with examples. |
| Unhandled tool errors | High | Return structured error objects; surface to LLM. |
| Memory bloat | Medium | Prune history; keep only recent steps. |
| Too many tools | Medium | Curate a minimal toolset per task. |
| Missing logging | Medium | Emit structured logs for each Reason/Act/Observe step. |
| Fragile output parsing | Medium | Use strict JSON output schema; validate before use. |

---

## Checklist for Building a Production‑Ready Agent
- [ ] Define a **clear goal** and limit scope to one primary function.
- [ ] Choose an appropriate **agent loop** (ReAct or Plan‑Execute).
- [ ] Implement a **Tool Registry** with complete JSON schemas and examples.
- [ ] Set **iteration limits** and cost caps.
- [ ] Add **permission levels** for each tool.
- [ ] Wrap risky tools in **sandboxed runners**.
- [ ] Log every Reason, Action, Observation with timestamps.
- [ ] Store periodic **checkpoints** for resume capability.
- [ ] Use **selective memory**; discard low‑value context.
- [ ] If using multiple models, map tasks to the right model.
- [ ] Write unit tests for each tool’s schema validation and error handling.
- [ ] Perform load testing with realistic token budgets before production.

---

## Related Skills
- `agent-tool-builder` – deeper tool‑schema techniques.
- `agent-memory-systems` – advanced vector‑store integration.
- `multi-agent-orchestration` – coordinating several agents.
- `rag-engineer` – retrieving external knowledge.
- `prompt-engineer` – crafting effective system prompts.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/agent-memory-context.md](references/agent-memory-context.md) | Design and operate agent memory and context: choose memory types, chunk and retrieve facts, manage context windows, persist conversation and entity memory, version project state with GCC, and create session handoffs. Use for agents with long-running tasks, token limits, cross-session continuity, or retrieval quality issues. |

## Related skills

Load these when the task spans more than this skill.

- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`langchain-langgraph`](../langchain-langgraph/SKILL.md) — Build LLM applications with LangChain (agents, chains, RAG, memory, vector stores) and stateful multi-actor wo…
- [`llamaindex`](../llamaindex/SKILL.md) — LlamaIndex skill for building RAG applications with document ingestion, indexing, and querying. Use when creat…
- [`crewai`](../crewai/SKILL.md) — CrewAI skill guides you to design, configure, and run role‑based multi‑agent teams in Python. Use it for build…
- [`dspy`](../dspy/SKILL.md) — Build complex AI systems with declarative programming using DSPy (Stanford NLP). Covers signatures, modules (P…
- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
