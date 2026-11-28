@REF:review-output
§PAT[ConventionalComments]{
  fmt:`<label> [(decorations)]: <subject>\n[discussion]`;
  labels:{issue:bug|sec|logic_flaw,suggestion:concrete_improvement,question:clarify_intent,nitpick:trivial_non_blocking,praise:highlight_good_pattern,todo:small_required_action,thought:idea_for_later,chore:simple_task};
  decorations:{blocking,non-blocking,if-minor,security,perf,ux,test};
  ex_block:`issue (blocking, security): missing ownership check enables IDOR on GET /orders/:id`;
  ex_suggest:`suggestion (non-blocking): extract retry backoff helper for reuse`;
  ex_nit:`nitpick (non-blocking): prefer const over let for unchanged binding`;
}
§OUT{
  fields:File:Line·Severity·Label·Problem·Evidence·Fix·References;
  issue:"issue (blocking): [p]|Current:[code]|Suggested:```suggestion\n[code]\n```|Why:[r]|Ref:[CWE|OWASP25|ASVS5]";
  question:"question (non-blocking): [q]|Context:[why]|Suggestion:[opt]";
  praise:"praise: [what]—good because [why]";
  audit:"#Code Review Report|Scope:[PR|branch|codebase]|Range:[base..head]|Date|Summary:[APPROVE|REQUEST_CHANGES|COMMENT]|CI_Gates:[PASS/FAIL]|Findings(Critical,High,Medium,Low)|AI_&_Supply_Chain_Checks|Verified_clean|Unverified_areas(+why)";
  machine_fmt:SARIF_2.1.0(unified_SAST/SCA/secrets→GitHub_Code_Scanning|GitLab|AppSec);
}
§CHK{
  full_diff+files_rev;
  ticket_reqs+ctx_verified;
  chk(func,OWASP25_sec,AI_code,perf,qual,tests,docs,git,design);
  conventional_labels+decorations+evidence;
  blocking_vs_nonblocking_explicit;
  unverified_disclosed;
}
