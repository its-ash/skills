@REF:typescript-patterns

§D{
  scope:app_TS(type_design,narrowing,errors,resources,async,boundaries,dep_hygiene);compiler/monorepo/perf⇒[typescript](../SKILL.md);
  when∈{new_TS_JS,PR_review(.ts/.tsx),refactor(rm_any,stricten,erasable),design(types,generics,boundaries),tsconfig_setup_upgrade,debug(cascading_type_errs⇒design_issue¬annotation)}
}

§R{
  1_strict:`strict:true`(strictNullChecks,noImplicitAny,strictFunctionTypes)≡mandatory;fail⇒migrate¬disable;base=[tooling-and-config.md](tooling-and-config.md)+{`noFallthroughCasesInSwitch`,`noUnusedLocals`,`noUnusedParameters`,`verbatimModuleSyntax`,`erasableSyntaxOnly`};`noUncheckedIndexedAccess`⇒lift_local∧check(`=== undefined`)¬rm_flag;TS6+⇒explicit_`types:["node"]`¬`baseUrl`;
  2_no_any:`any`≡bug⇒`unknown`+narrow;last_resort⇒explicit_loosen+comment¬silent_any;
  3_contracts:public_APIs⇒explicit_params∧return_types;locals⇒inferred;
  4_type_vs_interface:extensible_obj⇒`interface`;unions|intersections|tuples|mapped|utility⇒`type`;`as const`_objs+str_literal_unions≻`enum`(`enum`,runtime_`namespace`,param_props_violate_`erasableSyntaxOnly`∧break_Node_type_stripping);
  5_brands:`declare const brand: unique symbol; type X = string & { [brand]: 'X' }`;validate@boundary⇒cast_inside_validator¬expose_cast_far;
  6_generics:caller_dependent⇒`<T>(..., parse:(raw:string)=>T):T|undefined`¬`unknown`+cast;shape_assumed⇒`T extends SomeShape`;
  7_options:knobs>2⇒options_obj(`options:Opts={}`),require_mandatory¬allOptional;
  8_boundary_val:untrusted_I/O(API,msg,file)⇒validate_once(Zod_v4∨Standard_Schema∨guard)→refined_type_inside;schema_ref:[zod.md](zod.md);
  9_readonly:non_mutated_params⇒`readonly T[]`/`ReadonlyArray<T>`;updates⇒spread∨`toSorted`/`toReversed`/`with`(ES2023);`Object.freeze`@hot_boundaries_only;`readonly`@type_pos;
  10_errors:`try/catch`@actionable_edge¬swallow;narrow `catch(e:unknown)` via `Error.isError(e)`(ES2026_cross_realm;fallback_`e instanceof Error`);sync+async_norm⇒`Promise.try(fn)`(ES2025);expected(val,404,conflict)⇒`Result<T,E>`;unexpected⇒throw;rewrap⇒`new Error(msg,{cause})`¬lose_cause;
  11_resources_null:handles/locks/conns⇒`using`/`await using`(`Symbol.dispose`/`asyncDispose`,ES2026)¬nested_`try/finally`;absent⇒`T|undefined`+`=== undefined`/`=== null`;¬sentinels;¬deep_`?.`+silent_fallback;¬truthiness(`if(x)` breaks `0`|`''`);
  12_boundaries:named_exports>default;re-export@edge(`index.ts`)¬deep_internals;¬barrel_bloat(kills_treeshake∧cold_start)⇒concrete_imports;internal_aliases⇒`package.json`_`"imports":{"#/*":"./src/*"}`¬deprecated_`baseUrl`;circular⇒hoist_shared_type;deps:`domain`→`application`→`infrastructure`(inward_only);contracts¬import_impls;
  13_deps_build:stdlib(`Array`,`Map`,`Set`_ES2025,`Iterator`_helpers,`Promise`,`Intl`,`Temporal`)>micro_deps;pick_1_val_model(schema_first vs type_first);slow_tsc⇒narrow_surface¬relax;`moduleResolution:"bundler"|"nodenext"`;perf⇒[tooling-and-config.md](tooling-and-config.md);
  14_perf:complex_type_gymnastics(mapped,cond,template_lit)⇒boundary_mods_only¬public_API;hot_paths(render,per_msg)⇒¬defensive_re_spread_unchanged;memoize⇒`Map`+explicit_TTL¬unbounded_global;
  15_type_tests:public_contracts⇒Vitest_v4_`--typecheck`+`expectTypeOf`([tooling-and-config.md](tooling-and-config.md));preserve_literals+shape⇒`as const satisfies Record<K,V>`
}

