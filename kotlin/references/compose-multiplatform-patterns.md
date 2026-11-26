@REF:compose-multiplatform-patterns
§SCOPE{Compose_Multiplatform∧Jetpack_Compose(Android,iOS,Desktop,Web):state,nav,composables,KMP_UI,perf,theming}
§PAT{state:
  SingleState+StateFlow:immutable `data class`(e.g.`items=emptyList(),isLoading=false,error:String?=null,searchQuery=""`);
    VM:`_state=MutableStateFlow(S()); val state:StateFlow<S>=_state.asStateFlow()`;
    update:`viewModelScope.launch{_state.update{it.copy(isLoading=true)}; uc(q).fold(onSuccess={...},onFailure={e->_state.update{it.copy(error=e.message,isLoading=false)}})}`;
  Collect:`vm:VM=koinViewModel()`; `val state by vm.state.collectAsStateWithLifecycle()`→pass state+lambdas to stateless `@Composable private fun Content(state,onSearch)`(preview+test);
  EventSink(complex):`sealed interface Event{Search(query:String); Delete(itemId:String); data object Refresh}`; VM `fun onEvent(e:Event)`; UI passes single `onEvent=vm::onEvent`
}
§PAT{nav(Compose_Navigation≥2.8,type_safe):
  Routes:`@Serializable data object HomeRoute`; `@Serializable data class DetailRoute(val id:String)`;
  Host:`NavHost(rememberNavController(),HomeRoute){composable<HomeRoute>{...navController.navigate(DetailRoute(id))}; composable<DetailRoute>{it.toRoute<DetailRoute>().id}}`;
  Dialog/Sheet:`dialog<ConfirmDeleteRoute>{ConfirmDeleteDialog(it.toRoute<ConfirmDeleteRoute>().itemId, onConfirm={navController.popBackStack()}, onDismiss={navController.popBackStack()})}` (¬imperative show/hide)
}
§PAT{composable_design:
  Slot_API:`(modifier:Modifier=Modifier,header:@Composable ()->Unit={},content:@Composable ColumnScope.()->Unit,actions:@Composable RowScope.()->Unit={})` (`Card{Column{header(); Column(content); Row(Arrangement.End,actions)}}`);
  Modifier_order(strict):`1.Layout(.padding(16.dp),size)→2.Shape(.clip(RoundedCornerShape(8.dp)))→3.Draw(.background(),border)→4.Interaction(.clickable{})`
}
§PAT{kmp_platform_ui:
  `commonMain`:`@Composable expect fun PlatformStatusBar(darkIcons:Boolean)`;
  `androidMain`:`actual`→`rememberSystemUiController()`+`SideEffect{setStatusBarColor(Color.Transparent,darkIcons)}`;
  `iosMain`:`actual`→UIKit_interop∨`Info.plist`
}
§PAT{perf:
  Stability:`@Immutable`∨`@Stable` on UI_models when ∀props_stable⇒skippable_recomp;
  LazyLists:`LazyColumn{items(items,key={it.id}){...}}`⇒reuse+anims;
  Defer_reads:`val listState=rememberLazyListState(); val show by remember{derivedStateOf{listState.firstVisibleItemIndex>5}}`;
  ¬Alloc_in_recomp:`val active=remember(items){items.filter{it.isActive}}; active.forEach{item->key(item.id){ActiveItem(item,onClick={handle(item)})}}` (¬inline `items.filter{}.forEach{}` alloc list+lambdas/recomp)
}
§PAT{theme(M3_dynamic):
  `AppTheme(darkTheme:Boolean=isSystemInDarkTheme(),dynamicColor:Boolean=true,content:@Composable ()->Unit)`:
  `cs=when{dynamicColor&&Build.VERSION.SDK_INT>=Build.VERSION_CODES.S->if(darkTheme)dynamicDarkColorScheme(LocalContext.current)else dynamicLightColorScheme(LocalContext.current); darkTheme->darkColorScheme(); else->lightColorScheme()}`→`MaterialTheme(cs,content=content)`
}
§ANTI{¬mutableStateOf∈VM(→MutableStateFlow+collectAsStateWithLifecycle); ¬pass(NavController→deep_composables;→lambdas); ¬heavy_compute∈@Composable(→VM∨remember{}); ¬LaunchedEffect(Unit)_as_VM_init(re-runs_on_config_Δ); ¬new_obj∈composable_params(recomp)}
§REL{[android-clean-architecture.md](android-clean-architecture.md); [kotlin-coroutines-flows.md](kotlin-coroutines-flows.md)}
