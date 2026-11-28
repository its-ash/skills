@REF:foundation-models-on-device
§CTX{iOS26–27/macOS26–27:FoundationModels;on_device(privacy,offline,4096_toks_iOS26/8192_toks_iOS27)+iOS27_PCC/3rd_party_`LanguageModel`(32k+);caps:{text_gen,@Generable_struct,Tool_call,snapshot_stream,prewarm}}
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
    single:`LanguageModelSession()`→`try await session.respond(to: prompt)`;
    multi:`LanguageModelSession(instructions: ...)`∧reuse_session(maintains_`session.transcript`);
    instr:{role,task,style,safety_fallback};instr_priority>prompt;
    prewarm:`session.prewarm(promptPrefix: "...")` // call_~1s_before_submit→eager_loads_model+KV_cache
  };
  generable:{
    `@Generable(description: "...")`∧`@Guide(description: "...", .range(0...20)|.count(3))`;
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
    impl:`Tool`{`name`,`description`,`@Generable struct Arguments`,`call(arguments:) async throws -> Output` where `Output: PromptRepresentable` (`String`∨`@Generable`_struct;¬beta_`ToolOutput`)};
    ```swift
    struct WeatherTool: Tool {
        let name = "getWeather"
        let description = "Fetches current weather for a city."
        @Generable struct Arguments { let city: String }
        func call(arguments: Arguments) async throws -> String { await fetchWeather(arguments.city) }
    }
    let session = LanguageModelSession(tools: [WeatherTool()])
    ```
    err:`catch let e as LanguageModelSession.ToolCallError`→`e.tool.name`,`e.underlyingError`
  };
  stream:{
    type:`ResponseStream<T>.Snapshot`→`snapshot.content: T.PartiallyGenerated`(∀prop:Optional,auto_gen_by_`@Generable`);
    mode:complete_partial_snapshots(¬raw_token_deltas);final:`try await stream.collect().content`;
    ```swift
    @State private var partial: TripIdeas.PartiallyGenerated?
    // .task {
    //   let stream = session.streamResponse(to: prompt, generating: TripIdeas.self)
    //   for try await snapshot in stream { partial = snapshot.content }
    // }
    ```
  };
  errors:{
    catch:`LanguageModelSession.GenerationError`{.exceededContextWindowSize,.guardrailViolation,.refusal,.decodingFailure,.concurrentRequests,.rateLimited,.assetsUnavailable}(iOS27+:also_`LanguageModelError.contextSizeExceeded`);
    overflow_recovery:start_fresh_`LanguageModelSession()`∨prune/summarize_`session.transcript`∨chunk_input
  }
}
§R{
  1:ctx_win_bounded(instructions+tools+transcript+output≤4096_iOS26|8192_iOS27_on_device)⇒chunk∨reset_session∨scale_via_iOS27_`LanguageModel`(PCC/3rd_party);
  2:conc:1_req/session(chk_`session.isResponding`);multi_req⇒multi_sessions;
  3:read:`res.content`∧`snapshot.content`(¬beta_`.output`∨raw_snapshot);
  4:tools_return:`PromptRepresentable`(`String`∨`@Generable`,¬beta_`ToolOutput`);
  5:prewarm_when_intent_detected(≥1s_lead);
  6:tune:`GenerationOptions(temperature:)`∧prof:Xcode_Instruments;
  7:split_complex_prompts→focused_steps
}
§ANTI{
  ¬skip(`model.availability`);
  ¬assume_avail;
  ¬ignore_`exceededContextWindowSize`/`guardrailViolation`/`refusal`;
  ¬concurrent_req_on_single_session;
  ¬use_beta_`.output`_or_`ToolOutput`;
  ¬assign_`snapshot`_directly_to_`PartiallyGenerated`(use_`snapshot.content`);
  ¬parse_raw_str_when_`@Generable`_fits;
  ¬pack_multi_step_logic_in_1_prompt
}
§REL{
  [swift-concurrency](swift-concurrency.md):async_sessions+actor_isolation;
  [swift-ios](../SKILL.md):SwiftUI_stream_integration
}
