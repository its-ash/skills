@REF:swift-concurrency
§CTX{Swift6.2–6.4;Xcode26–27;SwiftPM6.4(SwiftBuild_default)}
§USE:Swift6_migration∨data_race_fix∨ApproachableConcurrency∨MainActor_default∨CPU_offload∨async_defer∨Mutex
§CORE:APPROACHABLE_CONCURRENCY{
  Swift≤6.1:nonisolated_async_implicitly_hops_bg⇒data_race_err(`Sending 'self.x' risks causing data races`);
  Swift≥6.2:`SWIFT_APPROACHABLE_CONCURRENCY=YES`⇒bundles{`NonisolatedNonsendingByDefault`(SE-0461),`InferIsolatedConformances`,`InferSendableFromCaptures`,`DisableOutwardActorInference`};
  semantics:`nonisolated(nonsending)`(default_w_AC)⇒async_fn_stays_on_caller_actor(`@MainActor`⇒stays_MainActor,¬unneeded_Sendable);
  Swift6.3:stabilized_`nonisolated(nonsending)`_specialization+closure_isolation_hops;
  ```swift
  // Swift 6.2+: stays on calling MainActor (no background hop / no data-race error)
  @MainActor final class StickerModel {
      let photoProcessor = PhotoProcessor()
      func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
          guard let data = try await item.loadTransferable(type: Data.self) else { return nil }
          return await photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
      }
  }
  ```
}
§PAT:ISOLATED_CONFORMANCE{
  MainActor_type→nonisolated_protocol⇒`extension T: @MainActor Proto`;
  compiler_enforces:use∈`@MainActor`_only(`nonisolated struct`⇒compile_err);
  ```swift
  protocol Exportable { func export() }
  extension StickerModel: @MainActor Exportable { func export() { photoProcessor.exportAsPNG() } }
  @MainActor struct ImageExporter { var items: [any Exportable]; mutating func add(_ x: StickerModel) { items.append(x) } } // OK
  nonisolated struct BadExporter { var items: [any Exportable]; mutating func add(_ x: StickerModel) { items.append(x) } } // ERR
  ```
}
§PAT:MAINACTOR_DEFAULT{
  SE-0466(opt-in,recommended∈{app,script,executable}):unannotated_types/props/conformances_implicitly_`@MainActor`;
  global/static_nonSendable_mut_state⇒`@MainActor`(`@MainActor final class StickerLibrary { static let shared = StickerLibrary() }`)
}
§PAT:AT_CONCURRENT{
  purpose:explicit_opt-in_to_hop_off_caller_actor→global_concurrent_pool(counterpart_to_`nonisolated(nonsending)`);
  steps:1:`nonisolated`_type→2:`@concurrent`_fn→3:`async`→4:`await`@call_site;
  ```swift
  nonisolated final class PhotoProcessor {
      private var cached: [String: Sticker] = [:]
      func extractSticker(data: Data, with id: String) async -> Sticker {
          if let s = cached[id] { return s }
          let s = await Self.extractSubject(from: data)
          cached[id] = s; return s
      }
      @concurrent static func extractSubject(from data: Data) async -> Sticker { /* profiled CPU-heavy */ }
  }
  ```
}
§PAT:SWIFT64_ASYNC_DEFER{
  SE-0493(Swift≥6.4):`await`_valid_inside_`defer`⇒safe_async_cleanup_on_normal_or_throwing_exit;
  ```swift
  func runJob() async throws {
      let conn = try await pool.acquire()
      defer { await pool.release(conn) }
      try await execute(conn)
  }
  ```
  Swift6.4_ergonomics:{`some Proto?`_without_parens;noncopyable_`for-in`_borrow(`Span`,`InlineArray`);`@diagnose`_warning_control}
}
§PAT:SYNC_MUTEX{
  `import Synchronization`;`Mutex<State>`⇒thread-safe_synchronous_state_without_actor_hop(replaces_`NSLock`/`DispatchQueue`);
  ```swift
  final class MetricsCounter: Sendable {
      private let state = Mutex(0)
      func increment() -> Int { state.withLock { $0 += 1; return $0 } }
  }
  ```
}
§CFG:SPM{
  ```swift
  // swift-tools-version: 6.2
  .target(name: "AppModule", swiftSettings: [
      .defaultIsolation(MainActor.self),
      .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
      .enableUpcomingFeature("InferIsolatedConformances")
  ])
  ```
  Xcode:Build_Settings>Swift_Compiler>Default_Actor_Isolation=MainActor∧Approachable_Concurrency=Yes
}
§MIG{
  1:enable_ApproachableConcurrency(Xcode26–27∨SPM_swiftSettings);
  2:app_targets⇒`.defaultIsolation(MainActor.self)`(libs_stay_nonisolated_unless_UI);
  3:auto_migrate⇒`swift.org/migration`;
  4:offload⇒profile(Instruments)_first→`@concurrent`_only_for_CPU_hotpaths(img,compression,heavy_math);
  5:verify⇒compile_time_data_race_checks∧zero_warnings
}
§R{
  1:start_`@MainActor`_default→optimize_w_profiled_`@concurrent`;
  2:sync_cross_thread_state⇒`Synchronization.Mutex`¬`NSLock`/`DispatchQueue`;
  3:async_teardown⇒Swift6.4_`defer { await ... }`;
  4:protocol_conformance⇒isolated(`@MainActor Proto`),¬`nonisolated`/`@unchecked Sendable`_hacks;
  5:adopt_incrementally_per_module
}
§ANTI{
  ¬`@concurrent`_on_∀async_fn;
  ¬`nonisolated`_or_`@unchecked Sendable`_to_silence_real_races;
  ¬legacy_`DispatchQueue`/`NSLock`∈new_code;
  ¬assume_`async`≡background_thread;
  ¬set_`defaultIsolation(MainActor.self)`_on_pure_headless_library_targets
}
§REL{
  [swift-actor-persistence](swift-actor-persistence.md):actor_storage+SwiftData;
  [swift-protocol-di-testing](swift-protocol-di-testing.md):Sendable_DI+Mutex_mocks;
  [swift-ios](../SKILL.md):SwiftUI_state_views
}
