---
name: code-review
description: "AUTO_INVOKE(silent)⇔prompt∈{code_review,PR,merge_request,git_diff,lint,static_analysis,npm_audit,bug_hunt,vuln,code_smell,attack_surface,security_checklist,refactor,dep_update,breaking_change,test_coverage,CI_fail,review_comment,prod_readiness,LGTM,approve,blocker,click_path,blast_radius,Critical,High}|SUB:{code-review-feedback,click-path-audit,change-impact,verification-loop}"
---
@SKL:code-review
§R{
  goal:find_real_risk(Δ)∧report_by_severity+evidence;
  first⇒read({Δ_desc,linked_issues,reqs});
  diff≡(git diff <base>...HEAD)∧(truncated⇒read_∀_Δ_files)∧list_∀_Δ_files_pre_review;
  ∀file⇒map_attack_surface({user_input,DB_queries,auth_checks,session_state,external_calls,crypto});
  ∀Δ_file⇒run_sec_checklist;
  ∀suspect_issue⇒verify_in(surrounding_code∧tests)∧¬report_unverified_guess_as_fact;
  run_checks∈{npm test,npm run lint,npm audit,stack_equiv};
  order_findings:(sec→bugs→quality)¬(style∨format);
  ∀finding⇒{File:Line,Severity,Problem,Evidence,Fix,References};
  findings≡∅⇒state_so¬invent_issues;
  mode≡report_only¬modify_code_unless_asked;
  pre_conclude⇒list({files_reviewed,checks_done,unverified_areas});
  feedback≡specific+actionable∧uncertain⇒ask_Q(Have_you_considered...?);
  only_minor_issues⇒approve¬block_on_pref(goal:less_risk¬perfect_code);
}
§D{
  Δ∈{schema,API_contract,framework,hot_path,sec_code}⇒flag_senior_review∧load(change-impact)¬approve_on_diff_alone;
  large_diff⇒ask_split∧review(Critical∨High_first)¬line_by_line_nits_∀_files;
  many_findings⇒report(Critical∨High_first)∧track_rest(issues+owners)¬flat_list;
  suspect_issue⇒check({callers,guards,tests})¬report_wo_evidence;
  prod_readiness_Q⇒run_audit_table(review-checklist)¬diff_only_review;
  UI_action_does_nothing_post_refactor⇒load(click-path-audit)¬guess_from_component_code;
  receive_review_cmts⇒load(code-review-feedback)¬agree_wo_verification;
  sev≡Critical(exploit∨data_loss∨outage)⇒block_merge¬merge;
  sev≡High(wrong_behavior@main_path)⇒block_merge¬merge;
  sev≡Medium(edge_bug∨missing_test∨perf_risk)⇒fix⊕ticket¬ignore;
  sev≡Low(maintainability∨minor_clarity)⇒comment_only¬block_merge;
}
§REF{
  per_area_checklist(functionality,sec,perf,quality,tests,docs,design),prod_readiness_audit,pitfalls→references/review-checklist.md;
  cmt_shapes,audit_report_tpl,final_checklist→references/review-output.md;
  request_review∨handle_received_feedback→references/code-review-feedback.md;
  button_does_nothing∨wrong_UI_state_post_shared_store_refactor→references/click-path-audit.md;
  cross_module,migration,auth,public_iface_Δ,blast_radius→references/change-impact.md;
  pre_PR:build,types,lint,tests,sec_grep,PASS_FAIL_report→references/verification-loop.md;
}
§REL{
  ../secure-coding/SKILL.md:secrets,auth,input_val,injection_checks;
  ../unit-testing-patterns/SKILL.md:judge,write_missing_tests;
  ../systematic-debugging/SKILL.md:root_cause_confirmed_bug;
  ../clean-code/SKILL.md:naming,fn_design,deslop_diff;
}
