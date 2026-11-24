---
name: rust
description: "AUTO_INVOKE(silent)⇔prompt∈{.rs,Cargo.toml,lib.rs,cargo(build|clippy|fmt|test),rust,ownership,borrow_checker,lifetime,Result,?,thiserror,anyhow,enum,match,trait,impl_Trait,dyn_Trait,generic,Cow,newtype,builder,iterator,#[must_use],Arc,Mutex,RwLock,mpsc,sync_channel,tokio,async_rust,tokio::spawn,timeout,unsafe,FFI,crate,module,panic,race,write|review|refactor_rust}|SUB:{rust-testing}"
---
@SKL:rust
§R{
  type_sys⇒enforce(correctness)∧safe∧idiomatic;
  read_only⇒borrow(&T,&[T],&str);own⇔store∨consume;¬.clone()⇒silence(borrow_chk);
  sometimes(alloc∨borrow)⇒Cow<'_,T>;
  err⇒Result∧?;(lib∨prod)⇒¬unwrap();expect("reason")⇔true_invariant;
  ∀boundary⇒err.with_context(||...);
  (Option∨Result)⇒(map,and_then,ok_or)≻nested_match;
  state∈enum⇒illegal_state≡∅;∀business_enum⇒exhaustive_match∧¬_wildcard;
  boundary⇒parse(raw→typed_struct)¬validate_only;
  prim_ID⇒newtype(struct UserId(u64))⇒¬arg_swap;
  in⇒impl Trait;out⇒concrete_type;many_opt_fields⇒Builder;
  iter_chain≻manual_push_loop;annotate(collect()_target);fail_fast⇒collect::<Result<Vec<_>,_>>();
  important_ret⇒#[must_use];¬(let _ = Result);
  async⇒¬block(std::thread::sleep,sync_IO)→tokio_equiv;net_call⇒tokio::time::timeout;
  backpressure⇒bounded_channel;close_rx⇒drop(last_tx);
  unsafe⇔(FFI∨proven_hot_path);unsafe⇒doc(# Safety on fn)∧cmt(// SAFETY: on ∀block);
  mod_org⇒by_domain¬by_type;pub≡minimal→pub(crate)∧reexport(pub_API@lib.rs);
}
§D{
  err∈lib⇒thiserror_enum+#[from]¬(Box<dyn Error>∨anyhow∈pub_API);
  err∈(bin∨app)⇒anyhow::Result+bail!+context¬custom_unmatched_enum;
  polymorph∧hot_path⇒generics∨impl Trait(monomorph)¬unneeded_dyn;
  heterogeneous_coll∨plugins⇒Vec<Box<dyn Trait+Send+Sync>>¬giant_enum(unrelated);
  shared_mut_state_across_threads⇒Arc<Mutex<T>>∨RwLock¬(static mut∨unsafe_share);
  prod_cons_threads⇒mpsc::sync_channel(n)¬unbounded_channel;
  concurrent_async_IO⇒tokio::spawn/task+await_handles¬seq_await_in_loop;
  (bypass_borrow_chk∨convenience∨transmute_unrelated)⇒redesign_ownership¬unsafe;
}
§REF{
  examples,crate_layout,cargo_cmds,anti_patterns→references/idioms.md;
  unit_integ_tests,#[tokio::test],rstest,proptest,mockall,doc_tests,Criterion,cargo-llvm-cov,CI→references/rust-testing.md;
}
§REL{
  ../systematic-debugging/SKILL.md:panics,test_fail,race_cond;
  ../secure-coding/SKILL.md:in_val,secrets,dep_audit;
  ../backend-development/SKILL.md:rust_svc_API_design;
  ../devops-iac/references/docker.md:rust_multi_stage_build;
}
