@REF:react-performance
§SYS{target:React19.3+Next.js16;ReactCompiler=ON_by_def⇒¬manual_useMemo/useCallback_for_speed(treat_rerender-*_memo_rules_as_review-only∧strip_unnecessary_memo)}
§WF{1.Profile_baseline(ReactDevToolsProfiler|BrowserPerf)→2.Hotspots(>16ms∨freq_rerender)→3.Classify(waterfall|bundle|server|rerender|rendering)→4.Apply_critical_rule→5.Re-measure(flamegraph+metrics)→6.Iterate}
§R_WATERFALL[CRITICAL]{
  async-defer-await:check_cheap_sync_first(`if(!id)return null`);move_await_into_branch_using_result;
  async-parallel:`Promise.all`_for_independent;nested_lists⇒1_`Promise.all`_per_list(`users.map(async u=>({...u,posts:await getPostsFor(u.id)}))`);
  async-dependencies:`better-all`∨start_early_await_late(`const uP=getUser(id),pP=getPosts(id);const prof=await getProfile(id);if(prof.private)return null;const[u,p]=await Promise.all([uP,pP]);`);
  async-api-routes:start_async_top_of_route→await_just_before_response;
  async-suspense-boundaries:split_sibling_awaits_into_child_RSCs(parallel_fetch)∧wrap_data_sections_in_<Suspense>_near_data+skeleton/min-height(¬CLS)
}
§R_BUNDLE[CRITICAL]{
  bundle-barrel-imports:direct_source_imports(`lucide-react/dist/esm/icons/check`);Next13.5+`optimizePackageImports`_rewrites_listed_pkgs→direct_for_others;
  bundle-dynamic-imports:`next/dynamic(()=>import('./monaco-editor'),{ssr:false})`∨`import()`;static_paths_only(ternary,¬`` `./pages/${name}` ``);
  bundle-defer-third-party:`next/script` `strategy="afterInteractive"|"lazyOnload"`(analytics/logging);
  bundle-conditional:load_module_only_when_flag|action_enables;
  bundle-preload:preload_on_hover/focus
}
§R_SERVER[HIGH]{
  server-cache-react:`React.cache(async id=>...)`(1_DB_query/req);static_I/O_at_module_scope(`readFileSync`);
  server-cache-lru:`node-lru-cache`∨`unstable_cache`_for_cross-req_config/lookups;
  server-serialization:minimal_client_props;¬mutable_module_state_in_RSC/SSR(race⇒use `headers()`,`cookies()`,async_ctx);1_RSC→N_Clients_serializes_N_times⇒lift_Client_comp+pass_`children`;
  server-parallel-fetching:sibling_RSC_children;
  server-after-nonblocking:`import{after}from'next/server'`(Next15+)_post-response_work;
  server-action-sec:∀`'use server'`=public_endpoint⇒authN(`getSession()`)∧authZ(`role`/`id`)_inside_action
}
§R_CLIENT[MED-HIGH]{
  client-swr-dedup:SWR_for_auto_req_dedup+cache;
  client-event-listeners:1_shared_global_listener_via_hook(reuse_fn_ref);scroll⇒`{passive:true}`(¬`preventDefault()`);`localStorage`⇒include_`version`_field(migrate/discard_on_Δ)∧keep_small(sync_blocks_main_thread)
}
§R_RERENDER[MED]{
  rerender-defer-reads:subscribe_only_render_state;read_cb_state_at_call(`useStore.getState().count`);
  rerender-memo:extract_expensive_subtree→`memo`;isolate_ticking_state(`<Clock/>`≠`<ExpensiveList/>`);hoist_default_non-primitives(`const EMPTY:Item[]=[]`);¬define_comp_inside_comp(remounts_children);
  rerender-dependencies:primitive_effect_deps(`[id,name]`);split_independent_hooks;`useRef`_for_frequent_non-render_vals(timestamps,accumulators);
  rerender-derived-state:derived_booleans(`useStore(s=>s.cart.length>0)`);¬`useMemo`_primitives(`x+1`);
  rerender-functional-setstate:`setState(p=>...)`;
  rerender-lazy-state-init:`useState(()=>init())`;
  rerender-transitions:`startTransition`_non-urgent;`useDeferredValue(q)`+`useMemo`;
  manual_when_no_compiler:`useCallback`+`memo`+`useMemo`
}
§R_RENDERING[MED]{
  rendering-content-visibility:`.row{content-visibility:auto;contain-intrinsic-size:auto 80px;}`(long_lists);
  rendering-hoist-jsx:static_JSX_outside_comp;
  rendering-svg-precision:reduce_SVG_path_precision;animate_wrapper_`<div>`(GPU)_¬`<svg>`(triggers_paint);
  rendering-hydration-no-flicker:inline_`<script>`→`document.documentElement.dataset.*`(pre-hydration_theme/locale);`suppressHydrationWarning`_ONLY_on_divergent_leaf(`<time>`),¬tree;
  rendering-conditional-render:ternary(`cond?<A/>:<B/>`)>&&_(avoids_`0`_text_node);
  activity_R19:`<Activity mode="visible|hidden">`(tabs/accordions,keeps_state,cheaper_than_unmount);
  resource_hints:`import{preload,preconnect}from'react-dom'`;`requestIdleCallback`_non-critical
}
§R_JS[LOW-MED]{
  js-batch-dom-css:batch_DOM/style_writes(class_toggles>style_writes);
  js-index-maps:`Map`>`Array.find`;
  js-cache-property-access:cache_obj_prop_in_local_var_in_loops;
  js-cache-function-results:module-level_`Map`;
  js-cache-storage:read_`localStorage`/`sessionStorage`_once;
  js-combine-iterations:merge_`filter`/`map`_into_1_loop;
  js-early-exit:early_return;
  js-hoist-regexp:define_`RegExp`_outside_render/loops;
  js-min-max-loop:simple_loop>sort;
  js-set-map-lookups:`Set`/`Map`_O(1)_checks;
  js-tosorted-immutable:`Array.prototype.toSorted`(¬mutate_`.sort()`)
}
§R_ADV[LOW]{
  advanced-event-handler-refs:store_handlers_in_`ref`;
  advanced-use-latest:`useLatest<T>(v){const r=useRef(v);r.current=v;return r;}`;`useEffectEvent`_vals=stable(omit_from_deps);module_singletons(telemetry/logger)⇒module-scope_flag(¬`useEffect`)
}
§METRICS{
  LCP(main_visual)←Waterfalls,Bundle,ResourceHints;
  INP(interaction_latency,replaced_FID)←Re-render,Rendering,JS;
  CLS(visual_stability)←Rendering(Suspense_placement,img_dims);
  TBT←Bundle,JS,Defer3P;
  also:{TTI,initial_JS_bundle,TTFB(SSR),Profiler_render_time}
}
§ANTI{¬barrel_imports;¬seq_await;¬rerender_large_list_on_tick;¬new_handler/render;¬heavy_calc_in_render;¬3P_tracking_in_critical_path;¬mutating_.sort();¬RegExp/large_obj_inside_comp}
§CHK{profile_baseline;Promise.all;direct_imports;next/dynamic|import();React.cache|LRU;SWR;memo_subtrees;useCallback/useMemo(if_no_compiler);isolate_tick_state;content-visibility:auto;batch_DOM+hoist_RegExp;re-measure}
§REFS{
  https://react.dev/learn/optimizing-performance;
  https://nextjs.org/docs/app/building-your-application/optimizing/dynamic-import;
  https://swr.vercel.app/;
  https://vercel.com/blog/how-we-optimized-package-imports-in-next-js;
  https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices;
  https://github.com/shuding/better-all;
  https://github.com/isaacs/node-lru-cache
}
