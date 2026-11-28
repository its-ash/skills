@REF:tooling-and-config

§CMD{
  analyze:`npx tsc --version && node -v`;
  detect:`node -e "const p=require('./package.json');console.log(Object.keys({...p.devDependencies,...p.dependencies}).join('\n'))" | grep -E 'biome|oxlint|oxfmt|eslint|prettier|vitest|jest|tsx|turborepo|nx' || echo 'No tooling detected'`;
  monorepo:`ls pnpm-workspace.yaml lerna.json nx.json turbo.json 2>/dev/null`;
  verify:`npm run -s typecheck || npx tsc --noEmit`;`npm test -s || npx vitest run`;`npx vitest typecheck`#type_tests;`npm run -s build`#iff Δ⇒out;
  lint_fmt:Biome_v2:`npx biome check --write .`;Oxlint:`npx oxlint --type-aware .`;ESLint_flat:`npx eslint .`;
  perf:`npx tsc --extendedDiagnostics --incremental false | grep -E "Check time|Files:|Lines:|Nodes:"`;`npx tsc --noEmit --stableTypeOrdering`#TS6→TS7_order_preview;
  run_debug:native_Node22.18+/24+(`erasable_.ts`):`node src/file.ts`∧`node --inspect-brk src/file.ts`;`.tsx`/JSX/decorators:`npx tsx --inspect-brk src/file.ts`;
  trace:`npx tsc --traceResolution > resolution.log && grep "Module resolution" resolution.log`;`npx tsc --generateTrace trace --incremental false && npx @typescript/analyze-trace trace`;`node --max-old-space-size=8192 node_modules/typescript/lib/tsc.js`;
  migrate:`npx typesync`#+@types
}

§CFG{
  strict_base([typescript-patterns.md](typescript-patterns.md)):`compilerOptions:{strict,noUncheckedIndexedAccess,noImplicitOverride,exactOptionalPropertyTypes,noPropertyAccessFromIndexSignature,verbatimModuleSyntax,erasableSyntaxOnly,skipLibCheck,incremental}:true`;
  native_node_ts(Node22.18+/24+_type_stripping):`compilerOptions:{target:"esnext",module:"nodenext",moduleResolution:"nodenext",erasableSyntaxOnly:true,verbatimModuleSyntax:true,allowImportingTsExtensions:true,noEmit:true,types:["node"]}`;
  bundler_app:`compilerOptions:{module:"esnext",moduleResolution:"bundler",verbatimModuleSyntax:true,erasableSyntaxOnly:true,noEmit:true}`;
  ts6_7_bridge:TS6.0≡final_JS_tsc_before_Go_TS7.0(`tsgo`,~10x_faster);TS6_defaults:{`types:[]`(¬auto_load_all_`@types/*`,add_explicit_`types:["node"]`),`rootDir:"."`};TS6_deprecated(removed_TS7):{`baseUrl`,`moduleResolution:"node"|"node10"|"classic"`,`module:"amd"|"umd"|"systemjs"|"none"`,`outFile`,legacy_`assert`_import_assertions(use_`with`)};escape_hatch:`"ignoreDeprecations":"6.0"`+`--stableTypeOrdering`;
  subpath_imports(replaces_`baseUrl`/`tsconfig-paths`):`package.json`→`"imports":{"#/*":"./src/*"}`;
  monorepo_root(proj_refs⇒Δ_pkg_only):`references:[{path:"./packages/core"},...],compilerOptions:{composite:true,declaration:true,declarationMap:true}`;
  vitest4_quiet(`--reporter=basic`_removed_v4):`vitest.config.ts`→`test:{reporters:[['default',{summary:false}]]}`
}

§PAT{
  brands∧`satisfies`⇒[typescript-patterns.md](typescript-patterns.md);
  deep_readonly(depth≤10):`type DeepReadonly<T>=T extends(...a:never[])=>unknown?T:T extends object?{readonly[K in keyof T]:DeepReadonly<T[K]>}:T`;
  const_union(erasable_safe):`const ROLES=['admin','user'] as const;type Role=(typeof ROLES)[number]`;
  vitest_type_test(libs,generics,APIs):`import{expectTypeOf}from'vitest';expectTypeOf<T>().toHaveProperty('k');expectTypeOf<T['k']>().toEqualTypeOf<'a'|'b'>()`;
  ambient(`types/ambient.d.ts`):`declare module 'pkg'{const v:unknown;export default v;}`#ESM;`declare module 'cjs-pkg'{const v:unknown;export=v;}`#CJS_.d.ts_only
}

§D{
  lint_fmt(greenfield|standard_app)⇒Biome_v2(single_bin+built_in_type_aware_Biotype+GritQL_rules);
  lint(large_monorepo|ESLint_parity|CI_speed)⇒Oxlint+`tsgolint`(`--type-aware`)+`oxfmt`;
  lint(custom_JS_AST_plugins|Vue|Angular|Svelte_edge)⇒ESLint_v9/v10(flat_config_`eslint.config.*`,`.eslintrc`_removed_v10)+`@typescript-eslint`;
  run_ts(scripts|CLI|backend_erasable,Node22.18+/24+)⇒native_`node file.ts`+`tsc --noEmit`@CI(Node_strips_types_only,¬typecheck,¬`.tsx`);
  run_ts(`.tsx`|JSX|decorators|non_erasable)⇒`tsx`¬legacy_`ts-node`;
  type_tests(`expectTypeOf`)⇒Vitest_v4(`--typecheck`);
  monorepo(<20)⇒Turborepo;(>50∨graph_viz)⇒Nx;
  excessive_instantiation_depth⇒{intersections→`interface`;split_unions(>100);rm_circular_generics;intermediate_aliases};
  build_speed⇒{`skipLibCheck:true`;`incremental:true`+`.tsbuildinfo`;explicit_`types:[]`(TS6_default);precise(`include`,`exclude`);monorepo⇒proj_refs(`composite:true`);evaluate_TS7(`tsgo`)};
  js→ts⇒[1:`allowJs:true,checkJs:true`,2:`.js`→`.ts`(1/step,+types),3:gradual_`strict`+`erasableSyntaxOnly`,4:`typesync`]
}

§R{
  err("The inferred type of X cannot be named")⇒export_type∨`ReturnType<typeof fn>`∨`import type`(break_circular);
  err(missing_decls)⇒ambient_module;
  err(missing_global_types_post_TS6)⇒add_explicit_`types:["node"]`(TS6_defaults_`types:[]`);
  err(syntax_disallowed_erasableSyntaxOnly)⇒`enum`→`as const`_union,param_props→explicit_fields,runtime_`namespace`→ESM_module,`<T>x`→`x as T`;
  err(excessive_stack_depth)⇒limit_recursion∧recursive_intersections→`interface`;
  err("Cannot find module"@runtime)⇒match(`moduleResolution`,bundler|nodenext)∧use_subpath_`imports`(`#/*`)¬deprecated_`baseUrl`∧`rm -rf node_modules/.cache .tsbuildinfo`
}

§CHK{
  ¬implicit_any(`unknown`∨explicit);public_API_return_types;`interface`@shapes;brands@primitives;`erasableSyntaxOnly`_clean;TS6_7_clean(¬`baseUrl`,¬`node10`,explicit_`types`);¬circular_type_imports;linter_cfg_match(Biome_v2|Oxlint|ESLint_flat);published_lib_type_tests;CI_typecheck_test(¬watch);subpath_imports_aligned;custom_errors(`extends Error`+`{cause}`)
}
