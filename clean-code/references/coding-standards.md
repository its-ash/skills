@REF:coding-standards
§REL{../../frontend-development/SKILL.md:React19|state|forms|render|UI;../../backend-development/SKILL.md:services|endpoints|validation|server;../../typescript/SKILL.md:TS7_types|tsconfig|Zod4;deslop.md:post_Δ_cleanup;codehealth-mcp.md:structural_scores}
§R{
  scope:cross_proj_TS_JS_clean_code_floor(¬fw_playbook);
  principles:readability>cleverness∧KISS∧YAGNI∧DRY(3rd_real_dup)∧deep_modules>shallow_wrappers;
  lint_fmt_2026:Biome_v2(unified_Rust_fmt+type_aware_lint)⊕Oxlint(type_aware_via_tsgolint)+Oxfmt(Prettier_compat)⊕ESLint_10(Flat_Config_eslint.config.*_ONLY;eslintrc_removed);
  typecheck_2026:TypeScript_7(tsc_native_Go_GA;tsgo_folded_into_typescript)∧strict:true∧noUncheckedIndexedAccess:true∧erasableSyntaxOnly:true∧import_type;
  dead_code_2026:Knip_for_unused({files,exports,types,deps})_across_repo_and_monorepo;
  naming:var=descriptive(searchQuery,isAuthenticated,totalRevenue)¬(q,flag,x);fn=verb+noun(fetchUserData,calculateScore,isValidEmail);bool=is|has|can|should;const=SCREAMING_SNAKE;
  immutability[CRIT]:ES2023+_copy_methods(arr.toSorted(cmp),arr.toReversed(),arr.toSpliced(...),arr.with(i,v))∧{...obj,k:v}∧structuredClone(x)¬in_place_mutation;
  errors:preserve_cause(throw new Error(msg,{cause:e}))∧check_res.ok_on_fetch∧validate_boundaries_via_safeParse∧log_at_boundary_once¬(swallow∨log_and_rethrow);
  async:Promise.all|Promise.allSettled_for_independent_IO¬seq_await_waterfalls∧AbortSignal.timeout(ms)_for_cancellable_fetches;
  types:explicit_interfaces∧discriminated_unions∧unknown+type_guard¬any∧satisfies+as_const¬loose_casts;
  docs_cmts:cmt_WHY(backoff_Math.min(1000*2**retry,30_000),invariants)¬WHAT;JSDoc_on_public_APIs(@param,@returns,@throws,@example);
}
§D{
  greenfield_TS_JS_lint_fmt⇒Biome_v2_or_Oxlint+Oxfmt¬legacy_eslintrc;
  heavy_custom_eslint_plugins⇒ESLint_10_flat_config¬deprecated_eslintrc;
  sort_or_reverse_array⇒arr.toSorted()/arr.toReversed()¬[...arr].sort()∨arr.sort();
  Zod_v4_string_formats⇒z.iso.datetime()/z.email()/z.uuid()+safeParse()¬deprecated_z.string().datetime()|email()|uuid();
  React_19_with_Compiler⇒omit_manual_useMemo/useCallback¬wrap_every_val_fn(keep_only_for_explicit_external_ref_stability);
  rethrow_wrapped_error⇒new Error(ctx,{cause:e})¬bare_new_Error_dropping_stack;
  project_dead_code⇒knip_in_CI¬manual_grep;
  exponentiation⇒2**n¬Math.pow(2,n);
}
§PAT{
  fetch_safe:`const r=await fetch(url,{signal:AbortSignal.timeout(ms)});if(!r.ok)throw new Error(\`HTTP \${r.status}\`,{cause:r});return await r.json() as unknown`→schema.safeParse;
  zod_v4_boundary:`z.object({name:z.string().min(1).max(200),endDate:z.iso.datetime(),email:z.email()}).safeParse(raw)`∧`z.codec(z.iso.datetime(),z.date(),{decode,encode})`(v4.1+);fail→400_RFC9457(application/problem+json)∨typed_error_envelope;
  react_clean:typed_props_with_defaults∧functional_updater(`setCount(n=>n+1)`)¬stale_closure∧flat_guards¬nested_ternary∧`lazy(()=>import(...))`+`<Suspense>`_for_heavy_chunks;
  api_rest:resource_nouns(`/api/items/:id`),verbs(GET|POST|PUT_full|PATCH_partial|DELETE),bounded_pagination(limit/cursor),explicit_DB_column_select¬`SELECT *`;
  file_org:feature_first∨layered(`src/{app|features,components/ui,hooks,lib,types}`);files:{Button.tsx:PascalCase,useAuth.ts:camelCase+use,formatDate.ts:camelCase,item.types.ts:camelCase+.types};
  test_aaa:Arrange→Act→Assert∧behavior_test_names('returns empty array when query unmatched')¬vague('works');
}
§CMD{
  biome:`npx @biomejs/biome check --write .`;
  oxc:`npx oxlint --type-aware && npx oxfmt --check`;
  eslint10:`npx eslint .`;
  typecheck:`npx tsc --noEmit`;
  dead_code:`npx knip`;
}
§ANTI{
  god_fn(>40L∨cognitive>15)⇒split_cohesively(validate→transform→persist);
  deep_nest(≥3_levels)⇒early_return_guard_clauses;
  magic_nums(retry>3,timeout_500)⇒named_consts(MAX_RETRIES=3,DEBOUNCE_MS=500);
  Zod_v3_chained_formats(z.string().datetime()|email()|uuid())⇒deprecated_in_Zod_v4;
  manual_useMemo/useCallback_everywhere_under_React_Compiler⇒noisy_boilerplate;
  in_place_arr.sort()_or_copy_sort_[...arr].sort()⇒use_arr.toSorted();
  catch_log_and_rethrow_without_cause⇒double_logging+lost_root_cause;
  select_star_or_unbounded_queries⇒select_explicit_cols+limit;
}
§CHK{
  TS7_strict_pass∧¬any_escapes∧ES2023_immutable_ops∧Error.cause_preserved∧Zod_v4_safeParse∧linter_and_knip_clean∧AAA_tests_pass
}
