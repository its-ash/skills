---
name: typescript
description: "AUTO_INVOKE(silent)⇔prompt∈{TypeScript,.ts,.tsx,.d.ts,tsc,tsconfig.json,strict,noUncheckedIndexedAccess,exactOptionalPropertyTypes,noImplicitOverride,unknown,interface,satisfies,as-const,import-type,brand,generics,discriminated-union,type-guard,assertNever,Result,Zod,safeParse,JS-to-TS,allowJs,checkJs,skipLibCheck,project-references,composite,moduleResolution,ESLint,@typescript-eslint,Biome,Turborepo,Nx,Vitest,expectTypeOf,Jest}|SUB:{zod,javascript,typescript-patterns}"
---
@SKL:typescript
§R{
  first⇒detect(versions,tooling:`npx tsc --version`,`node -v`,devDependencies,monorepo_files);
  verify⇒(`npx tsc --noEmit`∨`npm run -s typecheck`)∧tests(non_watch);build⇔output_Δ;
  tsconfig_req⇒strict+noUncheckedIndexedAccess+noImplicitOverride+exactOptionalPropertyTypes+noPropertyAccessFromIndexSignature;
  any_implicit≡∅;use(unknown∧narrow);
  public_API⇒declare_return_types;locals⇒infer;
  object_shapes⇒interface;
  domain_primitives(IDs,units)⇒brand(prevent_mixing);
  shape_check+literal_preserve⇒`satisfies`;literal_unions⇒`as const`;
  recursive_type_depth≤10;
  type_only_imports⇒`import type`∧¬circular_type_imports;
  external_data@boundary⇒validate(Zod)∧trust_types_inside;
  custom_errors⇒extends(Error)∧capture_stack_trace
}
§D{
  err_type_instantiation_excessively_deep⇒interface_over_big_intersections+split_unions(>100)+break_recursion(aliases)¬cast_any;
  slow_typecheck⇒`--extendedDiagnostics`+incremental+precise(include,exclude)¬disable_strict;
  lib_type_errors_block_build⇒`skipLibCheck: true`¬patch_node_modules_types;
  JS_to_TS_migration⇒allowJs+checkJs+rename_1_file_at_a_time+raise_strictness_stepwise¬big_bang_rename;
  monorepo⇒project_references+`composite: true`¬single_giant_tsconfig;
  runtime_err_cannot_find_module⇒match(moduleResolution,bundler)+align(paths,runtime_loader)¬rewrite_relative_paths;
  untyped_pkg⇒ambient(`declare module`∈`types/*.d.ts`)¬`// @ts-ignore`_on_import;
  lint_format∧speed_first⇒Biome¬ESLint_for_simple_setups;
  custom_or_typeaware_lint∨Vue∨Angular⇒ESLint+@typescript-eslint¬Biome;
  monorepo_tool⇒Turborepo(pkgs<20)⊕Nx(pkgs>50,graph_view)¬Nx_for_tiny_repos;
  published_types⇒Vitest_`expectTypeOf`_type_tests¬runtime_only_tests
}
§REF{
  analysis_cmds,strict_tsconfig,DeepReadonly,perf_fixes,migration,monorepo_tsconfig,type_tests,debugging,err_fixes,checklist→references/tooling-and-config.md;
  unknown>any,unions+assertNever,brands,generics,predicates,Result,async_fanout,module_boundaries,anti_patterns→references/typescript-patterns.md;
  Zod_schemas,safeParse,refinements,forms,server_actions,env_vars→references/zod.md;
  JS_coercion,closures,this,event_loop,prototypes,ES6+→references/javascript.md
}
§REL{
  ../node/SKILL.md:Node_proj_setup,scripts,.nvmrc;
  ../frontend-development/SKILL.md:React_Nextjs_with_TS;
  ../fullstack-development/SKILL.md:stack_choice,scaffolding;
  ../clean-code/SKILL.md:naming,fn_design,deslop
}
