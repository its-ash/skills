---
name: typescript
description: "AUTO_INVOKE(silent)⇔prompt∈{TypeScript,.ts,.tsx,.d.ts,tsc,tsgo,tsconfig.json,strict,erasableSyntaxOnly,noUncheckedIndexedAccess,exactOptionalPropertyTypes,noImplicitOverride,unknown,interface,satisfies,as-const,import-type,brand,generics,discriminated-union,type-guard,assertNever,Result,using,Zod,Zod-v4,safeParse,Standard-Schema,JS-to-TS,allowJs,checkJs,skipLibCheck,project-references,composite,moduleResolution,Biome,Oxlint,tsgolint,ESLint,@typescript-eslint,tsx,Turborepo,Nx,Vitest,expectTypeOf,Jest}|SUB:{zod,javascript,typescript-patterns,tooling-and-config}"
---
@SKL:typescript
§R{
  first⇒detect(versions,tooling:`npx tsc --version`,`node -v`,devDependencies,monorepo_files);
  verify⇒(`npx tsc --noEmit`∨`npm run -s typecheck`)∧tests(non_watch);build⇔output_Δ;
  tsconfig_req⇒strict+noUncheckedIndexedAccess+noImplicitOverride+exactOptionalPropertyTypes+noPropertyAccessFromIndexSignature+verbatimModuleSyntax+erasableSyntaxOnly;
  ts6_7_ready⇒moduleResolution("bundler"∨"nodenext")+explicit(`types:["node"]`)+subpath_imports(`#/*`)¬`baseUrl`¬`moduleResolution:"node"`;
  any_implicit≡∅;use(unknown∧narrow);
  public_API⇒declare_return_types;locals⇒infer;
  object_shapes⇒interface;unions|tuples|mapped⇒type;literal_unions(`as const`)≻enum(¬erasable);
  domain_primitives(IDs,units)⇒brand(prevent_mixing);
  shape_check+literal_preserve⇒`satisfies`;recursive_type_depth≤10;
  type_only_imports⇒`import type`∧¬circular_type_imports;
  external_data@boundary⇒validate(Zod_v4∨Standard_Schema)∧trust_types_inside;
  errors⇒extends(Error)+`{cause}`+`Error.isError`(ES2026,fallback_`instanceof`);expected⇒`Result<T,E>`;
  resources(handles,locks,conns)⇒`using`/`await using`(`Symbol.dispose`/`asyncDispose`)¬nested_try_finally;
  runtime_ts⇒Node22.18+/24+(`node f.ts`,erasable_`.ts`)⊕`tsx`(`.tsx`/JSX/decorators)¬`ts-node`;
  async_control⇒`AbortSignal.timeout`/`AbortSignal.any`∧`Promise.try`(sync+async_norm)
}
§D{
  err_type_instantiation_excessively_deep⇒interface_over_big_intersections+split_unions(>100)+break_recursion(aliases)¬cast_any;
  slow_typecheck⇒`--extendedDiagnostics`+incremental+precise(include,exclude)+explicit_`types:[]`∨TS7(`tsgo`)¬disable_strict;
  lib_type_errors_block_build⇒`skipLibCheck: true`¬patch_node_modules_types;
  ts6_upgrade_deprecations⇒fix(`baseUrl`→`#/*`,`node10`→`bundler|nodenext`,explicit_`types`)∨temp_`ignoreDeprecations:"6.0"`+`--stableTypeOrdering`¬stay_stuck;
  JS_to_TS_migration⇒allowJs+checkJs+rename_1_file_at_a_time+raise_strictness_stepwise¬big_bang_rename;
  monorepo⇒project_references+`composite: true`¬single_giant_tsconfig;
  runtime_err_cannot_find_module⇒match(moduleResolution,bundler|nodenext)+`package.json`_`imports`(`#/*`)¬deprecated_`baseUrl`¬rewrite_relative_paths;
  untyped_pkg⇒ambient(`declare module`∈`types/*.d.ts`)¬`// @ts-ignore`_on_import;
  lint_format(greenfield|standard_app)⇒Biome_v2(single_bin+built_in_type_aware)¬ESLint+Prettier;
  lint(large_monorepo∨ESLint_rule_parity)⇒Oxlint+`tsgolint`(`--type-aware`)+`oxfmt`¬slow_Node_lint;
  custom_JS_AST_plugins∨complex_Vue/Angular/Svelte⇒ESLint_v9/v10(flat_config)+`@typescript-eslint`¬legacy_.eslintrc;
  monorepo_tool⇒Turborepo(pkgs<20)⊕Nx(pkgs>50,graph_view)¬Nx_for_tiny_repos;
  published_types⇒Vitest_v4(`--typecheck`+`expectTypeOf`)¬runtime_only_tests
}
§REF{
  analysis_cmds,strict_tsconfig,ts6_ts7_tsgo,erasableSyntaxOnly,node_native_ts,Biome_v2,Oxlint,Vitest_v4,DeepReadonly,perf_fixes,migration,monorepo_tsconfig,type_tests,debugging,err_fixes,checklist→references/tooling-and-config.md;
  unknown>any,unions+assertNever,brands,generics,predicates,Result,using_dispose,async_fanout,AbortSignal,module_boundaries,anti_patterns→references/typescript-patterns.md;
  Zod_v4,z.email,z.stringbool,z.treeifyError,z.flattenError,z.toJSONSchema,z.codec,recursive_getters,zod_mini,Standard_Schema,forms,server_actions,env_vars→references/zod.md;
  JS_coercion,closures,this,event_loop,prototypes,ES2023-2026(iterators,Set_methods,Promise.try,using,Error.isError,Temporal)→references/javascript.md
}
§REL{
  ../node/SKILL.md:Node_proj_setup,scripts,.nvmrc;
  ../frontend-development/SKILL.md:React_Nextjs_with_TS;
  ../fullstack-development/SKILL.md:stack_choice,scaffolding;
  ../unit-testing-patterns/SKILL.md:Vitest,Jest,Playwright,testing;
  ../clean-code/SKILL.md:naming,fn_design,deslop
}
