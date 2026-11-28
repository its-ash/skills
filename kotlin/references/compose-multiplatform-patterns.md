@REF:compose-multiplatform-patterns
§SCOPE{Compose_Multiplatform_1.12.2∧Jetpack_Compose(Android,iOS,Desktop,Web/WasmGC):state,Navigation_3,composables,KMP_UI,perf,enableEdgeToEdge,Hot_Reload,M3}
§PAT{state:
  SingleState+StateFlow:immutable `data class`(e.g.`items=emptyList(),isLoading=false,error:String?=null,searchQuery=""`);
    VM(Kotlin_2.4):`val state:StateFlow<S> field = MutableStateFlow(S())`(pre-2.4⇒`_state=MutableStateFlow(S()); val state=_state.asStateFlow()`);
    update:`viewModelScope.launch{state.update{it.copy(isLoading=true)}; uc(q).fold(onSuccess={...},onFailure={e->state.update{it.copy(error=e.message,isLoading=false)}})}`;
  Collect:`vm:VM=koinViewModel()`; `val state by vm.state.collectAsStateWithLifecycle()`→pass state+lambdas to stateless `@Composable private fun Content(state,onSearch)`(preview+test);
  EventSink(complex):`sealed interface Event{Search(query:String); Delete(itemId:String); data object Refresh}`; VM `fun onEvent(e:Event)`; UI passes single `onEvent=vm::onEvent`
}
§PAT{nav(Navigation_3:androidx.navigation3_1.2.2∨KMP_org.jetbrains.androidx.navigation3:navigation3-ui):
  Keys:`@Serializable data object HomeKey:NavKey`; `@Serializable data class DetailKey(val id:String):NavKey`;
  BackStack:`val backStack=rememberNavBackStack(HomeKey)`(push=`backStack.add(DetailKey(id))`;pop=`backStack.removeLastOrNull()`);
  Display:`NavDisplay(backStack=backStack,onBack={backStack.removeLastOrNull()},entryProvider=entryProvider{entry<HomeKey>{HomeScreen(onDetail={backStack.add(DetailKey(it))})}; entry<DetailKey>{k->DetailScreen(k.id,onBack={backStack.removeLastOrNull()})}})`;
  Addons:`lifecycle-viewmodel-navigation3`(entry-scoped_VM)∧`adaptive-navigation3`(M3_multi-pane_list-detail);
  Legacy_Nav2(existing_apps≥2.8):`@Serializable` routes + `NavHost(rememberNavController(),HomeRoute){composable<HomeRoute>{...}; composable<DetailRoute>{it.toRoute<DetailRoute>().id}; dialog<ConfirmDeleteRoute>{...}}`
}
§PAT{composable_design:
  Slot_API:`(modifier:Modifier=Modifier,header:@Composable ()->Unit={},content:@Composable ColumnScope.()->Unit,actions:@Composable RowScope.()->Unit={})` (`Card{Column{header(); Column(content); Row(Arrangement.End,actions)}}`);
  Modifier_order(strict):`1.Layout(.padding(16.dp),size)→2.Shape(.clip(RoundedCornerShape(8.dp)))→3.Draw(.background(),border)→4.Interaction(.clickable{})`;
  DevX(CMP_1.12):unified_`commonMain`@Preview + built-in_Compose_Hot_Reload
}
§PAT{kmp_platform_ui:
  Android_edge_to_edge(enforced_API_35+):`ComponentActivity.onCreate`→`enableEdgeToEdge()`(opt `SystemBarStyle.auto/light/dark`)_before_`setContent{}`; consume_insets_via_`Scaffold` `innerPadding`∨`Modifier.safeDrawingPadding()`/`statusBarsPadding()` (¬deprecated_Accompanist_`rememberSystemUiController`);
  `commonMain`:`@Composable expect fun PlatformBackHandler(enabled:Boolean,onBack:()->Unit)`;
  `iosMain`:`actual`→UIKit_interop∨`Info.plist`+Compose_`WindowInsets`
}
§PAT{perf:
  Strong_Skipping(default):auto-memoizes_lambdas∧skips_unstable_by_instance_eq; still_use_`@Immutable`/`@Stable`+`ImmutableList`(kotlinx.collections.immutable)_for_structural_eq;
  LazyLists:`LazyColumn{items(items,key={it.id},contentType={it.type}){...}}`⇒reuse+anims;
  Defer_reads:`val listState=rememberLazyListState(); val show by remember{derivedStateOf{listState.firstVisibleItemIndex>5}}`;
  ¬Alloc_in_recomp:`val active=remember(items){items.filter{it.isActive}}; active.forEach{item->key(item.id){ActiveItem(item,onClick={handle(item)})}}`
}
§PAT{theme(M3_dynamic):
  `AppTheme(darkTheme:Boolean=isSystemInDarkTheme(),dynamicColor:Boolean=true,content:@Composable ()->Unit)`:
  `cs=when{dynamicColor&&Build.VERSION.SDK_INT>=Build.VERSION_CODES.S->if(darkTheme)dynamicDarkColorScheme(LocalContext.current)else dynamicLightColorScheme(LocalContext.current); darkTheme->darkColorScheme(); else->lightColorScheme()}`→`MaterialTheme(cs,content=content)`
}
§ANTI{¬rememberSystemUiController(deprecated→enableEdgeToEdge+WindowInsets); ¬mutableStateOf∈VM(→StateFlow+collectAsStateWithLifecycle); ¬pass(NavController∨backStack→deep_composables;→lambdas); ¬heavy_compute∈@Composable(→VM∨remember{}); ¬LaunchedEffect(Unit)_as_VM_init(re-runs_on_config_Δ); ¬new_obj∈composable_params(recomp)}
§REL{[android-clean-architecture.md](android-clean-architecture.md); [kotlin-coroutines-flows.md](kotlin-coroutines-flows.md)}
