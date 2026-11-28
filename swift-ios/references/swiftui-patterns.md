@REF:swiftui-patterns
§CTX{SwiftUI(iOS26–27/macOS26–27);Swift6.4;@Observable+@Entry+@Previewable+@Animatable+TabView}
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
§PAT:ENV_AND_ENTRY{
  replaces:`@EnvironmentObject`∧manual_`EnvironmentKey`;
  inject:`.environment(authManager)`;read:`@Environment(AuthManager.self) private var auth`;
  custom_key:`extension EnvironmentValues { @Entry var accentSurface: Color = .clear }` // works∈TransactionValues∧ContainerValues
}
§PAT:COMP_AND_ANIMATION{
  split_subviews⇒isolate_state_reads;
  mod:`struct CardModifier: ViewModifier{func body(content:Content)->some View{content.padding().background(.regularMaterial).clipShape(RoundedRectangle(cornerRadius:12))}}`+`View.cardStyle()`;
  custom_interp:`@Animatable struct GaugeShape: Shape { var progress: Double; @AnimatableIgnored var strokeWidth: CGFloat }` // auto_synthesizes_animatableData
}
§PAT:NAV_AND_TABS{
  router:`@Observable final class Router{var path=NavigationPath(); func navigate(to d:Destination){path.append(d)}; func popToRoot(){path=NavigationPath()}}`;
  dest:`enum Destination: Hashable{case detail(Item.ID),settings,profile(User.ID)}`;
  stack:`NavigationStack(path:$router.path){HomeView().navigationDestination(for:Destination.self){...}}.environment(router)`;
  tabs:`TabView { Tab("Home", systemImage: "house") { HomeView() }; Tab("Search", systemImage: "magnifyingglass", role: .search) { SearchView() } }.tabBarMinimizeBehavior(.onScrollDown).tabViewBottomAccessory { MiniPlayerView() }` // replaces_legacy_.tabItem
}
§PAT:PERF{
  list:`ScrollView{LazyVStack(spacing:8){ForEach(items,id:\.stableID){ItemRow(item:$0)}}}`(stableID,¬indices);
  skip_rerender:`struct ExpensiveChartView:View,Equatable{let dataPoints:[DataPoint]; static func ==(l:Self,r:Self)->Bool{l.dataPoints==r.dataPoints}}`;
  sparingly∈ScrollView:{`.sensoryFeedback()`,`.geometryGroup()`};minimize∈lists:{`.shadow()`,`.blur()`,`.mask()`}(offscreen_render);
  webview_under_glass⇒configure_insets∧profile_Instruments(heavy_DOM_scroll_hitches)
}
§PAT:PREVIEWS{
  stateful:`#Preview { @Previewable @State var expanded = false; FilterBar(isExpanded: $expanded) }`;
  states:`#Preview("Empty"){ItemListView(viewModel:ItemListViewModel(repository:EmptyMockRepo()))}`;`#Preview("Loaded"){ItemListView(viewModel:ItemListViewModel(repository:PopulatedMockRepo()))}`
}
§R{
  1:@Observable≻ObservableObject;
  2:@Entry≻manual_EnvironmentKey;
  3:@Previewable_@State≻preview_wrapper_views;
  4:Tab(...)≻deprecated_.tabItem;
  5:scope_custom_@Entry_keys_to_feature/design_system(¬global_pollution)
}
§ANTI{¬AnyView;¬ForEach_indices_for_mutable_data;¬IO_in_body/init;¬@StateObject/@EnvironmentObject_in_new_code;¬wrapper_structs_for_stateful_previews}
§REL{[swift-ios](../SKILL.md):core_rules;[liquid-glass-design](liquid-glass-design.md):iOS26–27_glass+chrome}
