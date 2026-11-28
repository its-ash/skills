@REF:cli
§R{prefer(`ng`CLI)over(manual_files|`npm`);Angular_22_req:Node≥22∧TS≥6}
§DEPS{
  angular_libs:ALWAYS(`ng add <pkg>`,¬`npm install`)⇒installs+runs_init_schematics(`angular.json`,root_providers);
  ex:`ng add @angular/material` | `ng add tailwindcss` | `ng add @angular/fire`;
  update(auto_migrations):`ng update @angular/core@<latest|ver> @angular/cli@<latest|ver>`
}
§GEN{
  cmd:`ng generate`∨`ng g`;
  c:`ng g c path/to/name` (`--inline-style`/`-s`, `--inline-template`/`-t`;`OnPush`+zoneless_default_v22);
  s:`ng g s path/to/name` (`@Injectable({providedIn:'root'})`);
  d:`ng g d path/to/name`;
  p:`ng g p path/to/name`;
  g:`ng g g path/to/name` (functional_guard);
  env:`ng g environments` (scaffolds `src/environments/` + updates `angular.json` fileReplacements);
  routes:¬gen_cmd⇒`ng g c` then add_to `Routes[]` in `app.routes.ts`
}
§SERVE{
  dev(HMR):`ng serve`;
  proxy_api:{
    1:`src/proxy.conf.json`→`{"/api/**":{"target":"http://localhost:3000","secure":false}}`;
    2:`angular.json`→`"serve":{"builder":"@angular/build:dev-server","options":{"proxyConfig":"src/proxy.conf.json"}}`
  }
}
§BUILD{
  cmd:`ng build` (default_config=`production`:AOT,minify,tree-shake);
  out:`dist/<project-name>/browser`;
  builder:`@angular/build:application`;
  cfg:`ng build --configuration=staging`
}
§TEST{
  unit:`ng test` (Vitest+jsdom_default_v22;Karma_deprecated,CLI_migration_avail);
  e2e:`ng e2e` (prompts_install_if_unset:Cypress|Playwright|Puppeteer)
}
§DEPLOY{
  `ng add <deploy_builder>`→`ng deploy` (ex:`ng add @angular/fire && ng deploy`)
}
