---
name: move-code-quality
description: "Analyzes Move packages against the Move Book Code Quality Checklist (2024 Edition) by scanning .move source files and Move.toml manifests for naming conventions, import ordering, module and constant structure, struct definitions, function signatures, body patterns, option and loop macro usage, test coverage, and comment standards. Use when linting Move smart contracts, auditing Move.toml dependencies, enforcing style guides on .move files, checking macro expansions, validating test annotations, or running pre-commit quality gates for Sui or Aptos projects."
---

# Move Code Quality Checker

Analyze a Move package and receive actionable feedback that follows the Move Book Code Quality Checklist (2024 Edition). The skill works on any directory that contains `.move` files or a `Move.toml` manifest.

## When to Use
- You ask to review Move code, check a package, or verify 2024‑Edition compliance.
- The current folder contains `.move` sources or a `Move.toml` file.
- You need a prioritized list of fixes before a commit or audit.

## Discovery
1. Look for `Move.toml` in the current directory.
2. Collect all `*.move` files (including those in sub‑folders).
3. Identify test modules (files or modules ending with `_tests`).
4. Ask the user if they want a full package scan or a focused check.

## Manifest Checks (`Move.toml`)
- **Edition**: Must contain `edition = "2024"` or `edition = "2024.beta"`. Missing edition blocks all modern checks.
- **Implicit Framework Dependencies** (Sui 1.45+): Do not list `Sui`, `Bridge`, `MoveStdlib`, or `SuiSystem` under `[dependencies]`. They are added automatically.
- **Named Address Prefix**: Use a project‑specific prefix, e.g., `my_protocol_math = "0x0"`. Avoid generic names like `math`.

## Imports, Modules & Constants
- **Module Label Syntax**: Use `module my_package::my_module;` followed by declarations. Do not use curly‑brace syntax.
- **Use Statements**:
  - Do not write `use my_package::my_module::{Self};`. Write `use my_package::my_module;`.
  - Group members with `Self` in a single statement: `use my_package::my_module::{Self, Member};`.
- **Error Constants**: Name in `EPascalCase`, e.g., `const ENotAuthorized: u64 = 0;`.
- **Regular Constants**: Use `ALL_CAPS`, e.g., `const MAX_LIMIT: u64 = 100;`.

## Structs
- **Capability Naming**: End capability structs with `Cap`, e.g., `public struct AdminCap has key, store { ... }`.
- **Avoid “Potato” Names**: Do not add redundant words that duplicate ability information.
- **Event Structs**: Name in past tense, e.g., `UserRegistered`.
- **Positional Structs for Dynamic Keys**: Prefer `public struct DynamicFieldKey() has copy, drop, store;`.

## Functions
- **Visibility**:
  - Use `public fun` for composable functions.
  - Use `entry fun` for transaction entry points.
  - Do not combine `public entry fun`.
- **Composable Design**: Return values from public functions so they can be chained in programmable transaction blocks.
- **Parameter Order**:
  1. Objects (mutable first, then immutable)
  2. Capability references
  3. Primitive types (`u8`, `u64`, `bool`, …)
  4. `Clock` reference (if needed)
  5. `TxContext` (always last)
- **Getter Naming**:
  - Immutable accessor: `pub fun name(u: &User): string`.
  - Mutable accessor: `pub fun details_mut(u: &mut User): &mut Details`.

## Function Body Patterns
- **Coin Operations**:
  ```move
  // Preferred
  let balance = payment.balance_mut().split(amount);
  let coin = balance.into_coin(ctx);
  ```
- **String Literals**: Use `b"text".to_string()` or `b"text".to_ascii_string()`. Do not import `std::string::utf8`.
- **UID Deletion**: Call `id.delete();` instead of `object::delete(id);`.
- **TxContext Sender**: Use `ctx.sender()`.
- **Vector Syntax**:
  ```move
  let mut v = vector[10];
  let first = v[0];
  assert!(v.length() == 1);
  ```
  Avoid `vector::empty(); vector::push_back(&mut v, …);`.
