@REF:kotlin-coroutines-flows
§SCOPE{Android∧KMP:structured_concurrency,Flow/StateFlow/SharedFlow,parallel/debounce/retry,dispatchers,cancellation,testing}
§PAT{structured_concurrency:
  Hierarchy:`Application→viewModelScope(VM)→coroutineScope{}→{async{},launch{}}`;
  Scopes:¬`GlobalScope`; VM⇒`viewModelScope.launch{}`; Composable⇒`LaunchedEffect(key){}`;
  Parallel:`coroutineScope{val a=async{...}; val b=async{...}; Result(a.await(),b.await())}`;
  Partial_isolation:`supervisorScope{launch{...}; launch{...}}` (child_fail⇒¬cancel_siblings)
}
§PAT{flows:
  Cold:`flow{dao.observeAll().map{it.map(Entity::toDomain)}.collect{emit(it)}}`;
  StateFlow:`observe().stateIn(viewModelScope,SharingStarted.WhileSubscribed(5_000),init)` (`5_000`ms:keeps_upstream_5s_post_last_sub⇒survives_config_Δ);
  Combine:`combine(f1,f2,f3){a,b,c->State(a,b,c)}.stateIn(viewModelScope,SharingStarted.WhileSubscribed(5_000),State())`;
  Debounce:`searchQuery.debounce(300).distinctUntilChanged().flatMapLatest{repo.search(it)}.catch{emit(emptyList())}.collect{_state.update{...}}`;
  Retry_backoff:`flow{emit(api.fetch())}.retryWhen{cause,attempt->cause is IOException&&attempt<3⇒delay(1000L*(1 shl attempt.toInt())); true else false}`;
  SharedFlow(1-time_effects):
    VM:`_effects=MutableSharedFlow<Effect>(); val effects=_effects.asSharedFlow()`; `sealed interface Effect{ShowSnackbar(msg:String); NavigateTo(route:String)}`; emit∈`viewModelScope.launch`;
    UI:`LaunchedEffect(Unit){vm.effects.collect{...}}` (`snackbarHostState.showSnackbar`, `navController.navigate`)
}
§R{dispatchers:
  CPU:`withContext(Dispatchers.Default){...}`(KMP:all);
  IO:`withContext(Dispatchers.IO){...}`(JVM/Android_ONLY;KMP_other⇒`Default`∨DI);
  UI:`withContext(Dispatchers.Main){...}`(default∈`viewModelScope`,KMP:all)
}
§R{cancel:
  Loops:`ensureActive()`/iter(throws `CancellationException`);
  Cleanup:`try{...}finally{...}`(runs_on_cancel);
  Suspend_cleanup:`try{res.process()}finally{withContext(NonCancellable){res.release()}}`;
  Supervisor_fallback:ALWAYS rethrow `CancellationException`:`try{d.await()}catch(e:CancellationException){throw e}catch(e:Exception){emptyList()}`
}
§PAT{test:
  Turbine:`runTest{vm.state.test{assertEquals(init,awaitItem()); vm.onSearch("q"); assertTrue(awaitItem().isLoading); assertFalse(awaitItem().isLoading)}}`;
  TestDispatcher:`runTest{vm.load(); advanceUntilIdle(); assertNotNull(vm.state.value.items)}`;
  FakeFlow:`class FakeRepo:Repo{private val _items=MutableStateFlow<List<Item>>(emptyList()); override fun observeItems()=_items; fun emit(v:List<Item>){_items.value=v}}`
}
§ANTI{¬GlobalScope(leaks,¬cancel); ¬collect_Flow∈init{}_sans_scope(→viewModelScope.launch); ¬MutableStateFlow_mutable_collections(→`_state.update{it.copy(list=it.list+newItem)}`); ¬swallow(CancellationException); ¬flowOn(Dispatchers.Main)_to_collect(collector_sets_dispatcher); ¬create_Flow∈@Composable_sans_remember(recreates/recomp)}
§REL{[compose-multiplatform-patterns.md](compose-multiplatform-patterns.md); [android-clean-architecture.md](android-clean-architecture.md)}
