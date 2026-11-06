# MCP Server Patterns

Build MCP servers with the official SDKs: tools, resources, prompts, Zod validation, tool annotations, and stdio or Streamable HTTP transport.

Current spec: 2025-11-25 and later. Transports: stdio (local) and Streamable HTTP (remote). HTTP+SSE is deprecated. Verify signatures against the [MCP docs](https://modelcontextprotocol.io) when the SDK major version changes.

## Core concepts

- **Tools**: actions the model invokes. Register with `registerTool()`. Give each an `inputSchema`, an `outputSchema` for structured results, and `annotations`.
- **Resources**: read-only data by URI. Register with `registerResource()`; use `ResourceTemplate` for parameterized URIs.
- **Prompts**: reusable templates the client surfaces. Register with `registerPrompt()`.
- **Elicitation** asks the user for input inside a tool call. **Sampling** requests a completion from the client. **Tasks** run long async jobs with progress and cancellation.
- **Annotations**: `readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`. Clients use them for permission prompts. Set them honestly.

## TypeScript example

```bash
npm install @modelcontextprotocol/sdk zod
```

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "my-server", version: "1.0.0" });

server.registerTool(
  "search_docs",
  {
    description: "Search project docs by keyword",
    inputSchema: { query: z.string().min(1), limit: z.number().int().max(50).default(10) },
    outputSchema: { hits: z.array(z.object({ path: z.string(), score: z.number() })) },
    annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  },
  async ({ query, limit }) => {
    const hits = await search(query, limit);
    return { content: [{ type: "text", text: JSON.stringify(hits) }], structuredContent: { hits } };
  },
);

await server.connect(new StdioServerTransport());
```

Remote: create one `StreamableHTTPServerTransport` per session behind a `/mcp` HTTP handler. Protect it with OAuth 2.1 (resource indicators, RFC 8707; protected resource metadata, RFC 9728). Keep tool and resource logic independent of transport.

## Python example

```python
from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations

mcp = FastMCP("my-server")

@mcp.tool(annotations=ToolAnnotations(readOnlyHint=True, idempotentHint=True))
def search_docs(query: str, limit: int = 10) -> list[dict]:
    """Search project docs by keyword."""
    return search(query, limit)

mcp.run(transport="stdio")  # or "streamable-http"
```

## Best practices

- Schema first: narrow inputs, typed outputs, one job per tool.
- Errors: return `isError: true` with a message the model can act on. No raw stack traces.
- Idempotency: prefer idempotent tools so retries are safe. Mark side effects with `destructiveHint`.
- Rate and cost: document limits in the tool description. Add timeouts.
- Security: least-privilege scopes, no secrets in tool output, treat inputs and fetched content as untrusted (tool poisoning, confused deputy).
- Versioning: pin the SDK version. Publish a `server.json` to the MCP Registry for discovery.
- Test with `npx @modelcontextprotocol/inspector`. Register locally with `claude mcp add` or `.mcp.json`.

## Official SDKs

TypeScript, Python, Go, Java, Kotlin, C#, Rust, Swift, PHP, Ruby, all under `github.com/modelcontextprotocol`.

## Related

- `references/mcp-dependency-review.md` — review MCP config for mutable package references
- `typescript/references/zod.md` — input schemas
