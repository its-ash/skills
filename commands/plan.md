---
description: "Restate reqs, assess risks, create phased plan; WAIT for user CONFIRM before code."
argument-hint: "[feature description | path/to/*.prd.md]"
---
@CMD:plan
§ARGS{$ARGUMENTS:[feature_desc|path/to/*.prd.md]?}
§R{
  exec:inline_by_default∧¬subagent(unless_user_asks)
  planner_agent:only_on_explicit_req(unavailable⇒inline∧¬err)
  use_when:{new_feat,arch_change,complex_refactor,multi_file_Δ,ambiguous_req}
  revise_cmds:{"modify: [changes]","different approach: [alt]","skip phase X and do phase Y first"}
}
§GATE{
  CRITICAL:¬write_code_until_explicit_confirm("yes"|"proceed"|affirmative)
  after_artifact:report_path∧WAIT_CONFIRM
}
§FLOW{
  mode:{
    `path/to/name.prd.md`⇒PRD_mode:read_prd→pick_next_pending(Delivery Milestones|Implementation Phases)→"mkdir -p .claude/plans"→write:".claude/plans/{kebab-case-name}.plan.md"(§TPL)→if(Delivery Milestones)upd_row(pending→in-progress,Plan=plan_path)→if(".claude/PRPs/prds/"∧Implementation Phases)read_as_is(¬migrate)
    other_*.md⇒ref_mode:read_context→inline_plan
    free_text⇒conv_mode:inline_plan
    ∅⇒clarify:Q("what to plan?")
  }
  steps:[
    1:restate_reqs,
    2:ground_patterns(repo_avail⇒capture_top_ex{Naming,Error_handling,Logging,Data_access,Tests}@path:line;none⇒state_explicitly∧¬invent),
    3:break_into_phases(actionable_steps,deps),
    4:assess_risks+blockers,
    5:estimate_complexity(High|Medium|Low),
    6:present_plan(inline|artifact)→WAIT_CONFIRM("Proceed with this plan? (yes/no/modify)")
  ]
}
§TPL{
```markdown
# Plan: {Feature Name}
**Source PRD**: {path} | **Selected Milestone**: {milestone|phase} | **Complexity**: {Small|Medium|Large}
## Summary
{2-3 sentences}
## Patterns to Mirror
- Naming @ `path:line`: {desc}
- Errors @ `path:line`: {desc}
- Tests @ `path:line`: {desc}
## Files to Change
- `path`: CREATE|UPDATE|DELETE — {why}
## Tasks
### Task 1: {name}
- **Action**: {what} | **Mirror**: {pattern} | **Validate**: {cmd}
## Validation
```bash
{project-specific validation commands}
```
## Risks
- {risk} | Likelihood: {L} | Mitigation: {M}
## Acceptance
- [ ] All tasks complete | [ ] Validation passes | [ ] Patterns mirrored, not reinvented
```
}
§OUT{
  inline_sections:[Requirements Restatement,Implementation Phases,Dependencies,Risks(HIGH|MEDIUM|LOW),Estimated Complexity(per_area+Total),WAITING FOR CONFIRMATION]
  rel:{unit-testing-patterns/references/test-driven-development.md,/build-fix,/code-review,/pr,/prp-pr,/plan-prd,.claude/PRPs/(/prp-plan,/prp-implement)}
}
