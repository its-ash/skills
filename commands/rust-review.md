---
description: "Rust code review via rust-reviewer: ownership, lifetimes, errors, unsafe, idioms"
---
@CMD:rust-review
§META{agent:rust-reviewer;skills:[rust/SKILL.md,rust/references/rust-testing.md];rel:[/rust-test,/rust-build,/code-review]}
§WHEN{post_edit/new_Rust;pre_commit;PR;onboarding;idioms}
§GATE_PRE{
  must_pass(STOP_on_fail):
  `cargo check`
  `cargo clippy -- -D warnings`
  `cargo fmt --check`
  `cargo test`
  `if command -v cargo-audit >/dev/null; then cargo audit; else echo "cargo-audit not installed"; fi`
}
§FLOW{
  1:run(§GATE_PRE)
  2:diff_rs:`git diff HEAD~1`∨`git diff main...HEAD`(PR)
  3:sec_scan:unsafe,cmd_inj,hardcoded_secrets
  4:ownership:clones,lifetimes,borrowing
  5:emit(§OUT)
}
§R{
  CRITICAL(must_fix):
  - unchecked `.unwrap()`/`.expect()` in prod(fix:`?`+`.context(...)`)
  - `unsafe`¬`// SAFETY:` invariant_cmt
  - SQLi(string_interp in queries)
  - cmd_inj(unvalidated_in in `std::process::Command`)
  - hardcoded_creds
  - UAF(raw_ptrs)
  HIGH(should_fix):
  - unnecessary `.clone()` for borrow_checker(restructure)
  - `String` param where `&str`∨`impl AsRef<str>` suffices
  - blocking in async(`std::thread::sleep`,`std::fs`)
  - missing `Send`/`Sync` bounds on shared_types
  - wildcard `_ =>` on biz-critical enums
  - fn>50L
  MEDIUM(consider):
  - unnecessary_alloc(hot_path)
  - missing `with_capacity`(known_size)
  - suppressed clippy_warns¬justif
  - pub_API¬`///` doc
  - `#[must_use]` on ret_types(ignore≈bug)
}
§GATE{Approve⇔CRITICAL≡0∧HIGH≡0;Warning⇔CRITICAL≡0∧HIGH≡0∧MEDIUM>0;Block⇔CRITICAL>0∨HIGH>0}
§OUT{files:[path(status)];checks:[Build,Clippy,Fmt,Tests];issues:[`[SEV]` title,file:line,bad,fix];counts:[CRITICAL,HIGH,MEDIUM];rec:Approve|Warning|Block}
