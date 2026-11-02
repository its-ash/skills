---
name: kotlin
description: "Idiomatic Kotlin: null safety, immutability, sealed types, coroutines, Flow, delegation, DSL builders, Gradle Kotlin DSL, Ktor, Exposed, Kotest, MockK, Android Clean Architecture, Compose Multiplatform. Use for .kt/.kts code, build.gradle.kts, StateFlow, SharedFlow, Koin, HikariCP, Flyway, Kover, detekt, ktlint, KMP, Room, SQLDelight, Jetpack Compose. Sub-skills: kotlin-coroutines-flows, kotlin-testing, kotlin-ktor-patterns, kotlin-exposed-patterns, android-clean-architecture, compose-multiplatform-patterns."
---

# Kotlin

Write idiomatic Kotlin that uses the type system for safety.

## Core rules
- Use non-nullable types by default. Use `?.` and `?:`. Never use `!!`.
- Treat Java platform types as nullable at the boundary.
- Use `val` and read-only collections. Update data classes with `copy()`. Do not put `var` in data classes.
- Use expression bodies and `when` as an expression for single-expression functions.
- Use `data class` for values. Use `@JvmInline value class` with `require` in `init` for typed IDs (`UserId`, `Email`).
- Model closed sets with `sealed class` / `sealed interface`. Make `when` exhaustive; do not add `else` on sealed types.
- Do not nest scope functions. Chain safe calls: `user?.address?.city?.let { ... }`.
- Keep extensions scoped (private or class member) when only one class needs them.
- Use structured concurrency (`coroutineScope`, `supervisorScope`, `viewModelScope`). Never use `GlobalScope`.
- Never swallow `CancellationException`; rethrow it. Call `ensureActive()` in long loops.
- Use `require` for argument checks and `check` for state checks, with a clear message.
- Return `T?` or `Result<T>` for expected failures. Do not use exceptions for control flow.
- Use `by` delegation (`lazy`, `observable`, interface `by`) to reuse behavior; avoid inheritance for it.
- Mark DSL receivers with `@DslMarker`.
- Configure builds in `build.gradle.kts` with `jvmToolchain`, detekt, and Kover.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Nullable transform | `x?.let { }` | `if (x != null)` chains, `!!` |
| Configure new object | `apply { }` | repeated `obj.` lines |
| Side effect, keep value | `also { }` | temp variables |
| Compute with receiver | `run { }` / `with(x) { }` | nested scope functions |
| Children may fail alone | `supervisorScope` + per-child try/catch | `coroutineScope` (one failure cancels all) |
| Parallel independent calls | `coroutineScope { async {}; async {} }` | sequential `await` chains |
| Suspend call in `finally` | `withContext(NonCancellable)` | plain suspend call (skipped on cancel) |
| Large collection, many steps | `asSequence()` ... `toList()` | eager chains with big intermediates |
| Index or group | `associateBy`, `groupBy`, `partition` | manual `mutableMapOf` loops |
| Domain error set | sealed interface + exhaustive `when` | error codes as strings |
| Expected failure | `T?` / `runCatching` → `Result` | `try/catch` for normal flow |

## Load on demand
| Need | Read |
|---|---|
| Good/bad examples for every core rule, scope-function table, DSL builders, delegation, `build.gradle.kts` template with versions | [references/kotlin-idioms.md](references/kotlin-idioms.md) |
| Coroutines, StateFlow, SharedFlow, Flow operators, dispatchers, cancellation, Turbine / `runTest` | [references/kotlin-coroutines-flows.md](references/kotlin-coroutines-flows.md) |
| Kotest, MockK, TDD, coroutine and Flow tests, property tests, Kover gates | [references/kotlin-testing.md](references/kotlin-testing.md) |
| Ktor server: routing, ContentNegotiation, JWT, StatusPages, CORS, Koin, WebSockets, `testApplication` | [references/kotlin-ktor-patterns.md](references/kotlin-ktor-patterns.md) |
| Exposed DSL/DAO, transactions, HikariCP, Flyway, JSONB, pagination, H2 tests | [references/kotlin-exposed-patterns.md](references/kotlin-exposed-patterns.md) |
| Android/KMP layers: UseCases, repositories, mappers, Room, SQLDelight, Koin/Hilt, convention plugins | [references/android-clean-architecture.md](references/android-clean-architecture.md) |
| Jetpack Compose / Compose Multiplatform: screen state, navigation, slots, recomposition, Material 3 | [references/compose-multiplatform-patterns.md](references/compose-multiplatform-patterns.md) |

## Related skills
- [`java`](../java/SKILL.md) — JVM backends: Spring Boot, Quarkus, JPA.
- [`backend-development`](../backend-development/SKILL.md) — API design, resilience, observability.
- [`mobile-design`](../design/references/mobile-design.md) — Android and iOS screen design rules.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — General test structure, TDD, mocking.
