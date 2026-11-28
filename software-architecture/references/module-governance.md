@REF:module-governance
§STD{
  AGENTS.md:open_standard_under_Linux_Foundation_AAIF(Agentic_AI_Foundation,alongside_MCP_&_goose);vendor_neutral_repo_guidance(root+scoped_subdirs);
  budget:total_standing_instructions≤150-200_rules_for_reliable_adherence⇒keep_local_files_terse,scoped,pointer_based(¬bloated_prose)
}
§USE{
  ON:new_biz_mod(even_unnamed)∨doc_mod∨confirmed_resp_Δ∨auth_mod_Δ_needing(local_rules+links);
  OFF:bugfix∨style_Δ∨internal_refactor(same_bounds)∨new_dir|UI_comp_inheriting_parent;
  RO:design_talk∨audit⇒inspect+report(¬create_files);
  NOTE:intent≠bg_hook∧≠auth(unrelated_code|commit|push|biz_choices)
}
§FLOW{
  1:discover→read(proj|ancestor_rules,map,reqs,code,contracts);id(resp,non_resp,state_owner,consumers);dir_name≠bounded_ctx;surface_ambiguities(¬invent_biz);existing_bound_Δ⇒RO_impact_1st(../../code-review/references/change-impact.md:consumers+evidence,¬unrelated_wf);
  2:sep_rules→proj_owns(global,mod_nav,cross_mod);local`AGENTS.md`_owns_ONLY(resp,state_owner,pub_iface_ptrs,verif_entry);local¬waive_proj;reuse`CLAUDE.md`|active_harness(¬rename∨dup);parent_covers∧¬missing_local⇒link_parent(¬redundant_file);follow_explicit_local_entry_req;¬claim_auto_load_all_nested;
  3:owners→{
    terms/rels(`CONTEXT.md`|equiv,¬AGENTS;FE+BE_share;UI_rules_OK¬glossary/page):../../documentation/references/context-and-decisions.md;
    hard_decisions/rationale:architecture-decision-records.md;
    boundary_CI_enforcement:fitness-and-c4.md;
    cross_bound_contracts:../../backend-development/references/contract-first.md;
    nav+lifecycle(living_docs_gov,top_level_approval):../../documentation/SKILL.md;
    consumers+bound_Δ:../../code-review/references/change-impact.md∧module-regression.md
  };ref_only(¬copy_bodies);
  4:maintain→min_Δ(missing_local+confirmed_ctx);apply(../../documentation/SKILL.md)nav/lifecycle;¬empty_files(2file_quota);unimpl⇒`confirmed design, code unverified`(¬prose_consistency);
  5:verify→cmp(claimed_owner|iface|rule vs code|contracts|exec);enforce_module_bounds_with_CI_fitness_check(fitness-and-c4.md)when_present;contradict⇒report_owner(¬match_accidental_impl);rel_links_from(doc_dir,¬CWD);run(`lychee`|`markdown-link-check`)∨manual_FS(local,ctx,nav);chk_exit_code;fix+rerun(¬empty_targets);unchecked⇒`unverified`;biz_test_pass≠valid_links;same_name≠right_owner
}
§EX{
  "Impl inventory"⇒discover+local_new_rules_only+reuse(glossary,contract)+link_nav+verify(code,fitness,links);
  "Split payments?"⇒options+evidence(¬write,¬impl_auth);
  "Fix badge color"⇒fix_UI(¬AGENTS/CONTEXT/ADR);
  "Audit mod docs"⇒RO(links+semantic;missing≠create_auth)
}
§ANTI{AGENTS+CONTEXT_per_dir|FE_page;dup(global,glossary,contracts,ADR);rule_bloat>200_instructions;doc_chk=impl_proof;hooks|auto_nested_load_claim_without_wiring}
§DELIVER{paths,proj|mod_scope,Δ,verif_evidence,open_ownership_Qs;delivers_rules+ptrs(¬full_DDD)}
