@REF:architecture-decision-records
§LOC{`docs/adr/NNNN-decision-title.md` (Nygard_lightweight_AI_adapted)}
§USE{
  explicit∈{"let's record this decision","ADR this","we decided to...","the reason we're doing X instead of Y is..."};
  read:"why did we choose X?";
  choice∈{framework,library,pattern,database,API_design}∨planning_tradeoffs
}
§FMT{
  ```markdown
  # ADR-NNNN: [Decision Title]
  **Date**: YYYY-MM-DD | **Status**: proposed | accepted | deprecated | superseded by ADR-NNNN | **Deciders**: [...]
  ## Context
  [2-5 sentences: situation, constraints, forces; ≤10 lines]
  ## Decision
  [1-3 sentences, present tense]
  ## Alternatives Considered
  ### Alternative N: [Name] — Pros:[...] | Cons:[...] | Why not:[...]
  ## Consequences
  ### Positive / ### Negative / ### Risks ([risk + mitigation])
  ```
}
§FLOW{
  capture:{
    1:init_if_missing(`¬exists("docs/adr/")`⇒ask_confirm_first→create(`docs/adr/README.md`(idx_hdr)+`template.md`),¬auto_create);
    2:identify_decision→3:gather_context→4:doc_alts_&_rejections→5:state_consequences→
    6:assign_num(scan_`docs/adr/`+1)→
    7:present_draft⇒write(`docs/adr/NNNN-decision-title.md`)⇔explicit_approval(decline⇒discard,¬write);
    8:append(`docs/adr/README.md`)
  };
  read:{
    1:`¬exists("docs/adr/")`⇒reply("No ADRs found in this project. Would you like to start recording architectural decisions?");
    2:scan(`docs/adr/README.md`)→3:read_matching_ADRs(present_Context+Decision);
    4:no_match⇒reply("No ADR found for that decision. Would you like to record one now?")
  };
  tree:`docs/adr/{README.md,0001-use-nextjs.md,...,template.md}`;
  idx_cols:`| ADR([NNNN](NNNN-slug.md)) | Title | Status | Date |`
}
§SIG{
  explicit:["Let's go with X","We should use X instead of Y","The trade-off is worth it because...","Record this as an ADR"];
  implicit(suggest_only,¬auto_create):{compare_2_fw_or_libs→conclusion,DB_schema_choice+rationale,arch_pattern_choice(monolith_vs_micro,REST_vs_GraphQL),authN/authZ_strategy,deploy_infra_after_eval}
}
§R{
  do:{be_specific("Use Prisma ORM"¬"use an ORM"),record_why(>what),include_rejected_alts,honest_consequences,≤2min_read,present_tense("We use X")};
  anti:{trivial_decisions(naming,formatting),essays(context>10_lines),omit_alts("just picked it"),unmarked_backfill(note_original_date),stale_ADRs(link_superseding_ADR)}
}
§STATE{proposed→accepted→(deprecated⊕superseded by ADR-NNNN)}
§CAT{tech_choices(fw,lang,DB,cloud),arch_patterns(monolith/micro,event_driven,CQRS),API_design(REST/GraphQL,versioning,auth),data_modeling(schema,norm,cache),infra(deploy,CI/CD,monitoring),security(auth,encryption,secrets),testing(fw,coverage,E2E/int),process(branching,review,release)}
§REL{
  planning⇒suggest_ADR;
  ../../code-review/SKILL.md:flag_arch_PRs_sans_ADR;
  ../../documentation/SKILL.md:link_ADR_index_in_nav
}
