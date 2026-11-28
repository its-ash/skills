@REF:mcp-server-patterns
§SPEC{
  ver:2026-07-28+(https://modelcontextprotocol.io);
  arch:stateless_req_resp@StreamableHTTP(dropped_mandatory_init_handshake∧sticky_sessions;self_describing_req[ver+caps]⇒round_robin/serverless/edge_friendly);
  tx:stdio(local),StreamableHTTP(remote),¬HTTP+SSE(depr);
  routing:HTTP_hdrs(`Mcp-Method`,`Mcp-Name`)⇒gateway_route+authz_pre_compute;
  cache:list/read_res←{`ttlMs`,`cacheScope`}(HTTP_Cache-Control_style⇒cache_`tools/list`_wo_active_stream)
}
§CORE{
  Tools:`registerTool()`←{inputSchema,outputSchema,annotations};
  Resources:`registerResource()`(URI_ro,+cache_hints),`ResourceTemplate`(param_URI);
  Prompts:`registerPrompt()`;
  Extensions:{
    Tasks(graduated_ext:long_running_async+poll/updates+cancel);
    Elicitation:{Form(structured_JSON_schema_in),URL(ext_domain_for_secrets/payments⇒¬in_MCP_client_payload)};
    MCP_Apps(SEP-1865:server_rendered_HTML_UI@sandboxed_iframe;prefetch+cache+sec_review_templates;actions→JSON-RPC_w/_audit+consent);
    Sampling(client_llm)
  };
  Annotations:{readOnlyHint,destructiveHint,idempotentHint,openWorldHint}⇒perm_prompts
}
§TS{
  sdk_v2(split_pkgs_replaces_monolithic_`@modelcontextprotocol/sdk`):`npm install @modelcontextprotocol/server zod`(client:`@modelcontextprotocol/client`;adapters:Express,Fastify,Hono,Cloudflare_Workers);
  schema:Standard_Schema(Zod_v4|Valibot|ArkType);
  `McpServer`(@modelcontextprotocol/server),`StdioServerTransport`,z(zod);
  `s=new McpServer({name,version})`;
  `s.registerTool(name,{description,inputSchema:{q:z.string().min(1),n:z.number().int().max(50).default(10)},outputSchema:{hits:z.array(z.object({path:z.string(),score:z.number()}))},annotations:{readOnlyHint:true,idempotentHint:true,openWorldHint:false}},fn→{content:[{type:"text",text:JSON.stringify(hits)}],structuredContent:{hits}})`;
  `await s.connect(new StdioServerTransport())`;
  remote:stateless_StreamableHTTP@/mcp(adapter:Hono|Fastify|Express|Workers);OAuth2.1+OIDC_Discovery+RFC8707(Resource_Indicators)+RFC9728(built_in_SDK_OAuth_helpers);logic⊥tx
}
§PY{
  sdk_v2:Python_3.11+∧native_type_hints⇒auto_input_schema(`FastMCP`∈mcp);
  `@mcp.tool(annotations=ToolAnnotations(readOnlyHint=True,idempotentHint=True))`→`fn(q:str,n:int=10)->list[dict]`;
  `mcp.run(transport="stdio"|"streamable-http")`;
  dev_cli:`uv run mcp dev server.py`(launches_server+interactive_MCP_Inspector);built_in_OAuth_helpers
}
§R{
  schema:narrow_in∧typed_out∧1_job/tool∧Standard_Schema;err:`isError:true`+actionable∧¬stack;
  idemp:prefer;side_fx⇒destructiveHint;limits:doc_rate_cost+timeouts;
  sec:least_priv∧¬secrets_out∧URL_mode_elicitation(secrets/pay)∧untrusted(in,fetched)⇒guard(tool_poison,confused_deputy);
  perf:emit(`ttlMs`,`cacheScope`)on_cacheable_lists;design_for_dynamic_tool_search(crisp_names+descriptions);
  ver:pin_SDK_v2∧publish(server.json→MCP_Registry);test:`uv run mcp dev`|`npx @modelcontextprotocol/inspector`;reg:`claude mcp add`|`.mcp.json`;
  SDKs@github.com/modelcontextprotocol:{TS,Py,Go,Java,Kotlin,C#,Rust,Swift,PHP,Ruby}
}
§REL{references/mcp-dependency-review.md;../../typescript/references/zod.md}