- **Collection Indexing**: Use `&x[&key]` or `&mut x[&key]` for `VecMap`‑like types.

## Option Macros
- **`do!`** – Execute a closure when the option is `some`:
  ```move
  opt.do!(|v| call(v));
  ```
- **`destroy_or!`** – Extract value or provide default/abort:
  ```move
  let v = opt.destroy_or!(default);
  let v = opt.destroy_or!(abort EEmpty);
  ```

## Loop Macros
- **Repeat N Times**: `32u8.do!(|_| action());`
- **Tabulate Vector**: `vector::tabulate!(32, |i| i * 2);`
- **Iterate by Reference**: `vec.do_ref!(|e| process(e));`
- **Destroy with Callback**: `vec.destroy!(|e| cleanup(e));`
- **Fold**: `let sum = src.fold!(0, |acc, v| acc + v);`
- **Filter**: `let filtered = src.filter!(|e| e > 10);`

## Testing
- Combine `#[test]` and `#[expected_failure]` on the same function: `#[test, expected_failure]`.
- End expected‑failure tests with an explicit `abort` to show the failure point.
- Do not prefix test names with `test_`; the attribute already marks them.
- Use the simplest test harness. Prefer `let ctx = &mut tx_context::dummy();` over a full `TestScenario` when not needed.
- **Assertions**:
  - Use `assert!(condition);` – do not supply an abort code.
  - Prefer `assert_eq!(actual, expected);` for value comparison.
- **Black‑hole Destroy**: Import and call `sui::test_utils::destroy; destroy(nft);`.

## Comments
- Start documentation comments with `///`.
- Add inline comments for non‑obvious logic, potential underflows, or TODOs.
  ```move
  // Note: underflow possible if `value < 10`.
  // TODO: add an assert here.
  let v = external_call(value, ctx);
  ```

## Reporting
Present findings in the following structure:

```markdown
## Move Code Quality Analysis

### Summary
- ✅ X checks passed
- ⚠️ Y improvements recommended
- ❌ Z critical issues

### Critical Issues
#### 1. Missing Move 2024 Edition
**File**: Move.toml:2
**Issue**: No edition specified.
**Impact**: Modern features unavailable.
**Fix**:
```toml
[package]
name = "my_package"
edition = "2024"
```

### Important Improvements
#### 2. Legacy Module Syntax
**File**: sources/my_module.move:1‑10
**Issue**: Uses curly‑brace module definition.
**Impact**: Increases indentation, outdated.
**Current**:
```move
module my_package::my_module {
    public struct A {}
}
```
**Recommended**:
```move
module my_package::my_module;

public struct A {}
```

### Recommended Enhancements
* List lower‑priority items here.

### Next Steps
1. Apply critical fixes.
2. Run the formatter.
3. Re‑run the checker.
4. Review test suite.
```

## Checklist
- [ ] `Move.toml` contains a 2024 edition line.
- [ ] No explicit framework dependencies for Sui 1.45+.
- [ ] Named addresses use a project‑specific prefix.
- [ ] All modules use label syntax.
- [ ] `use` statements are grouped and avoid redundant `Self` braces.
- [ ] Error constants are `EPascalCase`; other constants are `ALL_CAPS`.
- [ ] Capability structs end with `Cap`.
- [ ] Event structs are named in past tense.
- [ ] Public functions are composable; entry points are `entry fun` only.
- [ ] Parameter order follows objects → capabilities → primitives → clock → TxContext.
- [ ] Getter names follow `<field>` and `<field>_mut` patterns.
- [ ] Vector and collection syntax uses literal and index forms.
- [ ] Option and loop macros replace manual `if`/`while` patterns.
- [ ] Tests combine `#[test]` and `#[expected_failure]` when needed.
- [ ] Assertions use `assert!` or `assert_eq!` without abort codes.
- [ ] Documentation comments start with `///`.
- [ ] All code passes the Move formatter.

## Related skills

Load these when the task spans more than this skill.

- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
