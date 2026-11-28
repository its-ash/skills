@REF:swift-actor-persistence
§CTX{Swift6.2–6.4;actor_persistence+SwiftData_@ModelActor+Synchronization.Mutex}
§USE:shared_mut_state∨local_persist∨offline_first∨SwiftData_bg_writes∨replace_GCD_NSLock
§D{
  simple_JSON/blob_store⇒actor_LocalRepository+`.atomic`_file_write;
  relational_schema/queries/CloudKit⇒SwiftData_`@Model`+`@ModelActor`_bg_writer;
  tiny_sync_in_mem_state(no_IO,no_await)⇒`Synchronization.Mutex`¬actor_hop¬`NSLock`/`DispatchQueue`
}
§PAT:ACTOR_REPO{
  why:compiler_thread_safety∧O(1)_id_lookup∧`.atomic`_crash_safety∧sync_init(¬async_init);
  ```swift
  public actor LocalRepository<T: Codable & Identifiable & Sendable> where T.ID == String {
      private var cache: [String: T] = [:]; private let fileURL: URL
      public init(directory: URL = .documentsDirectory, filename: String = "data.json") {
          self.fileURL = directory.appendingPathComponent(filename); self.cache = Self.loadSynchronously(from: fileURL)
      }
      public func save(_ item: T) throws { cache[item.id] = item; try persistToFile() }
      public func delete(_ id: String) throws { cache[id] = nil; try persistToFile() }
      public func find(by id: String) -> T? { cache[id] }
      public func loadAll() -> [T] { Array(cache.values) }
      private func persistToFile() throws { try JSONEncoder().encode(Array(cache.values)).write(to: fileURL, options: .atomic) }
      private static func loadSynchronously(from url: URL) -> [String: T] {
          guard let d = try? Data(contentsOf: url), let items = try? JSONDecoder().decode([T].self, from: d) else { return [:] }
          return Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
      }
  }
  ```
  call:`await`(find,loadAll)|`try await`(save,delete);
  vm:`@Observable final class QuestionListViewModel`:`private(set) var questions:[Question]=[]`, `load() async`→`loadAll()`, `add(_:) async throws`→`save(_:)`+reload
}
§PAT:SWIFTDATA{
  bg_actor:`@ModelActor actor DataStore { func upsert(_ dto: ItemDTO) throws { ...; try modelContext.save() } }`;
  strict_concurrency:pass_only_`Sendable`_DTOs_or_`PersistentIdentifier`_across_actor_boundaries(¬raw_`@Model`_instances);
  test_container:`try ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))`
}
§R{
  1:cross_actor_types⇒`: Sendable`(incl_generic_param_`T: Codable & Identifiable & Sendable`);
  2:pub_API⇒domain_ops(¬expose_cache/persist_impl);
  3:file_write⇒`.atomic`;
  4:actor_init⇒sync_load(avoid_async_init_ergonomics);
  5:UI⇒`@Observable`_VM;
  6:SwiftData_bg_work⇒`@ModelActor`+`PersistentIdentifier`/DTO_handoff;
  7:async_resource_cleanup⇒Swift6.4_`defer { await ... }`
}
§ANTI{¬`DispatchQueue`|`NSLock`;¬expose_`cache`;¬unvalidated_`fileURL`;¬omit_`Sendable`_on_actor_generics;¬pass_nonSendable_`@Model`_across_actors;¬`nonisolated`_bypass}
§REL{[swift-concurrency](swift-concurrency.md):Swift6.4_isolation+Mutex;[swift-protocol-di-testing](swift-protocol-di-testing.md):file_accessor_DI+SwiftTesting}