§PAT{
  unchecked_idx:`const [first] = items; if (first === undefined) throw new Error("expected >=1 item");`;
  unknown_narrow:```ts
  const DEFAULT_CFG: Config = { timeout: 30_000, retries: 3 };
  function isRecord(v: unknown): v is Record<string, unknown> { return typeof v === 'object' && v !== null; }
  function toPosInt(v: unknown, f: string): number {
    if (typeof v !== 'number' || !Number.isInteger(v) || v <= 0) throw new TypeError(`Expected ${f}>0 int`);
    return v;
  }
  export function parseConfig(raw: unknown): Config {
    if (!isRecord(raw)) return { ...DEFAULT_CFG };
    return {
      timeout: raw['timeout'] === undefined ? DEFAULT_CFG.timeout : toPosInt(raw['timeout'], 'timeout'),
      retries: raw['retries'] === undefined ? DEFAULT_CFG.retries : toPosInt(raw['retries'], 'retries'),
    };
  }
  ```;
  discriminated_union:```ts
  type Tx = { kind: 'draft'; id: string } | { kind: 'submitted'; id: string; submittedAt: Date } | { kind: 'paid'; id: string; paidAt: Date; amountCents: number };
  function assertNever(v: never): never { throw new Error(`Unhandled: ${JSON.stringify(v)}`); }
  function describe(t: Tx): string {
    switch (t.kind) {
      case 'draft': return 'draft';
      case 'submitted': return t.submittedAt.toISOString();
      case 'paid': return `${t.amountCents}@${t.paidAt.toISOString()}`;
      default: return assertNever(t); // compile err on missing branch
    }
  }
  ```;
  brand:```ts
  declare const brand: unique symbol;
  export type CustomerId = string & { [brand]: 'CustomerId' };
  function ensureCustomerId(v: string): CustomerId {
    if (!/^cus_[a-z0-9]+$/.test(v)) throw new TypeError(`Invalid id: ${v}`);
    return v as CustomerId;
  }
  ```;
  assert_guard:`function assertIsStringArray(v: unknown): asserts v is string[] { if (!Array.isArray(v)) throw new TypeError('Expected string[]'); for (const x of v) if (typeof x !== 'string') throw new TypeError('Expected string[]'); }` // for-of visits sparse holes as undefined;
  boundary_err_id_guard(`[A-Za-z0-9_-]+`):```ts
  function assertUserId(id: string): void {
    if (typeof id !== 'string' || id.length === 0 || /[^A-Za-z0-9_-]/.test(id)) throw new TypeError('Invalid userId');
  }
  async function loadUser(id: string, signal?: AbortSignal): Promise<User> {
    assertUserId(id);
    const sig = signal ? AbortSignal.any([signal, AbortSignal.timeout(5_000)]) : AbortSignal.timeout(5_000);
    const res = await fetch(`/users/${id}`, { signal: sig });
    if (!res.ok) throw new Error(`Failed ${id}: ${res.status}`);
    const data: unknown = await res.json();
    if (!isUser(data)) throw new TypeError(`Invalid payload for ${id}`);
    return data;
  }
  export async function getUser(id: string, signal?: AbortSignal): Promise<User> {
    try { return await loadUser(id, signal); }
    catch (e: unknown) {
      if (Error.isError(e)) throw new Error(`lookup failed: ${e.message}`, { cause: e });
      throw new TypeError('unknown error shape');
    }
  }
  ```;
  using_resource:```ts
  async function withLock<T>(key: string, fn: () => Promise<T>): Promise<T> {
    await using _lock = await acquireLock(key); // auto calls [Symbol.asyncDispose]() on exit/throw
    return await fn();
  }
  ```;
  result:`type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };`;
  async_fanout:independent⇒`Promise.allSettled`(check `status==='fulfilled'`);all_or_nothing⇒`Promise.all`;
  bounded_pool:```ts
  async function mapWithConcurrency<T, R>(items: readonly T[], limit: number, mapper: (x: T) => Promise<R>): Promise<R[]> {
    if (!Number.isInteger(limit) || limit < 1) throw new RangeError(`Bad limit: ${limit}`);
    const out: R[] = new Array(items.length); let next = 0;
    const workers = Array.from({ length: Math.min(limit, items.length) }, async () => {
      while (true) {
        const i = next++; if (i >= items.length) return;
        if (!Object.hasOwn(items, i)) continue; // skip sparse holes; keep present undefined
        out[i] = await mapper(items[i]!);
      }
    });
    await Promise.all(workers); // rejects fast; pass AbortSignal or use allSettled for cancel/partial
    return out;
  }
  ```;
  timeout:prefer_`AbortSignal.timeout(ms)`∧`AbortSignal.any([sig,AbortSignal.timeout(ms)])`;non_abortable_Promise⇒`setTimeout`+`clearTimeout`_in_`finally`;
  satisfies:`const statusByAction = { new: 'open', reopen: 'open', close: 'closed' } as const satisfies Record<Action, Status>;`;
  type_test:`import { expectTypeOf } from 'vitest'; expectTypeOf<Result<User, ValidationIssue[]>>().toEqualTypeOf<{ ok: true; value: User } | { ok: false; error: ValidationIssue[] }>();`
}

§CMD{
  `npx tsc --noEmit`;`npx vitest run`;`npx vitest typecheck`;`npx biome check .`⊕`npx oxlint --type-aware .`⊕`npx eslint .`#flat_config+recommended-type-checked,slow⇒fix_structure¬disable
}

§ANTI{
  `any`_speed_hack⇒`unknown`+narrow;lying_`as`⇒validate_first,cast@validator;nested_callbacks/chains⇒`async/await`;`enum`/runtime_`namespace`/param_props(break_`erasableSyntaxOnly`+Node_type_strip)⇒`as const`_unions/ESM/explicit_fields;god_type⇒discriminated_union∨split;allOptional_opts⇒require_mandatory;silent_catch⇒handle∨rethrow(`{cause}`);`instanceof Error`_cross_realm⇒`Error.isError`;nested_`try/finally`_cleanup⇒`using`/`await using`;`baseUrl`_path_hacks⇒`package.json`_`#/*`;mixed_sync_async_err⇒`async`_fn∨`Promise.try`
}

§REL{
  [typescript](../SKILL.md):compiler_opts,adv_types,migration,monorepo;[tooling-and-config](tooling-and-config.md):tsconfig,TS6_7,Biome,Oxlint,Vitest;[zod](zod.md):Zod_v4_runtime_val;[nestjs](../../backend-development/references/nestjs.md):TS_backend;[frontend-development](../../frontend-development/SKILL.md):React/Next_TS;[prisma](../../database-design/references/prisma.md):TS_DB
}
