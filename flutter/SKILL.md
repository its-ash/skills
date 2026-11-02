---
name: flutter
description: "Provides expert guidance for building multi-platform Flutter apps with Dart 3, covering architecture, state management, UI, platform integration, performance, testing, security, and deployment. Use when developing Flutter apps, writing Dart code, configuring pubspec.yaml, using widgets, Riverpod, Bloc, Provider, GetX, platform channels, Firebase, testing with flutter_test, or deploying to iOS, Android, web, and desktop, or reviewing Flutter/Dart code. Sub-skills: dart-flutter-patterns, flutter-code-review."
---

# Flutter
Production Flutter 3.x apps with Dart 3 for mobile, web, desktop, and embedded.

## Core rules
- Use the latest stable Flutter 3.x and Dart 3: full null safety, records, patterns, sealed classes.
- Default to clean architecture with feature modules (`features/`, `core/`).
- Mark immutable widgets `const`. Extract small widget classes, not helper methods.
- Never run heavy CPU work on the main isolate; use `compute` or isolates.
- Use `SliverList`/`SliverGrid` for large scrollable data.
- Add `Semantics` labels, contrast, and focus order to each interactive widget.
- Store secrets in `flutter_secure_storage` or the native keychain; never hard-code API keys.
- Use `freezed` and `json_serializable` for immutable models.
- Test on each target platform; web can lack plugins.
- Use flavors (dev/staging/prod) with separate config files.
- Theme changes: follow the shared theme repo flow in root conventions.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Simple UI, few shared states | `Provider` or Riverpod `StateProvider` | Bloc boilerplate |
| Complex logic, many events | `Bloc`/`Cubit` + `Equatable` | `setState` chains |
| Quick prototype, reactive DI | `GetX` | GetX in large long-lived apps |
| Large codebase, strict layers | Clean Architecture + Riverpod + `GetIt` | Global singletons |
| Heavy background work | Isolates + `compute` | Async on main isolate |
| Web with strict bundle size | Impeller, tree-shaking, `dart2js` optimizations | Unused assets |
| Native sensors (BLE, camera) | Platform channel + native plugin | Pure-Dart workarounds |
| High security (keys, pinning) | `flutter_secure_storage`; cert pinning in `dio` interceptor | `SharedPreferences` for secrets |
| Local DB | Drift (SQL), Hive or ObjectBox (NoSQL) | Raw SQL strings |
| Network | Dio (REST), Ferry or Artemis (GraphQL) | Ad hoc `http` with no interceptors |

## Load on demand
| Need | Read |
|---|---|
| Step-by-step workflow, patterns, pitfalls table, release checklist (CI/CD, signing, OTA) | [references/project-workflow.md](references/project-workflow.md) |
| Dart 3 null safety, sealed/Freezed state, async `mounted` checks, scoped rebuilds, BLoC/Cubit, Riverpod notifiers, GoRouter auth redirect, Dio interceptors, global error capture, tests | [references/dart-flutter-patterns.md](references/dart-flutter-patterns.md) |
| Review checklist: project health, Dart pitfalls, widgets, state, performance, testing, a11y, security, packages, routing, l10n, DI, static analysis | [references/flutter-code-review.md](references/flutter-code-review.md) |

## Related skills
- [`mobile-design`](../design/references/mobile-design.md) — mobile-first UI, touch targets
- [`firebase-backend`](../backend-development/references/firebase-backend.md) — Firebase auth, Firestore, functions
- [`swift-ios`](../swift-ios/SKILL.md) — native iOS for platform channels
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — unit test patterns and mocks
