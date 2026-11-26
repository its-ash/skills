@REF:figma
§REL{../SKILL.md:parent_workflow(load_first);../../frontend-development/SKILL.md:React/Next;../../typescript/SKILL.md:TS;../../screenshot/SKILL.md:capture;../../ux-research/SKILL.md:UX}
§WHEN{figma_URL|node_id,gen_framework_code_from_design,figma_MCP_avail,existing_DS}
§CFG:prereqs_setup{
  MCP:Dev_Mode(`https://mcp.figma.com/mcp`|Figma_Desktop_local);
  project:DTCG_tokens(←Figma_vars)+Code_Connect(when_present);
```bash
claude mcp add --transport http figma https://mcp.figma.com/mcp   # Claude Code
codex mcp add figma --url https://mcp.figma.com/mcp                 # Codex CLI
# complete OAuth login then restart client
```
  MCP_fail⇒pause→run_setup→resume
}
§PAT:workflow{
  1_id_node:{URL:`/design/<fileKey>/...?node-id=<nodeId>`(e.g.`https://figma.com/design/kL9xQn2VwM8pYrTb4ZcHjF/DesignSystem?node-id=42-15`⇒`fileKey=kL9xQn2VwM8pYrTb4ZcHjF`,`nodeId=42-15`);figma-desktop⇒open_file⇒`nodeId`_only};
  2_fetch:`get_design_context(fileKey="<fileKey>",nodeId="<nodeId>")`+`get_variable_defs`→map_tokens+Code_Connect;truncated⇒`get_metadata(fileKey="<fileKey>",nodeId="<nodeId>")`→child_ids→`get_design_context(fileKey="<fileKey>",nodeId="<childNodeId>")`;
  3_screenshot:`get_screenshot(fileKey="<fileKey>",nodeId="<nodeId>")`(keep_for_validation);
  4_assets:MCP_assets_endpoint;rules:{`localhost`_URL⇒use_direct,¬external_icon_pkgs,¬placeholder_when_real_src_exists};
  5_translate:MCP_output(React+TW)=blueprint¬final;TW_utils→project_DS_tokens;reuse_existing(btns,inputs,icons,layout);follow_project(routing,state,data-fetch,DS_dir,naming);
  6_parity:use_context_tokens;prefer_project_tokens(minimal_space/size_tweak_for_match);WCAG_2.2_AA(contrast,visible_focus,targets≥24px);¬hard-coded_vals(constants/tokens);
  7_validate_vs_screenshot:{layout(space/align/size),type(family/size/weight/lh),colors,states(hover/active/disabled),responsive(bp/constraints),assets(imgs/SVGs),a11y(contrast/ARIA)}⇒iterate_on_diff
}
§R{
  MCP_out=ref¬final_style;map_tokens_pre_code;reuse/extend_components(new⇔0_match);
  assets=MCP_only(¬ext_icon_libs);TS_types;¬inline_styles(unless_dynamic);
  @container_queries>viewport_bp_for_components;record_new_components/deviations_in_handoff
}
§CHK{MCP_configured+authed,fileKey+nodeId_ok,get_design_context_reviewed,screenshot_saved,assets_downloaded,TW→tokens,DS_components_reused,parity_validated,WCAG_2.2_AA_pass,lint+typecheck_pass,new_components+deviations_noted}
§ERR{
  truncated⇒get_metadata→fetch_children_individually;
  asset_load_fail⇒verify_MCP_endpoint+use_localhost_direct;
  token_mismatch⇒prefer_project_tokens+minimal_space_tweak;
  visual_diff⇒compare_side_by_side+check_tokens+realign_constraints
}
§URLS{https://developers.figma.com/docs/figma-mcp-server/,https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma}
