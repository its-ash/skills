@REF:deslop
§REL{../SKILL.md:mandatory_post_Δ_pass}
§CMD{
  diff:`git diff main...HEAD`;
  verify[proj_tooling,¬invent]:{TS/JS:`npm run lint && npm run typecheck && npm test`,Py:`ruff check . && mypy . && pytest`,Go:`go vet ./... && go test ./...`}
}
§PAT[slop_rm_keep_Δ]{
  excess_cmt(¬human∨≠file_style,e.g.above_getUser())⇒del;
  overcheck(abnormal_try/catch|null_chk|val,esp_validated_paths)⇒del;
  type_escape(TS:`as any`,Py:`cast(Any, ...)`)⇒fix_type;
  inline_import(Py_in_fn)⇒top;
  style_drift(fmt|name|pat≠file)⇒match_file
}
§R{report:1-3_sent(e.g."Removed 3 inline comments, 1 unnecessary try/catch, moved 2 inline imports to top in user_service.py")}
§CHK[fix_failures_pre_done]{Goal:exact_req?;Files:importers∧importees∧tests∧shared_users?;Works:verified?;Clean:lint∧types_pass?;Edges:¬missed?;Deslop:diff_cleaned?}
