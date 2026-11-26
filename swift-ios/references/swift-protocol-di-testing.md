@REF:swift-protocol-di-testing
§USE:ext_IO(FS|net|iCloud|API)∨deterministic_err_test∨multi_env(app|test|#Preview)∨actor_Sendable_DI
§PAT:5_STEP_DI{
  1_PROTOS(1_concern/proto,`: Sendable`):
  `protocol FileSystemProviding: Sendable { func containerURL(for purpose: Purpose) -> URL? }`;
  `protocol FileAccessorProviding: Sendable { func read(from: URL) throws -> Data; func write(_: Data, to: URL) throws; func fileExists(at: URL) -> Bool }`;
  `protocol BookmarkStorageProviding: Sendable { func saveBookmark(_: Data, for: String) throws; func loadBookmark(for: String) throws -> Data? }`;
  2_PROD:`DefaultFileSystemProvider`→`FileManager.default.url(forUbiquityContainerIdentifier: nil)`; `DefaultFileAccessor`→`Data(contentsOf: url)`|`data.write(to: url, options: .atomic)`|`FileManager.default.fileExists(atPath: url.path)`;
  3_MOCK(`@unchecked Sendable`):
  ```swift
  final class MockFileAccessor: FileAccessorProviding, @unchecked Sendable {
      var files: [URL: Data] = [:]; var readError: Error?; var writeError: Error?
      func read(from url: URL) throws -> Data { if let readError { throw readError }; guard let d = files[url] else { throw CocoaError(.fileReadNoSuchFile) }; return d }
      func write(_ data: Data, to url: URL) throws { if let writeError { throw writeError }; files[url] = data }
      func fileExists(at url: URL) -> Bool { files[url] != nil }
  }
  ```
  4_INJECT(default_prod,override_test):
  ```swift
  actor SyncManager {
      private let fs: FileSystemProviding; private let fa: FileAccessorProviding
      init(fileSystem: FileSystemProviding = DefaultFileSystemProvider(), fileAccessor: FileAccessorProviding = DefaultFileAccessor()) { fs = fileSystem; fa = fileAccessor }
      func sync() async throws { guard let u = fs.containerURL(for: .sync) else { throw SyncError.containerNotAvailable }; _ = try fa.read(from: u.appendingPathComponent("data.json")) }
  }
  ```
  5_TEST(`import Testing`):
  `@Test`+`#expect`:missing→`await #expect(throws: SyncError.containerNotAvailable){try await SyncManager(fileSystem: MockFileSystemProvider(containerURL: nil)).sync()}`;readOK→`fa.files[u]=d; #expect(try await m.loadData()==exp)`;readErr→`fa.readError=CocoaError(.fileReadCorruptFile); await #expect(throws: SyncError.self){try await m.sync()}`
}
§R{1:SRP(1_concern/proto);2:`: Sendable`∀actor_boundary;3:default_prod_params;4:mocks_have_err_props;5:mock_boundaries_only}
§ANTI{¬god_protos;¬mock_internal_nonIO;¬`#if DEBUG`_DI;¬omit_`Sendable`⊕actors;¬proto_without_ext_deps}
§REL{[swift-actor-persistence](swift-actor-persistence.md):actor_repos;[unit-testing-patterns](../../unit-testing-patterns/SKILL.md):TDD_tests}
