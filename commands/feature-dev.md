---
description: "Guided feature dev: codebase understanding & architecture workflow"
---
@CMD:feature-dev
§FLOW{
1_discover: read_req ∧ id(reqs,constraints,AC) ∧ ask_if_ambig
2_explore: code-explorer→analyze(code,exec_paths,arch_layers,integ_pts,conv)
3_clarify: emit(findings) ∧ ask(design,edge_cases) → §GATE:wait(user)
4_arch: code-architect→blueprint → §GATE:wait(approval)
5_impl: follow(design) ∧ prefer(TDD) ∧ commits(small,focused)
6_review: code-reviewer→fix(critical,important) ∧ verify(cov)
7_summary: emit(built,followups_limits,test_instr)
}
§R{¬impl_before_understand ∧ ¬bypass_§GATE(3,4)}
