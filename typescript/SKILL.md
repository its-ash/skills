---
name: typescript
description: "Guides TypeScript compiler options, advanced type patterns, migration, monorepo setup, linting, testing, and debugging. Use when writing .ts, .tsx, or .d.ts; fixing TS errors; configuring tsc, tsconfig.json, strict mode, project references, path aliases; using generics, utility types, type guards, discriminated unions, branded types, conditional types, satisfies, or const assertions; migrating JavaScript to TypeScript; speeding up type-check or build; or setting up workspaces with eslint, jest, or vitest. Sub-skills: zod, javascript, typescript-patterns."
---

# TypeScript
Give precise type, config, migration, and tooling fixes for any TypeScript code base.

## Core rules
- Detect versions and tooling first (`npx tsc --version`, `node -v`, devDependencies, monorepo files).
- Verify with `npx tsc --noEmit` (or `npm run -s typecheck`) and tests in non-watch mode. Build only if output changes.
- Turn on `strict` + `noUncheckedIndexedAccess`, `noImplicitOverride`, `exactOptionalPropertyTypes`, `noPropertyAccessFromIndexSignature`.
- No implicit `any`. Use `unknown` and narrow.
- Declare return types on public APIs; let locals infer.
- Use `interface` for object shapes.
- Brand domain primitives that must not mix (IDs, units).
- Use `satisfies` to check shape and keep literal types; `as const` for literal unions.
- Keep recursive types ≤ 10 levels deep.
- Use `import type` for type-only imports; no circular type imports.
- Validate external data at the boundary with Zod; trust types inside.
- Custom error classes extend `Error` and capture the stack trace.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| "Type instantiation is excessively deep" | `interface` over big intersections; split unions > 100; break recursion with aliases | Cast to `any` |
| Slow type-check | `--extendedDiagnostics`; `incremental`; precise `include`/`exclude` | Turning off `strict` |
| Library type errors block build | `skipLibCheck: true` | Patching `node_modules` types |
| JS → TS migration | `allowJs` + `checkJs`, rename one file at a time, raise strictness step by step | Big-bang rename |
| Monorepo | Project references + `composite: true` | One giant tsconfig |
| "Cannot find module" at runtime | Match `moduleResolution` to bundler; align `paths` with runtime loader | Relative-path rewrites everywhere |
| Untyped package | Ambient `declare module` in `types/*.d.ts` | `// @ts-ignore` on import |
| Lint + format, speed first | Biome | ESLint for simple setups |
| Custom/type-aware lint, Vue/Angular | ESLint + `@typescript-eslint` | Biome |
| Monorepo tool | Turborepo (< 20 pkgs); Nx (> 50 pkgs, graph view) | Nx for tiny repos |
| Published types | Vitest `expectTypeOf` type tests | Runtime-only tests |

## Load on demand
| Need | Read |
|---|---|
| Analysis commands, strict tsconfig, DeepReadonly, perf fixes, migration, monorepo tsconfig, type tests, debugging, error fixes, checklist | [references/tooling-and-config.md](references/tooling-and-config.md) |
| `unknown` over `any`, unions + `assertNever`, brands, generics, predicates, `Result`, async fan-out, module boundaries, anti-patterns | [references/typescript-patterns.md](references/typescript-patterns.md) |
| Zod schemas, `safeParse`, refinements, forms, server actions, env vars | [references/zod.md](references/zod.md) |
| JS coercion, closures, `this`, event loop, prototypes, ES6+ | [references/javascript.md](references/javascript.md) |

## Related skills
- [`node`](../node/SKILL.md) — Node project setup, scripts, `.nvmrc`
- [`frontend-development`](../frontend-development/SKILL.md) — React/Next.js with TypeScript
- [`fullstack-development`](../fullstack-development/SKILL.md) — stack choice and scaffolding
- [`clean-code`](../clean-code/SKILL.md) — naming, function design, deslop
