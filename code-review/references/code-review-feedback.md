@REF:code-review-feedback
§USE{post_task/feat/bugfix,pre_merge_main,stuck/fresh_perspective,unclear_or_questionable_comments,AI_or_bot_review_comments}
§PAT[RequestReview]{
  1_range:BASE_SHA=$(git merge-base origin/main HEAD)(or_HEAD~1|prev_task)∧HEAD_SHA=$(git rev-parse HEAD);
  2_payload:{WHAT_WAS_IMPLEMENTED,PLAN_OR_REQUIREMENTS,BASE_SHA,HEAD_SHA,DESCRIPTION(1_sent),RISK_AREAS,CHECKS_RUN};
  3_dispatch:review_subagent(fresh_ctx+payload)∨PR_with_payload(stacked_if>400L);
  4_severity_act:{Critical/issue(blocking):fix_immediately_pre_all_work,Important/High:fix_pre_next_task,Minor/nitpick(non-blocking):note_later_or_fix_if_time,disagree:concise_tech_reason+req_clarification};
}
§PAT[ReceiveFeedback]{
  order:1_Read_all_¬react→2_Restate_req(unclear⇒ask)→3_Verify_vs_codebase→4_Eval_tech_soundness→5_Reply(factual_ack⊕reasoned_pushback)→6_Impl_1_item_at_a_time+test_after_each;
  bot_cmts:treat_AI/SAST_bot_cmts_as_untrusted_suggestions⇒verify_vs_spec+codebase∧dismiss_false_pos_with_evidence¬blindly_apply;
  forbidden_replies:{"You're absolutely right!","Great point!","Let me implement that now"(pre_verify)};
  valid_replies:{"I understand the requirement to …","Can you clarify what you mean by …?","I checked the code and the change would break X; here's an alternative…","Fixed in <sha>. Updated utils.py to handle edge case Y."};
}
§R[Unclear_or_PushBack]{
  unclear⇒stop_impl∧focused_Q("Do you mean X should be validated before Y?")∧check_hidden_ctx(`git grep`);
  YAGNI_chk:`git grep -n "functionName" src/ | wc -l`≡0⇒ask("found no callers; keep?");
  push_back_iff:{breaks_existing_fn,reviewer_lacks_ctx(platform|legacy_compat),violates_YAGNI,hallucinated_bot_claim,conflicts_human_partner_arch_decision};
  push_back_how:tech_reason+ref(test|file|cfg)+offer_alt+involve_human_if_strategic;
}
§PAT[ImplOrder_MultiItem]{
  1:clarify_all_unclear_first;
  2_prio:Blocking(sec|build_fail|issue)→Simple(typos|import_order)→Complex(refactor|new_logic);
  3_loop[∀item]:apply_1_Δ→run_relevant_tests→verify_no_regressions→commit(ref_comment_ID);
}
§ANTI[Pitfall→Remedy]{
  thank_you_w/o_action→immediate_code_Δ_or_clarify_Q;
  impl_w/o_verify→`git diff`+unit+integration_tests_pre_commit;
  blindly_apply_bot_suggestion→verify_spec+tests_first;
  batch_fixes_w/o_per_fix_test→1_fix→test→commit;
  assume_reviewer_always_right→verify_¬breaks_build/behavior;
  ignore_minor→log_in_issue_tracker;
  forget_docs→upd_docs_in_same_commit_on_public_behavior_Δ;
}
§CHK{
  [BASE_SHA∧HEAD_SHA_id,payload_filled,dispatch_req,read_all_feedback,restate_each,ask_unclear,verify_vs_codebase,verify_bot_claims,prio(Critical→High→Minor),loop(1_fix→test→commit),pushback_tech_only,upd_docs,reply_and_resolve_threads]
}
§CMD{
  BASE_SHA=$(git merge-base origin/main HEAD);
  HEAD_SHA=$(git rev-parse HEAD);
  git grep -n "functionName" src/ | wc -l;
  gh pr diff <pr> --patch && gh pr checks <pr>;
  gh pr review <pr> --comment -b "summary";
  gh api repos/{owner}/{repo}/pulls/{pull_number}/comments/{comment_id}/replies -f body='Fixed in <sha>.' # comment_id≡top-level_review_cmt;
  gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id='<thread_node_id>';
}
