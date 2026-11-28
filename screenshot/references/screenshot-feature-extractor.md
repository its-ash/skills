@REF:screenshot-feature-extractor
§REL{
  ../SKILL.md:parent;
  ../../ux-research/SKILL.md:personas,journey_maps,heuristic_eval;
  ../../product-strategy/SKILL.md:PRD,competitor_benchmark;
  ../../design/SKILL.md:UI_components,design_system,a11y;
  ../../frontend-development/SKILL.md:React,Next.js,TS,Vue,Angular;
}

§R{
  trigger⇔competitor_screenshots∨mockup→PRD∨batch_screens→feature_list∨visual_gap_analysis;
  fmt:- [ ] markdown_checkbox(small_executable_user_visible_tasks);
  scope≡what_to_build¬how(user_visible_behavior_only);
  evidence_tagging⇒distinguish([VISIBLE]_in_pixels)vs([ASSUMED]_inferred_state_needing_confirmation);
  multi_screen⇒deduplicate∧link_screen_refs(file_basename);
  competitive⇒flag([TARGET_UNIQUE],[COMPETITOR_GAP],[PARITY]);
  privacy⇒scrub(emails,names,API_keys,tokens,account_IDs)≺writing_markdown;
  reviewer_gate⇒∀visible_feature∈final_checklist∧zero_vague_tasks;
}

§D{
  ambiguous_screenshot_without_context⇒ask_user_or_tag([ASSUMED])¬invent_hidden_rules;
  mixed_products_in_batch⇒verify_same_product⊕group_and_label_per_product¬blend_specs;
  subagents_available⇒run_3_analyzers_parallel;else⇒run_3_focused_passes_seq;
  generic_task("Improve UI")⇒rewrite_specific("Add category filter dropdown to product list view");
  multi_viewport(desktop+mobile)⇒extract_responsive_layout_and_nav_deltas¬treat_as_duplicates;
}

§PAT{
  pipeline:{
    1_collect:read(∀images)∧record(path,viewport,notes)∧verify|label_product;
    2_analyze(3_parallel_subagents⊕3_seq_passes):{
      UI_Analyzer:{components,layout_grid,states(empty|loading|error|disabled),a11y_cues(landmarks,labels,contrast,focus)}→JSON;
      Interaction_Analyzer:{controls,nav_flows,modals_drawers,validation_feedback,state_transitions}→JSON;
      Business_Analyzer:{user_goals,domain_entities,CRUD_actions,permissions_roles,filters_sorts}→JSON
    };
    3_synthesize:merge(3_JSONs)→deduplicate→group_by_flow→docs/plans/<YYYY-MM-DD>-<product>-features.md;
    4_review:audit(completeness,specificity,zero_PII,zero_tech_prescriptions)→patch_checklist;
    5_deliver:write(file)∧concise_summary(counts,gaps,open_questions)
  };
}

§ANTI{
  ¬emit(tech_stack,libs,frameworks,DB_schemas,code_architecture)_in_feature_checklist;
  ¬hallucinate_unshown_backend_rules_as_facts(tag_[ASSUMED]_or_ask);
  ¬transcribe_PII_or_secrets_from_captured_screens_into_docs;
  ¬emit_generic_checkboxes("Make responsive","Polish dashboard","Handle errors");
}

§CHK{
  [ ] collected_all_files+notes∧verified|labeled_products;
  [ ] completed_3_analysis_passes(UI,Interaction,Business)→JSON;
  [ ] tagged_[VISIBLE]_vs_[ASSUMED]∧flagged_competitive_gaps_if_applicable;
  [ ] scrubbed_PII_and_removed_tech_stack_prescriptions;
  [ ] ran_reviewer_pass→100%_visible_features_mapped;
  [ ] wrote_docs/plans/<YYYY-MM-DD>-<product>-features.md∧summarized;
}
