@REF:swift-concurrency
§USE:Swift≥6.2_migration(5.x|6.0|6.1→6.2)∨data_race_fix∨MainActor_arch∨CPU_offload∨Xcode26_build_settings

§CORE:APPROACHABLE_CONCURRENCY{
  Swift≤6.1:async_implicitly_offloads_bg⇒data_race_err(`Sending 'self.x' risks causing data races`);
  Swift6.2:single_threaded_def∧async_stays_on_calling_actor(`@MainActor`⇒runs_on_MainActor);
  ```swift
  // Swift 6.2: OK (stays on calling MainActor)
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

§PAT:GLOBALS_AND_MAINACTOR_DEFAULT{
  global/static_nonSendable_mut_state⇒`@MainActor` (`@MainActor final class StickerLibrary { static let shared = StickerLibrary() }`);
  MainActor_default_inference(opt-in,recommended∈{app,script,executable}):types∧props∧conformances_implicitly_`@MainActor`
}

§PAT:AT_CONCURRENT{
  req:SE-0466(MainActor_default_isolation)∧SE-0461(NonisolatedNonsendingByDefault);¬settings⇒data_race_err;
  steps:1:`nonisolated`_type→2:`@concurrent`_fn→3:`async`→4:`await`@call_site;
  ```swift
  nonisolated final class PhotoProcessor {
      private var cachedStickers: [String: Sticker] = [:]
      func extractSticker(data: Data, with id: String) async -> Sticker {
          if let s = cachedStickers[id] { return s }
          let s = await Self.extractSubject(from: data)
          cachedStickers[id] = s
          return s
      }
      @concurrent static func extractSubject(from data: Data) async -> Sticker { /* CPU-heavy */ }
  }
  ```
}

§MIG{
  1:Xcode⇒Build_Settings>Swift_Compiler>Concurrency;
  2:SPM⇒`SwiftSettings`_API∈Package.swift;
  3:auto_migrate⇒`swift.org/migration`;
  4:app_targets⇒enable_MainActor_default_inference;
  5:offload⇒profile(Instruments)_first→`@concurrent`_CPU_hotpaths(img,compression,heavy_math);
  6:verify⇒compile_time_data_race_checks
}

§R{
  1:start_`@MainActor`→optimize_later;
  2:`@concurrent`⇔CPU_intensive∧profiled;
  3:globals/statics⇒`@MainActor`;
  4:protocol_conformance⇒isolated(`@MainActor Proto`),¬`nonisolated`/`@Sendable`_hacks;
  5:adopt_incrementally
}

§ANTI{
  ¬`@concurrent`_on_∀async_fn;
  ¬`nonisolated`_to_suppress_errs;
  ¬legacy_`DispatchQueue`∈new_code;
  ¬skip_`model.availability`_in_FoundationModels_concurrency;
  ¬fight_compiler_data_race_errs;
  ¬assume_async≡background
}

§REL{
  [swift-actor-persistence](swift-actor-persistence.md):actor_storage;
  [swift-protocol-di-testing](swift-protocol-di-testing.md):Sendable_DI_tests;
  [swift-ios](../SKILL.md):SwiftUI_state_views
}
