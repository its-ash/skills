---
name: rust
description: "Idiomatic Rust patterns for ownership and borrowing, Result and ? error handling with thiserror and anyhow, enums and pattern matching, traits and generics, concurrency with Arc, Mutex, channels, and Tokio, unsafe rules, and crate layout. Use when writing, reviewing, or refactoring .rs code, Cargo.toml, cargo build, cargo clippy, cargo fmt, cargo test, borrow checker errors, lifetimes, Cow, newtypes, builders, async Rust, or crate and module structure. Sub-skills: rust-testing."
---
# Rust

Write safe, idiomatic Rust that lets the type system enforce correctness.

## Core rules
- Borrow (`&T`, `&[T]`, `&str`) when you only read. Take ownership only to store or consume. Do not `.clone()` to silence the borrow checker.
- Use `Cow<'_, T>` when a function sometimes allocates and sometimes borrows.
- Propagate errors with `Result` and `?`. Never `unwrap()` in library or production code; use `expect("reason")` only for real invariants.
- Add context to errors at each boundary (`.with_context(|| ...)`).
- Prefer `Option`/`Result` combinators (`map`, `and_then`, `ok_or`) over nested `match`.
- Model states as enums so illegal states cannot exist. Match all variants; no `_` wildcard on business enums.
- Parse, don't validate: convert raw input to typed structs at the boundary.
- Wrap primitive IDs in newtypes (`struct UserId(u64)`) to prevent argument swaps.
- Accept generics (`impl Trait`), return concrete types. Use a builder for structs with many optional fields.
- Prefer iterator chains over manual push loops. Annotate the `collect()` target; collect into `Result<Vec<_>, _>` to stop at the first error.
- Add `#[must_use]` to important returns. Never discard a `Result` with `let _ =`.
- Never block in async code (`std::thread::sleep`, sync I/O); use Tokio equivalents. Wrap network calls in `tokio::time::timeout`.
- Use bounded channels for backpressure; `drop` the last sender so receivers end.
- Write `unsafe` only for FFI or proven hot paths. Document `# Safety` on the fn and a `// SAFETY:` comment on each block.
- Organize modules by domain, not by type. Keep `pub` minimal; use `pub(crate)` and re-export the public API from `lib.rs`.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Error type in a library | `thiserror` enum with `#[from]` | `Box<dyn Error>`, `anyhow` in public API |
| Error type in a binary/app | `anyhow::Result` + `bail!` + `context` | custom enums with no caller that matches them |
| Polymorphism, hot path | generics / `impl Trait` (monomorphized) | `dyn` without need |
| Heterogeneous collection or plugins | `Vec<Box<dyn Trait + Send + Sync>>` | giant enum of unrelated types |
| Shared mutable state across threads | `Arc<Mutex<T>>` (or `RwLock`) | `static mut`, unsafe sharing |
| Producer/consumer threads | `mpsc::sync_channel(n)` | unbounded channel with no limit |
| Concurrent async I/O | `tokio::spawn` per task, await handles | sequential awaits in a loop |
| Bypass borrow checker, convenience, `transmute` across unrelated types | redesign ownership | `unsafe` |

## Load on demand

| Need | Read |
|---|---|
| Code examples, crate layout, cargo commands, anti-pattern table | [references/idioms.md](references/idioms.md) |
| Unit/integration tests, `#[tokio::test]`, rstest, proptest, mockall, doc tests, Criterion, cargo-llvm-cov, CI | [references/rust-testing.md](references/rust-testing.md) |

## Related skills
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — panics, test failures, race conditions.
- [`secure-coding`](../secure-coding/SKILL.md) — input validation, secrets, dependency audit.
- [`backend-development`](../backend-development/SKILL.md) — API and service design for Rust services.
- [`docker`](../devops-iac/references/docker.md) — multi-stage builds for Rust binaries.
