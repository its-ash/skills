@REF:code-tour
§R{
  out:`.tours/<persona>-<focus>.tour`(CodeTour_JSON_only;¬modify_source);
  purpose:persona-targeted_narrative_walkthrough(what_looking_at→why_matters→next_path);
  use∈{code/onboarding/arch/PR/RCA/security_tour,"explain X"+reusable_artifact,engineer/reviewer_ramp-up,guided_sequence>summary};
  ¬use:{one-off_chat⇒answer_directly;prose_docs⇒edit_repo_docs([documentation](../SKILL.md));impl/refactor⇒implement;broad_onboarding_¬tour⇒[codebase-onboarding.md](codebase-onboarding.md)};
  drift_resilience:volatile_files⇒use_`pattern`_anchor(regex/content_match)∨set_VS_Code_`codetour.recordMode:"pattern"`(default=`"lineNumber"`)
}
§D{
  workflow:[
    1_discover:{read(README,pkg/app_entrypoints,dir_tree,configs,PR_changed_files);¬write_steps_before_understanding_code_shape},
    2_persona:{
      "onboarding"|"new joiner"⇒new-joiner(9-13_steps);
      "quick tour"|"vibe check"⇒vibecoder(5-8_steps);
      "architecture"⇒architect(14-18_steps);
      "tour this PR"⇒pr-reviewer(7-11_steps);
      "why did this break"⇒rca-investigator(7-11_steps);
      "security review"⇒security-reviewer(7-11_steps);
      "explain how this feature works"⇒feature-explainer(7-11_steps);
      "debug this path"⇒bug-fixer(7-11_steps)
    },
    3_verify_anchors:{∀file_exists;∀line∈range(1-based);exact_selection(1-based_line∧1-based_character);volatile_file⇒pattern_anchor;¬guess_lines},
    4_write:`.tours/<persona>-<focus>.tour`(deterministic,readable,schema_valid),
    5_validate:{∀path_exists;∀line|selection|pattern_valid;step[0]∈(file∨dir);ref_has_∀referenced_file;coherent_story(¬file_inventory)}
  ];
  ref_rule:{
    semantics:ref≠checked-out_branch⇒CodeTour_reads_from_git_rev_`ref`(¬disk)∨warns_on_mismatch;missing_file@`ref`⇒`"The editor could not be opened because the file was not found"`(comments_still_render);
    pr_tour⇒PR_branch(NEVER_base_e.g.`develop`/`main`;PR_adds_new_files_absent_on_base);
    onboarding|arch⇒reader_branch(often_`main`)∨omit_`ref`;
    unsure⇒omit_`ref`(reads_working_tree);
    verify:∀step.file_exists@chosen_`ref`
  };
  SMIG:{Situation:what_reader_sees;Mechanism:how_works;Implication:why_matters_for_persona;Gotcha:what_smart_reader_misses};
  arc:1_orientation→2_module_map→3_core_exec_path→4_edge_case|gotcha→5_closing(what_reader_can_now_do,¬recap)
}
§CFG{
  root:`"$schema":"https://aka.ms/codetour-schema"`,title,description,ref?,steps:[];
  vscode_setting:`"codetour.recordMode":"pattern"`(drift-safe_recording_vs_`"lineNumber"`);
  steps:{
    content(sparingly,usually_closing;NEVER_step[0]):`{"title","description"}`;
    directory(module_orient):`{"directory","title","description"}`;
    file_line(1-based_line):`{"file","line","title","description"}`;
    selection(1-based_line_AND_1-based_character):`{"file","selection":{"start":{"line":15,"character":1},"end":{"line":34,"character":1}},"title","description"}`;
    pattern(drift-safe_regex_or_line_match):`{"file","pattern","title","description"}`;
    uri(PR|issue|doc):`{"uri","title","description"}`
  }
}
§ANTI{
  flat_file_list⇒story_w/_step_dependency;
  generic_desc⇒concrete_code_path|pattern;
  guessed_anchors∨0-based_`selection.character`⇒verify_1-based_file+line+char_first;
  hardcoded_line_numbers_in_high-churn_files⇒use_`pattern`_anchor;
  excess_steps_on_quick_tour⇒cut_aggressively;
  step[0]_content-only⇒anchor_to_real_file|dir;
  persona_mismatch⇒write_for_actual_reader;
  PR_tour_w/_base_`ref`⇒use_PR_branch
}
§CHK{
  step_count∝(repo_size,persona_depth);
  directory=orientation∧file=substance;
  PR_tour⇒changed_files_first;
  monorepo⇒scope_to_relevant_pkgs;
  selection_indices_1-based∧pattern_matches_unique_line;
  closing=reader_capability,¬recap
}
§REL{
  [codebase-onboarding.md](codebase-onboarding.md):full_onboarding_guide;
  [code-review](../../code-review/SKILL.md):PR_review;
  https://github.com/microsoft/codetour
}
