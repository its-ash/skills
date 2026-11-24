---
name: node
description: "AUTO_INVOKE(silent)⇔prompt∈{Node.js,.nvmrc,package.json,tsconfig.json,ecosystem.config.cjs,Makefile,PM2,Bun,bun.lock,Bun.serve,bun:sqlite,Bun.sql,Express,Fastify,NestJS,Nuxt,npm,pnpm,yarn,dotenv,zod,helmet,.env,engines.node,esm,cjs,workspaces,init_node,node_srv,static_pages}|SUB:{bun}"
---
@SKL:node
§R{
  root/.nvmrc≡exact_ver(20.17.0)∧¬bare_major∧engines.node≡.nvmrc;
  package.json.type≡'module'∨fw_req_CJS;
  scripts⊇{dev,build,start}∧((TS∨ESLint)⇒scripts⊇{lint,typecheck});
  new_proj⇒TS{strict:1,esModuleInterop:1,skipLibCheck:1,src:'src/',out:'dist/'};
  Makefile:{run→'npm run dev',start→(build→'pm2 startOrReload ecosystem.config.cjs --env production && pm2 save'|srv),deploy→push(main,LLM@'http://127.0.0.1:9694/v1')};
  ∀app∈{Node_srv,web_srv}⇒auto_create(root/ecosystem.config.cjs);
  .gitignore⊇{'node_modules/','dist/',.env,.DS_Store};
  validate({env_vars,req_bodies,CLI_args})via(zod∨sim);
  .env∈.gitignore∧commit(.env.example{∀req_keys,¬real_vals});
  env_load⇒(Node≥20⇒'node --env-file=.env'∧process.env)|(Node<20⇒dotenv);
  Express⇒helmet;¬eval;¬child_process(unsanitized_in);
}
§D{
  choose_pkg_mgr⇒npm(keep_existing_in_existing_proj)¬mix_lockfiles;
  pin_deps⇒exact(prod_deps)∧caret(dev_deps)¬caret(prod_deps);
  lockfile⇒commit(apps)∧¬commit(package-lock.json|libs)¬lockfile_in_pub_lib;
  Nuxt_static⇒'nuxt generate'→docs/+.nojekyll∧manual_Pages¬unasked_deploy_wf;
  proj_uses_Bun∨user_asks⇒read(references/bun.md)¬npm_cmds_in_Bun_repo;
}
§REF{
  tpls:{.nvmrc,package.json,ecosystem.config.cjs(PM2),Makefile(run/start/deploy),Nuxt_static_start,.gitignore}→references/project-setup.md;
  Bun_vs_Node,migration,bun_install/test/audit,workspaces,Bun.serve,bun:sqlite,Bun.sql,Bun_Makefile,Vercel_bunVersion→references/bun.md;
}
§REL{
  ../typescript/SKILL.md:TS_setup,migration,monorepo_cfg;
  ../frontend-development/references/nextjs.md:Next.js_App_Router;
  ../backend-development/references/nestjs.md:NestJS_modules,DI,guards;
  ../database-design/references/prisma.md:Prisma_schema,migrations,queries;
  ../devops-iac/references/docker.md:multi_stage_Node_images;
}
