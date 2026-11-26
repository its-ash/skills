---
description: "Create self-contained feature implementation plan from codebase analysis and pattern extraction"
argument-hint: <feature description | path/to/prd.md>
---

@CMD:prp-plan
§R:
  golden_rule: capture_all_codebase_knowledge_NOW ∧ self_contained_single_pass_plan ∧ ¬questions_during_impl
§FLOW:
  0_DETECT($ARGUMENTS):
    `*.prd.md`∨(`*.md`∧contains`"Implementation Phases"`)⇒PRD: `cat "$PRD_PATH"` → parse `Implementation Phases` → find `pending`∧deps(`complete`) → select_next_eligible_pending → extract(name,desc,acceptance_criteria,deps,scope/constraints) → use_phase_desc; `∅`pending⇒report_all_phases_complete
    other_file_path⇒read_for_context ∧ treat_as_free_form
    free_form_text⇒1_PARSE
    ∅⇒ask_user_what_feature_to_plan
  1_PARSE:
    identify: What(deliverable), Why(user_value), Who(target_user/sys), Where(codebase_fit)
    user_story: `As a [type of user], I want [capability], So that [benefit].`
    complexity: Small(1f,isolated,¬deps;1-3f,<100L) | Medium(multi-f,existing_patterns,minor_new;3-10f,100-500L) | Large(cross-cutting,new_patterns,ext_int;10+f,500+L) | XL(arch_Δ,new_subsys,migration;20+f,consider_split)
    §GATE(ambiguity): STOP∧ask_user iff vague_deliverable ∨ undefined_success_criteria ∨ multi_valid_interpretations ∨ major_tech_unknowns (¬guess)
  2_EXPLORE(grep+find+read):
    8_categories: 1.Similar_Implementations 2.Naming_Conventions 3.Error_Handling 4.Logging_Patterns 5.Type_Definitions 6.Test_Patterns(paths,naming,setup/teardown,assertions) 7.Configuration(files,env,flags) 8.Dependencies(pkgs,imports,internal)
    5_traces: 1.Entry_Points 2.Data_Flow 3.State_Changes 4.Contracts(interfaces/APIs/protocols) 5.Patterns(repo/service/controller/etc)
    compile_discovery_ref: (Category, File:Lines, Pattern, Key Snippet)
  3_RESEARCH:
    ext_libs∨APIs∨unfamiliar_tech⇒web_search(official_docs,examples,best_practices,version_gotchas) → fmt:`KEY_INSIGHT|APPLIES_TO|GOTCHA`
    internal_only⇒skip + note:"No external research needed — feature uses established internal patterns."
  4_DESIGN:
    UX_applicable⇒ASCII Before/After boxes + Interaction Changes(Touchpoint,Before,After,Notes)
    internal_only⇒"Internal change — no user-facing UX transformation."
  5_ARCHITECT:
    define: Approach, Alternatives Considered(+why_rejected), Scope(WILL_build), NOT Building(OUT_OF_SCOPE)
  6_GENERATE:
    `mkdir -p .claude/PRPs/plans`
    write `.claude/PRPs/plans/{kebab-case-feature-name}.plan.md` with template sections:
      `# Plan: [Feature Name]`
      `## Summary`(2-3sent) | `## User Story` | `## Problem → Solution`
      `## Metadata`(Complexity, Source PRD[path|"N/A"], PRD Phase[name|"N/A"], Estimated Files)
      `## UX Design`(Before/After[ASCII|"N/A — internal change"], Interaction Changes[Touchpoint,Before,After,Notes])
      `## Mandatory Reading`(Priority[P0 critical|P1 important|P2 reference], File, Lines, Why)
      `## External Documentation`(Topic, Source, Key Takeaway)
      `## Patterns to Mirror`(`NAMING_CONVENTION`,`ERROR_HANDLING`,`LOGGING_PATTERN`,`REPOSITORY_PATTERN`,`SERVICE_PATTERN`,`TEST_STRUCTURE` — each `// SOURCE: [file:lines]` + real_snippet)
      `## Files to Change`(File, Action:`CREATE|UPDATE`, Justification)
      `## NOT Building`(out_of_scope_items)
      `## Step-by-Step Tasks`: `### Task N: [Name]` → `ACTION`,`IMPLEMENT`,`MIRROR`,`IMPORTS`,`GOTCHA`,`VALIDATE`
      `## Testing Strategy`: Unit Tests(Test,Input,Expected Output,Edge Case?) + Edge Cases Checklist(`Empty input`,`Maximum size input`,`Invalid types`,`Concurrent access`,`Network failure (if applicable)`,`Permission denied`)
      `## Validation Commands`: Static Analysis, Unit Tests, Full Test Suite, Database Validation(if_applicable), Browser Validation(if_applicable), Manual Validation(checklist) — each `[bash cmd]` + `EXPECT: ...`
      `## Acceptance Criteria`(all_tasks_done,validation_cmds_pass,tests_written+passing,0_type_err,0_lint_err,matches_UX_if_applicable)
      `## Completion Checklist`(patterns,error_handling,logging,test_patterns,¬hardcoded_vals,docs_if_needed,¬scope_creep,self_contained)
      `## Risks`(Risk,Likelihood,Impact,Mitigation) | `## Notes`
§GATE(pre_finalize_verification):
  context_completeness: all_files∧naming_examples∧error_patterns∧test_patterns∧deps
  impl_readiness: ∀task_has(ACTION,IMPLEMENT,MIRROR,VALIDATE) ∧ ¬extra_search ∧ imports_specified ∧ GOTCHAs_noted
  pattern_faithfulness: real_snippets(¬invented) ∧ real_SOURCE(file:lines) ∧ covers(naming,errors,logging,data_access,tests) ∧ indistinguishable_code
  validation_coverage: static_analysis ∧ tests ∧ build
  ux_clarity: before_after|N/A ∧ interaction_Δ ∧ UX_edge_cases
  no_prior_knowledge_test: unfamiliar_dev_implements_using_ONLY_plan(¬search,¬questions); fail⇒add_missing_context
§OUT:
  save: `.claude/PRPs/plans/{kebab-case-feature-name}.plan.md`
  if_PRD_input: update phase status `pending`→`in-progress` ∧ add plan_path_ref
  report:
    ## Plan Created
    File: `.claude/PRPs/plans/{kebab-case-feature-name}.plan.md`
    Source PRD: [path|"N/A"] | Phase: [name|"standalone"] | Complexity: [level] | Scope: [N files, M tasks]
    Key Patterns: [top 3] | External Research: [topics|"none needed"] | Risks: [top|"none identified"]
    Confidence Score: [1-10] (single-pass likelihood)
    Next: `/prp-implement .claude/PRPs/plans/{name}.plan.md` | `/plan` | `/prp-prd`
