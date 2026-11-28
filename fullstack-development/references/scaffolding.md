@REF:scaffolding
§R{
  detect_first⇒match_1_template(§D)before_generating_files;
  runtime_pin⇒`.nvmrc`(26.x_Active_LTS∨24.x_Maint_LTS)∧`engines.node`∧`packageManager`(pnpm@11.x|bun|npm@11.x);
  env_safety⇒Zod4_schema(@t3-oss/env-nextjs∨@t3-oss/env-core)⇒fail_fast_at_boot∧commit_`.env.example`_only;
  Next16⇒AppRouter(`src/app/`)+Turbopack_default+`proxy.ts`(¬`middleware.ts`)+`next.config.ts`+Biome2(¬removed_`next lint`);
  authz_layer⇒DAL(`src/lib/dal.ts`)checks_session+ownership@every_ServerAction/RouteHandler/ServerFn;
  ORM_TS⇒Drizzle(SQL_perf,edge)⊕Prisma7(`prisma.config.ts`+`provider="prisma-client"`+explicit_`output`+driver_adapter);
  monorepo⇒Turborepo2(`turbo.json` uses `tasks`,¬deprecated `pipeline`)+`apps/*`+`packages/{ui,db,env,config-ts}`;
  supply_chain⇒frozen_lockfile∧block_untrusted_lifecycle_scripts(pnpm:`onlyBuiltDependencies`;Bun:`trustedDependencies`);
}
§D{
  detect(first_match;fallback=nextjs-fullstack):{
    saas(subscription|billing|stripe|multi-tenant|dashboard)⇒nextjs-saas⊕tanstack-start-saas;
    social(feed|post|like|follow|profile)⇒nextjs-fullstack+Valkey_cache;
    content|landing(static|marketing|docs|blog|hero|cta)⇒astro-static⊕nextjs-static⊕nuxt-static;
    api(REST|GraphQL|tRPC|endpoint|microservice)⇒hono-api⊕fastify-api⊕express5-api⊕python-fastapi;
    mobile(react-native|expo|flutter|android|ios)⇒expo-sdk58⊕flutter-riverpod;
    multi-app(monorepo|shared-ui|web+mobile|web+api)⇒monorepo-turborepo;
  };
  ORM_choice⇒Drizzle(edge,low_latency,SQL_control)⊕Prisma7(schema_DSL,typed_relations)¬Prisma_Rust_engine;
  auth_choice⇒BetterAuth(self-hosted,DB_adapter,passkeys,2FA,orgs)⊕Clerk(managed_B2B_UI)¬Auth.js_legacy;
  lint_fmt⇒Biome2(single_fast_tool)⊕ESLint9_flat(type-aware_AST_only)¬legacy_.eslintrc_or_next_lint;
  unit_test⇒Vitest5(native_ESM/TS/Oxc)¬Jest_new_projects;
}
§PAT{
  templates:{
    nextjs-fullstack:Next.js16+React19+TS+Tailwind4+(Drizzle∨Prisma7)+PostgreSQL18/19+BetterAuth;
    nextjs-saas:nextjs-fullstack+Stripe(webhooks+idempotency)+orgs/RBAC+Valkey9;
    tanstack-start:TanStackStart+TanStackRouter/Query+Vite+createServerFn+Zod4+Drizzle+BetterAuth;
    astro-static:Astro5+Tailwind4+ContentCollections(zero_JS_default);
    nuxt-app:Nuxt4+Nitro+Pinia+PostgreSQL(static:`nuxt generate`→docs/);
    hono-api:Hono+Zod4/OpenAPI(Node26|Bun|CF_Workers)+Drizzle+Pino+OTel;
    fastify-express-api:Fastify5⊕Express5(native_async_err)+Zod4+Pino+Prisma7/Drizzle;
    python-fastapi:FastAPI+uv+Pydantic_v2+SQLAlchemy2_async+Alembic+Ruff+pytest;
    expo-sdk58:Expo_SDK58(NewArch+ExpoRouter)+React19+NativeWind+TanStackQuery;
    flutter-riverpod:Flutter+Dart3+Riverpod+GoRouter+Freezed;
    monorepo-turborepo:Turborepo2.11++pnpm11_workspaces+apps/{web,api,mobile}+packages/{ui,db,env,config};
  };
  tree_next16:{
    `src/app/{layout.tsx,page.tsx,loading.tsx,error.tsx,not-found.tsx,actions.ts}`;
    `src/app/api/health/{live,ready}/route.ts`;
    `src/features/<domain>/{components,hooks,schemas,actions,queries}.ts`;
    `src/lib/{db.ts,auth.ts,dal.ts,env.ts,logger.ts,errors.ts}`;
    `src/proxy.ts`(@root_or_src_matching_app);
    `src/generated/prisma/`(if_Prisma7;gitignored_or_committed_per_team);
    `prisma/{schema.prisma,migrations/}`∨`src/db/{schema.ts,migrations/}`(Drizzle);
    root:`next.config.ts`,`prisma.config.ts`∨`drizzle.config.ts`,`biome.json`,`vitest.config.ts`,`playwright.config.ts`,`compose.yaml`,`.env.example`;
  };
  tree_monorepo:{
    `apps/{web(Next16),dashboard(TanStackStart),api(Hono),docs(Astro5),mobile(Expo58)}`;
    `packages/{ui(@repo/ui),db(@repo/db),env(@repo/env),validators(@repo/validators),tsconfig(@repo/tsconfig)}`;
    root:`turbo.json`,`pnpm-workspace.yaml`,`biome.json`,`package.json`;
  };
  init_steps:{
    1:`mkdir <app> && cd <app> && git init -b main`;
    2:pin_runtime(`.nvmrc`+`packageManager`)+scaffold_template;
    3:`pnpm install --frozen-lockfile`(or_initial_`pnpm install`);
    4:`cp .env.example .env`→fill_DB_URL+AUTH_SECRET+3p_keys∧verify_boot_env_schema;
    5:boot_local_DB(`docker compose up -d db cache`)→run_initial_migration(Prisma7∨Drizzle);
    6:add_health_routes(`/api/health/live`,`/api/health/ready`)+Pino_logger+OTel_hook+RFC9457_err_handler;
  };
  agent_order(pass_only_scoped_files_between_stages):1:project-planner(tasks,dep_graph,contracts)→2:database-architect(schema,indexes,migrations)→3:backend-specialist(DAL,API/Actions,authz,RFC9457)→4:frontend-specialist(UI,forms,RSC/Query,a11y)→5:devops-engineer(Dockerfile,compose,CI,K8s/edge);
}
§CFG{
  next.config.ts:`import type {NextConfig} from 'next'; export default {output:'standalone',cacheComponents:true} satisfies NextConfig;`;
  prisma7_schema:`generator client { provider = "prisma-client"; output = "../src/generated/prisma" } datasource db { provider = "postgresql" }`;
  prisma7_config:`import 'dotenv/config'; import {defineConfig,env} from 'prisma/config'; export default defineConfig({schema:'prisma/schema.prisma',migrations:{path:'prisma/migrations'},datasource:{url:env('DATABASE_URL')}});`;
  prisma7_client:`new PrismaClient({adapter:new PrismaPg({connectionString:env.DATABASE_URL})})`(globalThis_singleton_dev);
  turbo.json:`{"$schema":"https://turbo.build/schema.json","ui":"tui","tasks":{"build":{"dependsOn":["^build"],"outputs":[".next/**","!.next/cache/**",".output/**","dist/**",".open-next/**"]},"lint":{"dependsOn":["^lint"]},"typecheck":{"dependsOn":["^typecheck"]},"test":{"dependsOn":["^build"]},"dev":{"cache":false,"persistent":true}}}`;
  tanstack_serverfn:`createServerFn({method:'POST'}).validator((d:unknown)=>Schema.parse(d)).handler(async({data})=>{await requireSession();...})`;
}
§CMD{
  dev:`pnpm dev` | `pnpm turbo run dev` | `docker compose up -d db cache`;
  prisma7:`npx prisma generate && npx prisma migrate dev --name <desc>`(local_only) | `npx prisma migrate deploy`(CI/prod) | `npx prisma studio`;
  drizzle:`npx drizzle-kit generate && npx drizzle-kit migrate` | `npx drizzle-kit studio`;
  quality:`npx biome check --write .` | `pnpm exec tsc --noEmit` | `npx vitest run` | `npx playwright test`;
  security:`pnpm audit --audit-level=high` | `npm audit --omit=dev --audit-level=high`;
}
§ANTI{
  Node_20_EOL⇒use_Node_26_LTS_or_24_LTS;
  `middleware.ts`_in_Next16⇒use_`proxy.ts`_and_enforce_authz_in_DAL;
  `next lint`_in_Next16⇒removed;use_`biome check`_or_`eslint`;
  Pages_Router_greenfield⇒use_AppRouter;
  Prisma7_missing_`output`_or_adapter⇒set_`provider="prisma-client"`,explicit_`output`,`prisma.config.ts`,driver_adapter;
  `turbo.json` `pipeline`⇒deprecated_in_Turbo2;use_`tasks`;
  `prisma migrate dev`_in_CI/prod⇒resets_on_drift;use_`prisma migrate deploy`;
  unvalidated_`process.env`⇒Zod4/@t3-oss/env_fail-fast;
  heavy_barrel_reexports⇒direct_imports_to_preserve_tree-shaking;
}
§CHK{runtime_pinned(Node26/24);env_schema_validates_at_boot;.env.example_committed;DAL_authz_enforced_per_action/route;ORM_migrations_versioned;Biome2+tsc_noEmit=0_err;Vitest5+Playwright_wired;health_endpoints+Pino+RFC9457_present;CI_runs_lint+typecheck+test+audit}
