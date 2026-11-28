@REF:rust-testing
§REL{../SKILL.md:rules;./idioms.md:unsafe_2024,conc_async}

§R{
  trigger:new_fn|trait|coverage|bench|proptest|snapshot|unsafe_UB|TDD_Rust;
  flow:1:id_target→2:write_test(#[test]|rstest|proptest|insta)→3:mock_boundary_only→4:RED(todo!())→5:GREEN(min_impl)→6:REFACTOR→7:nextest+llvm-cov(≥80%)+miri_if_unsafe;
  core:{TDD_first,#[cfg(test)]_inline_unit,test_behavior¬impl,descriptive_names,assert_eq!≻assert!,?∈Result_tests,isolated¬shared_mut_state};
  cov_targets:{critical_biz:100%,pub_api:≥90%,general:≥80%,generated_FFI:exclude};
  determinism:¬std::thread::sleep_in_tests→(channels|barriers|tokio::time::pause()+advance());
}

§D{
  test_runner⇒cargo-nextest(0.9.x,process_per_test,timeouts,retries,filtersets,JUnit)+cargo_test_--doc¬cargo_test_only;
  coverage⇒cargo-llvm-cov(-C_instrument-coverage,accurate_async_generics)¬cargo-tarpaulin(ptrace_distortion);
  bench_rigorous⇒criterion_0.8+std::hint::black_box¬criterion::black_box(deprecated);
  bench_ergonomic_or_alloc⇒divan_0.1(#[divan::bench],alloc_thread_profiling,cargo_test_--benches_smoke);
  complex_output_assert⇒insta_1.49(snapshots+cargo_insta_review)¬giant_inline_assert_eq!;
  unsafe_verification⇒cargo_+nightly_miri_test(OOB,UAF,align,data_races,stacked_tree_borrows)¬native_tests_alone;
  dep_isolation⇒in_memory_fake|integration_test≻mockall(only_at_external_IO_boundary);
}

§PAT{
  unit:#[cfg(test)] mod tests{use super::*;#[test] fn parses_valid(){assert_eq!(parse("42"),Ok(42));}};
  assert:{assert_eq!(a,b),assert_ne!(a,b),assert!(cond,"ctx {v}"),float:(0.1_f64+0.2-0.3).abs()<f64::EPSILON};
  err_assert:assert!(matches!(res.unwrap_err(),ConfigError::Parse(_)));
  res_test:fn t()->Result<(),Box<dyn std::error::Error>>{let v=parse("1")?;assert_eq!(v,1);Ok(())};
  panic_test:#[should_panic(expected="index out of bounds")];// only for true panics ¬Result::Err
  integration:my_crate/{src/lib.rs,tests/{api_test.rs,db_test.rs,common/mod.rs}};// each tests/*.rs=separate crate; common/mod.rs=shared helper
  async_test:#[tokio::test] async fn fetches(){..};
  async_time:#[tokio::test(start_paused=true)] async fn expires(){tokio::time::advance(Duration::from_secs(60)).await;..};
  async_timeout:assert!(tokio::time::timeout(Duration::from_millis(100),slow_op()).await.is_err());
  rstest:use rstest::{rstest,fixture};#[rstest] #[case("hi",2)] #[case("",0)] fn len(#[case] s:&str,#[case] n:usize);#[fixture] fn db()->TestDb{TestDb::mem()}→#[rstest] fn ins(db:TestDb);
  proptest:use proptest::prelude::*;proptest!{#[test] fn roundtrip(s in ".*"){assert_eq!(s,decode(&encode(&s)).unwrap());}#[test] fn sorted(mut v in prop::collection::vec(any::<i32>(),0..100)){v.sort();assert!(v.windows(2).all(|w|w[0]<=w[1]));}};
  prop_strat:fn valid_email()->impl Strategy<Value=String>{("[a-z]{1,10}","[a-z]{1,5}").prop_map(|(u,d)|format!("{u}@{d}.com"))};
  insta:insta::assert_snapshot!(render(&doc));insta::assert_json_snapshot!(payload,{".timestamp"=>"[ts]"});// review w/ cargo insta review
  mockall:use mockall::{automock,predicate::eq};#[automock] trait UserRepo{fn find(&self,id:u64)->Option<User>;fn save(&self,u:&User)->Result<(),StorageError>;};// MockUserRepo::new()+.expect_find().with(eq(42)).times(1).returning(..)
  doc_test:/// # Examples (``` runs via cargo test --doc) | /// # Errors (```no_run compiles_only);
  bench_criterion:Cargo.toml:[dev-dependencies] criterion={version="0.8",features=["html_reports"]};[[bench]] name="bench" harness=false;// benches/bench.rs: use std::hint::black_box;use criterion::{criterion_group,criterion_main,Criterion};c.bench_function("fib 20",|b|b.iter(||fib(black_box(20))));criterion_group!(benches,bench_fib);criterion_main!(benches);
  bench_divan:Cargo.toml:[dev-dependencies] divan="0.1";[[bench]] name="bench" harness=false;// benches/bench.rs: #[divan::bench(args=[16,256])] fn parse(n:usize){work(divan::black_box(n));} fn main(){divan::main();}
  miri:rustup +nightly component add miri && cargo +nightly miri test;// runs MIR interpreter on unsafe tests
}

§CFG{
  ci_hardening:permissions:{contents:read}∧concurrency:{group:"${{github.workflow}}-${{github.ref}}",cancel-in-progress:true}∧pin_actions_to_commit_SHA(¬floating_@v4);
  ci_steps:actions/checkout@<sha>→dtolnay/rust-toolchain@<sha>(toolchain:stable,components:clippy,rustfmt)→Swatinem/rust-cache@<sha>(v2)→taiki-e/install-action@<sha>(tool:nextest,cargo-llvm-cov,cargo-deny,cargo-audit);
  ci_gates:cargo fmt --all -- --check && cargo clippy --workspace --all-targets --all-features -- -D warnings && cargo nextest run --workspace --all-features && cargo test --doc --workspace && cargo deny check && cargo audit;
  ci_cov:cargo llvm-cov nextest --workspace --all-targets --lcov --output-path lcov.info --fail-under-lines 80;
  ci_unsafe:dtolnay/rust-toolchain@<sha>(toolchain:nightly,components:miri)→cargo +nightly miri test;
}

§CMD{
  cargo nextest run                                        // all unit+integration (process isolated)
  cargo nextest run --workspace --all-features --profile ci
  cargo nextest run -E 'test(my_test)'                     // filterset query
  cargo nextest run --no-fail-fast                         // continue after failure
  cargo test --doc --workspace                             // doctests (nextest skips doctests)
  cargo test -- --nocapture                                // show stdout/println!
  cargo test -- --ignored                                  // run #[ignore] tests
  cargo test --benches                                     // compile+smoke-test benches (divan)
  cargo insta test --test-runner nextest && cargo insta review
  cargo llvm-cov nextest --workspace --all-targets --lcov --output-path lcov.info
  cargo llvm-cov nextest --html --open                     // local visual HTML report
  cargo llvm-cov nextest --fail-under-lines 80             // enforce coverage gate
  cargo llvm-cov --no-report nextest && cargo llvm-cov --no-report --doc && cargo llvm-cov report --doctests --lcov --output-path lcov.info // merge nextest+doctests (nightly)
  cargo +nightly miri test                                 // UB check for unsafe modules
}

§ANTI{
  #[should_panic]_for_Result_Err⇒assert!(res.is_err())∧matches!(..);
  mock_everything⇒prefer_real_fakes_or_integration;
  ignore_flaky_tests⇒fix_root_cause∨quarantine_w/_issue;
  sleep()_in_tests⇒tokio::time::pause()+advance()|channels|barriers;
  criterion::black_box⇒std::hint::black_box(criterion_0.8_deprecated_wrapper);
  cargo-tarpaulin⇒cargo-llvm-cov(zero_async_distortion);
  cargo_llvm-cov_--lcov_>_lcov.info⇒--lcov_--output-path_lcov.info;
  nextest_without_cargo_test_--doc⇒run_both_in_CI;
  unsafe_without_miri⇒run_cargo_+nightly_miri_test;
  unpinned_floating_action_tags(@v4)⇒pin_immutable_commit_SHA;
}

§CHK{
  nextest_unit_integ+cargo_test_--doc≡pass;
  zero_wall_clock_sleeps_in_tests;
  cov≥80%_general∧≥90%_pub_api(--fail-under-lines);
  ∀unsafe_crate:miri_test≡pass;
  benches_compile(cargo_test_--benches)∧use_std::hint::black_box;
  CI_actions_SHA_pinned∧cargo_deny+cargo_audit≡pass;
}
