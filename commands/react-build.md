---
description: "Fix React build/bundler/hydration failures incrementally via react-build-resolver agent."
---
@CMD:react-build
agent:react-build-resolver
skills:[`frontend-development/SKILL.md`,`frontend-development/references/react-patterns.md`]
scope:React build/bundler/runtime hydration(Vite,Next.js,Bun,esbuild,webpack,Parcel,legacy CRA);pure TS(¬React)⇒`/build-fix`
triggers:[build fail,JSX/TSX err post-upgrade,Next.js hydration mismatch,RSC/Client boundary err,React/bundler upgrade,missing types/module not found]
§FLOW{
  1_DETECT:identify bundler(Vite|Next.js|Bun|esbuild|webpack|Parcel|CRA)
  2_DIAG:
    build:`npm run build --if-present` | `pnpm build 2>/dev/null` | `yarn build 2>/dev/null` | `bun run build 2>/dev/null`
    types:`npm run typecheck --if-present` | `tsc --noEmit -p tsconfig.json`
    fallback:`next build` | `vite build` | `react-scripts build` | `webpack --mode=production` | `parcel build src/index.html` | `bun build ./src/index.tsx --outdir=dist`
  3_PARSE:group errors by layer→order[1:Compile/TS,2:Hydration,3:Bundler_cfg](+runtime)
  4_FIX:1 error/step→re-run build after each Δ;minimal changes(¬`// @ts-ignore` w/o reason)
  5_VERIFY:re-run full build∧tests→report(§OUT)
}
§FIX_MAP{
  `'React' is not defined`⇒`tsconfig` `"jsx": "react-jsx"`
  `middleware.ts` ignored/deprecated(Next.js 16)⇒rename `proxy.ts`∧export `proxy`
  missing `@types/react`⇒`npm i -D @types/react @types/react-dom`
  `Unexpected token '<'`⇒add `@vitejs/plugin-react`∨`babel-loader`
  `importing component that needs useState`(Next.js)⇒add `"use client"`∨move hook to Client Component child
  `Module not found: 'fs'`(Next.js)⇒remove `fs` import∨move to Server Component/API route
  `Hydration failed`⇒move `Date.now()`/`Math.random()`/`window.*` to `useEffect`
  `Invalid hook call`⇒dedupe React copies via `resolutions`/`overrides`
  `Element type is invalid`⇒fix default vs named import mismatch
}
§GATE{
  STOP∧report if:same error>`3` attempts ∨ fix adds more errors than resolved ∨ requires arch change(e.g. RSC boundary redesign) ∨ bundler version incompatible w/ installed React major
}
§OUT{
  `# React Build Resolution`:Build System,Initial Diagnostics,Fixes Applied,Final Verification,Summary(errors_fixed,files_modified,deps_added,remaining),`Build Status: PASS|FAIL`
}
§REL{
  `/react-test`(post-green),`/react-review`(post-build),`/build-fix`(generic non-React)
}
