@REF:mcp
§CMD{
  srv:`npx -y @angular/cli mcp`;
  flags:{`--read-only`:¬mutating_tools;`--local-only`:offline_only;`--experimental-tool`|`-E`:enable_exp_tool}
  ex:`"args": ["-y", "@angular/cli", "mcp", "--read-only", "-E", "build", "-E", "modernize"]`
}
§API{
  default_tools:{
    `ai_tutor`:interactive_AI_tutor;
    `find_examples`:authoritative_modern_Angular_examples;
    `get_best_practices`:Angular_Best_Practices_Guide(standalone,typed_forms,etc);
    `list_projects`:apps+libs_from_`angular.json`;
    `onpush_zoneless_migration`:analyze+plan_`OnPush`_migration(zoneless_prereq);
    `search_documentation`:search_`https://angular.dev`
  }
  exp_tools(req_`-E`):{
    `build`:`ng build`(one-off);
    `devserver.start`:async_`ng serve`(immediate_return);
    `devserver.stop`:stop_devserver;
    `devserver.wait_for_build`:latest_build_logs_of_running_devserver;
    `e2e`:run_e2e_tests;
    `modernize`:migrate_code_to_latest_practices+syntax;
    `test`:run_unit_tests
  }
}
§CFG{
  base:`{"command":"npx","args":["-y","@angular/cli","mcp"]}`;
  paths:{
    Antigravity_IDE:`.antigravity/mcp.json`→`{"mcpServers":{"angular-cli":<base>}}`;
    Gemini_CLI:`.gemini/settings.json`→`{"mcpServers":{"angular-cli":<base>}}`;
    Cursor:`.cursor/mcp.json`|`~/.cursor/mcp.json`→`{"mcpServers":{"angular-cli":<base>}}`;
    VS_Code:`.vscode/mcp.json`→`{"servers":{"angular-cli":<base>}}`
  }
}
