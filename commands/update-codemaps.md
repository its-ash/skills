---
description: "Scan structure & generate token-lean architecture codemaps."
---
@CMD:update-codemaps
§FLOW{
1:scan→type∈{monorepo,single_app,lib,microservice}∧dirs∈{src/,lib/,app/,packages/}∧entries(`main.ts`,`index.ts`,`app.py`,`main.go`)
2:gen(`docs/CODEMAPS/`∨`.reports/codemaps/`):
`architecture.md`:sys_diagram,svc_bounds,data_flow
`backend.md`:API_routes,middleware,svc→repo
`frontend.md`:page_tree,comp_tree,state_flow
`data.md`:DB_tables,rels,migrations
`dependencies.md`:ext_svcs,3p_integrations,shared_libs
3:prev_exists⇒calc(Δ%)→§GATE
4:∀map:add(`<!-- Generated: YYYY-MM-DD | Files scanned: N | Token estimate: ~N -->`)
5:write(`.reports/codemap-diff.txt`,{added/rm/mod_files,new_deps,arch_Δ(routes,svcs),stale(docs≥90d)})
}
§GATE{
Δ>30%⇒show_diff∧ask_approval→overwrite
Δ≤30%⇒update_in_place
}
§R{
cap:<1000_tok/map
style:high_lvl_struct∧paths+sigs∧ASCII_flow∧¬{impl_details,code_blocks,prose}
when:post(major_feature∨refactor)
}
§OUT{
tpl:`# <Area> Architecture\n## Routes\n<METHOD /path → Ctrl.fn → Svc.fn → Repo.fn>\n## Key Files\n<path (role, N lines)>\n## Dependencies\n- <Name (purpose)>`
}
