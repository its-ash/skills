@REF:swift-actor-persistence
§USE:Swift≥5.5∧(shared_mut_state∨local_persist∨offline_first∨replace_GCD_NSLock)
§PAT:ACTOR_REPO{
  why:compiler_thread_safety∧O(1)_id_lookup∧`.atomic`_crash_safety∧sync_init(¬async_init);
  ```swift
  public actor LocalRepository<T: Codable & Identifiable> where T.ID == String {
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
§R{1:cross_actor⇒`: Sendable`;2:pub_API⇒domain_ops(¬cache/persist_impl);3:write⇒`.atomic`;4:init⇒sync_load;5:UI⇒`@Observable`VM;6:use⇒{user_data,settings,cache,offline_sync,iOS_macOS}}
§ANTI{¬`DispatchQueue`|`NSLock`;¬expose_`cache`;¬unvalidated_`fileURL`;¬omit_`await`;¬`nonisolated`_bypass}
§REL{[swift-concurrency](swift-concurrency.md):Swift6.2_isolation;[swift-protocol-di-testing](swift-protocol-di-testing.md):file_accessor_DI}
