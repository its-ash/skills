---
name: mcp-development
description: "Build, test, and integrate Model Context Protocol (MCP) servers in Python with FastMCP or TypeScript, including tools, resources, authentication, middleware, and Claude Code plugin configuration. Use when creating an MCP server, adding MCP tools or resources, writing FastMCP or TypeScript MCP code, configuring MCP in Claude Code, debugging MCP connections, or integrating MCP with plugins."
---

# MCP Development Guide

Create high‑quality MCP servers that let LLMs call external APIs or services. The guide covers planning, implementation, testing, evaluation, and integration with Claude Code plugins.

---

## When to use
- You need a new MCP server (Python FastMCP or TypeScript SDK).
- You want to expose a service as a set of tools for LLMs.
- You must add authentication, rate‑limiting, or logging middleware.
- You are packaging an MCP server inside a Claude Code plugin.
- You need to evaluate whether the server helps LLMs solve real tasks.

---

## High‑Level Workflow
| Phase | Goal |
|------|------|
| 1. Research & Planning | Understand MCP design, select transport, study the service API, decide tool coverage. |
| 2. Implementation | Set up project, build core utilities, define tools/resources, add authentication & middleware. |
| 3. Review & Test | Run static checks, compile, test with MCP Inspector, verify error handling. |
| 4. Evaluation | Write realistic read‑only questions, run them against the server, verify answers. |

---

## Phase 1 – Research & Planning
1. **Read the MCP specification** – start at the sitemap `https://modelcontextprotocol.io/sitemap.xml` and fetch the markdown pages you need.
2. **Choose language & transport**
   - TypeScript SDK is recommended for static typing and broad AI support.
   - Python FastMCP is recommended for rapid development.
   - Transport options: `streamable HTTP` (remote), `stdio` (local child process), `SSE`, or `WebSocket`.
3. **Tool naming** – use clear, action‑oriented names with a consistent prefix, e.g. `github_create_issue`.
4. **Context management** – keep tool descriptions concise, support pagination, and return focused data.
5. **Error messages** – make them actionable (suggest next steps, indicate which parameter is wrong).
6. **Plan API coverage** – list the most common endpoints first; prefer comprehensive coverage over a single high‑level workflow when unsure.

---

## Phase 2 – Implementation
### 2.1 Project structure
- **TypeScript** – `src/`, `package.json`, `tsconfig.json`.
- **Python** – package directory, `pyproject.toml` or `requirements.txt`.
- Keep a `tools/` folder for each tool implementation.

### 2.2 Core infrastructure (both languages)
- API client with authentication (OAuth, API keys, etc.).
- Central error‑handling helper that formats messages for LLMs.
- Pagination helper that returns `nextPageToken` when needed.
- Logging utility that writes to the MCP `Context`.

### 2.3 Defining tools
#### Input schema
- **TypeScript** – use **Zod**.
- **Python** – use **Pydantic**.
- Include constraints, clear descriptions, and example values.

#### Output schema
- Define a structured schema (`outputSchema` in TypeScript, Pydantic model in Python).
- Return both `text` and `structuredContent` when the SDK supports it.

#### Annotations (optional but recommended)
```json
{
  "readOnlyHint": true,
  "destructiveHint": false,
  "idempotentHint": true,
  "openWorldHint": false
}
```
These hints help the client decide when a tool can be called automatically.

#### Example – Python FastMCP tool
```python
from fastmcp import FastMCP
from pydantic import BaseModel, Field

mcp = FastMCP("MyServer")

class CreateIssueInput(BaseModel):
    title: str = Field(..., description="Issue title")
    body: str = Field(..., description="Issue description")
    repo: str = Field(..., description="Repository name, e.g. 'owner/repo'")

@mcp.tool
async def github_create_issue(data: CreateIssueInput) -> dict:
    """Create a GitHub issue and return its URL."""
    # Call GitHub API (auth handled by core client)
    resp = await client.post(f"/repos/{data.repo}/issues", json={"title": data.title, "body": data.body})
    if resp.status != 201:
        raise mcp.Error(f"GitHub returned {resp.status}: {await resp.text()}")
    issue = await resp.json()
    return {"url": issue["html_url"], "number": issue["number"]}
```

#### Example – TypeScript tool (Zod)
```typescript
import { server } from "@modelcontextprotocol/sdk";
import { z } from "zod";

const CreateIssueInput = z.object({
  title: z.string().describe("Issue title"),
  body: z.string().describe("Issue description"),
  repo: z.string().describe("Repository 'owner/repo'")
});

server.registerTool({
  name: "github_create_issue",
  inputSchema: CreateIssueInput,
  async handler(input) {
    const resp = await apiClient.post(`/repos/${input.repo}/issues`, input);
    if (resp.status !== 201) {
      throw new Error(`GitHub error ${resp.status}`);
    }
    return { url: resp.data.html_url, number: resp.data.number };
  }
});
```

### 2.4 Authentication & Authorization
- **FastMCP** – use `BearerAuthProvider` with JWKS URL, audience, and issuer.
- **TypeScript** – configure SDK client with OAuth token refresh logic.
- Scope tools with `readOnlyHint`, `destructiveHint`, etc., and enforce via middleware.

