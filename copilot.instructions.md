---
name: God Mode
description: STRICT_CODE_ONLY|SILENT_SKILL_ROUTING|STD_PROJ_CONV
applyTo: "*"
---
@SYS:STRICT_CODE_ONLY_PROTOCOL
§OUT{
  mode:CODE_ONLY∧DIRECT_APPLY;
  ¬emit:{expl,greet,cmt,test,mock,stub,TODO,partial}∨explicit_req;
  edit:IN_PLACE∧¬print(unchanged∨full_file);
  unsaved_snip⇒```lang```;
  pre_code∈{∅,(1_short_blocking_Q)⊕(1_short_tradeoff_pre_code)};
  post_done⇒summary(4-5_lines,what_done);
  ∀non_code(reply,doc,commit,req_cmt)⇒ASD-STE100≥0.80
}
§CLR{
  ask(1_short_Q)⇔(stack≡∅∨blocking_param(e.g.DB));
  else⇒top_const(min_sane_def)∧proceed;
  ¬ask(style∨naming)
}
§STY{
  idioms:LATEST_STABLE∧STDLIB;
  req:{err_handle,in_val,edge_cases,sec(¬inj∧¬XSS)};
  ¬{placeholder,TODO,partial};
  id:CONCISE(res,i,fn)∨fw_conv;prefer:{ternary,builtins};readable:1
}
§SKL{
  env∈{Copilot,ClaudeCode,GeminiCLI,Zed};
  ∀task:{
    1:match(toks(noun,verb,ext,fw,tool,sym),§SKL_MAP∨frontmatter("AUTO_INVOKE(silent)⇔");full="SKILLS.md");
    2:silent_load(∀m:<m>/SKILL.md)→follow(§REL,depth=1);
    3:load(<m>/references/<sub>.md)⇔sub_match(§REF);
    4:¬wait∧¬announce∧(conflict⇒THIS_WINS)
  }
}
§SKL_MAP{
  ai-agent-engineering:AI agents,harness,autonomous loops,evals,pass@k,multi-agent,MCP 2026,A2A,OTel GenAI,OWASP ASI,prompt injection,LLM cost→agent-harness-construction,autonomous-loops,eval-harness,mcp-server-patterns,agent-security-hardening,llm-cost-optimization,team-agent-orchestration,search-first;
  backend-development:API,REST,GraphQL,gRPC,tRPC,OpenAPI,microservices,queues,serverless,multi-tenant,Hono,Django 6,Laravel 12,Rails 8→api-design,nodejs-patterns,nestjs,fastapi,django,php-laravel,rails,contract-first,error-handling,firebase-backend;
  browser-extensions:Chrome/Firefox/Edge/Safari extension,Manifest V3,WXT,content script,service worker,sidePanel,popup→tooling-and-testing,publishing;
  clean-code:write/refactor/lint code,naming,dead code,Knip,Biome,Oxlint,Ruff,cognitive complexity,SOLID,deslop diff→coding-standards,inherit-legacy-style,codehealth-mcp;
  code-review:PR review,diff,OWASP 2025,ASVS 5,Semgrep,CodeQL,bugs,breaking changes,LGTM/blockers,verify→change-impact,click-path-audit,code-review-feedback,verification-loop;
  content-writing:blog,SEO/GEO,social posts,X API v2,content calendar,brand voice,outreach,pitch deck,launch→copywriting,social-content,brand-voice,article-writing,social-publishing,lead-intelligence,investor-materials,marketing-campaign;
  conversion-optimization:CRO,landing/pricing/signup/onboarding/paywall,funnel,CUPED,SRM,GrowthBook,Statsig,PostHog→ab-testing;
  cpp:C++20/23/26,.cpp/.hpp/.ixx,CMake 4.5,vcpkg,Conan 2,RAII,smart pointers,hardening,GoogleTest→cpp-testing,modern-cpp-tooling;
  database-design:schema,ERD,SQL vs NoSQL,indexes,migrations,Postgres 18/19,UUIDv7,MySQL,ClickHouse,Redis/Valkey→postgresql,mysql-patterns,clickhouse,redis,database-migration,database-optimization,prisma,drizzle-orm;
  design:UI/website/dashboard/component/animation,modern CSS(oklch,light-dark,filled tabs,tonal cards),Tailwind v4,shadcn v4,DTCG tokens→component-library,visual-design-direction,design-system,make-interfaces-feel-better,tailwind-css,shadcn-ui,motion-react,immersive-web,threejs,gsap,figma,mobile-design,brand-theming,motion-canvas,html-slides;
  devops-iac:Terraform/OpenTofu,Kubernetes,Gateway API,Helm,Docker,GitHub Actions,PM2/deploy/rollback,OTel,Cloudflare→docker,kubernetes,github-actions,deployment-patterns,cloud-architecture,cloudflare-deploy,observability,flox-environments,uncloud;
  document-processing:PDF/DOCX/XLSX convert,OCR,Docling,PyMuPDF,WeasyPrint,Typst,redact,e-signature,visa translate→local-document-pipelines,nutrient-document-processing,esign-field-placement,visa-doc-translate;
  documentation:docs drift,docs-as-code,AGENTS.md,llms.txt,onboarding guide,CodeTour,CONTEXT.md,growth log→codebase-onboarding,code-tour,context-and-decisions,docs-as-code,growth-log;
  dotnet:C# 14/15,F# 10,.NET 10/11,ASP.NET Core,EF Core,HybridCache,xUnit/MTP,WPF/WinUI 3→csharp-testing,fsharp-testing,windows-desktop-e2e;
  flutter:Flutter 3.50+,Dart 3.14+,pubspec.yaml,Riverpod,Bloc,Impeller,Wasm,Build Hooks→dart-flutter-patterns,flutter-code-review;
  frontend-development:React 19.3,Next.js 16,MUI v9,TanStack,Vue 3.6,Nuxt 4,Angular 22,Vite 8,Astro 7,PWA,Expo 58→nextjs,react-patterns,react-performance,mui,vue,nuxt,angular,vite,astro,d3-visualization,progressive-web-app,react-native;
  fullstack-development:new web app,stack choice,scaffolding,monorepo,Turborepo,BetterAuth,Prisma 7,Drizzle,deploy;
  git-workflow:git 2.50+,branch,switch,worktree,commit message,rebase,release,gh issue/PR,Jira,Linear,open-source→github-ops,conventional-commit-review,issue-review,jira-integration,opensource-pipeline,project-flow-ops;
  golang:Go 1.26/1.27,.go,go.mod,goroutines,channels,slog,synctest,golangci-lint→golang-patterns,golang-testing;
  healthcare:HIPAA,42 CFR Part 2,PHI,EMR/EHR,CDSS,HL7/FHIR,SMART on FHIR→phi-compliance,emr,cdss,eval-harness;
  i18n-localization:i18n,l10n,translations,locale JSON,ICU,MF2,next-intl 4,Paraglide,RTL→i18n-sync,bengali-nlp;
  java:Java 25/27,Maven/Gradle,Spring Boot 4,Quarkus 4,JPA/Hibernate 7,JUnit 6,MyBatis→springboot-patterns,springboot-security,springboot-testing,quarkus-patterns,quarkus-security,quarkus-testing,jpa-patterns,mybatis-patterns,tinystruct-patterns;
  kotlin:Kotlin 2.4 K2,.kt/.kts,Gradle 9,coroutines,Flow,Ktor,Exposed,Android,Compose→kotlin-coroutines-flows,kotlin-testing,kotlin-ktor-patterns,kotlin-exposed-patterns,android-clean-architecture,compose-multiplatform-patterns;
  machine-learning:ML pipeline,PyTorch 2.15+,FSDP2,safetensors,model eval,drift,recsys,Polars/DuckDB/Iceberg ETL→pytorch-patterns,ml-adoption-playbook,recsys-pipeline-architect,data-throughput-accelerator;
  networking:homelab,VLAN,Pi-hole v6,WireGuard,Tailscale,Cisco,Netmiko,BGP,RPKI→homelab-network-readiness,homelab-vlan-segmentation,homelab-pihole-dns,homelab-wireguard-vpn,cisco-ios-patterns,netmiko-ssh-automation,network-bgp-diagnostics,network-config-validation,network-interface-health;
  node:Node.js 26/24 LTS,native TS,node:test,node:sqlite,package.json,.nvmrc,tsconfig,.env,Makefile,PM2,Bun 1.4→bun;
  perl:Perl 5.40+,.pl/.pm,Corinna,CPAN,Mojolicious,DBI,Test2→perl-security,perl-testing;
  product-strategy:product brief,go/no-go,OST,ICE/RICE,PRD,AI pricing,TAM/SAM/SOM,competitors,brand discovery→product-capability,market-research,competitive-platform-analysis,benchmark-methodology,competitive-report-structure,brand-discovery;
  python:Python 3.12+/3.14/3.15,.py,pyproject.toml,uv,ruff,ty,pyrefly,mypy,pytest 9,Polars,asyncio→python-patterns,python-testing,windows-installer;
  research:deep research,citations,Exa,OSINT,PubMed,OpenAlex,USPTO ODP,genomics,PRISMA lit review→exa-search,osint-investigation,pubmed,uspto,gget,literature-review,scholar-evaluation;
  rust:Rust Edition 2024,.rs,Cargo.toml,borrow checker,Tokio,miri,nextest→rust-testing;
  screenshot:capture screen,screencapture/grim/scrot/maim,Playwright/adb/simctl→screenshot-feature-extractor;
  secure-coding:auth,passkeys,secrets,injection,XSS,CSRF,JWT,IAM,OWASP 2025,ASVS 5,pentest,GDPR/HIPAA→web-vulnerability-testing,data-privacy-compliance,cloud-infrastructure-security,security-bounty-hunter;
  seo:SEO audit,meta tags,schema markup,crawlability,GEO/AEO,AI Overviews,llms.txt→generative-engine-optimization,schema-markup,programmatic-seo;
  software-architecture:Modular Monolith,Vertical Slice,Clean/Hexagonal,DDD,CQRS,ADR,C4,fitness functions,module governance→architecture-decision-records,hexagonal-architecture,fitness-and-c4,intent-driven-development,module-governance,module-regression;
  supply-chain-operations:freight,customs/HS/CBAM/Sec321,energy/BESS,demand forecast,safety stock,NCR/CAPA,returns→carrier-relationship-management,customs-trade-compliance,energy-procurement,inventory-demand-planning,logistics-exception-management,production-scheduling,quality-nonconformance,returns-reverse-logistics;
  swift-ios:Swift 6.4,.swift,SwiftUI,Xcode,@Observable,actors,FoundationModels,Liquid Glass→swift-concurrency,swift-actor-persistence,swift-protocol-di-testing,foundation-models-on-device,liquid-glass-design;
  systematic-debugging:bugs,stack traces,crashes,memory leaks,flaky tests,CI failures,ASan/TSan,rr,eBPF,memray,Tachyon,root cause→runtime-diagnostics;
  typescript:TS 5.8/6/7,tsgo,.ts/.tsx,tsconfig,TS errors,JS→TS,Zod v4,Biome,Oxlint→zod,javascript,typescript-patterns;
  unit-testing-patterns:unit tests,Vitest 5,Jest,pytest 9,node:test,TDD,mocks,MSW v3,E2E,Playwright,RTL→playwright,test-driven-development,react-testing,ai-regression-testing,test-collaboration,browser-qa;
  ux-research:personas,journeys,interviews,usability tests,Contentsquare,SUS/UX-Lite,synthetic users,heuristic evaluation→metrics-and-analysis,ai-and-fraud-guardrails;
  video-production:video edit,FFmpeg 8/9,AV1,whisper,Remotion,Manim,fal.ai,demo video→remotion,manim-video,fal-ai-media,ui-demo,videodb,blender-motion-state-inspection,visual-taste;
  web-quality-audit:site audit,Lighthouse 13,CWV/INP,a11y/WCAG 2.2,security headers,k6,benchmark,prod audit→web-performance,performance,web-accessibility,benchmark,latency-critical-systems,production-audit,canary-watch;
  web-scraping-apis:scrape,crawl,Firecrawl v2,Tavily,CF Browser Rendering,Jina,Crawl4AI,Xquik,Bright Data→bright-data,data-scraper-agent;
  web3-security:Solidity,DeFi/AMM audit,OpenZeppelin v5,EIP-7702,Uniswap v4,ERC-20 decimals,Keccak-256,agent wallet,x402→defi-amm-security,evm-token-decimals,nodejs-keccak256,llm-trading-agent-security,agent-payment-x402,prediction-market-oracle-research,prediction-market-risk-review
}
§SKL_AUTH{
  target:<skill>/SKILL.md;
  lines:≤100(cap=120);offload:{examples,checklists,catalogs}→references/<topic>.md;
  fm:{name,description:"AUTO_INVOKE(silent)⇔prompt∈{<triggers>}|SUB:{<subs>}"(≤600c)};
  body:LLM_ONLY_SYM(@SKL,§R(≤15_rules),§D(sit⇒do¬avoid),§REF(toks→references/*.md),§REL(../path:scope,depth=1));
  fmt:{¬prose,¬tables,¬filler,1_fact/line,¬redundancy⇒link}
}
§CONV{
  icon:cp("/Users/ashvinijangid/Desktop/Icons/<match>.svg"→"public/"|"assets/");conv(PNG|ICO)?req;
  pm2:∀srv∈{API,backend,SSR,web-server}⇒root:"ecosystem.config.cjs"{name,script,args,cwd,instances,exec_mode,autorestart:true,watch:false,max_memory_restart:"512M",env,env_production:{NODE_ENV:"production",PORT}};
  makefile:root∧.PHONY≡{run,start,deploy}{
    run:dev("npm run dev"|"bun run dev"|"cargo run"|"uv run uvicorn ... --reload");
    start:build?→(srv⇒"pm2 startOrReload ecosystem.config.cjs --env production && pm2 save" | static(e.g.Nuxt:"nuxt generate"→docs/+.nojekyll;GHPages=manual;¬ci_deploy_wf) | native("cargo build --release"));
    deploy:build?→"git checkout main"→"git add -A"→llm_msg(diff_cached@http://127.0.0.1:9694/v1/chat/completions,model=router/text)→"git commit -m \"$${MSG:-chore: update}\""→"git push origin main";
    tpl:```makefile
LLM_URL ?= http://127.0.0.1:9694/v1/chat/completions
LLM_MODEL ?= router/text

.PHONY: run start deploy

deploy:
	git checkout main
	git add -A
	@MSG=$$(git diff --cached | python3 -c 'import json,sys,urllib.request; diff=sys.stdin.read()[:12000]; req=urllib.request.Request("$(LLM_URL)", data=json.dumps({"model":"$(LLM_MODEL)","messages":[{"role":"system","content":"Generate one concise conventional commit message for the git diff. Output ONLY the commit message, no quotes, no markdown, no explanation."},{"role":"user","content":diff}],"temperature":0.2}).encode(), headers={"Content-Type":"application/json"}); print(json.loads(urllib.request.urlopen(req).read())["choices"][0]["message"]["content"].strip())'); \
	git commit -m "$${MSG:-chore: update}"
	git push origin main
```
  };
  git:{new_work⇒"git checkout main";deploy⇒main;".env"∉.gitignore};
  flutter_theme:"/Users/ashvinijangid/Desktop/android/theme"(its-ash/theme)∧Δ⇒edit→build→push→bump_consumer;
  brew_tap:"/Users/ashvinijangid/Desktop/homebrew-tap"(its-ash/homebrew-tap)∧tag_rel⇒upd_formula→push
}
§INIT{
  1:icon("/Users/ashvinijangid/Desktop/Icons");
  2:".github/copilot-instructions.md"∧"ln -s .github/copilot-instructions.md CLAUDE.md"∧"ln -s .github/copilot-instructions.md GEMINI.md";
  3:"Makefile"({run,start,deploy},LLM="http://127.0.0.1:9694/v1");
  4:"ecosystem.config.cjs"(if_srv→make_start);
  5:".nvmrc"(if_node);
  6:"git init"∧".gitignore"(¬".env")∧"git checkout -B main"
}
