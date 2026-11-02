---
name: cpp
description: "Modern C++ (C++17/20/23) coding standards from the C++ Core Guidelines: interfaces, functions, classes, Rule of Zero and Five, RAII and smart pointers, initialization, exceptions, const and constexpr, concurrency, concepts and templates, standard library, enums, headers, naming, and performance. Use when writing, reviewing, or refactoring .cpp, .h, or .hpp code, CMakeLists.txt, unique_ptr, shared_ptr, move semantics, lock_guard, scoped_lock, std::string_view, enum class, or fixing memory leaks, dangling pointers, and data races. Sub-skills: cpp-testing."
---

# C++ (Core Guidelines)
Type-safe, resource-safe, immutable-by-default modern C++ (C++17/20/23). Rule IDs refer to the [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines).

## Core rules
- No naked `new`/`delete` or `malloc`/`free`; use RAII, `make_unique`, `make_shared` (R.10, R.11).
- Raw `T*` and `T&` never own (R.3, I.11).
- Initialize every object at declaration; prefer `{}` (ES.20, ES.23).
- Make variables and member functions `const`/`constexpr` by default (Con.1-5, ES.25).
- `enum class`, not plain `enum`; `constexpr`, not macros (Enum.1, Enum.3).
- `nullptr`, not `0`/`NULL`; no C-style casts; no narrowing; no casting away `const` (ES.46-50).
- Mark single-argument constructors `explicit` (C.46).
- Apply Rule of Zero; else Rule of Five (C.20, C.21).
- Base destructor public virtual or protected non-virtual; use exactly one of `virtual`/`override`/`final` (C.35, C.128).
- Constrain every template with concepts (T.10).
- Headers: include guards, self-contained, no global `using namespace` (SF.7, SF.8, SF.11).
- RAII locks only (`scoped_lock`, named `lock_guard`); wait only with a condition (CP.20, CP.42, CP.44).
- Custom exception types; throw by value, catch by `const&` (E.14, E.15).
- `'\n'`, not `std::endl` (SL.io.50). Named constants, no magic numbers (ES.45).
- Embedded/bare-metal or legacy C: adapt rules selectively.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Ownership | `unique_ptr`; `shared_ptr` only for shared ownership (R.21) | `shared_ptr` by default |
| Pass "in" param | Cheap types by value; others `const&`; sinks by value + move (F.16) | `const T` returns (F.49) |
| Return several values | Return a struct (F.20, F.21) | Output parameters |
| Text param | `std::string_view` to observe, `std::string` to own | `const char*` |
| Container | `std::vector` default, `std::array` fixed size | C arrays |
| Multiple mutexes | `std::scoped_lock lock(a, b)` (CP.21) | Nested `lock_guard`s |
| Sync primitive | `std::mutex` + `condition_variable` | `volatile` (CP.8), lock-free (CP.100), detached threads (CP.26) |
| Compile-time value | `constexpr` function or immediately invoked lambda (F.4, Per.11) | Template metaprogramming (T.120) |
| Specialize behavior per type | Overload (T.144) | Function template specialization |
| Performance change | Measure first (Per.1, Per.6); keep data contiguous (Per.19) | Pointer-chasing containers |
| Error cannot be handled here | Let it propagate (E.17) | Empty catch blocks, `errno` (E.28) |

## Load on demand
| Need | Read |
|---|---|
| Full rule tables (P, I, F, C, R, ES, E, Con, CP, T, SL, Enum, SF, NL, Per), anti-patterns, and one example per area | [references/core-guidelines.md](references/core-guidelines.md) |
| GoogleTest/GoogleMock, CMake/CTest, flaky tests, gcov/llvm-cov, ASan/UBSan/TSan, libFuzzer | [references/cpp-testing.md](references/cpp-testing.md) |

## Related skills
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — root cause for crashes, segfaults, memory bugs
- [`windows-desktop-e2e`](../dotnet/references/windows-desktop-e2e.md) — E2E tests for Win32/MFC and Qt apps
- [`secure-coding`](../secure-coding/SKILL.md) — input validation and secure defaults
