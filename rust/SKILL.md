---
name: rust
description: "AUTO_INVOKE(silent)⇔prompt∈{.rs,Cargo.toml,lib.rs,cargo(build|clippy|fmt|test|nextest|deny|audit|miri),rust,edition_2024,ownership,borrow_checker,lifetime,Result,?,thiserror,anyhow,enum,match,let_chains,trait,AFIT,impl_Trait,dyn_Trait,generic,Cow,newtype,builder,iterator,#[must_use],#[expect],LazyLock,Arc,Mutex,RwLock,thread::scope,mpsc,tokio,async_rust,JoinSet,CancellationToken,timeout,unsafe,FFI,workspace.lints,crate,module,panic,race,write|review|refactor_rust}|SUB:{rust-testing}"
---
@SKL:rust
§R{
  baseline⇒edition="2024"(MSRV≥1.85,resolver="3")∧centralize([workspace.lints])∧#[expect(lint,reason="..")]≻#[allow];
  type_sys⇒enforce(correctness)∧safe∧idiomatic;boundary⇒parse(raw→typed_struct)¬validate_only;
  read_only⇒borrow(&T,&[T],&str);own⇔store∨consume;¬.clone()⇒silence(borrow_chk);cond_alloc⇒Cow<'_,T>;
  err⇒Result∧?;(lib∨prod)⇒¬unwrap();expect("reason")⇔true_invariant;∀boundary⇒err.with_context(||..);
  (Option∨Result)⇒(map,and_then,ok_or)≻nested_match;multi_cond⇒let_chains(if let Some(a)=x && cond && let Some(b)=y);
  state∈enum⇒illegal_state≡∅;∀business_enum⇒exhaustive_match∧¬_wildcard;prim_ID⇒newtype(struct UserId(u64));
  in⇒impl Trait;out⇒concrete_type∨RPIT(+use<..>_precise_capture);many_opt_fields⇒Builder;
  iter_chain≻manual_push_loop;annotate(collect()_target);fail_fast⇒collect::<Result<Vec<_>,_>>();
  important_ret⇒#[must_use];¬(let _ = Result);
  global_lazy⇒std::sync::LazyLock|OnceLock¬(lazy_static∨once_cell);
  sync_threads∧borrow_stack⇒std::thread::scope¬(Arc_clone∨crossbeam::scope);
  async⇒¬block(std::thread::sleep,sync_IO)→(tokio_equiv∨spawn_blocking);¬hold(std::sync::MutexGuard_across_.await);
  async_net⇒tokio::time::timeout;fanout⇒tokio::task::JoinSet(auto_abort_on_drop);shutdown⇒CancellationToken;
  backpressure⇒bounded_channel(mpsc::channel(n)|sync_channel(n));close_rx⇒drop(last_tx);
  unsafe⇔(FFI∨proven_hot_path);req:doc(# Safety)∧cmt(// SAFETY:)∧2024(unsafe{}_in_unsafe_fn,unsafe extern,#[unsafe(no_mangle)])∧miri;
  mod_org⇒by_domain¬by_type;pub≡minimal→pub(crate)∧reexport(pub_API@lib.rs);
}
§D{
  err∈lib⇒thiserror_2+#[from]¬(Box<dyn Error>∨anyhow∈pub_API);
  err∈(bin∨app)⇒anyhow::Result+bail!+context¬custom_unmatched_enum;
  async_trait∧static_dispatch⇒native_AFIT∨(-> impl Future+Send)∨trait_variant::make¬#[async_trait]_boxing;
  async_trait∧dyn_dispatch⇒#[async_trait]∨closed_enum_dispatch¬AFIT(not_dyn_compatible);
  polymorph∧hot_path⇒generics∨impl Trait(monomorph)¬unneeded_dyn;
  heterogeneous_coll∨plugins⇒Vec<Box<dyn Trait+Send+Sync>>¬giant_enum(unrelated);
  shared_mut_state_across_threads⇒Arc<Mutex<T>>∨RwLock¬(static mut∨unsafe_share);
  prod_cons_threads⇒sync_channel(n)∨tokio::sync::mpsc::channel(n)¬unbounded_channel;
  concurrent_async_IO⇒JoinSet∨tokio::try_join!¬(seq_await_in_loop∨untracked_Vec<JoinHandle>);
  lint_suppress⇒#[expect(lint,reason="..")]¬#[allow(...)];
  test_run|bench⇒(cargo-nextest+cargo-llvm-cov)∧(criterion_0.8|divan+std::hint::black_box)¬(cargo-tarpaulin∨criterion::black_box);
  (bypass_borrow_chk∨convenience∨transmute_unrelated)⇒redesign_ownership¬unsafe;
}
§REF{
  edition_2024,let_chains,AFIT,LazyLock,JoinSet,CancellationToken,workspace.lints,cargo_cmds,crate_layout,anti_patterns→references/idioms.md;
  TDD,nextest,#[tokio::test],rstest,proptest,insta,mockall,miri,doc_tests,Criterion_0.8,Divan,cargo-llvm-cov,CI_SHA_pin→references/rust-testing.md;
}
§REL{
  ../systematic-debugging/SKILL.md:panics,test_fail,race_cond;
  ../secure-coding/SKILL.md:in_val,secrets,dep_audit;
  ../backend-development/SKILL.md:rust_svc_API_design;
  ../devops-iac/references/docker.md:rust_multi_stage_build;
}
