@REF:product-capability
§D{intent(PRD|roadmap|discussion|founder_note)→impl_ready_plan("what must be true before impl?");use⇔implicit_constraints∨multi_{svc|repo|team}∨unclear_{arch|data|lifecycle|policy}∨repeated_hidden_assumptions∨durable_artifact_req∨[product-strategy](../SKILL.md)=="build this"}
§CFG{artifact:if_exists(`PRODUCT.md`|`docs/product/`|program_spec_dir)⇒upd_there;else⇒ask_user(def:`docs/product/<capability>.md`);goal:durable_constraints(¬extra_stack)}
§R{¬invent_truth⇒mark_open_Qs;split(user_promises,impl_details);tag∈{fixed_policy,arch_preference,open};repo_conflict⇒state_explicitly(¬smooth_over);1_artifact>notes}
§PAT{
  inputs(min):{1:intent(issue,disc,PRD,roadmap,founder),2:curr_arch(docs,contracts,schemas,routes,wf),3:ctx(`PRODUCT.md`,design_docs,RFCs,migrations,op_model),4:delivery(auth,billing,compliance,rollout,backcompat,perf,review)};
  wf:1:restate(1stmt:{user/op,new_cap,changed_outcome};weak⇒drift);2:resolve_constraints({biz_rules,scope_bounds,invariants,trust_bounds,data_owner,lifecycle_trans,rollout/mig,fail/recovery});3:SRS_contract:{summary,non_goals,actors&surfaces,states&trans,I/O_ifaces,data_effects,sec/billing/policy,obs&op_reqs,blocking_Qs};4:handoff∈{ready_direct_impl|needs_arch([software-architecture](../../software-architecture/SKILL.md))|needs_prod_clarif};refs:{AC→[software-architecture/references/intent-driven-development.md](../../software-architecture/references/intent-driven-development.md),contracts→[backend-development/references/contract-first.md](../../backend-development/references/contract-first.md),TDD→[unit-testing-patterns](../../unit-testing-patterns/SKILL.md)};
}
§OUT{sections:[CAPABILITY(1para),CONSTRAINTS(rules,invariants,bounds),IMPLEMENTATION CONTRACT(actors,surfaces,states&trans,iface/data),NON-GOALS(excluded),OPEN QUESTIONS(blockers),HANDOFF(next_step&wf)]}
§CHK{prevents_mid_PR_surprises;durable(¬chat);cross_agent_reusable}
