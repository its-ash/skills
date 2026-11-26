---
description: "Multi-agent PR review (/code-review=checklist)."
argument-hint: "[pr-number | pr-url] [--focus=comments|tests|errors|types|code]"
---
@CMD:review-pr
§ARGS{in:$ARGUMENTS;pr:[pr-number|pr-url](∅⇒curr_PR);focus:[--focus=comments|tests|errors|types|code](∅⇒all)}
§FLOW{
1:`gh pr view`→PR,Δfiles,diff;
2:guidance:`AGENTS.md`,`CLAUDE.md`,lint,TS,conventions;
3:agents(¬focus⇒all):code=code-reviewer,comments=comment-analyzer,tests=pr-test-analyzer,errors=silent-failure-hunter,types=type-design-analyzer;
4:dedupe∧rank(severity);
5:emit_grouped
}
§GATE{conf≥80;Critical:bugs,sec,data_loss;Important:tests,quality,style;Advisory:if_req}
