---
name: typescript
description: "Guides TypeScript compiler options, advanced type patterns, migration, monorepo setup, linting, testing, and debugging. Use when writing .ts, .tsx, or .d.ts; fixing TS errors; configuring tsc, tsconfig.json, strict mode, project references, path aliases; using generics, utility types, type guards, discriminated unions, branded types, conditional types, satisfies, or const assertions; migrating JavaScript to TypeScript; optimizing type-check or build speed; or setting up workspaces with eslint, jest, or vitest. Sub-skills: zod, javascript, typescript-patterns."
---

# TypeScript Expert

Deliver precise, actionable advice for any TypeScript code base. Analyze the project, apply advanced type patterns, improve build and type‑checking performance, migrate JavaScript to TypeScript, configure monorepos, choose tooling, test types, and debug issues.

## When to use
- Designing shared types, interfaces, or generic utilities.
- Solving complex type‑level errors, conditional or mapped types.
- Migrating a JavaScript project to TypeScript incrementally.
- Optimizing type‑checking or build speed in large or monorepo projects.
- Selecting or configuring linting, formatting, and testing tools.
- Debugging module resolution, runtime path mapping, or custom error handling.

## Project Analysis Workflow
1. Detect core versions.
   ```bash
   npx tsc --version
   node -v
   ```
2. List development dependencies to infer tooling.
   ```bash
   node -e "const p=require('./package.json');
   console.log(Object.keys({...p.devDependencies,...p.dependencies}).join('\n'))" | grep -E 'biome|eslint|prettier|vitest|jest|turborepo|nx' || echo 'No tooling detected'
   ```
3. Detect monorepo configuration.
   ```bash
   if [ -f pnpm-workspace.yaml ] || [ -f lerna.json ] || [ -f nx.json ] || [ -f turbo.json ]; then
     echo 'Monorepo detected'
   fi
   ```
4. Run a fast type‑check.
   ```bash
   npm run -s typecheck || npx tsc --noEmit
   ```
5. Run unit tests without watch mode.
   ```bash
   npm test -s || npx vitest run --reporter=basic --no-watch
   ```
6. Build only if the change affects output.
   ```bash
   npm run -s build
   ```

## Advanced Type System Patterns
### Branded Types (Nominal typing)
```typescript
type Brand<K, T> = K & { __brand: T };
type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;
function processOrder(orderId: OrderId, userId: UserId) { }
```
Use for domain primitives that must not be mixed.

### Recursive Conditional Types
```typescript
type DeepReadonly<T> = T extends (...args: any[]) => any
  ? T
  : T extends object
    ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
    : T;
```
Avoid recursion depth >10 to prevent compiler errors.

### `satisfies` for constraint validation (TS 5.0+)
```typescript
const config = {
  api: "https://api.example.com",
  timeout: 5000,
} satisfies Record<string, string | number>;
```
Preserves literal types while checking shape.

### Const Assertions for literal unions
```typescript
const routes = ['/home', '/about', '/contact'] as const;
type Route = typeof routes[number]; // '/home' | '/about' | '/contact'
```

## Performance Optimization
### Type‑checking speed
```bash
npx tsc --extendedDiagnostics --incremental false | grep -E "Check time|Files:|Lines:|Nodes:"
```
Common fixes for "Type instantiation is excessively deep":
- Replace large intersections with `interface`.
- Split unions larger than 100 members.
- Remove circular generic constraints.
- Break recursion with intermediate type aliases.

### Build speed
- Set `skipLibCheck: true` when library type errors are acceptable.
- Enable `incremental: true` and keep the `.tsbuildinfo` cache.
- Define precise `include`/`exclude` arrays.
- In monorepos, use project references with `composite: true`.

## Migration Strategies
### Incremental JavaScript → TypeScript
1. Add to `tsconfig.json`:
   ```json
   {
     "compilerOptions": { "allowJs": true, "checkJs": true }
   }
   ```
2. Rename files from `.js` to `.ts` one at a time.
3. Add explicit types to each file.
4. Enable `strict` options gradually.
5. Run helper tools if installed:
   ```bash
   npx ts-migrate migrate . --sources 'src/**/*.js'
   npx typesync   # installs missing @types packages
   ```

## Monorepo Configuration
### Root `tsconfig.json`
```json
{
  "references": [
    { "path": "./packages/core" },
    { "path": "./packages/ui" },
    { "path": "./apps/web" }
  ],
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true
  }
}
```
Use `projectReferences` to limit recompilation to changed packages.

