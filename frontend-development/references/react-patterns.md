@REF:react-patterns
§SCOPE{TS+React19;hooks;state_scope;UI_states;RSC/Actions;type-safe_routing;perf/useEffect}
§DESIGN{
  SRP:1_resp/comp∧small∧focused;flow:props↓∧events↑(callbacks);compose>inherit(children,Context,render_props);
  types:{Server:fetch/static|state=∅;Client:interactivity/events|state=useState+effect;Presentational:pure_UI|state=props_only;Container:fetch/heavy|state=useState/useReducer/Context};
  a11y:semantic_HTML(<button>,<a>,<nav>,<main>)>role∧keyboard_reachable∧(<label htmlFor>∨icon_aria-label)∧focus_mgmt(route_Δ,modal_open/close)∧axe_in_tests
}
§HOOKS{
  extract⇔same_hook_seq≥2_comps∨{useLocalStorage:shared_storage,useDebounce:multi_debounced,useFetch:repeated_fetch,useForm:complex_form};
  R:{top_level_only;stable_call_order/render;prefix="use";cleanup_in_useEffect_return;explicit_TS_types∧tuple_return="as const"};
  ex:`function useToggle(init=false){const[v,setV]=useState(init);return[v,()=>setV(x=>!x)]as const;}`
}
§STATE{
  loc:{1_comp⇒useState|useReducer;parent+few_descendants⇒lift_to_nearest_common_ancestor;subtree|distant_low-freq(theme,auth,locale)⇒Context;global|high-freq_cross-tree⇒Zustand|Jotai|RTK;server-derived⇒TanStackQuery|SWR|RSC_fetch};
  note:most_pages⇒¬(Context∨global_store)
}
§R19{
  useActionState:replaces_useFormState(forms);
  use:unwrap(promise|async_res)_in_render→suspends_until_resolved(¬await_promise_before_passing_to_use());
  useOptimistic:optimistic_UI(≈ReactQuery_optimisticUpdates);
  ref_prop:forwardRef_deprecated⇒pass_ref_as_prop(`type P={ref?:React.Ref<HTMLButtonElement>}&React.ComponentPropsWithoutRef<'button'>;function Btn({ref,children,...r}:P){return<button ref={ref}{...r}>{children}</button>;}`)
}
§COMP{
  compound:Parent_creates_Context∧Children_consume(Tabs,Accordion);
  choice:{reusable_logic⇒custom_hook;render_flexibility⇒render_prop;cross-cutting⇒HOC}
}
§TS{
  props:`& React.ComponentPropsWithoutRef<'tag'>`;children:`React.ReactNode`;single_el:`React.ReactElement`;variants⇒discriminated_unions;
  events:¬any⇒exact(`React.MouseEvent<HTMLButtonElement>`,`React.ChangeEvent<HTMLInputElement>`);
  generic:`type Column<T>={key:keyof T;header:string;render?:(v:T[keyof T],item:T)=>React.ReactNode};type TableProps<T>={data:T[];columns:Column<T>[];keyExtractor:(item:T)=>string|number};`∧constrain(`T extends {id:string|number}`)
}
§UI_STATE{
  loading_golden_rule:show_loading_ONLY_when_!data(`if(error)return <ErrorState error={error} onRetry={refetch}/>;if(loading&&!data)return <LoadingState/>;if(!data?.items.length)return <EmptyState/>;return <ItemList items={data.items}/>;`);
  loading_ui:{known_shape⇒skeleton;unknown|modal⇒spinner};
  btn:`isLoading={isSubmitting} disabled={!isValid||isSubmitting}`(¬double_click);
  empty:mandatory_∀list(`<FlatList data={items} ListEmptyComponent={<EmptyState title="No items yet"/>}/>`)∧contextual_copy(search_empty vs new_collection)
}
§ERR_SUSPENSE{
  eb_scope:{app⇒root;feature/route⇒wrap_route;risky_comp⇒direct_wrap};
  recovery:{fallback_UI;log(e.g.Sentry);retry_btn;preserve_valid_input};
  ErrorState:`interface ErrorStateProps{error:Error;onRetry?:()=>void;title?:string}`(fallback `title??'Something went wrong'`);
  wrap:`<ErrorBoundary fallback={<ErrorView/>}><Suspense fallback={<UserSkeleton/>}><UserDetail id={id}/></Suspense></ErrorBoundary>`;
  R:{place_Suspense_near_data(¬route_root)⇒progressive_stream;EB=class_API⇒use_react-error-boundary;catches=render|lifecycle|ctor(¬event_handlers∧¬async)}
}
§RSC_FORMS{
  boundary:{RSC:default,async,0_client_JS,notFound();pass_serializable_props|children_server→client;¬import_RSC_into_'use client'⇒compose_via_children;separate_.server.tsx∧.client.tsx};
  server_action:`'use server'`+`revalidatePath(...)`;call_via:`<form action={...}>`∨event_handler(`useTransition`/`startTransition(()=>act(id))`);
  form_R19:`const[state,formAction,pending]=useActionState(action,init)`+Zod `safeParse(Object.fromEntries(fd))`+`<p role="alert">{state.error}</p>`;
  controlled_inputs⇔value_drives_other_UI∨format_per_keystroke∨live_validation;complex_forms(multi-step,field_arrays,cross-field)⇒ReactHookForm|TanStackForm;
  optimistic:`const[opt,addOpt]=useOptimistic(msgs,(s,m:Msg)=>[...s,m]);`
}
§FETCH{
  Next_AppRouter_per-req⇒RSC `await fetch()`;
  client_cache+mutations+invalidation⇒TanStackQuery;
  light_client_cache+revalidation⇒SWR;
  realtime⇒SSE|WebSockets|lib_sub_API;
  fire-and-forget⇒`fetch()`_in_event_handler;
  ¬(useEffect+fetch)⇔race_conds∧¬cache∧¬retry∧¬Suspense
}
§ROUTE{
  TanStackRouter_v2+:`const r=createRoute({path:'/users/$userId',component:UserPage,loader:async({params})=>({user:await fetchUser(params.userId)}),validateSearch:z.object({tab:z.enum(['profile','settings']).optional(),page:z.number().int().positive().default(1)})})`→`useLoaderData({from:r.id})`,`useSearch({from:r.id})`,`useParams({from:r.id})`;
  ReactRouter_v7:`import type{Route}from'./+types/user';export async function loader({params}:Route.LoaderArgs){...} export default function UserPage({loaderData}:Route.ComponentProps){...}`
}
§EFFECT_PERF{
  render_purity:compute_derived_during_render(¬useState+useEffect);¬(effects|mutations|network|subs)_in_render_body;use_functional_updater(`setX(p=>p+1)`)_when_dep_on_prev;
  ¬useEffect:{derived_data⇒render|useMemo;reset_state_on_prop_Δ⇒key_prop;user_events⇒event_handler;notify_parent⇒call_parent_cb_directly};
  useEffect:{sync_external/non-React/browser_APIs;sub_external_stores(prefer_useSyncExternalStore);mount/unmount_analytics/logging;fetch_needing_cleanup(AbortController/unsub)};
  perf_order:1.ReactProfiler→2.bottleneck→3.smallest_fix→4.re-measure;default=¬memoize;
  React.memo_ONLY_if:(frequent_rerender ∧ props_usually_equal ∧ measurably_expensive);
  cascades:{move_state_down;split_Context_per_concern(ThemeContext≠NotificationsContext);useSyncExternalStore(concurrent_safe);virtualize(>~50_non-trivial_visible_rows)@tanstack/react-virtual|react-window}
}
§ANTI{
  ¬deep_prop_drill(⇒Context|store);¬monolith_comp;¬useEffect_derived_state;¬premature_opt;¬array_idx_key(⇒stable_ID);¬forwardRef_R19(⇒ref_prop);¬silent_err;¬mix_server_client_file;¬missing_effect_cleanup;¬un-dep_state_update_in_effect
}
§CHK{
  SRP;ComponentPropsWithoutRef+ReactNode;correct_state_scope;hooks_extracted(≥2_uses);UI_states(loading_iff_!data,err+retry,empty,disabled_btn);EB_placed;profile_before_memo;¬unnecessary_useEffect;R19(ref_prop,useActionState,use());RSC≠Client;type-safe_routing;tests(unit_hooks,integration_comp,E2E_flows)
}
§REFS{ReactDocs(Hooks,RSC,use());ReactQuery/SWR;TanStackRouter;ReactRouter_v7;Zustand/RTK;ReactProfiler}
