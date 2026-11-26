---
description: "Enforce Rust TDD (RED→GREEN→REFACTOR) with #[test]/rstest/proptest/mockall & ≥80% cargo-llvm-cov"
---
@CMD:rust-test
§META{agent:tdd-guide;tools:[`#[test]`,rstest,proptest,mockall];skills:[rust/references/rust-testing.md,rust/SKILL.md];rel:[/rust-build,/rust-review]}
§WHEN{new_fn/method/trait;add_cov;bug_fix(failing_test_first);critical_biz_logic;TDD_learning}
§FLOW{
  1:scaffold(types,traits,fn_sigs→`todo!()`)
  2:RED:write_tests(`#[cfg(test)] mod tests`)
  3:verify_RED:`cargo test`→MUST_FAIL(expected:`todo!` panic/unimpl)
  4:GREEN:minimal_impl_to_pass
  5:verify_GREEN:`cargo test`→PASS;REFACTOR(keep_green);REPEAT(next_case)
  6:cov:`cargo llvm-cov --fail-under-lines 80`
}
§CMD{
  `cargo llvm-cov` # summary
  `cargo llvm-cov --html` # HTML_report
  `cargo llvm-cov --fail-under-lines 80` # threshold_gate
  `cargo test test_name` # single_test
  `cargo test -- --nocapture` # show_stdout
  `cargo nextest run` # fast_parallel(no_fail_fast)
}
§PAT{
  unit:`#[cfg(test)] mod tests { use super::*; #[test] fn ...; #[test] fn ... -> Result<(), Box<dyn std::error::Error>> { ... Ok(()) } }`
  param:`use rstest::{rstest, fixture}; #[rstest] #[case(...)] fn ...`
  async:`#[tokio::test] async fn ...`
  prop:`use proptest::prelude::*; proptest! { #[test] fn ... }`
}
§GATE_COV{
  critical_biz_logic:100%
  public_API:≥90%
  general_code:≥80%
  generated/FFI:exclude
}
§R{
  DO:test_FIRST(¬impl_before_test);run_tests_after_Δ;`assert_eq!`>`assert!`;use `?` in `Result` tests;test_behavior(¬impl);cover_edges(empty,boundary,err_paths)
  DONT:impl_before_test;skip_RED;`#[should_panic]` when `Result::is_err()` works;`sleep()`(use channels∨`tokio::time::pause()`);mock_all(prefer_integration_tests)
}
