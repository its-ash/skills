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
  ai-agent-engineering:AI agents,harness,autonomous loops,evals,pass@k,multi-agent,MCP server,prompt injection,LLM cost→agent-harness-construction,autonomous-loops,eval-harness,mcp-server-patterns,agent-security-hardening,llm-cost-optimization,team-agent-orchestration,search-first;
  backend-development:API,REST,GraphQL,gRPC,OpenAPI,microservices,queues,serverless,multi-tenant,Django,Laravel,Rails→api-design,nodejs-patterns,nestjs,fastapi,django,php-laravel,rails,contract-first,error-handling,firebase-backend;
  browser-extensions:Chrome/Firefox/Edge extension,Manifest V3,content script,service worker,popup;
  clean-code:write/refactor/lint code,naming,dead code,SOLID,deslop diff→coding-standards,inherit-legacy-style,codehealth-mcp;
  code-review:PR review,diff,bugs,breaking changes,LGTM/blockers,verify→change-impact,click-path-audit,code-review-feedback,verification-loop;
  content-writing:blog,social posts,content calendar,brand voice,outreach,pitch deck,launch→copywriting,social-content,brand-voice,article-writing,social-publishing,lead-intelligence,investor-materials,marketing-campaign;
  conversion-optimization:CRO,landing/pricing/signup/onboarding/paywall,funnel→ab-testing;
  cpp:C++,.cpp/.hpp,CMake,RAII,smart pointers,GoogleTest→cpp-testing;
  database-design:schema,ERD,SQL vs NoSQL,indexes,migrations,Postgres,MySQL,ClickHouse,Redis→postgresql,mysql-patterns,clickhouse,redis,database-migration,database-optimization,prisma,drizzle-orm;
  design:UI/website/dashboard/component/animation,modern CSS(oklch,light-dark,filled tabs,tonal cards),design tokens→visual-design-direction,design-system,make-interfaces-feel-better,tailwind-css,shadcn-ui,motion-react,immersive-web,threejs,gsap,figma,mobile-design,brand-theming,motion-canvas,html-slides;
  devops-iac:Terraform,Kubernetes,Helm,Docker,GitHub Actions,PM2/deploy/rollback,observability,Cloudflare→docker,kubernetes,github-actions,deployment-patterns,cloud-architecture,cloudflare-deploy,observability,flox-environments,uncloud;
  document-processing:PDF/DOCX/XLSX convert,OCR,redact,e-signature,visa translate→nutrient-document-processing,esign-field-placement,visa-doc-translate;
  documentation:docs drift,onboarding guide,CodeTour,CONTEXT.md,growth log→codebase-onboarding,code-tour,context-and-decisions,growth-log;
  dotnet:C#,F#,.NET,ASP.NET Core,EF Core,xUnit,WPF→csharp-testing,fsharp-testing,windows-desktop-e2e;
  flutter:Flutter,Dart,pubspec.yaml,Riverpod,Bloc,Provider→dart-flutter-patterns,flutter-code-review;
  frontend-development:React,Next.js,MUI,TanStack,Vue,Nuxt,Angular,Vite,Astro,PWA,React Native→nextjs,react-patterns,react-performance,mui,vue,nuxt,angular,vite,astro,d3-visualization,progressive-web-app,react-native;
  fullstack-development:new web app,stack choice,scaffolding,monorepo,deploy;
  git-workflow:branch,commit message,rebase,release,gh issue/PR,Jira,open-source→github-ops,conventional-commit-review,issue-review,jira-integration,opensource-pipeline,project-flow-ops;
  golang:Go,.go,go.mod,goroutines,channels,golangci-lint→golang-patterns,golang-testing;
  healthcare:HIPAA,PHI,EMR/EHR,CDSS,HL7/FHIR→phi-compliance,emr,cdss,eval-harness;
  i18n-localization:i18n,l10n,translations,locale JSON,ICU,RTL→i18n-sync,bengali-nlp;
  java:Java,Maven/Gradle,Spring Boot,Quarkus,JPA,MyBatis→springboot-patterns,springboot-security,springboot-testing,quarkus-patterns,quarkus-security,quarkus-testing,jpa-patterns,mybatis-patterns,tinystruct-patterns;
  kotlin:Kotlin,.kt/.kts,coroutines,Flow,Ktor,Exposed,Android,Compose→kotlin-coroutines-flows,kotlin-testing,kotlin-ktor-patterns,kotlin-exposed-patterns,android-clean-architecture,compose-multiplatform-patterns;
  machine-learning:ML pipeline,PyTorch,model eval,drift,recsys,ETL→pytorch-patterns,ml-adoption-playbook,recsys-pipeline-architect,data-throughput-accelerator;
  networking:homelab,VLAN,Pi-hole,WireGuard,Cisco,Netmiko,BGP→homelab-network-readiness,homelab-vlan-segmentation,homelab-pihole-dns,homelab-wireguard-vpn,cisco-ios-patterns,netmiko-ssh-automation,network-bgp-diagnostics,network-config-validation,network-interface-health;
  node:Node.js,package.json,.nvmrc,tsconfig,.env,Makefile,PM2,Bun→bun;
  perl:Perl,.pl/.pm,CPAN,Mojolicious,DBI→perl-security,perl-testing;
  product-strategy:product brief,go/no-go,ICE,PRD,TAM/SAM/SOM,competitors,brand discovery→product-capability,market-research,competitive-platform-analysis,benchmark-methodology,competitive-report-structure,brand-discovery;
  python:Python,.py,pyproject.toml,uv,ruff,mypy,pytest,asyncio→python-patterns,python-testing,windows-installer;
  research:deep research,citations,Exa,OSINT,PubMed,patents,genomics,lit review→exa-search,osint-investigation,pubmed,uspto,gget,literature-review,scholar-evaluation;
  rust:Rust,.rs,Cargo.toml,borrow checker,Tokio→rust-testing;
  screenshot:capture screen,screencapture/scrot/maim→screenshot-feature-extractor;
  secure-coding:auth,secrets,injection,XSS,CSRF,JWT,IAM,pentest,GDPR/HIPAA→web-vulnerability-testing,data-privacy-compliance,cloud-infrastructure-security,security-bounty-hunter;
  seo:SEO audit,meta tags,schema markup,crawlability,GEO→generative-engine-optimization,schema-markup,programmatic-seo;
  software-architecture:Clean/Hexagonal,DDD,CQRS,ADR,monolith split,module governance→architecture-decision-records,hexagonal-architecture,intent-driven-development,module-governance,module-regression;
  supply-chain-operations:freight,customs/HS codes,energy,demand forecast,safety stock,NCR/CAPA,returns→carrier-relationship-management,customs-trade-compliance,energy-procurement,inventory-demand-planning,logistics-exception-management,production-scheduling,quality-nonconformance,returns-reverse-logistics;
  swift-ios:Swift,.swift,SwiftUI,Xcode,@Observable,actors,FoundationModels,Liquid Glass→swift-concurrency,swift-actor-persistence,swift-protocol-di-testing,foundation-models-on-device,liquid-glass-design;
  systematic-debugging:bugs,stack traces,crashes,memory leaks,flaky tests,CI failures,root cause;
  typescript:TS types,.ts/.tsx,tsconfig,TS errors,JS→TS→zod,javascript,typescript-patterns;
  unit-testing-patterns:unit tests,Jest,Vitest,pytest,TDD,mocks,E2E,Playwright,RTL→playwright,test-driven-development,react-testing,ai-regression-testing,test-collaboration,browser-qa;
  ux-research:personas,journeys,interviews,usability tests,heuristic evaluation;
  video-production:video edit,FFmpeg,Remotion,Manim,fal.ai,demo video→remotion,manim-video,fal-ai-media,ui-demo,videodb,blender-motion-state-inspection,visual-taste;
  web-quality-audit:site audit,Lighthouse,CWV,a11y/WCAG,security headers,benchmark,prod audit→web-performance,performance,web-accessibility,benchmark,latency-critical-systems,production-audit,canary-watch;
  web-scraping-apis:scrape,crawl,Firecrawl,Tavily,CF Browser Rendering,Xquik,Bright Data→bright-data,data-scraper-agent;
  web3-security:Solidity,DeFi/AMM audit,ERC-20 decimals,Keccak-256,agent wallet,x402→defi-amm-security,evm-token-decimals,nodejs-keccak256,llm-trading-agent-security,agent-payment-x402,prediction-market-oracle-research,prediction-market-risk-review
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
