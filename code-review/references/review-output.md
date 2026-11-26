@REF:review-output
§OUT{
  fields:File:Line·Severity·Problem·Evidence·Fix·References;
  issue:"Issue:[p]|Current code:[code]|Suggested fix:[code]|Why:[r]";
  question:"Question:[q]|Context:[why]|Suggestion:[opt]";
  praise:"Nice![what]—good because[why]";
  audit:"#Code Review Report|Scope:[PR|branch|codebase]|Date|Summary:[rec]|Findings(Critical,High,Medium,Low)|Verified clean|Unverified areas(+why)"
}
§CHK{full_diff+files_rev;ctx+req_ok;chk(func,sec,perf,qual,tests,docs,git,design);prioritized+evidence;unverified_disclosed}
