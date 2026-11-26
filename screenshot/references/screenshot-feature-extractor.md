@REF:screenshot-feature-extractor

§WHEN{competitor_screenshots|mockup→PRD|batch_screens→feature_list|visual_gap_analysis}

§FLOW{
  1:collect→read_files∧record(path,notes)∧verify_same_product(⊕label_per_product);
  2:parallel_Task_tool(3){
    UI_Analyzer:UI_components+layout+design_patterns→JSON;
    Interaction_Analyzer:user_interactions+nav_flows+state_transitions→JSON;
    Business_Analyzer:business_functions+data_entities+domain_logic→JSON
  };
  3:Synthesizer(seq)→merge_3_JSONs→docs/plans/<YYYY-MM-DD>-<product>-features.md;
  4:Reviewer(seq)→verify(completeness,quality)⇒emit_corrections_if_issues;
  5:output→write(- [ ] list)∧concise_user_summary
}

§R{
  fmt:- [ ] markdown_checkbox;
  scope:small_executable_tasks∧what_to_build¬how(user_visible_only);
  ¬{tech_stack,libs,frameworks,code_decisions,unverified_assumptions(ask_if_lacks_desc),generic_tasks("Improve UI"→"Add filter dropdown to product list view")};
  multi_screen⇒deduplicate; competitive⇒flag(unique_target_features,competitor_gaps);
  reviewer⇒∀extracted_feature∈final_checklist
}

§CHK{
  [ ] gather_files+notes; [ ] verify|label_products;
  [ ] run_3_analyzers_parallel(Task)→3_JSONs;
  [ ] run_synthesizer→run_reviewer;
  [ ] write docs/plans/<date>-<product>-features.md; [ ] summarize
}

§REL{
  ../../ux-research/SKILL.md:personas,journey_maps;
  ../../frontend-development/SKILL.md:React,Next.js,TS,MUI,TanStack_Query
}
