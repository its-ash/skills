---
name: dotnet
description: "Idiomatic C# and .NET patterns: immutability with records, dependency injection, async/await with CancellationToken, options pattern, result pattern, EF Core repositories, ASP.NET Core middleware, minimal APIs, and guard clauses. Use when writing or reviewing .cs, .fs, .csproj, or .sln code, ASP.NET Core, EF Core, dotnet build, dotnet test, xUnit, F#, WPF, WinForms, or Windows desktop apps. Sub-skills: csharp-testing, fsharp-testing, windows-desktop-e2e."
---
# .NET Development Patterns
Idiomatic C# and .NET for ASP.NET Core services, EF Core data access, and desktop apps.

## Core rules
- Use `sealed record` for value objects and `required` + `init` for DTOs. Make mutability an explicit choice.
- Expose `IReadOnlyList<T>`, not `List<T>`, from models and repositories.
- Enable nullable reference types. Mark nullable returns with `?`.
- Seal classes by default. Write explicit access modifiers.
- Depend on interfaces at service boundaries. Register in DI (`AddScoped`, `AddSingleton`, `AddTransient`). Use primary-constructor injection.
- Go async all the way. Accept and pass `CancellationToken` on every async call.
- Never block on async with `.Result` or `.Wait()` (deadlock risk).
- Return `Task`, not `async void` (exception: event handlers).
- Run independent async calls together with `Task.WhenAll`.
- Bind config with the options pattern (`Configure<T>(GetSection(T.SectionName))`, inject `IOptions<T>`).
- Return `Result<T>` for expected failures. Throw only for programmer errors and invalid arguments.
- Guard early with `ArgumentNullException.ThrowIfNull`, `ArgumentOutOfRangeException`, `ArgumentException`; keep the happy path unnested.
- Use `AsNoTracking()` on EF Core read queries. `Include` only the needed navigations.
- Group minimal API routes with `MapGroup(...).RequireAuthorization().WithTags(...)`; return `TypedResults`.
- Log with message templates (`{Name}` placeholders), not string interpolation.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Expected business failure (validation, not found) | `Result<T>` or `TypedResults.NotFound()` | Exceptions for control flow |
| Unexpected exception | Handle or rethrow with context | `catch (Exception) { }` |
| Need a collaborator | Constructor injection | `new Service()` in constructors |
| Shared state | DI scope or `ConcurrentDictionary` | Mutable `static` state |
| Data on a type | Properties with right accessors | `public` fields |
| Unknown shape in business logic | Generics or explicit types | `dynamic` |
| String build in a loop | `StringBuilder` or interpolated string handlers | `string.Format` in loops |
| Cross-cutting HTTP concern (timing, headers) | Middleware with `RequestDelegate` + `try/finally` | Repeating logic per endpoint |
| Read-only EF query | `AsNoTracking()` | Tracked entities for reads |

## Load on demand
| Need | Read |
|---|---|
| Code for records, DI, async, `WhenAll`, options, `Result<T>`, EF Core repository, middleware, minimal API, guard clauses | [references/csharp-patterns.md](references/csharp-patterns.md) |
| C# tests: xUnit, FluentAssertions, NSubstitute, WebApplicationFactory, Testcontainers, test data builders | [references/csharp-testing.md](references/csharp-testing.md) |
| F# tests: xUnit, FsUnit, Unquote, FsCheck, function stubs, ASP.NET Core integration | [references/fsharp-testing.md](references/fsharp-testing.md) |
| E2E for WPF, WinForms, Win32/MFC, Qt with pywinauto and UI Automation; sandbox; CI on `windows-latest` | [references/windows-desktop-e2e.md](references/windows-desktop-e2e.md) |

## Related skills
- [`backend-development`](../backend-development/SKILL.md) — API and service design for ASP.NET Core.
- [`database-design`](../database-design/SKILL.md) — schema and migration design for EF Core.
- [`secure-coding`](../secure-coding/SKILL.md) — auth, secrets, input validation.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — general TDD and mock patterns.
