@REF:mcp-server-patterns
§SPEC{2025-11-25+;tx:stdio(local),StreamableHTTP(remote),¬HTTP+SSE(depr);https://modelcontextprotocol.io}
§CORE{
  Tools:`registerTool()`←{inputSchema,outputSchema,annotations};
  Resources:`registerResource()`(URI_ro),`ResourceTemplate`(param_URI);
  Prompts:`registerPrompt()`;
  Flows:{Elicitation(user_in_tool),Sampling(client_llm),Tasks(async+cancel)};
  Annotations:{readOnlyHint,destructiveHint,idempotentHint,openWorldHint}⇒perm_prompts
}
§TS{
  `npm install @modelcontextprotocol/sdk zod`;
  `McpServer`(@modelcontextprotocol/sdk/server/mcp.js),`StdioServerTransport`(@modelcontextprotocol/sdk/server/stdio.js),`z`(zod);
  `s=new McpServer({name,version})`;
  `s.registerTool(name,{description,inputSchema:{q:z.string().min(1),n:z.number().int().max(50).default(10)},outputSchema:{hits:z.array(z.object({path:z.string(),score:z.number()}))},annotations:{readOnlyHint:true,idempotentHint:true,openWorldHint:false}},fn→{content:[{type:"text",text:JSON.stringify(hits)}],structuredContent:{hits}})`;
  `await s.connect(new StdioServerTransport())`;
  remote:`StreamableHTTPServerTransport`/sess@/mcp;OAuth2.1(RFC8707,RFC9728);logic⊥tx
}
§PY{`FastMCP`(mcp.server.fastmcp),`ToolAnnotations`(mcp.types);`@mcp.tool(annotations=ToolAnnotations(readOnlyHint=True,idempotentHint=True))`→`fn(q:str,n:int=10)->list[dict]`;`mcp.run(transport="stdio"|"streamable-http")`}
§R{
  schema:narrow_in∧typed_out∧1_job/tool;err:`isError:true`+actionable∧¬stack;
  idemp:prefer;side_fx⇒destructiveHint;limits:doc_rate_cost+timeouts;
  sec:least_priv∧¬secrets_out∧untrusted(in,fetched)⇒guard(tool_poison,confused_deputy);
  ver:pin_SDK∧publish(server.json→MCP_Registry);test:`npx @modelcontextprotocol/inspector`;reg:`claude mcp add`|`.mcp.json`;
  SDKs@github.com/modelcontextprotocol:{TS,Py,Go,Java,Kotlin,C#,Rust,Swift,PHP,Ruby}
}
§REL{references/mcp-dependency-review.md;typescript/references/zod.md}
