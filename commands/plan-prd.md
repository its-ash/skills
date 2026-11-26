---
description: "Generate lean, problem-first PRD and hand off to /plan."
argument-hint: "[product/feature idea] (blank = start with questions)"
---
@CMD:plan-prd
§ARGS{$ARGUMENTS:idea?}
§R{
  scope∈{frame_problem+users,success_criteria+scope,open_questions+risks,write:".claude/prds/{name}.prd.md"}
  scope∉{arch,files,patterns,impl_tasks,impl_plan⇒/plan}
  ∀impl_detail⇒cut→/plan
  missing⇒"TBD — needs validation via {method}"∧¬invent_req
  gate:1_Qset/phase→wait(user∨"skip")→next(¬nested_loops∧¬parallel_research)
}
§FLOW{
  1_FRAME:($ARGUMENTS≡∅⇒Q("Build what? 1-2s"))⊕($ARGUMENTS≠∅⇒restate(1s)∧Q("Understand: {restated}. Correct?"))→Q[1:Who(role/seg),2:What(observable_pain),3:Why_unsolved,4:Why_now]→wait
  2_GROUND:Q("Evidence problem real/worth solving?(quotes,tickets,metrics,obs,workarounds)")→wait;(none⇒Evidence="Assumption — needs validation via {user research | analytics | prototype}")
  3_DECIDE:Q[1:Hypothesis("We believe {capability} will {solve problem} for {users}. We'll know we're right when {measurable outcome}."),2:MVP,3:Out_of_scope,4:Open_questions]→wait
  4_GEN:"mkdir -p .claude/prds"→write:".claude/prds/{kebab-case-name}.prd.md"(§TPL)→emit(§OUT)
}
§TPL{
```markdown
# {Product / Feature Name}
## Problem
{2-3s: who, problem, cost}
## Evidence
- {quote|data|obs OR "Assumption — needs validation via {method}"}
## Users
- **Primary**: {role, context, trigger} | **Not for**: {excluded}
## Hypothesis
We believe **{capability}** will **{solve problem}** for **{users}**. We'll know we're right when **{measurable outcome}**.
## Success Metrics
- {primary} | Target: {number} | Measured: {method}
## Scope
**MVP**: {min to test} | **Out of scope**: {item} — {why deferred}
## Delivery Milestones
<!-- Status: pending|in-progress|complete -->
- #1 {name}: {user-visible change} | Status: pending | Plan: —
- #2 {name}: {user-visible change} | Status: pending | Plan: —
## Open Questions
- [ ] {question}
## Risks
- {risk} | Likelihood: {L} | Impact: {I} | Mitigation: {M}
---
*Status: DRAFT — requirements only. Implementation planning pending via /plan.*
```
}
§GATE{PROBLEM_CLEAR,USER_CONCRETE(≠"users"),HYPOTHESIS_TESTABLE,SCOPE_BOUNDED,NO_IMPLEMENTATION_DETAIL}
§OUT{
  report:"PRD created: .claude/prds/{name}.prd.md | Problem:{1L} Hypothesis:{1L} MVP:{1L} | Validation: Problem={validated|assumption}, Users={concrete|generic — refine}, Metrics={defined|TBD} | Open questions:{n} | Next: /plan .claude/prds/{name}.prd.md"
  rel:{/plan <prd-path>,unit-testing-patterns/references/test-driven-development.md,/pr}
}
