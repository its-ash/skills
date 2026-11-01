---
name: swift-ios
description: "Native iOS and macOS development with Swift and SwiftUI: @Observable state, view composition, type-safe NavigationStack, render performance, Swift 6.2 concurrency, actor-based persistence, protocol DI with Swift Testing, on-device FoundationModels LLM, and iOS 26 Liquid Glass. Use when building or reviewing SwiftUI views, .swift files, Xcode projects, @Observable view models, NavigationStack routing, @MainActor or @concurrent code, Sendable or data-race errors, actors, Swift Testing #expect, Apple Intelligence on-device models, @Generable, glassEffect, UIKit or WidgetKit glass. Sub-skills: swift-concurrency, swift-actor-persistence, swift-protocol-di-testing, foundation-models-on-device, liquid-glass-design."
---

# Swift / iOS

Modern SwiftUI patterns for building declarative, performant user interfaces on Apple platforms. Covers the Observation framework, view composition, type-safe navigation, and performance optimization. Sub-skills cover concurrency, persistence, testing, on-device AI, and Liquid Glass.

## When to use

- Building SwiftUI views and managing state (`@State`, `@Observable`, `@Binding`)
- Designing navigation flows with `NavigationStack`
- Structuring view models and data flow
- Optimizing rendering performance for lists and complex layouts
- Working with environment values and dependency injection in SwiftUI

## State Management

### Property Wrapper Selection

Choose the simplest wrapper that fits:

| Wrapper | Use Case |
|---------|----------|
| `@State` | View-local value types (toggles, form fields, sheet presentation) |
| `@Binding` | Two-way reference to parent's `@State` |
| `@Observable` class + `@State` | Owned model with multiple properties |
| `@Observable` class (no wrapper) | Read-only reference passed from parent |
| `@Bindable` | Two-way binding to an `@Observable` property |
| `@Environment` | Shared dependencies injected via `.environment()` |

### @Observable ViewModel

Use `@Observable` (not `ObservableObject`) — it tracks property-level changes so SwiftUI only re-renders views that read the changed property:

```swift
@Observable
final class ItemListViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    var searchText = ""

    private let repository: any ItemRepository

    init(repository: any ItemRepository = DefaultItemRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await repository.fetchAll()) ?? []
    }
}
```

### View Consuming the ViewModel

```swift
struct ItemListView: View {
    @State private var viewModel: ItemListViewModel

    init(viewModel: ItemListViewModel = ItemListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .searchable(text: $viewModel.searchText)
        .overlay { if viewModel.isLoading { ProgressView() } }
        .task { await viewModel.load() }
    }
}
```

### Environment Injection

Replace `@EnvironmentObject` with `@Environment`:

```swift
// Inject
ContentView()
    .environment(authManager)

// Consume
struct ProfileView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        Text(auth.currentUser?.name ?? "Guest")
    }
}
```

## View Composition

### Extract Subviews to Limit Invalidation

Break views into small, focused structs. When state changes, only the subview reading that state re-renders:

```swift
struct OrderView: View {
    @State private var viewModel = OrderViewModel()

    var body: some View {
        VStack {
            OrderHeader(title: viewModel.title)
            OrderItemList(items: viewModel.items)
            OrderTotal(total: viewModel.total)
        }
    }
}
```

### ViewModifier for Reusable Styling

```swift
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
```

## Navigation

### Type-Safe NavigationStack

Use `NavigationStack` with `NavigationPath` for programmatic, type-safe routing:

```swift
@Observable
final class Router {
    var path = NavigationPath()

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

enum Destination: Hashable {
    case detail(Item.ID)
    case settings
    case profile(User.ID)
}

struct RootView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Destination.self) { dest in
                    switch dest {
                    case .detail(let id): ItemDetailView(itemID: id)
                    case .settings: SettingsView()
                    case .profile(let id): ProfileView(userID: id)
                    }
                }
        }
        .environment(router)
    }
}
```

## Performance

### Use Lazy Containers for Large Collections

`LazyVStack` and `LazyHStack` create views only when visible:

```swift
ScrollView {
    LazyVStack(spacing: 8) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### Stable Identifiers

Always use stable, unique IDs in `ForEach` — avoid using array indices:

```swift
// Use Identifiable conformance or explicit id
ForEach(items, id: \.stableID) { item in
    ItemRow(item: item)
}
```

### Avoid Expensive Work in body

- Never perform I/O, network calls, or heavy computation inside `body`
- Use `.task {}` for async work — it cancels automatically when the view disappears
- Use `.sensoryFeedback()` and `.geometryGroup()` sparingly in scroll views
- Minimize `.shadow()`, `.blur()`, and `.mask()` in lists — they trigger offscreen rendering

### Equatable Conformance

For views with expensive bodies, conform to `Equatable` to skip unnecessary re-renders:

```swift
struct ExpensiveChartView: View, Equatable {
    let dataPoints: [DataPoint] // DataPoint must conform to Equatable

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.dataPoints == rhs.dataPoints
    }

    var body: some View {
        // Complex chart rendering
    }
}
```

## Previews

Use `#Preview` macro with inline mock data for fast iteration:

```swift
#Preview("Empty state") {
    ItemListView(viewModel: ItemListViewModel(repository: EmptyMockRepository()))
}

#Preview("Loaded") {
    ItemListView(viewModel: ItemListViewModel(repository: PopulatedMockRepository()))
}
```

## Anti-Patterns to Avoid

- Using `ObservableObject` / `@Published` / `@StateObject` / `@EnvironmentObject` in new code — migrate to `@Observable`
- Putting async work directly in `body` or `init` — use `.task {}` or explicit load methods
- Creating view models as `@State` inside child views that don't own the data — pass from parent instead
- Using `AnyView` type erasure — prefer `@ViewBuilder` or `Group` for conditional views
- Ignoring `Sendable` requirements when passing data to/from actors

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/swift-concurrency.md](references/swift-concurrency.md) | Swift 6.2 Approachable Concurrency: single-threaded by default, `@concurrent` offloading, isolated conformances, MainActor default inference, migration from Swift 5.x/6.0/6.1, data-race errors. |
| [references/swift-actor-persistence.md](references/swift-actor-persistence.md) | Thread-safe local storage with an actor repository: in-memory cache + atomic file writes, combined with `@Observable` view models. |
| [references/swift-protocol-di-testing.md](references/swift-protocol-di-testing.md) | Small `Sendable` protocols for file system, network, and external APIs; default production implementations; mocks; Swift Testing `@Test` / `#expect`. |
| [references/foundation-models-on-device.md](references/foundation-models-on-device.md) | Apple FoundationModels (iOS 26+): availability check, `LanguageModelSession`, `@Generable` guided generation, tool calling, snapshot streaming, 4,096-token limit. |
| [references/liquid-glass-design.md](references/liquid-glass-design.md) | iOS 26 Liquid Glass: `.glassEffect()`, `GlassEffectContainer`, morphing with `glassEffectID`, glass button styles, UIKit `UIGlassEffect`, WidgetKit accented mode. |

## Related skills

Load these when the task spans more than this skill.

- [`mobile-design`](../design/references/mobile-design.md) — iOS/Android conventions, touch targets, phone/tablet layouts.
- [`flutter`](../flutter/SKILL.md) — cross-platform alternative; platform channels into Swift.
- [`react-native`](../frontend-development/references/react-native.md) — cross-platform alternative with Expo.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — general TDD and test structure.
- [`secure-coding`](../secure-coding/SKILL.md) — Keychain, secrets, and input validation.
