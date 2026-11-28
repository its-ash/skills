@REF:project-setup
§R{
  LTS:Node26(Lithium,Active_LTS,26.13.0+,EOL_2029-04-30)≻Node24(Krypton,Maint_LTS,EOL_2028-04-30)≻Node22(Jod,Maint_LTS,EOL_2027-04-30);Node20(Iron)≡EOL(2026-04-30);Node27+≡annual_LTS(¬odd/even);
  Corepack:removed_from_Node≥25(incl_Node26_binaries+Docker_images);install_explicit_if_needed∨use(mise|fnm);
  native_TS:unflagged_Node24,stable_Node25/26('node app.ts',SWC_type_stripping,¬typecheck⇒run_'tsc --noEmit'_in_CI);--experimental-transform-types≡removed_Node26;
}
§CFG[.nvmrc]{node -v > .nvmrc(exact_semver,eg:26.13.0,¬bare_major)}
§CFG[package.json]{"type":"module","engines":{"node":">=26.0.0"},"packageManager":"npm@11.x","scripts":{"dev":"node --watch --env-file-if-exists=.env src/index.ts","build":"tsc","start":"node --env-file-if-exists=.env dist/index.js","test":"node --test","lint":"biome check .","typecheck":"tsc --noEmit"}}
§CFG[tsconfig.json]{"compilerOptions":{"target":"ESNext","module":"NodeNext","moduleResolution":"NodeNext","strict":true,"skipLibCheck":true,"erasableSyntaxOnly":true,"noEmit":true}}
§CFG[tsconfig_emit]{add:{noEmit:false,rootDir:"src",outDir:"dist",declaration:true,sourceMap:true}⇔compiling_to_dist/}
§CFG[supply-chain]{
  npm_11.10+(.npmrc):min-release-age=3(days,default_0);ignore-scripts=true(or_explicit_allowScripts);
  pnpm_10.16+/11(pnpm-workspace.yaml,¬.npmrc_in_v11):minimumReleaseAge:1440(min,1d_def_v11);minimumReleaseAgeExclude:['@internal/*'];onlyBuiltDependencies(v10)|allowBuilds(v10.26+/v11);blockExoticSubdeps:true(def_v11);
  Yarn_Berry_4.10+(.yarnrc.yml):enableScripts:false;npmMinimalAgeGate:4320(min,3d);
}
§CMD[corepack_node25+]{
  local/CI:npm install -g corepack && corepack enable;
  Docker(node:26-alpine):RUN npm install -g corepack && corepack enable;
}
§CMD[runtime_builtins]{
  run_ts:node src/index.ts;
  watch:node --watch src/index.ts;
  scripts:node --run build(¬npm_CLI_overhead);
  env:node --env-file=.env app.ts|node --env-file-if-exists=.env app.ts|process.loadEnvFile('.env');
  test:node --test(uses_node:test+node:assert);
  permission:node --permission --allow-fs-read=/app/data --allow-net app.ts(runtime_chk:process.permission.has('fs.read','/app/secrets'));
}
§PAT[node:sqlite]{import{DatabaseSync}from'node:sqlite';const db=new DatabaseSync(':memory:');db.exec('CREATE TABLE t(id INTEGER PRIMARY KEY,v TEXT)');db.prepare('INSERT INTO t(v) VALUES(?)').run('a');db.prepare('SELECT * FROM t').all();/*zero_C++_compile;Node26+=percentile_ext*/}
§PAT[erasable_ts]{erasableSyntaxOnly⇒¬enum∧¬namespace∧¬ctor_param_props;use:const Roles={ADMIN:'admin',USER:'user'} as const;type Role=typeof Roles[keyof typeof Roles];}
§PAT[temporal_node26]{Node26⇒Temporal_global_default(Temporal.Now.instant(),Temporal.PlainDate)≻Date_math}
§CFG[ecosystem.config.cjs]{∀(srv|web-srv):module.exports={apps:[{name:"<app-name>",script:"dist/index.js",cwd:__dirname,instances:1,exec_mode:"fork",autorestart:true,watch:false,max_memory_restart:"512M",env:{NODE_ENV:"development",PORT:3000},env_production:{NODE_ENV:"production",PORT:3000}}]};}
§CFG[Makefile]{
```makefile
LLM_URL ?= http://127.0.0.1:9694/v1/chat/completions
LLM_MODEL ?= router/text
.PHONY: run start deploy
run:
	npm run dev
start:
	npm run build
	pm2 startOrReload ecosystem.config.cjs --env production && pm2 save
deploy:
	npm run build
	git checkout main
	git add -A
	@MSG=$$(git diff --cached|python3 -c 'import json,sys,urllib.request;diff=sys.stdin.read()[:12000];req=urllib.request.Request("$(LLM_URL)",data=json.dumps({"model":"$(LLM_MODEL)","messages":[{"role":"system","content":"Generate one concise conventional commit message for the git diff. Output ONLY the commit message, no quotes, no markdown, no explanation."},{"role":"user","content":diff}],"temperature":0.2}).encode(),headers={"Content-Type":"application/json"});print(json.loads(urllib.request.urlopen(req).read())["choices"][0]["message"]["content"].strip())');\
	git commit -m "$${MSG:-chore: update}"
	git push origin main
```}
§CFG[nuxt]{GHPages_docs/(manual_set;¬deploy_wf_unless_asked):start:npx nuxt generate;cp -r .output/public/* docs/ 2>/dev/null||cp -r dist/* docs/ 2>/dev/null;touch docs/.nojekyll}
§CFG[.gitignore]{node_modules/,dist/,.DS_Store;local_conv⇒¬".env";pub_repo⇒add(".env")∧commit(".env.example")}
§ANTI{
  Node20_in_.nvmrc/engines(EOL_2026-04);
  corepack_enable_without_install_on_Node≥25(binary_missing);
  --experimental-transform-types_on_Node26(removed);
  pnpm11_minimumReleaseAge_in_.npmrc(must_live_in_pnpm-workspace.yaml);
  dotenv_dep_on_Node≥22(use_--env-file-if-exists|process.loadEnvFile);
  Express4_new_proj(use_Express5_async_err|Fastify5);
  mixing_lockfiles(package-lock.json+pnpm-lock.yaml+bun.lock);
}
§CHK{
  exact_.nvmrc(Node26/24_LTS)∧matching_engines.node;
  type:'module'∧packageManager_pinned;
  erasableSyntaxOnly:true∧CI_runs_'tsc --noEmit';
  cooldown_cfg(1-3d)+lifecycle_scripts_restricted;
  ecosystem.config.cjs+Makefile(run/start/deploy)_present_for_servers;
}
