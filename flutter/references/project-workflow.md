# Flutter project workflow and release checklist

## Workflow
1. Clarify: platform targets, performance goals (fps, memory), data sync, security constraints.
2. Architecture: clean architecture with feature modules (`features/`, `core/`) by default; MVVM, MVP, or MVI if the team prefers.
3. State management: pick the simplest option that fits (see SKILL.md Decisions).
4. Data layer: Drift (type-safe SQLite), Hive or ObjectBox (NoSQL), Dio (REST), Ferry or Artemis (GraphQL).
5. UI: `const` constructors; Material 3 or Cupertino; responsive with `LayoutBuilder`, `MediaQuery`, `Flex`; `Semantics` with `label` and `hint`.
6. Native code: `MethodChannel` / `EventChannel` in Kotlin and Swift, exposed through Dart wrappers.
7. Performance: `const`, keys, scoped providers (Riverpod `select`, `shouldRebuild` in custom render objects); `SliverList`/`SliverGrid` for large lists; isolates for heavy work; profile CPU, memory, GPU in DevTools.
8. Tests: unit (`package:test`, `mockito`), widget (`testWidgets`, golden files), integration (`patrol` or `integration_test`); run on a device matrix in CI.
9. CI/CD: GitHub Actions, Codemagic, or Bitrise for lint, test, flavor builds, artifact upload.
10. Release: dev/staging/prod flavors (`--flavor` + separate config files); code signing for iOS, Android, macOS, Windows, Linux; OTA via Firebase App Distribution or custom; follow store guidelines.

## Patterns
- Compose small reusable widgets; do not use inheritance for widgets.
- Keys: `ValueKey` for list items; `GlobalKey` only for rare imperative actions.
- DI: `GetIt` or Riverpod `ProviderScope`; `injectable` for generated registration.
- Errors: `try/catch` on async calls, user-friendly messages, report to Sentry or Firebase Crashlytics.
- i18n: `flutter_localizations` + ARB files; load translations lazily.
- Images: `cached_network_image` with `placeholder`.
- Codegen: `freezed`, `json_serializable`, `injectable`.

## Pitfalls
| Pitfall | Fix |
|---|---|
| `setState` overuse | Scoped providers |
| Large trees without `const` | Add `const`; slow on low-end devices otherwise |
| Heavy CPU work on main isolate | `compute` or isolates |
| Plugin missing on web | Test UI and plugins on each target |
| Legacy non-null-safe code | Migrate; Dart 3 requires full null safety |
| Hard-coded API keys | Env config or native keychain |
| Large bundle | Only needed assets, tree-shaking, compressed images |
| CI on one platform only | Matrix: iOS, Android, web, desktop |

## Release checklist
- [ ] Targets and performance budgets defined.
- [ ] Folder structure and state management set up.
- [ ] Data layer type-safe.
- [ ] UI: `const`, responsive, semantics.
- [ ] Platform channels wrapped in Dart.
- [ ] Rebuilds optimized; DevTools shows no leaks or jank.
- [ ] Unit, widget (with goldens), integration tests pass in CI.
- [ ] CI: lint, test, flavor builds, artifacts.
- [ ] Code signing, store metadata, OTA set up.
- [ ] Security: secure storage, certificate pinning, obfuscation.
- [ ] Accessibility audit with the semantics tester.
- [ ] Bundle-size analysis done; Impeller on for web/desktop if needed.