### 2.5 Middleware (optional)
```python
@mcp.middleware
async def rate_limit(ctx, next_handler):
    if ctx.rate_limiter.exceeded():
        raise ctx.Error("Rate limit exceeded")
    return await next_handler()
```
Add logging, request‑size limits, or custom header injection similarly.

### 2.6 Providers
- **LocalProvider** – default, registers decorators.
- **FileSystemProvider** – load tools from Python files on disk.
- **SkillsProvider** – bundle tools as a reusable skill package.
- **CustomProvider** – implement `load_component(name)` to fetch from a database or remote store.

---

## Phase 3 – Review & Test
1. **Static analysis** – run `mypy` (Python) or `tsc` (TypeScript) for type safety.
2. **Build** – `npm run build` (TS) or `python -m py_compile` (Python).
3. **MCP Inspector** –
   - TypeScript: `npx @modelcontextprotocol/inspector`
   - Python: `fastmcp inspect`
   Verify that all tools appear with correct schemas.
4. **Unit tests** – mock external APIs, assert error handling and pagination.
5. **Integration test** – run a full evaluation (see Phase 4).

---

## Phase 4 – Evaluation
1. Write **10 independent, read‑only** questions that require multiple tool calls.
2. Ensure each answer is a single string that can be compared verbatim.
3. Store questions in an XML file:
```xml
<evaluation>
  <qa_pair>
    <question>Find the latest release tag of the repository "modelcontextprotocol/mcp" on GitHub.</question>
    <answer>v2.3.1</answer>
  </qa_pair>
  <!-- more pairs -->
</evaluation>
```
4. Run the evaluation script provided by the SDK (e.g., `npm run eval` or `python -m fastmcp eval`).
5. Fix any failures, then re‑run until all pass.

---

## Integration with Claude Code Plugins
### Configuration files
- **Method 1 – `.mcp.json` (recommended)**
```json
{
  "myservice": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/my_server",
    "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
    "env": { "API_KEY": "${API_KEY}" }
  }
}
```
- **Method 2 – `plugin.json` `mcpServers` field**
```json
{
  "name": "my-plugin",
  "mcpServers": {
    "myservice": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/my_server",
      "args": []
    }
  }
}
```
### Server types
| Type | Transport | Typical auth |
|------|-----------|--------------|
| `stdio` | Child‑process stdin/stdout | Env‑var tokens |
| `sse` | Server‑Sent Events | OAuth (handled by Claude Code) |
| `http` | REST calls | Bearer token in headers |
| `ws` | WebSocket | Bearer token in headers |

### Tool naming convention
```
mcp__plugin_<plugin-name>_<server-name>__<tool-name>
```
Example: `mcp__plugin_asana_asana__create_task`.

### Pre‑allowing tools in commands
```markdown
---
allowed-tools:
  - "mcp__plugin_asana_asana__create_task"
  - "mcp__plugin_asana_asana__search_tasks"
---
```
Avoid wildcards (`*`) unless absolutely necessary.

### Security best practices
- Always use `https://` or `wss://` URLs.
- Store tokens in environment variables, never in JSON files.
- Document required env vars in the plugin README.
- Pre‑allow only the tools that the command truly needs.

### Error handling in plugins
- Detect connection failures and show a friendly message.
- If a tool returns an error, surface the actionable part to the user.
- Provide a fallback (e.g., manual entry) when the MCP server is unavailable.

---

## Checklist
- [ ] Read MCP spec and SDK docs.
- [ ] Choose language, transport, and authentication method.
- [ ] Define clear, prefixed tool names.
- [ ] Write Zod/Pydantic schemas with examples.
- [ ] Implement core utilities (API client, pagination, logging).
- [ ] Add `readOnlyHint`, `destructiveHint`, `idempotentHint` where appropriate.
- [ ] Register tools with `@mcp.tool` (Python) or `server.registerTool` (TS).
- [ ] Configure auth provider (`BearerAuthProvider` or OAuth client).
- [ ] Add middleware for rate limiting, logging, or custom checks.
- [ ] Run static type checks and build.
- [ ] Test with MCP Inspector.
- [ ] Write 10 evaluation questions and run the evaluation.
- [ ] Create `.mcp.json` (or `plugin.json` entry) for Claude Code plugins.
- [ ] Document required environment variables.
- [ ] Pre‑allow needed tools in command frontmatter.
- [ ] Verify HTTPS/WSS URLs and token handling.
- [ ] Test locally with `claude --debug` and `/mcp` command.
- [ ] Publish server and update plugin README.

## Related skills

Load these when the task spans more than this skill.

- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`hook-development`](../hook-development/SKILL.md) — Guide for creating, configuring, and debugging Claude Code plugin hooks and Hookify rules. Use when you need t…
- [`slash-command-development`](../slash-command-development/SKILL.md) — Defines how to create, configure, and organize Claude Code slash commands. Covers file locations, YAML frontma…
- [`skill-authoring`](../skill-authoring/SKILL.md) — Skill Authoring guides you through designing, writing, testing, evaluating, and refining Claude skills. Use it…
- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
- [`bright-data`](../bright-data/SKILL.md) — Provides step‑by‑step guidance for using Bright Data services – local unfancy‑search server, SERP API, Web Unl…
- [`claude-api`](../claude-api/SKILL.md) — Provides concise guidance for building, debugging, and optimizing Claude API applications using the Anthropic…
