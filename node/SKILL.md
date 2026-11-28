---
name: node
description: "AUTO_INVOKE(silent)⇔prompt∈{Node.js,.nvmrc,package.json,tsconfig.json,ecosystem.config.cjs,Makefile,PM2,Bun,bun.lock,bunfig.toml,Bun.serve,bun:sqlite,Bun.sql,Bun.redis,Bun.S3Client,Express,Fastify,NestJS,Nuxt,npm,pnpm,yarn,dotenv,zod,helmet,Biome,.env,engines.node,packageManager,esm,cjs,workspaces,node:test,node:sqlite,--env-file,--permission,--run,strip_types,erasableSyntaxOnly,corepack,minimumReleaseAge,trustedDependencies,init_node,node_srv,static_pages}|SUB:{bun}"
---
@SKL:node
§R{
  LTS_2026:Node26(Active_LTS,EOL_2029-04)∨Node24(Maint_LTS,EOL_2028-04)∨Node22(Maint_LTS,EOL_2027-04);Node20≡EOL(2026-04);Node27+=annual_LTS;
  root/.nvmrc≡exact_ver(eg:26.13.0)∧¬bare_major∧engines.node≡match(.nvmrc,eg:'>=26.0.0');
  package.json.type≡'module'∨fw_req_CJS;pin(packageManager≡'npm@11.x'|'pnpm@11.x');
  Node≥25⇒Corepack_unbundled→(need_Corepack⇒'npm i -g corepack && corepack enable'∨mise|fnm);
  scripts⊇{dev,build,start,test}∧((TS∨lint)⇒scripts⊇{lint,typecheck});fast_local_run⇒'node --run <script>';
  new_proj⇒TS{strict:1,module:'NodeNext',moduleResolution:'NodeNext',skipLibCheck:1,erasableSyntaxOnly:1,src:'src/',out:'dist/'};
  Node≥24⇒native_TS_strip('node app.ts',stable_v25/26,¬runtime_typecheck⇒CI:'tsc --noEmit');Node26⇒¬--experimental-transform-types;
  builtins≻deps:env('node --env-file=.env'∨'--env-file-if-exists=.env'∨process.loadEnvFile()¬dotenv_Node≥22),test(node:test+node:assert),watch('node --watch'),SQLite(node:sqlite:DatabaseSync),time(Node26:Temporal);
  supply_chain:block_lifecycle_scripts(pnpm:onlyBuiltDependencies|allowBuilds;Bun:trustedDependencies;Yarn:enableScripts=false)∧cooldown(1-3d:pnpm_minimumReleaseAge≥1440|npm_min-release-age=3|Yarn_npmMinimalAgeGate|Bun_minimumReleaseAge);
  Makefile:{run→'npm run dev',start→(build→'pm2 startOrReload ecosystem.config.cjs --env production && pm2 save'|srv),deploy→push(main,LLM@'http://127.0.0.1:9694/v1',model='router/text')};
  ∀app∈{Node_srv,web_srv}⇒auto_create(root/ecosystem.config.cjs);
  .gitignore⊇{'node_modules/','dist/','.DS_Store'}∧(pub_repo⇒.env∈.gitignore;local_conv⇒¬'.env'∈.gitignore)∧commit(.env.example{∀req_keys,¬real_vals});
  validate({env_vars,req_bodies,CLI_args})via(Zod4∨sim);
  Express5(native_async_err)⇒helmet;Fastify5⇒JSON_Schema;untrusted_code⇒'node --permission --allow-fs-read=... --allow-net'(process.permission.has);¬eval;¬child_process(unsanitized_in);
}
§D{
  choose_runtime⇒Node26_LTS(max_compat|enterprise)∨Bun1.4.x(speed|all_in_one|Vercel_Bun)¬Node20_EOL;
  choose_pkg_mgr⇒npm(default|keep_existing_in_existing_proj)∨pnpm11(monorepo|strict_supply_chain)¬mix_lockfiles;
  pin_deps⇒exact(prod_deps)∧caret(dev_deps)¬caret(prod_deps);
  lockfile⇒commit(apps)∧¬commit(package-lock.json|libs)¬lockfile_in_pub_lib;
  TS_runtime⇒native_strip('node app.ts'+erasableSyntaxOnly+tsc_noEmit)¬ts-node_legacy_or_TS_enums;
  lint_fmt⇒Biome(fast_fmt+lint)∧ESLint9+_flat_cfg(deep_type_AST_rules)¬legacy_eslintrc;
  http_fw⇒Express5(ecosystem+async_err)∨Fastify5(throughput+schema)¬Express4_new_proj;
  Nuxt_static⇒'nuxt generate'→docs/+.nojekyll∧manual_Pages¬unasked_deploy_wf;
  proj_uses_Bun∨user_asks⇒read(references/bun.md)¬npm_cmds_in_Bun_repo;
}
§REF{
  tpls+modern_cfg:{.nvmrc,package.json,tsconfig.json(NodeNext+erasableSyntaxOnly),Corepack_Node≥25,supply_chain(.npmrc,pnpm-workspace.yaml,.yarnrc.yml),builtins(node:sqlite,node:test,--permission,--run,--env-file),ecosystem.config.cjs(PM2),Makefile(run/start/deploy),Nuxt_static_start,.gitignore}→references/project-setup.md;
  Bun_1.4.x,Bun_vs_Node,migration,bun_install/test/audit,trustedDependencies,minimumReleaseAge,workspaces,Bun.serve/sql/redis/S3/Image/cron,Bun_Makefile,Vercel_bunVersion→references/bun.md;
}
§REL{
  ../typescript/SKILL.md:TS_setup,migration,monorepo_cfg;
  ../backend-development/SKILL.md:API_design,REST,auth,queues,error_handling;
  ../frontend-development/references/nextjs.md:Next.js_App_Router;
  ../backend-development/references/nestjs.md:NestJS_modules,DI,guards;
  ../database-design/references/prisma.md:Prisma_schema,migrations,queries;
  ../devops-iac/references/docker.md:multi_stage_Node_images;
  ../secure-coding/SKILL.md:auth,secrets,injection,OWASP;
  ../unit-testing-patterns/SKILL.md:TDD,mocks,Playwright,coverage;
}