## Tooling Choices
- **Biome**: fast lint + format, suitable when speed outweighs rule granularity.
- **ESLint + @typescript-eslint**: required for custom rule sets, Vue/Angular support, or type‑aware linting.
- **Vitest**: preferred for type‑testing with `expectTypeOf`.
- **Turborepo**: simple monorepos (<20 packages).
- **Nx**: complex dependency graphs, >50 packages, need visualization.

## Type Testing with Vitest
```typescript
import { expectTypeOf } from 'vitest';
import type { Avatar } from './avatar';

test('Avatar props are correctly typed', () => {
  expectTypeOf<Avatar>().toHaveProperty('size');
  expectTypeOf<Avatar['size']>().toEqualTypeOf<'sm' | 'md' | 'lg'>();
});
```
Use for library publishing, generic utilities, and API contracts.

## Debugging
1. Run a single file with inspection.
   ```bash
   npx ts-node --inspect-brk src/file.ts
   ```
2. Trace module resolution.
   ```bash
   npx tsc --traceResolution > resolution.log
   grep "Module resolution" resolution.log
   ```
3. Analyze type‑checking performance.
   ```bash
   npx tsc --generateTrace trace --incremental false
   npx @typescript/analyze-trace trace   # if the package is installed
   ```
4. Increase Node memory for large projects.
   ```bash
   node --max-old-space-size=8192 node_modules/typescript/lib/tsc.js
   ```

## Strict Compiler Configuration (recommended base)
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "skipLibCheck": true,
    "incremental": true
  }
}
```
Adjust flags per project needs.

## Common Error Fixes
- **"The inferred type of X cannot be named"**
  1. Export the type from its module.
  2. Use `ReturnType<typeof fn>` instead of inline inference.
  3. Replace type‑only imports with `import type` to break circular deps.
- **Missing declarations**
  ```typescript
  // types/ambient.d.ts
  declare module 'some-untyped-package' {
    const value: unknown;
    export default value;
    export = value; // for CJS interop
  }
  ```
- **Excessive stack depth**
  Limit recursion depth or replace recursive type intersections with interfaces.
- **"Cannot find module" at runtime**
  1. Verify `moduleResolution` matches bundler.
  2. Align `baseUrl` and `paths` with runtime loader.
  3. For `ts-node`, add `-r tsconfig-paths/register`.
  4. Clear caches: `rm -rf node_modules/.cache .tsbuildinfo`.

## Checklist for Review or Migration
- [ ] No implicit `any`; use `unknown` or explicit types.
- [ ] `strict` flags enabled.
- [ ] All public APIs declare return types.
- [ ] Prefer `interface` for object shapes.
- [ ] Branded types used for domain primitives.
- [ ] No circular dependencies in type imports.
- [ ] `skipLibCheck` only when library issues are acceptable.
- [ ] Project references defined for each package in monorepo.
- [ ] Linter configuration matches chosen tool (Biome or ESLint).
- [ ] Type tests exist for exported types when library is published.
- [ ] Build and test scripts run without watch mode in CI.
- [ ] Runtime path mapping handled (e.g., `ts-node -r tsconfig-paths/register`).
- [ ] Custom error classes extend `Error` and capture stack trace.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/zod.md](references/zod.md) | Defines, parses, and validates TypeScript schemas with Zod, including primitives, objects, coercion, refinements, transforms, custom errors, and integrations for forms, Next.js actions, and environment variables. Use when working with zod, z.object, z.string, safeParse, parse, zodResolver, z.infer, schema validation, input validation, form validation, env vars, TypeScript types, Next.js server actions, React Hook Form, or tRPC. |
| [references/typescript-patterns.md](references/typescript-patterns.md) | Application patterns: `unknown` over `any`, explicit public types, discriminated unions with `assertNever`, validated brands, generics, options objects, type predicates and assertion functions, `Result` types, error `cause`, `Promise.allSettled`, bounded concurrency, timeouts, module boundaries, anti-patterns. |
| [references/javascript.md](references/javascript.md) | Reference for JavaScript primitives, type coercion, equality, scope types, var let const hoisting, closures, call stack, this binding, event loop phases, promise async await, prototype inheritance, and ES6+ features like arrow functions destructuring modules. Use when debugging typeof NaN null undefined coercion, fixing closure loop capture, resolving this loss in callbacks, tracing microtask macrotask order, converting callbacks to promises, refactoring prototypes to classes, writing arrow destructuring syntax, setting babel targets, or explaining scope chain shadowing. |

## Related skills

Load these when the task spans more than this skill.

- [`javascript`](references/javascript.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`fullstack-development`](../fullstack-development/SKILL.md) — Fullstack Development skill guides you through planning, scaffolding, coding, testing, and deploying modern we…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`astro`](../frontend-development/references/astro.md) — Astro is a web framework for content‑heavy sites that ships zero JavaScript by default and hydrates interactiv…
