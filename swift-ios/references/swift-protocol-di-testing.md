@REF:swift-protocol-di-testing
§CTX{Swift6.2–6.4;SwiftTesting(production_default)+Sendable_protocol_DI+Synchronization.Mutex_mocks}
§USE:ext_IO(FS|net|iCloud|API)∨deterministic_err_test∨multi_env(app|test|#Preview)∨actor_Sendable_DI∨SwiftTesting
§D{
  unit/integration/SwiftData_tests⇒SwiftTesting(`import Testing`,`@Suite`,`@Test`)¬XCTest;
  UI_automation/perf_metrics⇒XCTest(`XCUITest`,`measure{}`)(side_by_side_in_same_target);
  mutable_test_mocks_across_actors⇒`Synchronization.Mutex`¬racy_`@unchecked Sendable`
}
§PAT:5_STEP_DI{
  1_PROTOS(1_concern/proto,`: Sendable`):
  `protocol FileSystemProviding: Sendable { func containerURL(for purpose: Purpose) -> URL? }`;
  `protocol FileAccessorProviding: Sendable { func read(from: URL) throws -> Data; func write(_: Data, to: URL) throws; func fileExists(at: URL) -> Bool }`;
  `protocol BookmarkStorageProviding: Sendable { func saveBookmark(_: Data, for: String) throws; func loadBookmark(for: String) throws -> Data? }`;
  2_PROD:`DefaultFileSystemProvider`→`FileManager.default.url(forUbiquityContainerIdentifier: nil)`; `DefaultFileAccessor`→`Data(contentsOf: url)`|`data.write(to: url, options: .atomic)`|`FileManager.default.fileExists(atPath: url.path)`;
  3_MOCK(race-safe_`Sendable`_via_`Mutex`):
  ```swift
  import Synchronization
  final class MockFileAccessor: FileAccessorProviding, Sendable {
      struct State { var files: [URL: Data] = [:]; var readError: Error?; var writeError: Error? }
      let state = Mutex(State())
      func read(from url: URL) throws -> Data { try state.withLock { s in if let e = s.readError { throw e }; guard let d = s.files[url] else { throw CocoaError(.fileReadNoSuchFile) }; return d } }
      func write(_ data: Data, to url: URL) throws { try state.withLock { s in if let e = s.writeError { throw e }; s.files[url] = data } }
      func fileExists(at url: URL) -> Bool { state.withLock { $0.files[url] != nil } }
  }
  ```
  4_INJECT(default_prod,override_test):
  ```swift
  actor SyncManager {
      private let fs: any FileSystemProviding; private let fa: any FileAccessorProviding
      init(fileSystem: any FileSystemProviding = DefaultFileSystemProvider(), fileAccessor: any FileAccessorProviding = DefaultFileAccessor()) { fs = fileSystem; fa = fileAccessor }
      func sync() async throws { guard let u = fs.containerURL(for: .sync) else { throw SyncError.containerNotAvailable }; _ = try fa.read(from: u.appendingPathComponent("data.json")) }
  }
  ```
  5_TEST(`import Testing`):
  ```swift
  @Suite struct SyncManagerTests {
      @Test func missingContainerThrows() async {
          await #expect(throws: SyncError.containerNotAvailable) {
              try await SyncManager(fileSystem: MockFileSystemProvider(containerURL: nil)).sync()
          }
      }
      @Test(arguments: [CocoaError(.fileReadCorruptFile), CocoaError(.fileReadNoPermission)])
      func readFailurePropagates(_ err: CocoaError) async throws {
          let fa = MockFileAccessor(); fa.state.withLock { $0.readError = err }
          let url = try #require(URL(string: "file:///tmp/sync"))
          await #expect(throws: CocoaError.self) { try await SyncManager(fileSystem: MockFileSystemProvider(containerURL: url), fileAccessor: fa).sync() }
      }
  }
  ```
}
§PAT:SWIFT_TESTING_62_64{
  fail_fast:`let val = try #require(optional)` // replaces_XCTUnwrap;halts_test_on_nil/false;
  exit_tests(Swift≥6.2):`await #expect(processExitsWith: .failure) { preconditionFailure("bad") }` // child_proc_isolation;tests_fatalError/precondition;
  attachments(Swift≥6.2/6.3):`Attachment.record(data, named: "diag.json")` // Data,String,[UInt8],Encodable,images(6.3+_UI_overlays);
  cancel(Swift≥6.3):`try Test.cancel("offline")`∨`try Test.Case.cancel("skip arg")` // dynamic_runtime_skip_without_red_fail;
  warnings(Swift≥6.3):`Issue.record("deprecated payload", severity: .warning)` // non-fatal_diagnostic;
  async_callbacks:`await confirmation(expectedCount: 2) { done in ...; done() }`
}
§R{1:SRP(1_concern/proto);2:`: Sendable`∀actor_boundary;3:default_prod_params;4:mocks_use_`Mutex`+error_injection_props;5:mock_boundaries_only;6:prefer_`#require`_for_preconditions+`#expect`_for_assertions}
§ANTI{¬god_protos;¬mock_internal_nonIO;¬`#if DEBUG`_DI;¬racy_`@unchecked Sendable`_mocks;¬XCTest_for_new_unit_tests;¬proto_without_ext_deps}
§REL{[swift-actor-persistence](swift-actor-persistence.md):actor_repos+SwiftData_in_mem;[unit-testing-patterns](../../unit-testing-patterns/SKILL.md):TDD_tests}
