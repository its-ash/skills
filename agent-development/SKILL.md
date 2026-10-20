---
name: agent-development
description: "Creates and validates Claude Code plugin agents, including agent markdown files, frontmatter fields, system prompts, triggering examples, model and color settings, and tool allowlists. Use when adding, editing, debugging, or testing an agent, configuring agent.md, fixing invalid frontmatter or trigger examples, choosing sonnet, opus, or haiku, restricting tools, or writing autonomous subagent instructions."
---

# Agent Development

Create autonomous agents for Claude Code plugins. Agents run as subprocesses, handle multi‑step tasks, and are invoked automatically when the user request matches the description examples.

## When to use
- You need a new agent to perform a specific domain task.
- You want to edit an existing agent’s trigger conditions, model, or tools.
- You must validate that an agent file follows the required format.
- You are testing that an agent triggers correctly.

---

## Agent File Structure
Create a Markdown file in the plugin’s `agents/` directory.

```markdown
---
name: agent-identifier            # required, see rules below
description: Use this agent when ...
  <example>
  Context: [scenario]
  user: "[user request]"
  assistant: "[expected response]"
  <commentary>
  Why this agent applies
  </commentary>
  </example>
  <example> ... </example>
model: inherit                     # required, see options below
color: blue                        # required, choose from list
tools: ["Read", "Write"]         # optional, restrict tool access
---
You are [role] specializing in [domain].

**Your Core Responsibilities:**
1. ...
2. ...

**Analysis Process:**
1. ...
2. ...

**Output Format:**
- ...
```

All `.md` files in `agents/` are auto‑discovered.

---

## Frontmatter Fields
### name (required)
- Lowercase letters, numbers, hyphens only.
- Length 3‑50 characters.
- Must start and end with an alphanumeric character.
- Example: `code-reviewer`

### description (required)
- Starts with a clear trigger sentence: `Use this agent when ...`.
- Include 2‑4 `<example>` blocks.
- Each example must contain:
  - **Context** – brief scenario description.
  - **user** – exact user request.
  - **assistant** – how Claude should respond using the agent.
  - **<commentary>** – explanation why the agent is appropriate.
- Keep total length 200‑1,000 characters.

### model (required)
- `inherit` – use the plugin’s default model (recommended).
- `sonnet` – balanced performance.
- `opus` – most capable, higher cost.
- `haiku` – fast, low‑cost.

### color (required)
Choose a distinct UI color for the agent.
- Options: `blue`, `cyan`, `green`, `yellow`, `magenta`, `red`.
- Suggested mapping:
  - **blue/cyan** – analysis, review.
  - **green** – success‑oriented tasks.
  - **yellow** – validation, caution.
  - **red** – security, critical.
  - **magenta** – creative generation.

### tools (optional)
Array of tool names the agent may use. Omit to allow all tools.
```yaml
tools: ["Read", "Write", "Grep"]
```
Apply the principle of least privilege; restrict to the minimum needed.

---

## System Prompt Design
Write the body of the Markdown file as a second‑person system prompt.

### Standard Template
```markdown
You are [role] specializing in [domain].

**Your Core Responsibilities:**
1. ...
2. ...

**Analysis Process:**
1. ...
2. ...

**Quality Standards:**
- ...
- ...

**Output Format:**
- ...

**Edge Cases:**
- ...: ...
- ...: ...
```

### Best Practices
- Use second‑person voice (`You are`, `You will`).
- State responsibilities clearly.
- Provide a step‑by‑step analysis process.
- Define the exact output format.
- List quality standards and edge‑case handling.
- Keep total length under 10,000 characters (ideal 500‑3,000).

---

## Creating Agents
### Method 1 – AI‑Assisted Generation
Prompt Claude with the pattern below and convert the JSON response to the file format.
```
Create an agent configuration based on this request: "[your description]"

Requirements:
1. Identify core intent and responsibilities.
2. Define expert persona.
3. Produce a system prompt with responsibilities, process, output format, and edge cases.
4. Generate a valid identifier (lowercase‑hyphens, 3‑50 chars).
5. Write a description with triggering conditions and 2‑3 examples.
6. Return JSON: {"identifier":"...","whenToUse":"...","systemPrompt":"..."}
```
### Method 2 – Manual Creation
1. Choose a valid `name`.
2. Write a `description` with examples.
3. Select `model` (usually `inherit`).
4. Pick a `color`.
5. Add `tools` only if needed.
6. Write the system prompt using the template.
7. Save as `agents/<name>.md`.

---

## Validation Rules
### Identifier Validation
- Length 3‑50.
- Only lowercase letters, numbers, hyphens.
- Starts and ends with alphanumeric.

### Description Validation
- Length 10‑5,000 characters.
- Must contain trigger sentence and at least two `<example>` blocks.
- Each example must include `Context`, `user`, `assistant`, and `<commentary>`.

### System Prompt Validation
- Length 20‑10,000 characters.
- Must contain responsibilities, analysis steps, output format, and edge‑case handling.

---

## Organization and Testing
### Directory Layout
```
plugin-name/
└─ agents/
   ├─ analyzer.md
   ├─ reviewer.md
   └─ generator.md
```
Agents are automatically namespaced as `agent-name` or `plugin:subdir:agent-name`.

### Testing Triggering
1. Write test scenarios that match the description examples.
2. Run Claude with the scenario.
3. Verify the correct agent loads and returns the expected output.
4. Test variations of phrasing to ensure robustness.

### Testing System Prompt
1. Give the agent a typical task.
2. Check that it follows each step in the analysis process.
3. Confirm the output matches the defined format.
4. Exercise each edge case listed in the prompt.

---

## Checklist
- [ ] Identifier follows naming rules.
- [ ] Description starts with `Use this agent when` and includes 2‑4 examples.
- [ ] Each example has `Context`, `user`, `assistant`, and `<commentary>`.
- [ ] Model set to `inherit` unless a specific model is required.
- [ ] Color chosen from allowed list and distinct from other agents.
- [ ] Tools list defined only when needed.
- [ ] System prompt follows the standard template.
- [ ] Prompt length < 10,000 characters.
- [ ] File saved in `agents/` directory with `.md` extension.
- [ ] Triggering tested with realistic user inputs.
- [ ] System prompt behavior verified against edge cases.

## Related skills

Load these when the task spans more than this skill.

- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
- [`skill-authoring`](../skill-authoring/SKILL.md) — Skill Authoring guides you through designing, writing, testing, evaluating, and refining Claude skills. Use it…
- [`slash-command-development`](../slash-command-development/SKILL.md) — Defines how to create, configure, and organize Claude Code slash commands. Covers file locations, YAML frontma…
- [`hook-development`](../hook-development/SKILL.md) — Guide for creating, configuring, and debugging Claude Code plugin hooks and Hookify rules. Use when you need t…
- [`subagent-driven-development`](../subagent-driven-development/SKILL.md) — Subagent‑Driven Development runs an implementation plan by creating a fresh subagent for each independent task…
- [`mcp-development`](../mcp-development/SKILL.md) — Guide for building, testing, and integrating Model Context Protocol (MCP) servers. Use when creating a new MCP…
- [`crewai`](../crewai/SKILL.md) — CrewAI skill guides you to design, configure, and run role‑based multi‑agent teams in Python. Use it for build…
