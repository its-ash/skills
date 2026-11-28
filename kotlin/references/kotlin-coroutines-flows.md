@REF:kotlin-coroutines-flows
§SCOPE{Android∧KMP(kotlinx-coroutines_1.11.0):structured_concurrency,Flow/StateFlow/SharedFlow/Channel,parallel/debounce/retry,dispatchers,cancellation,testing}
§PAT{structured_concurrency:
  Hierarchy:`Application→viewModelScope(VM)→coroutineScope{}→{async{},launch{}}`;
  Scopes:¬`GlobalScope`; VM⇒`viewModelScope.launch{}`; Composable⇒`LaunchedEffect(key){}`;
  Parallel:`coroutineScope{val a=async{...}; val b=async{...}; Result(a.await(),b.await())}`;
  Partial_isolation:`supervisorScope{launch{...}; launch{...}}` (child_fail⇒¬cancel_siblings)
}
§PAT{flows:
  Cold:`flow{dao.observeAll().map{it.map(Entity::toDomain)}.collect{emit(it)}}`;
  StateFlow(Kotlin_2.4):`val state:StateFlow<S> field = MutableStateFlow(S())` (mutated_via `state.update{...}` in_VM; pre-2.4⇒`_state=MutableStateFlow(S()); val state=_state.asStateFlow()`);
  StateIn:`observe().stateIn(viewModelScope,SharingStarted.WhileSubscribed(5_000),init)` (`5_000`ms:keeps_upstream_5s_post_last_sub⇒survives_config_Δ);
  Combine:`combine(f1,f2,f3){a,b,c->State(a,b,c)}.stateIn(viewModelScope,SharingStarted.WhileSubscribed(5_000),State())`;
  Debounce:`searchQuery.debounce(300).distinctUntilChanged().flatMapLatest{repo.search(it)}.catch{emit(emptyList())}.collect{state.update{...}}`;
  Retry_backoff:`flow{emit(api.fetch())}.retryWhen{cause,attempt->cause is IOException&&attempt<3⇒delay(1000L*(1 shl attempt.toInt())); true else false}`;
  OneTimeEffects:
    prefer_state_over_events_when_feasible; else `Channel<Effect>(Channel.BUFFERED)`→`val effects=_effects.receiveAsFlow()`(single_consumer∧buffers_across_config_Δ;¬lost_events) ⊕ `MutableSharedFlow<Effect>()`(multi_consumer,drops_if_0_collectors);
    UI:`LaunchedEffect(Unit){lifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED){vm.effects.collect{...}}}` (`snackbarHostState.showSnackbar`, `onNavigate`)
}
§R{dispatchers:
  CPU:`withContext(Dispatchers.Default){...}`(KMP:all);
  IO:`withContext(Dispatchers.IO){...}`(JVM∧Android∧Kotlin/Native_iOS;¬JS/Wasm⇒inject_CoroutineDispatcher_via_DI_for_KMP+tests);
  UI:`withContext(Dispatchers.Main){...}` / `Main.immediate`(default∈`viewModelScope`,KMP:all_UI_targets)
}
§R{cancel:
  Loops:`ensureActive()`/iter(throws `CancellationException`);
  Cleanup:`try{...}finally{...}`(runs_on_cancel);
  Suspend_cleanup:`try{res.process()}finally{withContext(NonCancellable){res.release()}}`;
  Supervisor_fallback:ALWAYS rethrow `CancellationException`:`try{d.await()}catch(e:CancellationException){throw e}catch(e:Exception){emptyList()}`
}
§PAT{test:
  Turbine(1.2.1):`runTest{vm.state.test{assertEquals(init,awaitItem()); vm.onSearch("q"); assertTrue(awaitItem().isLoading); assertFalse(awaitItem().isLoading); cancelAndIgnoreRemainingEvents()}}`;
  BackgroundScope:`runTest{backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)){vm.state.collect{}}; vm.load(); advanceUntilIdle(); assertNotNull(vm.state.value.items)}` (auto-cancels_infinite_flows⇒¬UncompletedCoroutinesError);
  TestDispatcher:`runTest{vm.load(); advanceUntilIdle(); assertNotNull(vm.state.value.items)}`;
  FakeFlow:`class FakeRepo:Repo{private val _items=MutableStateFlow<List<Item>>(emptyList()); override fun observeItems()=_items; fun emit(v:List<Item>){_items.value=v}}`
}
§ANTI{¬GlobalScope(leaks,¬cancel); ¬collect_Flow∈init{}_sans_scope(→viewModelScope.launch); ¬MutableStateFlow_mutable_collections(→`state.update{it.copy(list=it.list+newItem)}`); ¬swallow(CancellationException); ¬flowOn(Dispatchers.Main)_to_collect(collector_sets_dispatcher); ¬create_Flow∈@Composable_sans_remember(recreates/recomp); ¬unbounded_launch∈runTest(→backgroundScope.launch)}
§REL{[compose-multiplatform-patterns.md](compose-multiplatform-patterns.md); [android-clean-architecture.md](android-clean-architecture.md); [kotlin-testing.md](kotlin-testing.md)}
