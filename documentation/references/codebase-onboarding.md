@REF:codebase-onboarding

§R{
  purpose:analyze unfamiliar repo→Onboarding Guide+starter `CLAUDE.md`;
  use∈{first Claude Code setup,new team/repo joiner,"help me understand this codebase","generate CLAUDE.md","onboard me"|"walk me through this repo"};
  upkeep⇒[documentation](../SKILL.md)(living docs governance);
  guided_walkthrough⇒[code-tour.md](code-tour.md);
  variants:{
    "Onboard me"⇒Phases 1-4→Guide(chat)+`CLAUDE.md`(root);
    "Generate CLAUDE.md"⇒Phases 1-3→`CLAUDE.md` only;
    "Update CLAUDE.md"⇒read existing `CLAUDE.md`+Phases 1-3→merge(mark Δ)
  }
}

§D{
  P1_recon(run parallel,Glob/Grep ¬Read all):{
    manifests:[package.json,go.mod,Cargo.toml,pyproject.toml,pom.xml,build.gradle,Gemfile,composer.json,mix.exs,pubspec.yaml];
    frameworks:[next.config.*,nuxt.config.*,angular.json,vite.config.*,django settings,flask app factory,fastapi main,rails config];
    entrypoints:[main.*,index.*,app.*,server.*,cmd/,src/main/];
    dir_tree:depth≤2,ignore∈{node_modules,vendor,.git,dist,build,__pycache__,.next};
    config_tooling:[.eslintrc*,.prettierrc*,tsconfig.json,Makefile,Dockerfile,docker-compose*,.github/workflows/,.env.example,CI configs];
    tests:[tests/,test/,__tests__/,*_test.go,*.spec.ts,*.test.js,pytest.ini,jest.config.*,vitest.config.*]
  };
  P2_arch:{
    stack:{langs+version_constraints,frameworks+major_libs,DBs+ORMs,build_tools/bundlers,CI/CD};
    pattern:{monolith|monorepo|microservices|serverless,FE/BE split|fullstack,API∈{REST,GraphQL,gRPC,tRPC}};
    key_dirs:top-level dir→purpose;
    data_flow:1 request:entry(router|handler|controller)→validation(middleware|schemas|guards)→logic(services|models|use_cases)→DB(ORM|raw_sql|repos)
  };
  P3_conventions:{
    naming:{file∈{kebab-case,camelCase,PascalCase,snake_case},component/class,test∈{*.test.ts,*.spec.ts,*_test.go}};
    code:{error∈{try/catch,Result,error_codes},DI vs direct imports,state_mgmt,async∈{callbacks,promises,async/await,channels}};
    git:{branch_naming(recent),commit_style(recent),PR∈{squash,merge,rebase}};
    git_edge:0_commits∨shallow(`git clone --depth 1`)⇒skip∧note `"Git history unavailable or too shallow to detect conventions"`
  };
  P4_outputs:{
    guide:`# Onboarding Guide: [Project Name]`→[`## Overview`(2-3 sentences:what+who),`## Tech Stack`(Layer|Tech|Version),`## Architecture`(diagram/connections),`## Key Entry Points`(paths+roles),`## Directory Map`(dir→purpose),`## Request Lifecycle`(entry→response),`## Conventions`(naming,errors,tests,git),`## Common Tasks`(dev,test,lint,migrate,build cmds),`## Where to Look`(intent→path)];
    claude_md:`# Project Instructions`→[`## Tech Stack`,`## Code Style`(naming+patterns),`## Testing`(test_cmd,test_pattern,coverage_cmd?),`## Build & Run`(Dev,Build,Lint),`## Project Structure`(dir→purpose),`## Conventions`(commit,PR,errors)]
  }
}

§CHK{
  Glob+Grep first;Read selectively only on ambiguous signals;
  config≠code⇒trust code;
  existing `CLAUDE.md`⇒read first,enhance/merge,preserve project rules,call out Δ;
  guide scannable≤2min(details stay in code);
  unknown convention⇒flag explicitly(e.g.`"Could not determine test runner"`),¬guess
}

§ANTI{
  `CLAUDE.md`>100 lines(cap≤100);
  listing every dep(list only code-shaping deps);
  explaining obvious dirs(e.g.`src/`);
  copying README(guide must add structural insight)
}
