@REF:swiftui-patterns
§REL:[swift-ios](../SKILL.md)
§PAT:OBSERVABLE_VM{
  property_read_tracking→only_reading_views_rerender;
  ```swift
  @Observable final class ItemListViewModel {
      private(set) var items: [Item] = []; private(set) var isLoading = false; var searchText = ""
      private let repo: any ItemRepository
      init(repository: any ItemRepository = DefaultItemRepository()) { repo = repository }
      func load() async { isLoading = true; defer { isLoading = false }; items = (try? await repo.fetchAll()) ?? [] }
  }
  // View: @State private var vm: ItemListViewModel; init(vm){_vm=State(initialValue:vm)}
  List(vm.items){ItemRow(item:$0)}.searchable(text:$vm.searchText).overlay{if vm.isLoading{ProgressView()}}.task{await vm.load()}
  ```
}
§PAT:ENV{replaces:`@EnvironmentObject`;inject:`.environment(authManager)`;read:`@Environment(AuthManager.self) private var auth`}
§PAT:COMP{split_subviews⇒isolate_state_reads;mod:`struct CardModifier: ViewModifier{func body(content:Content)->some View{content.padding().background(.regularMaterial).clipShape(RoundedRectangle(cornerRadius:12))}}`+`View.cardStyle()`}
§PAT:NAV{
  `@Observable final class Router{var path=NavigationPath(); func navigate(to d:Destination){path.append(d)}; func popToRoot(){path=NavigationPath()}}`;
  `enum Destination: Hashable{case detail(Item.ID),settings,profile(User.ID)}`;
  `NavigationStack(path:$router.path){HomeView().navigationDestination(for:Destination.self){...}}.environment(router)`
}
§PAT:PERF{
  list:`ScrollView{LazyVStack(spacing:8){ForEach(items,id:\.stableID){ItemRow(item:$0)}}}`(stableID,¬indices);
  skip_rerender:`struct ExpensiveChartView:View,Equatable{let dataPoints:[DataPoint]; static func ==(l:Self,r:Self)->Bool{l.dataPoints==r.dataPoints}}`;
  sparingly∈ScrollView:{`.sensoryFeedback()`,`.geometryGroup()`};minimize∈lists:{`.shadow()`,`.blur()`,`.mask()`}(offscreen_render)
}
§PAT:PREVIEWS{`#Preview("Empty state"){ItemListView(viewModel:ItemListViewModel(repository:EmptyMockRepository()))}`;`#Preview("Loaded"){ItemListView(viewModel:ItemListViewModel(repository:PopulatedMockRepository()))}`}
