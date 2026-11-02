# TypeScript Tooling, Config, and Debugging

## Project analysis workflow
```bash
npx tsc --version && node -v
node -e "const p=require('./package.json');console.log(Object.keys({...p.devDependencies,...p.dependencies}).join('\n'))" | grep -E 'biome|eslint|prettier|vitest|jest|turborepo|nx' || echo 'No tooling detected'
ls pnpm-workspace.yaml lerna.json nx.json turbo.json 2>/dev/null   # any hit = monorepo
npm run -s typecheck || npx tsc --noEmit
npm test -s || npx vitest run --reporter=basic --no-watch
npm run -s build   # only if the change affects output
```

## Strict compiler configuration
Recommended base. Adjust flags per project. Extra flags: see [typescript-patterns.md](typescript-patterns.md#1-strict-mode-is-the-baseline).
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

## Type patterns not in typescript-patterns
Brands and `satisfies`: see [typescript-patterns.md](typescript-patterns.md).
```typescript
// Recursive conditional type. Keep recursion depth ≤ 10 to avoid compiler errors.
type DeepReadonly<T> = T extends (...args: any[]) => any ? T
  : T extends object ? { readonly [K in keyof T]: DeepReadonly<T[K]> } : T;

// Const assertion → literal union
const routes = ['/home', '/about', '/contact'] as const;
type Route = typeof routes[number];
```

## Performance optimization
### Type-check speed
```bash
npx tsc --extendedDiagnostics --incremental false | grep -E "Check time|Files:|Lines:|Nodes:"
```
"Type instantiation is excessively deep":
- Replace large intersections with `interface`.
- Split unions > 100 members.
- Remove circular generic constraints.
- Break recursion with intermediate type aliases.

### Build speed
- `skipLibCheck: true` when library type errors are acceptable.
- `incremental: true`; keep the `.tsbuildinfo` cache.
- Precise `include`/`exclude`.
- Monorepo: project references with `composite: true`.

## Migration (JS → TS, incremental)
1. Set `"allowJs": true, "checkJs": true`.
2. Rename `.js` → `.ts` one file at a time; add explicit types.
3. Turn on `strict` options step by step.
4. Optional helpers: `npx ts-migrate migrate . --sources 'src/**/*.js'`, `npx typesync` (installs missing `@types`).

## Monorepo root tsconfig
Project references limit recompilation to changed packages.
```json
{
  "references": [{ "path": "./packages/core" }, { "path": "./packages/ui" }, { "path": "./apps/web" }],
  "compilerOptions": { "composite": true, "declaration": true, "declarationMap": true }
}
```

## Tooling choices
| Need | Pick |
|---|---|
| Fast lint + format, coarse rules OK | Biome |
| Custom rules, Vue/Angular, type-aware lint | ESLint + `@typescript-eslint` |
| Type tests (`expectTypeOf`) | Vitest |
| Simple monorepo (< 20 packages) | Turborepo |
| Complex graph (> 50 packages), visualization | Nx |

## Type testing with Vitest
Use for published libraries, generic utilities, and API contracts.
```typescript
import { expectTypeOf } from 'vitest';
import type { Avatar } from './avatar';

test('Avatar props are typed', () => {
  expectTypeOf<Avatar>().toHaveProperty('size');
  expectTypeOf<Avatar['size']>().toEqualTypeOf<'sm' | 'md' | 'lg'>();
});
```

## Debugging
```bash
npx ts-node --inspect-brk src/file.ts                       # debug one file
npx tsc --traceResolution > resolution.log && grep "Module resolution" resolution.log
npx tsc --generateTrace trace --incremental false && npx @typescript/analyze-trace trace
node --max-old-space-size=8192 node_modules/typescript/lib/tsc.js   # large projects
```

## Common error fixes
| Error | Fix |
|---|---|
| "The inferred type of X cannot be named" | Export the type; use `ReturnType<typeof fn>`; use `import type` to break circular deps |
| Missing declarations for a package | Add an ambient module (below) |
| Excessive stack depth | Limit recursion; replace recursive intersections with interfaces |
| "Cannot find module" at runtime | Match `moduleResolution` to the bundler; align `baseUrl`/`paths` with the runtime loader; `ts-node -r tsconfig-paths/register`; `rm -rf node_modules/.cache .tsbuildinfo` |

```typescript
// types/ambient.d.ts
declare module 'some-untyped-package' {
  const value: unknown;
  export default value;
  export = value; // CJS interop
}
```

## Review / migration checklist
- [ ] No implicit `any`; use `unknown` or explicit types.
- [ ] `strict` flags on.
- [ ] Public APIs declare return types.
- [ ] `interface` for object shapes.
- [ ] Brands for domain primitives.
- [ ] No circular type imports.
- [ ] `skipLibCheck` only when library issues are acceptable.
- [ ] Project references per monorepo package.
- [ ] Linter config matches the chosen tool.
- [ ] Type tests for exported types of published libraries.
- [ ] CI runs build and tests without watch mode.
- [ ] Runtime path mapping handled.
- [ ] Custom error classes extend `Error` and capture the stack trace.
