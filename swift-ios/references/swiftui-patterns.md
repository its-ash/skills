# SwiftUI Patterns

Code for the rules in [`swift-ios`](../SKILL.md): state, composition, navigation, performance, previews.

## @Observable view model
`@Observable` tracks property-level reads; only views that read a changed property re-render.
```swift
@Observable
final class ItemListViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    var searchText = ""
    private let repository: any ItemRepository

    init(repository: any ItemRepository = DefaultItemRepository()) { self.repository = repository }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await repository.fetchAll()) ?? []
    }
}

struct ItemListView: View {
    @State private var viewModel: ItemListViewModel
    init(viewModel: ItemListViewModel = ItemListViewModel()) { _viewModel = State(initialValue: viewModel) }

    var body: some View {
        List(viewModel.items) { ItemRow(item: $0) }
            .searchable(text: $viewModel.searchText)
            .overlay { if viewModel.isLoading { ProgressView() } }
            .task { await viewModel.load() }
    }
}
```

## Environment injection (replaces @EnvironmentObject)
```swift
ContentView().environment(authManager)

struct ProfileView: View {
    @Environment(AuthManager.self) private var auth
    var body: some View { Text(auth.currentUser?.name ?? "Guest") }
}
```

## Composition
```swift
// Small subviews: only the one that reads changed state re-renders
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

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding().background(.regularMaterial).clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
extension View { func cardStyle() -> some View { modifier(CardModifier()) } }
```

## Type-safe NavigationStack
```swift
@Observable
final class Router {
    var path = NavigationPath()
    func navigate(to destination: Destination) { path.append(destination) }
    func popToRoot() { path = NavigationPath() }
}

enum Destination: Hashable {
    case detail(Item.ID), settings, profile(User.ID)
}

struct RootView: View {
    @State private var router = Router()
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView().navigationDestination(for: Destination.self) { dest in
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
```swift
ScrollView {
    LazyVStack(spacing: 8) {
        ForEach(items, id: \.stableID) { ItemRow(item: $0) }   // stable IDs, never indices
    }
}

// Expensive body: Equatable lets SwiftUI skip re-render
struct ExpensiveChartView: View, Equatable {
    let dataPoints: [DataPoint]   // DataPoint: Equatable
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.dataPoints == rhs.dataPoints }
    var body: some View { /* chart */ }
}
```
- Use `.sensoryFeedback()` and `.geometryGroup()` sparingly in scroll views.
- Minimize `.shadow()`, `.blur()`, `.mask()` in lists: they trigger offscreen rendering.

## Previews
```swift
#Preview("Empty state") { ItemListView(viewModel: ItemListViewModel(repository: EmptyMockRepository())) }
#Preview("Loaded") { ItemListView(viewModel: ItemListViewModel(repository: PopulatedMockRepository())) }
```
