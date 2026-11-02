---
name: swift-ios
description: "Native iOS and macOS with Swift and SwiftUI: @Observable state, composition, NavigationStack, render performance, Swift 6.2 concurrency, actor persistence, protocol DI with Swift Testing, FoundationModels on-device LLM, iOS 26 Liquid Glass. Use for SwiftUI views, .swift files, Xcode projects, @MainActor or @concurrent code, Sendable or data-race errors, actors, Swift Testing #expect, @Generable, glassEffect, UIKit or WidgetKit glass. Sub-skills: swift-concurrency, swift-actor-persistence, swift-protocol-di-testing, foundation-models-on-device, liquid-glass-design."
---
# Swift / iOS
Modern SwiftUI on Apple platforms: Observation, composition, type-safe navigation, render performance.

## Core rules
- Use `@Observable` for models. Do not use `ObservableObject`, `@Published`, `@StateObject`, `@EnvironmentObject` in new code; migrate them.
- Pick the simplest property wrapper that fits (see table).
- Expose model state as `private(set) var`; mutate through methods.
- Inject dependencies through `init` with production defaults (`any Repository = Default...()`), and shared ones with `.environment(obj)` + `@Environment(Type.self)`.
- Own a view model with `@State` only in the view that owns the data. Pass it down to children.
- Split views into small structs so state changes invalidate only the reader.
- Put reusable styling in a `ViewModifier` + `View` extension.
- Route with `NavigationStack(path:)`, a `Hashable` `Destination` enum, and an `@Observable` router in the environment.
- Never do I/O, network, or heavy work in `body` or `init`. Use `.task {}` (auto-cancels on disappear).
- Use `LazyVStack`/`LazyHStack` for large collections. Use stable IDs in `ForEach`, never indices.
- Avoid `AnyView`. Use `@ViewBuilder` or `Group` for conditional views.
- Respect `Sendable` when passing data across actors.
- Add `#Preview` variants per state (empty, loaded) with mock repositories.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| View-local value (toggle, field, sheet flag) | `@State` | `@Observable` class |
| Child edits parent's `@State` | `@Binding` | Copy and callback |
| View owns a multi-property model | `@Observable` class held in `@State` | `@StateObject` |
| Read-only model from parent | Plain `@Observable` reference, no wrapper | `@State` in child |
| Two-way binding into `@Observable` property | `@Bindable` | Manual `Binding(get:set:)` |
| App-wide dependency | `.environment(obj)` + `@Environment(Type.self)` | `@EnvironmentObject` |
| Expensive `body` with stable inputs | Conform view to `Equatable` | Re-render on every parent change |
| Effects in scrolling lists | Few `.shadow`/`.blur`/`.mask`; sparse `.geometryGroup`, `.sensoryFeedback` | Offscreen effects per row |

## Load on demand
| Need | Read |
|---|---|
| Code: `@Observable` VM + view, environment, composition, `ViewModifier`, router, lazy lists, `Equatable` view, previews | [references/swiftui-patterns.md](references/swiftui-patterns.md) |
| Swift 6.2 concurrency: `@concurrent`, MainActor default, isolated conformances, migration, data-race errors | [references/swift-concurrency.md](references/swift-concurrency.md) |
| Actor repository: in-memory cache + atomic file writes with `@Observable` VMs | [references/swift-actor-persistence.md](references/swift-actor-persistence.md) |
| `Sendable` protocol DI for file system, network, APIs; mocks; Swift Testing `@Test`/`#expect` | [references/swift-protocol-di-testing.md](references/swift-protocol-di-testing.md) |
| FoundationModels (iOS 26+): availability, `LanguageModelSession`, `@Generable`, tools, streaming, 4,096-token limit | [references/foundation-models-on-device.md](references/foundation-models-on-device.md) |
| Liquid Glass: `.glassEffect()`, `GlassEffectContainer`, `glassEffectID`, UIKit `UIGlassEffect`, WidgetKit | [references/liquid-glass-design.md](references/liquid-glass-design.md) |

## Related skills
- [`mobile-design`](../design/references/mobile-design.md) — iOS/Android conventions, touch targets, layouts.
- [`flutter`](../flutter/SKILL.md) — cross-platform alternative; platform channels into Swift.
- [`react-native`](../frontend-development/references/react-native.md) — cross-platform alternative with Expo.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — general TDD and test structure.
- [`secure-coding`](../secure-coding/SKILL.md) — Keychain, secrets, input validation.
