@REF:bun
§R{
  parent[../SKILL.md]_def=npm;use_Bun⇔(bun.lock|bunfig.toml|user_req|Node→Bun|Bun_scripts/tests|Vercel_Bun);
  ver:Bun_1.4.x(latest:1.4.5/1.4.6)→run_'bun --version'_≺_flags;rt:JSC+Node_compat(Rust_core_≥1.4,was_Zig;5x_lower_idle_CPU,~35%_less_mem,+1500_Node_compat_tests);
  compat:¬100%(native_N-API_edge_cases,rare_node:_internals⇒verify_in_prod);v1.4.5+=security_fixes(HTTP/3,TLS,DNS,BoringSSL,c-ares,SQLite,node:quic,node:crypto);
  lock:bun.lock(text,commit_for_apps;bun.lockb=legacy_binary_mig_only);monorepo=root_package.json.workspaces[];
  env_auto:Bun_auto_loads(.env,.env.<NODE_ENV>,.env.local)∧supports(--env-file,--env-file-if-exists);
  typecheck:Bun_runs_.ts_natively_but_¬typechecks⇒run_'tsc --noEmit'_in_CI;
}
§D{
  choose_Bun⇒(new_JS/TS∧speed)|1_tool(run+inst+test+build)|Vercel_Bun_Fluid_compute¬npm_cmds_in_Bun_repo;
  choose_Node⇒max_compat|legacy_Node_native_addons|dep_Bun_bug¬unverified_prod_swap;
  test_runner⇒'bun test'(Jest_API+native_node:test+node:assert_compat)¬separate_Jest_setup;
  supply_chain⇒trustedDependencies+bunfig.toml_minimumReleaseAge¬blind_postinstall;
}
§CMD[migration_pkg]{
  run:node s.js→bun s.js|bun run s.js;npm install→bun install(writes_bun.lock);npm run <s>→bun run <s>;npx <p>→bun x <p>;
  pkg:bun add|remove|update|outdated|dedupe|prune <p>;bun install --frozen-lockfile(CI);
  monorepo:bun run --filter <pkg-name> <script>;bun pm ls [--all](lock;--all=trans;¬integrity);
  audit:bun audit(reg_advisory_from_bun.lock;no_fs_mut;sends_meta→verify_priv_ok;no_scoped_ep⇒skip∧¬exit);
  audit_fix:bun audit fix(upg+inst;mut_lock/inst/pins+lifecycle⇒review_as_mod_inst);
}
§CMD[run_test]{
  dev:bun run dev|bun src/index.ts|bun run --env-file=.env dev|FOO=bar bun run script.ts;
  test:bun test [--watch](supports_bun:test∧node:test);
  test_CI_1.4:--changed[=<ref>];--isolate(fresh_global/file_same_proc;¬sandbox);--parallel[=<n>](workers,+--isolate);--shard=<n>/<count>;--timings=<file> --update-timings(eg:bun test --parallel --timings=./test-timings.json --update-timings;chk_'bun test --help'_pre_shard);
}
§PAT[builtins]{
  prefer≺dep:File(Bun.file,Bun.write;`await Bun.file("package.json").json()`);
  SQLite:bun:sqlite;SQL:Bun.sql([docs](https://bun.com/docs/runtime/sql));Redis:Bun.redis([docs](https://bun.com/docs/runtime/redis));S3:Bun.S3Client([docs](https://bun.com/docs/runtime/s3));
  HTTP/WS:`Bun.serve({port:Number(process.env.PORT??3000),fetch(req){return new URL(req.url).pathname==="/health"?new Response("ok"):new Response("Not found",{status:404})}})`;
  Bun_1.4_new:Bun.Image,Bun.WebView,Bun.markdown,Bun.Terminal,Bun.cron();
  test_eg:`import{expect,test}from"bun:test";test("add",()=>{expect(1+2).toBe(3)})`;
}
§CFG[supply-chain]{
  package.json(lifecycle_allowlist):"trustedDependencies":["my-native-pkg"](Bun_blocks_arbitrary_postinstall_by_default);
  bunfig.toml(cooldown):[install]\nminimumReleaseAge = 259200 # or "3d"\nminimumReleaseAgeExcludes = ["@internal/*"];
}
§CFG[Makefile]{same_as[../SKILL.md](../SKILL.md)/[project-setup.md](project-setup.md)(LLM_URL?=http://127.0.0.1:9694/v1/chat/completions,LLM_MODEL?=router/text,.PHONY:run start deploy)w/Bun:run:bun run dev;start:bun run build && pm2 startOrReload ecosystem.config.cjs --env production && pm2 save;deploy:bun run build→git checkout main→git add -A→@MSG=$$(git diff --cached|LLM(12000,t=0.2))→git commit -m "$${MSG:-chore: update}"→git push origin main}
§CFG[Vercel]{vercel.json:{"$schema":"https://openapi.vercel.sh/vercel.json","bunVersion":"1.4.x"}([docs](https://vercel.com/docs/functions/runtimes/bun);1.4.x=explicit_opt_in_Fluid_compute+Bun.serve;1.x=legacy_fallback);inst:bun install --frozen-lockfile;build:bun run build|bun build ./src/index.ts --outdir=dist;entry:server.ts|src/server.ts+bun.lock}
§ANTI{
  npm_cmds_or_package-lock.json_in_Bun_repo;
  committing_legacy_bun.lockb_on_new_proj;
  skipping_'tsc --noEmit'_assuming_Bun_typechecks;
  omitting_bunVersion:'1.4.x'_on_Vercel_when_using_1.4_features;
}
§CHK{
  commit(bun.lock)∧CI_uses_'bun install --frozen-lockfile';
  trustedDependencies+bunfig.toml_minimumReleaseAge_configured;
  keep(.nvmrc)_if_Node_CI_also_runs;
  CI_runs_'tsc --noEmit'+'bun test --parallel';
  links:[Bun 1.4](https://bun.com/blog/bun-v1.4),[bun audit](https://bun.com/docs/pm/cli/audit),[../SKILL.md](../SKILL.md),[../../typescript/SKILL.md](../../typescript/SKILL.md),[../../unit-testing-patterns/SKILL.md](../../unit-testing-patterns/SKILL.md);
}
