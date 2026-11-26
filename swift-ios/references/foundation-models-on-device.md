@REF:foundation-models-on-device
§CTX{iOS26:FoundationModels;on_device(privacy,offline);caps:{text_gen,@Generable_struct,Tool_call,snapshot_stream}}
§PAT{
  avail_chk:∀session⇒switch(SystemLanguageModel.default.availability);
  ```swift
  switch SystemLanguageModel.default.availability {
  case .available: ContentView()
  case .unavailable(.deviceNotEligible): Text("Device not eligible")
  case .unavailable(.appleIntelligenceNotEnabled): Text("Enable Apple Intelligence")
  case .unavailable(.modelNotReady): Text("Downloading/not ready")
  case .unavailable(let other): Text("Unavailable: \(other)")
  }
  ```
  session:{
    single:LanguageModelSession()→try await session.respond(to:prompt);
    multi:LanguageModelSession(instructions:...)∧reuse_session;
    instr:{role,task,style,safety_fallback};instr_priority>prompt
  };
  generable:{
    @Generable(description:"...")∧@Guide(description:"...",.range(0...20)|.count(3));
    ```swift
    @Generable(description: "Cat profile")
    struct CatProfile {
        var name: String
        @Guide(description: "Age", .range(0...20)) var age: Int
        @Guide(description: "Personality") var profile: String
    }
    let res = try await session.respond(to: prompt, generating: CatProfile.self)
    // read res.content.name (NOT .output)
    ```
  };
  tools:{
    impl:Tool{name,description,@Generable struct Arguments,call(arguments:)async throws->ToolOutput(.string(...))};
    init:LanguageModelSession(tools:[MyTool()]);
    err:catch let e as LanguageModelSession.ToolCallError→e.tool.name,e.underlyingError as? MyErr
  };
  stream:{
    type:T.PartiallyGenerated(∀prop:Optional,auto_gen_by_@Generable);
    mode:complete_partial_snapshots(¬deltas);
    ```swift
    @State private var partial: TripIdeas.PartiallyGenerated?
    // .task { for try await p in session.streamResponse(to: prompt, generating: TripIdeas.self) { partial = p } }
    ```
  }
}
§R{
  ctx_win≤4096_toks(instructions+prompt+output)⇒chunk_across_sessions;
  conc:1_req/session(chk session.isResponding);multi_req⇒multi_sessions;
  read:res.content(¬.output);
  tune:GenerationOptions(temperature:);
  prof:Xcode_Instruments;
  split_complex_prompts→focused_steps
}
§ANTI{
  ¬skip(model.availability);
  ¬assume_avail;
  ¬exceed(4096_toks);
  ¬concurrent_req_on_single_session;
  ¬use(.output);
  ¬parse_raw_str_when_@Generable_fits;
  ¬pack_multi_step_logic_in_1_prompt
}
§REL{
  [swift-concurrency](swift-concurrency.md):async_sessions+actor_isolation;
  [swift-ios](../SKILL.md):SwiftUI_stream_integration
}
