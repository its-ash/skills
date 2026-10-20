---
name: flutter
description: "Provides expert guidance for building multi-platform Flutter apps with Dart 3, covering architecture, state management, UI, platform integration, performance, testing, security, and deployment. Use when developing Flutter apps, writing Dart code, configuring pubspec.yaml, using widgets, Riverpod, Bloc, Provider, GetX, platform channels, Firebase, testing with flutter_test, or deploying to iOS, Android, web, and desktop."
---

# Flutter Development Expert

**Purpose** – Deliver practical, production‑ready advice for Flutter 3.x+ projects that target mobile, web, desktop, and embedded devices. The skill covers Dart 3 language features, widget composition, architecture, state management, platform channels, performance, testing, security, and CI/CD.

## When to use
- You are starting a new Flutter project or refactoring an existing one.
- You need to choose an architecture or state‑management solution.
- You must integrate native iOS/Android code, web APIs, or desktop features.
- You require performance optimization, memory profiling, or bundle‑size reduction.
- You want a complete testing strategy, including unit, widget, and integration tests.
- You are preparing CI/CD pipelines, app‑store releases, or over‑the‑air updates.

## Core Workflow
1. **Clarify requirements** – platform targets, performance goals, data sync needs, security constraints.
2. **Select architecture** – clean architecture with feature modules is the default; adapt MVVM, MVP, or MVI if the team prefers.
3. **Pick state management** –
   - Riverpod 2.x for compile‑time safety and testability.
   - Bloc/Cubit for event‑driven logic.
   - GetX for quick prototypes.
   Choose the simplest solution that meets the app’s complexity.
4. **Define data layer** – use Drift for type‑safe SQLite, Hive/ObjectBox for NoSQL, and Dio for REST or Ferry/Artemis for GraphQL.
5. **Create UI** –
   - Use `const` constructors wherever possible.
   - Apply Material 3 or Cupertino design system.
   - Build responsive layouts with `LayoutBuilder`, `MediaQuery`, and `Flex` widgets.
   - Add accessibility semantics (`Semantics`, `label`, `hint`).
6. **Integrate native code** – create platform channels (`MethodChannel`, `EventChannel`) in Kotlin/Swift and expose them via Dart wrappers.
7. **Optimize performance** –
   - Minimize rebuilds with `const`, `keys`, and selective `Provider` scopes.
   - Use `SliverList`/`SliverGrid` for large scrollable data.
   - Offload heavy work to isolates.
   - Profile with Flutter DevTools (CPU, memory, GPU).
8. **Write tests** –
   - Unit tests with `package:test` and `mockito`.
   - Widget tests with `testWidgets` and golden files.
   - Integration tests with `patrol` or `integration_test`.
   - Run tests in CI on multiple device configurations.
9. **Configure CI/CD** – use GitHub Actions, Codemagic, or Bitrise to run lint, tests, and build flavors.
10. **Prepare release** –
    - Set up flavors for dev/staging/prod.
    - Sign code for iOS, Android, macOS, Windows, Linux.
    - Enable OTA updates with Firebase App Distribution or custom solutions.
    - Publish to app stores following platform guidelines.

## Decision Rules
| Situation | Recommended Choice |
|-----------|--------------------|
| Simple UI with few shared states | `Provider` or `Riverpod` with `StateProvider` |
| Complex business logic, many events | `Bloc`/`Cubit` with `Equatable` |
| Need reactive DI and quick prototyping | `GetX` |
| Large codebase, strict separation | Clean Architecture + Riverpod + `GetIt` |
| Heavy background processing | Isolates + `compute` function |
| Targeting web with strict bundle size | Enable Impeller, tree‑shake, use `dart2js` optimizations |
| Need native sensor data (BLE, camera) | Platform channel + native plugin |
| High security (key storage, pinning) | `flutter_secure_storage`, certificate pinning via `dio` interceptor |

## Patterns & Best Practices
- **Widget composition** – prefer small, reusable widgets over inheritance.
- **Const everywhere** – mark immutable widgets with `const` to avoid rebuilds.
- **Keys** – use `ValueKey` for list items, `GlobalKey` sparingly for imperative actions.
- **Dependency injection** – register services with `GetIt` or Riverpod’s `ProviderScope`.
- **Error handling** – wrap async calls in `try/catch`, surface user‑friendly messages, log with Sentry or Firebase Crashlytics.
- **Internationalization** – use `flutter_localizations` and ARB files; load translations lazily.
- **Accessibility** – always provide `semanticLabel`, proper contrast, and focus order.
- **Lazy loading** – load images with `cached_network_image` and enable `placeholder`.
- **Build flavors** – define `--flavor` in `flutter build` and separate config files.
- **Code generation** – use `freezed`, `json_serializable`, and `injectable` to reduce boilerplate.

## Common Pitfalls
- **Over‑using `setState`** – leads to unnecessary rebuilds; replace with scoped providers.
- **Large widget trees without const** – hurts performance on low‑end devices.
- **Blocking UI thread** – never run heavy CPU work on the main isolate.
- **Ignoring platform differences** – test UI on each target; web may lack certain plugins.
- **Skipping null‑safety migration** – Dart 3 requires full null safety; legacy code will cause runtime errors.
- **Hard‑coding API keys** – store them securely, use environment variables or native keychain.
- **Neglecting bundle size** – include only needed assets, enable tree‑shaking, compress images.
- **Insufficient testing on CI** – ensure device matrix covers iOS, Android, web, and desktop.

## Checklist
- [ ] Define target platforms and performance targets (fps, memory).
- [ ] Choose architecture (clean, MVVM, etc.) and create folder structure (`features/`, `core/`).
- [ ] Select state‑management solution and set up providers.
- [ ] Implement data layer with type‑safe DB (Drift) or NoSQL (Hive).
- [ ] Build UI with `const` widgets, responsive layout, and accessibility semantics.
- [ ] Add platform channels for native features; write Kotlin/Swift wrappers.
- [ ] Optimize rebuilds (keys, `select` in Riverpod, `shouldRebuild` in custom render objects).
- [ ] Profile with DevTools; fix memory leaks and jank.
- [ ] Write unit, widget, and integration tests; include golden files for UI.
- [ ] Configure CI pipeline: lint, test, build flavors, upload artifacts.
- [ ] Set up code signing, app‑store metadata, and OTA update mechanism.
- [ ] Verify security: secure storage, certificate pinning, obfuscation.
- [ ] Perform accessibility audit with Flutter’s semantics tester.
- [ ] Conduct final bundle‑size analysis; enable Impeller for web/desktop if needed.

---
**Note** – Always keep Dart null safety enabled. Use the latest stable Flutter SDK (3.x) and Dart 3 features such as records, patterns, and sealed classes to write concise, type‑safe code.

## Related skills

Load these when the task spans more than this skill.

- [`mobile-design`](../mobile-design/SKILL.md) — Guidelines for mobile‑first design of iOS, Android, and cross‑platform apps. Covers touch targets, performance…
- [`firebase-backend`](../firebase-backend/SKILL.md) — Expert guidance for building scalable, secure backends using Firebase. Use this skill for tasks involving Fire…
- [`app-store-optimization`](../app-store-optimization/SKILL.md) — Provides end‑to‑end guidance for researching keywords, optimizing metadata, managing reviews, planning launche…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
