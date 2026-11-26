@REF:rust-testing

§WHEN{new_fn|trait|coverage|bench|proptest_validation|TDD_Rust}
§FLOW{1:id_target→2:write_test(#[test]∈#[cfg(test)]|rstest|proptest)→3:mockall→4:RED(todo!()→panic 'not yet implemented')→5:GREEN(min_impl)→6:REFACTOR→7:cargo-llvm-cov(≥80%)}

§UNIT{
  mod:#[cfg(test)] mod tests{use super::*; #[test] fn ...};
  assert:{assert_eq!(a,b),assert_ne!(a,b),assert!(cond),assert_eq!(v,42,"msg {v}"),float:(0.1_f64+0.2-0.3).abs()<f64::EPSILON};
  err_res:assert!(r.is_err())∧assert!(matches!(r.unwrap_err(),ConfigError::ParseError(_)));
  ret_res:fn t()->Result<(),Box<dyn std::error::Error>>{...? ;Ok(())};
  panic:#[should_panic]|#[should_panic(expected="index out of bounds")]
}

§INT{
  layout:my_crate/{src/lib.rs,tests/{api_test.rs,db_test.rs,common/mod.rs}}; // each tests/*.rs = separate binary; common/mod.rs = shared helpers
}

§ASYNC{
  #[tokio::test] async fn ...;
  timeout:tokio::time::timeout(Duration::from_millis(100),slow_operation()).await→assert!(res.is_err())
}

§RSTEST{
  use rstest::{rstest,fixture};
  #[rstest] #[case("hello",5)] #[case("",0)] fn len(#[case] input:&str,#[case] expected:usize);
  #[fixture] fn test_db()->TestDb{TestDb::new_in_memory()} → #[rstest] fn ins(test_db:TestDb)
}

§PROP{
  use proptest::prelude::*;
  proptest!{
    #[test] fn roundtrip(input in ".*"){assert_eq!(input,decode(&encode(&input)).unwrap());}
    #[test] fn sort_prop(mut v in prop::collection::vec(any::<i32>(),0..100)){v.sort(); v.windows(2)=>w[0]<=w[1];}
  }
  strat:fn valid_email()->impl Strategy<Value=String>{("[a-z]{1,10}","[a-z]{1,5}").prop_map(|(u,d)|format!("{u}@{d}.com"))}
}

§MOCK{
  use mockall::{automock,predicate::eq};
  #[automock] trait UserRepository{fn find_by_id(&self,id:u64)->Option<User>;fn save(&self,user:&User)->Result<(),StorageError>;}
  // MockUserRepository::new(); mock.expect_find_by_id().with(eq(42)).times(1).returning(|_|Some(...))
}

§DOC{
  /// # Examples (``` runs) | /// # Errors (```no_run compiles_only)
}

§BENCH{
  // Cargo.toml: [dev-dependencies] criterion={version="0.5",features=["html_reports"]}; [[bench]] name="benchmark" harness=false
  // benches/benchmark.rs: use criterion::{black_box,criterion_group,criterion_main,Criterion};
  c.bench_function("fib 20",|b|b.iter(||fibonacci(black_box(20))));
  criterion_group!(benches,bench_fibonacci); criterion_main!(benches);
}

§COV{
  inst:cargo install cargo-llvm-cov | CI:taiki-e/install-action@cargo-llvm-cov;
  cmd:cargo llvm-cov | --html | --lcov > lcov.info | --fail-under-lines 80;
  targets:{critical_biz_logic:100%,public_api:≥90%,general:≥80%,generated_FFI:exclude}
}

§CMD{
  cargo test                  // all
  cargo test -- --nocapture   // println output
  cargo test test_name        // pattern match
  cargo test --lib            // unit only
  cargo test --test api_test  // integration file
  cargo test --doc            // doc tests only
  cargo test --no-fail-fast   // continue on fail
  cargo test -- --ignored     // ignored tests
}

§R{
  DO:{TDD_first,#[cfg(test)],test_behavior¬impl,descriptive_names,assert_eq!>assert!,?∈Result_tests,independent¬shared_mut_state};
  ¬DO:{#[should_panic]_when_Result::is_err()_fits,mock_everything(prefer_integration),ignore_flaky(fix∨quarantine),sleep()_in_tests(use_channels|barriers|tokio::time::pause()),skip_err_paths}
}

§CI{
  // GitHub Actions (ubuntu-latest):
  // actions/checkout@v4 → dtolnay/rust-toolchain@stable(components:clippy,rustfmt)
  cargo fmt --check && cargo clippy -- -D warnings && cargo test
  // taiki-e/install-action@cargo-llvm-cov → cargo llvm-cov --fail-under-lines 80
}
