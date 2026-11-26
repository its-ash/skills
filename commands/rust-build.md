---
description: "Fix Rust build/borrow/dep errors incrementally via rust-build-resolver agent (minimal surgical fixes)"
---
@CMD:rust-build
§META{agent:rust-build-resolver;skill:rust/SKILL.md;rel:[/rust-test,/rust-review]}
§WHEN{
  `cargo build|check` fail
  `cargo clippy` warnings
  borrow/lifetime compile errors
  Cargo dep resolution fail
  post-pull build breakage
}
§DIAG{
  `cargo check 2>&1`
  `cargo clippy -- -D warnings 2>&1`
  `cargo fmt --check 2>&1`
  `cargo tree --duplicates`
  `if command -v cargo-audit >/dev/null; then cargo audit; else echo "cargo-audit not installed"; fi`
}
§FLOW{
  1:run(§DIAG)→parse(err_codes,files)
  2:priority:compile_errs→clippy_warns→`cargo fmt`
  3:∀err(1_at_a_time,minimal_Δ,¬refactor):apply_fix→`cargo check`
  4:post_compile:verify(`cargo clippy -- -D warnings`∧`cargo test`)
}
§FIX_MAP{
  `cannot borrow as mutable`⇒restructure(end_immut_borrow_first);clone⇔justified
  `does not live long enough`⇒owned_type∨lifetime_annotation
  `cannot move out of`⇒restructure_ownership;clone⇔last_resort
  `mismatched types`⇒`.into()`|`as`|explicit_conv
  `trait X not implemented`⇒`#[derive(Trait)]`∨manual_impl
  `unresolved import`⇒add(Cargo.toml)∨fix(`use`_path)
  `cannot find value`⇒add_import∨fix_path
}
§GATE{
  STOP∧report⇔(same_err_attempts≥3)∨(fix⇒more_errs)∨(needs_arch_Δ)∨(borrow_err⇒needs_ownership_redesign)
}
§OUT{
  per_fix:[file:line,err_code,cause/Δ,`cargo check`_remaining]
  summary:[build_errs_fixed,clippy_warns_fixed,files_modified,remaining_issues,Build Status:SUCCESS|FAIL]
}
