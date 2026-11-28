@REF:architecture-decision-records
§LOC{`docs/adr/NNNN-decision-title.md`∨`docs/decisions/NNNN-decision-title.md`(match_existing_repo_dir;default=`docs/adr/`)}
§USE{
  explicit∈{"let's record this decision","ADR this","we decided to...","the reason we're doing X instead of Y is..."};
  read:"why did we choose X?";
  choice∈{framework,library,pattern,database,API_design,infra,security}∨planning_tradeoffs
}
§SCOPE_DIFF{
  RFC:pre_decision→propose_cross_team/org_direction+gather_debate(Draft→In_Discussion→Accepted|Withdrawn);
  Design_Doc:pre_build→specify_how_feature/service_is_built(data_flow,APIs,rollout;Draft→Reviewed→Implemented|Superseded);
  ADR:post_decision→immutable_why_record+tradeoffs_next_to_code(Proposed→Accepted→Deprecated|Superseded);
  lifecycle:major_shift⇒RFC(consensus)→Design_Doc(how)→ADRs(atomic_why_per_key_choice)
}
§STD{
  MADR_4.0.0:default_structured_std;YAML_frontmatter(`status`,`date`,`decision-makers`,`consulted`,`informed`[RACI]);4_variants(`full`,`minimal`,`bare`,`bare-minimal`);single_line_placeholders;SSG_ready(Jekyll,Hugo,Astro,MkDocs);
  Nygard:ultra_lightweight_alt(Context,Decision,Consequences);
  Y_Statement:1_sentence_summary_or_inline_code_justification(`In the context of [context], facing [forces], we decided for [option] and against [alts], to achieve [quality], accepting [tradeoffs].`)→graduate_to_MADR_when_multi_alt_analysis_needed
}
§FMT{
  ```markdown
  ---
  status: proposed | accepted | rejected | deprecated | superseded by ADR-NNNN
  date: YYYY-MM-DD
  decision-makers: [names/roles]
  consulted: [SMEs/two-way]
  informed: [teams/one-way]
  ---
  # ADR-NNNN: [Short Noun-Phrase Title]
  ## Context and Problem Statement
  [2-5 sentences: forces, constraints; ≤10 lines]
  ## Decision Drivers
  - [driver 1, e.g. latency, team skills, compliance]
  ## Considered Options
  - Option 1: [Name] — Pros:[...] | Cons:[...] | Why not:[...]
  - Option 2: [Name] — Pros:[...] | Cons:[...]
  ## Decision Outcome
  Chosen option: "[Name]", because [justification].
  ### Consequences
  - Good: [...] | Bad: [...] | Risks & mitigation: [...]
  ### Confirmation
  [How enforced/verified: CI fitness function test, review gate, or metric]
  ```
}
§FLOW{
  capture:{
    1:init_if_missing(`¬exists(adr_dir)`⇒ask_confirm_first→create(`README.md`(idx_hdr)+`template.md`),¬auto_create);
    2:identify_decision→3:gather_context_&_drivers→4:doc_alts_&_rejections→5:state_consequences_&_confirmation→
    6:assign_num(scan_`adr_dir`+1)→
    7:present_draft⇒write(`NNNN-decision-title.md`)⇔explicit_approval(decline⇒discard,¬write);
    8:append(`README.md`)
  };
  read:{
    1:`¬exists(adr_dir)`⇒reply("No ADRs found in this project. Would you like to start recording architectural decisions?");
    2:scan(`README.md`)→3:read_matching_ADRs(present_Context+Decision+Status);
    4:no_match⇒reply("No ADR found for that decision. Would you like to record one now?")
  };
  tree:`docs/adr/{README.md,0001-use-postgresql.md,...,template.md}`;
  idx_cols:`| ADR([NNNN](NNNN-slug.md)) | Title | Status | Date |`
}
§SIG{
  explicit:["Let's go with X","We should use X instead of Y","The trade-off is worth it because...","Record this as an ADR"];
  implicit(suggest_only,¬auto_create):{compare_2_fw_or_libs→conclusion,DB_schema_choice+rationale,arch_pattern_choice(mod_monolith_vs_micro,REST_vs_GraphQL),authN/authZ_strategy,deploy_infra_after_eval}
}
§TOOLS{
  CLI:`adr-tools`(init/new/TOC);MADR_4.0_templates;
  lint:`markdownlint`(validate_MADR_headings_&_frontmatter);YADR(YAML/JSON_schema_validation);
  publish:MkDocs|Jekyll|Astro|Log4brains|Backstage
}
§R{
  do:{be_specific("Use PostgreSQL"¬"use a DB"),record_why(>what),include_rejected_alts,honest_consequences,link_fitness_test_in_Confirmation,≤2min_read,present_tense("We use X")};
  anti:{trivial_decisions(naming,formatting),essays(context>10_lines),omit_alts("just picked it"),unmarked_backfill(note_original_date),stale_ADRs(link_superseding_ADR),using_ADR_as_RFC_or_impl_spec}
}
§STATE{proposed→(accepted⊕rejected)→(deprecated⊕superseded by ADR-NNNN)}
§CAT{tech_choices(fw,lang,DB,cloud),arch_patterns(mod_monolith/micro,vertical_slice,event_driven,CQRS),API_design(REST/GraphQL/gRPC,versioning,auth),data_modeling(schema,isolation,cache),infra(deploy,CI/CD,observability),security(auth,encryption,secrets),testing(fw,fitness_fns,E2E/int),process(branching,review,release)}
§REL{
  planning⇒suggest_ADR;
  fitness-and-c4.md:enforce_structural_ADRs_in_CI;
  ../../code-review/SKILL.md:flag_arch_PRs_sans_ADR;
  ../../documentation/SKILL.md:link_ADR_index_in_nav
}
