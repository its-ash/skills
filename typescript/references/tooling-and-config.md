@REF:tooling-and-config

§CMD{
analyze:`npx tsc --version && node -v`;
`node -e "const p=require('./package.json');console.log(Object.keys({...p.devDependencies,...p.dependencies}).join('\n'))" | grep -E 'biome|eslint|prettier|vitest|jest|turborepo|nx' || echo 'No tooling detected'`;
`ls pnpm-workspace.yaml lerna.json nx.json turbo.json 2>/dev/null`#⇒monorepo;
`npm run -s typecheck || npx tsc --noEmit`;`npm test -s || npx vitest run --reporter=basic --no-watch`;`npm run -s build`#iff Δ⇒out;
perf:`npx tsc --extendedDiagnostics --incremental false | grep -E "Check time|Files:|Lines:|Nodes:"`;
migrate:`npx ts-migrate migrate . --sources 'src/**/*.js'`;`npx typesync`#+@types;
debug:`npx ts-node --inspect-brk src/file.ts`;`npx tsc --traceResolution > resolution.log && grep "Module resolution" resolution.log`;`npx tsc --generateTrace trace --incremental false && npx @typescript/analyze-trace trace`;`node --max-old-space-size=8192 node_modules/typescript/lib/tsc.js`
}

§CFG{
strict([typescript-patterns.md](typescript-patterns.md#1-strict-mode-is-the-baseline)):`compilerOptions:{strict,noUncheckedIndexedAccess,noImplicitOverride,exactOptionalPropertyTypes,noPropertyAccessFromIndexSignature,skipLibCheck,incremental}:true`;
monorepo_root(proj_refs⇒Δ_pkg_only):`references:[{path:"./packages/core"},...],compilerOptions:{composite:true,declaration:true,declarationMap:true}`
}

§PAT{
brands∧`satisfies`⇒[typescript-patterns.md](typescript-patterns.md);
deep_readonly(depth≤10):`type DeepReadonly<T>=T extends(...a:any[])=>any?T:T extends object?{readonly[K in keyof T]:DeepReadonly<T[K]>}:T`;
const_union:`const r=[...]as const;type R=typeof r[number]`;
vitest_type_test(libs,generics,APIs):`import{expectTypeOf}from'vitest';expectTypeOf<T>().toHaveProperty('k');expectTypeOf<T['k']>().toEqualTypeOf<'a'|'b'>()`;
ambient(`types/ambient.d.ts`):`declare module 'pkg'{const v:unknown;export default v;export=v;}`#CJS
}

§D{
lint_fmt(fast,coarse_OK)⇒Biome;lint(custom|Vue|Angular|type_aware)⇒ESLint+`@typescript-eslint`;type_tests(`expectTypeOf`)⇒Vitest;
monorepo(<20)⇒Turborepo;(>50∨graph_viz)⇒Nx;
excessive_instantiation_depth⇒{intersections→`interface`;split_unions(>100);rm_circular_generics;intermediate_aliases};
build_speed⇒{`skipLibCheck:true`(lib_OK);`incremental:true`+`.tsbuildinfo`;precise(`include`,`exclude`);monorepo⇒proj_refs(`composite:true`)};
js→ts⇒[1:`allowJs:true,checkJs:true`,2:`.js`→`.ts`(1/step,+types),3:gradual_`strict`,4:`ts-migrate`∨`typesync`]
}

§R{
err("The inferred type of X cannot be named")⇒export_type∨`ReturnType<typeof fn>`∨`import type`(break_circular);
err(missing_decls)⇒ambient_module;
err(excessive_stack_depth)⇒limit_recursion∧recursive_intersections→`interface`;
err("Cannot find module"@runtime)⇒match(`moduleResolution`,bundler)∧align(`baseUrl`/`paths`,loader)∧`ts-node -r tsconfig-paths/register`∧`rm -rf node_modules/.cache .tsbuildinfo`
}

§CHK{
¬implicit_any(`unknown`∨explicit);public_API_return_types;`interface`@shapes;brands@primitives;¬circular_type_imports;linter_cfg_match;published_lib_type_tests;CI_build_test(¬watch);runtime_path_mapping;custom_errors(`extends Error`+stack)
}
