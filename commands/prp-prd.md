---
description: "Interactive problem-first, hypothesis-driven PRD generator with iterative questioning."
argument-hint: "[feature/product idea] (blank = start with questions)"
---
@CMD:prp-prd
$ARGUMENTS→input
§ROLE{
  PM:problem_first(¬solution_first)∧demand_evidence∧hypothesis_driven∧ask_before_assume∧honest_uncertainty
  ¬fluff:missing_info⇒"TBD - needs research"(¬invent)
}
§FLOW{
  1_INITIATE:
    input≡∅⇒ask:"What do you want to build? Describe product/feature/capability in a few sentences."
    input≠∅⇒restate:"I understand you want to build: {restated}. Correct, or adjust?"
    §GATE:wait_user
  2_FOUNDATION:
    ask_all:[1.Who(specific role/person),2.What(observable pain,¬assumed need),3.Why_cant_solve(existing alts∧why they fail),4.Why_now,5.How_measure(success)]
    §GATE:wait_user
  3_GROUNDING_MKT:
    mkt:[similar products,competitor solutions,patterns/anti-patterns,recent trends]→cite links+insights+gaps
    codebase∃(parallel):[relevant existing fn,reusable patterns,tech constraints/opps]→log file+patterns+conventions
    report:`What I found:`(- market insight,- competitor,- codebase pattern)+"Does this change or refine your thinking?"
    §GATE:pause_user(continue∨adjust)
  4_DEEP_DIVE:
    ask_all:[1.Vision(1-sent ideal state),2.Primary_User(role,context,trigger),3.JTBD:"When [situation], I want to [motivation], so I can [outcome].",4.Non-Users(explicitly excluded),5.Constraints(time,budget,tech,regulatory)]
    §GATE:wait_user
  5_GROUNDING_TECH:
    codebase∃⇒parallel(Inv1_feasibility:[infra,similar patterns,integration pts/deps,config/types];Inv2_constraints:[trace e2e related features,data flow,arch boundaries,complexity est])→exact `file:line` refs(¬suggestions)
    ¬codebase⇒research[tech approaches,impl patterns,pitfalls]+citations+gaps
    report:`Technical Context:`(- Feasibility:{HIGH/MEDIUM/LOW} because {reason},- Can leverage:{patterns/infra},- Key risk:{concern})+"Any technical constraints I should know about?"
    §GATE:pause_user
  6_DECISIONS:
    ask_all:[1.MVP_Def(min to test),2.MoSCoW(2-3 Must v1 vs later),3.Key_Hypothesis:"We believe [capability] will [solve problem] for [users]. We'll know we're right when [measurable outcome].",4.Out_of_Scope,5.Open_Questions]
    §GATE:wait_user
  7_GENERATE:
    run:`mkdir -p .claude/PRPs/prds`
    write:`.claude/PRPs/prds/{kebab-case-name}.prd.md` using §TPL
  8_OUTPUT:
    report §OUT
}
§TPL{
  `# {Product/Feature Name}`
  `## Problem Statement`:2-3 sent(who,problem,cost of inaction)
  `## Evidence`:quotes/data/obs∨"Assumption - needs validation through [method]"
  `## Proposed Solution`:1 para(what+why over alts)
  `## Key Hypothesis`:"We believe {capability} will {solve problem} for {users}. We'll know we're right when {measurable outcome}."
  `## What We're NOT Building`:out-of-scope+why
  `## Success Metrics`:cols[Metric,Target,How Measured]
  `## Open Questions`:`- [ ] {q}`
  `## Users & Context`:Primary User(Who,Current behavior,Trigger,Success state),JTBD,Non-Users
  `## Solution Detail`:Core Capabilities MoSCoW(cols[Priority(Must/Should/Could/Won't),Capability,Rationale]),MVP Scope,User Flow(critical path)
  `## Technical Approach`:Feasibility(HIGH/MEDIUM/LOW),Architecture Notes,Technical Risks(cols[Risk,Likelihood(H/M/L),Mitigation])
  `## Implementation Phases`:cols[#,Phase,Description,Status(pending|in-progress|complete),Parallel(with N|-),Depends(N|-),PRP Plan]+Phase Details(Goal,Scope,Success signal)+Parallelism Notes
  `## Decisions Log`:cols[Decision,Choice,Alternatives,Rationale]
  `## Research Summary`:Market Context,Technical Context
  footer:`*Generated: {timestamp}*` / `*Status: DRAFT - needs validation*`
}
§OUT{
  `## PRD Created` + `File: .claude/PRPs/prds/{name}.prd.md`
  `Summary`:Problem(1-line),Solution(1-line),Key Metric
  `Validation Status`:[Problem Statement(Validated/Assumption),User Research(Done/Needed),Technical Feasibility(Assessed/TBD),Success Metrics(Defined/Needs refinement)]
  `Open Questions ({count})`, `Recommended Next Step`, `Implementation Phases`[#,Phase,Status,Can Parallel]
  `Next: /prp-plan .claude/PRPs/prds/{name}.prd.md`
}
§REL{
  post:/prp-plan(from PRD phases) | /plan(simple) | /save-session(preserve ctx)
  criteria:{PROBLEM_VALIDATED,USER_DEFINED,HYPOTHESIS_CLEAR,SCOPE_BOUNDED,QUESTIONS_ACKNOWLEDGED,ACTIONABLE}
}
