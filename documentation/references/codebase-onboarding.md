@REF:codebase-onboarding
§R{
  purpose:analyze_unfamiliar_repo→Onboarding_Guide+concise_starter_`AGENTS.md`(universal_default)⊕`CLAUDE.md`/`GEMINI.md`(when_requested);
  use∈{first_agent_setup,new_team/repo_joiner,"help me understand this codebase","generate AGENTS.md"|"generate CLAUDE.md","onboard me"|"walk me through this repo"};
  upkeep⇒[documentation](../SKILL.md)∧[living-docs-governance.md](living-docs-governance.md);
  guided_walkthrough⇒[code-tour.md](code-tour.md);
  bloat_rule:starter_harness≤100_lines∧non_inferable_only(exact_cmds,boundaries,non_linter_convs,doc_signposts)¬auto_dump_manifest_facts;
  variants:{
    "Onboard me"⇒P1-P4→Guide(chat)+starter_`AGENTS.md`(or_existing_repo_harness);
    "Generate AGENTS.md|CLAUDE.md"⇒P1-P3→harness_file_only;
    "Update AGENTS.md|CLAUDE.md"⇒read_existing+P1-P3→merge∧prune_bloat∧mark_Δ
  }
}
§D{
  P1_recon(run_parallel,Glob/Grep ¬Read_all):{
    existing_harness:[`AGENTS.md`,`CLAUDE.md`,`GEMINI.md`,`.claude/rules/`,`*.instructions.md`,`.cursor/rules/*.mdc`,`.cursorrules`(flag_deprecated),`.github/copilot-instructions.md`];
    manifests:[`package.json`,`go.mod`,`Cargo.toml`,`pyproject.toml`,`uv.lock`,`bun.lock`,`deno.json`,`pom.xml`,`build.gradle*`,`Gemfile`,`composer.json`,`mix.exs`,`pubspec.yaml`];
    frameworks:[`next.config.*`,`nuxt.config.*`,`angular.json`,`vite.config.*`,`astro.config.*`,django_settings,flask_app_factory,fastapi_main,rails_config];
    entrypoints:[`main.*`,`index.*`,`app.*`,`server.*`,`cmd/`,`src/main/`];
    dir_tree:depth≤2,ignore∈{`node_modules`,`vendor`,`.git`,`dist`,`build`,`__pycache__`,`.next`,`.venv`,`target`};
    config_tooling:[`biome.json*`,`eslint.config.*`,`.eslintrc*`,`oxlint*`,`.prettierrc*`,`tsconfig.json`,`Makefile`,`mise.toml`,`Dockerfile`,`compose.yaml`,`docker-compose*`,`.github/workflows/`,`.env.example`,CI_configs];
    tests:[`tests/`,`test/`,`__tests__/`,`*_test.go`,`*.spec.ts`,`*.test.*`,`pytest.ini`,`pyproject.toml`,`vitest.config.*`,`jest.config.*`]
  };
  P2_arch:{
    stack:{langs+version_constraints,frameworks+major_libs,DBs+ORMs,pkg_mgrs/build_tools,CI/CD};
    pattern:{monolith|monorepo|microservices|serverless,FE/BE_split|fullstack,API∈{REST,GraphQL,gRPC,tRPC}};
    key_dirs:top-level_dir→purpose(non-obvious_only);
    boundaries:forbidden_imports,read-only_generated_dirs,module_ownership;
    data_flow:1_request:entry(router|handler|controller)→validation(middleware|schemas|guards)→logic(services|models|use_cases)→DB(ORM|raw_sql|repos)
  };
  P3_conventions:{
    naming:{file∈{kebab-case,camelCase,PascalCase,snake_case},component/class,test∈{`*.test.ts`,`*.spec.ts`,`*_test.go`}};
    code:{error∈{try/catch,Result,error_codes},DI_vs_direct_imports,state_mgmt,async∈{promises,async/await,channels,actors}};
    git:{branch_naming(recent),commit_style(recent),PR∈{squash,merge,rebase}};
    git_edge:0_commits∨shallow(`git clone --depth 1`)⇒skip∧note `"Git history unavailable or too shallow to detect conventions"`
  };
  P4_outputs:{
    guide:`# Onboarding Guide: [Project Name]`→[`## Overview`(2-3_sent:what+who),`## Tech Stack`(Layer/Tech/Version),`## Architecture`(connections+boundaries),`## Key Entry Points`(paths+roles),`## Directory Map`(non_obvious_dir→purpose),`## Request Lifecycle`(entry→response),`## Conventions`(naming,errors,tests,git),`## Common Tasks`(exact_dev,test,lint,migrate,build_cmds),`## Where to Look`(intent→path)];
    harness_md(`AGENTS.md`|`CLAUDE.md`,≤100L):`# AGENTS.md`→[`## Build & Test Commands`(exact_scripts),`## Architecture & Boundaries`(forbidden_deps,read-only_dirs,entrypoints),`## Non-Obvious Conventions`(patterns_linters_dont_catch),`## Docs & Decisions`(signposts→Map,Status,ADRs)]
  }
}
§CHK{
  Glob+Grep_first;Read_selectively_only_on_ambiguous_signals;
  config≠code⇒trust_code;
  existing_harness⇒read_first,enhance/merge,preserve_human_rules,call_out_Δ;
  if_`.cursorrules`_found⇒recommend_migration_to_`.cursor/rules/*.mdc`∨`AGENTS.md`;
  guide_scannable≤2min(details_stay_in_code);
  unknown_convention⇒flag_explicitly(e.g.`"Could not determine test runner"`),¬guess;
  verify_starter_harness_in_clean_session_against_1_small_task
}
§ANTI{
  harness_file>100_lines(causes_attention_dilution∧+20%_token_cost);
  restating_every_dep_or_obvious_manifest_fact_agents_infer_from_code;
  explaining_obvious_dirs(e.g.`src/`);
  copying_README_or_full_ADRs_into_guide_or_harness;
  creating_duplicate_`CLAUDE.md`+`GEMINI.md`+`AGENTS.md`_prose_instead_of_canonical_`AGENTS.md`+thin_links
}
