@REF:llm-cost-optimization
§D{use:LLM_APIs(Claude,OpenAI,Gemini)|mixed_batches|budget_cap|cache_hit/cost/latency|effort_tuning;¬use:1prompt_qual_only}
§MODELS{
  Claude_2026(dateless_IDs+adaptive_reasoning_effort∈{standard,high,xhigh,max}):{
    small:`claude-haiku-5-5`(routing,cls,extraction,high_vol);
    mid:`claude-sonnet-5-5`(balanced_speed+intel,default_impl);
    heavy:`claude-opus-5-5`(long_agentic_coding,core_enterprise);
    frontier:`claude-fable-5-2`(hardest_reasoning,long_horizon)
  };
  OpenAI:{GPT-5_series(dynamic_reasoning_effort,Responses_API)};
  Gemini:{Gemini_2.5/3/4(multimodal,massive_ctx,implicit_caching)}
}
§PAT{
  route:`MODEL_LARGE="claude-sonnet-5-5"`,`MODEL_SMALL="claude-haiku-5-5"`,`MODEL_HEAVY="claude-opus-5-5"`,`_LARGE_TEXT_THRESHOLD=10_000`,`_LARGE_ITEM_THRESHOLD=30`;`select_model(text_length:int,item_count:int,force_model:str|None=None)->str`:`force_model` or(`MODEL_LARGE` if `text_length>=10_000|item_count>=30` else `MODEL_SMALL`);tune(effort←complexity)pre_model_upgrade;
  track(`@dataclass(frozen=True,slots=True)`):`CostRecord(model:str,input_tokens:int,output_tokens:int,cost_usd:float)`;`CostTracker(budget_limit:float=1.00,records:tuple[CostRecord,...]=())`[`.add(r)->CostTracker(...,(*records,r))`,`total_cost->sum(r.cost_usd)`,`over_budget->total_cost>budget_limit`];
  retry(`anthropic.{APIConnectionError,RateLimitError,InternalServerError}`):`_RETRYABLE_ERRORS=(...)`,`_MAX_RETRIES=3`;`call_with_retry(func,*,max_retries=3)`:sleep `2**attempt` on retryable,raise on last;fail_fast auth/bad_req/val;
  compose:`process(text:str,config:Config,tracker:CostTracker)->tuple[Result,CostTracker]`:`select_model`->if `over_budget` raise `BudgetExceededError(total_cost,budget_limit)`->`call_with_retry(lambda:client.messages.create(model=model,messages=build_cached_messages(system_prompt,text)))`->`(parse_result(resp),tracker.add(CostRecord(...)))`;
  ctx_hygiene:apply(Context_Editing+Compaction+dynamic_tool_search)⇒cut_quadratic_turn_cost∧prevent_context_rot
}
§CACHE{
  pre:chk(endpoint,model,tier,mode)+docs(rates,min_pre,TTL);caching ¬reduces ctx_window;
  order:stable(tools,instructions,ex/ref)->dynamic(Q,retrieval,meta);claude:tools->system->messages;exact_match(content+tool_schemas+req_settings);diff breaks reuse;
  claude_msg:`{"role":"user","content":[{"type":"text","text":system_prompt,"cache_control":{"type":"ephemeral"}},{"type":"text","text":user_input}]}`;
  pad:¬pad/add_ctx for min_len unless cost+qual justifies;
  iso:authz pre-lookup/reuse;keys scoped(user,workspace,provider_acct,model,content_rev);key=routing/acct_hint(¬auth/sandbox);inv on perm/content Δ;¬log private prompts;
  providers:{
    OpenAI([docs](https://developers.openai.com/api/docs/guides/prompt-caching)):auto(implicit)_prefix_caching_above_model_min;verify(retention,w/r_rates);cnt:Responses(`usage.input_tokens_details.cached_tokens`,+`cache_write_tokens`?),Chat(`prompt_tokens_details.cached_tokens`);
    Claude([docs](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)):explicit_block_`cache_control`(TTL:5m|1h;write>in);cnt:`input_tokens`(uncached),`cache_creation_input_tokens`,`cache_read_input_tokens`,`output_tokens`;short_pre⇒0_cnt;
    Gemini([docs](https://ai.google.dev/gemini-api/docs/caching)):implicit_caching_built_in(Gemini_2.5/3/4,auto_above_min_e.g.2048/4096_toks)+explicit_caching@`generateContent`;cnt:Interactions(`usage.total_cached_tokens`),GenerateContent(`usage_metadata`+explicit_tokens+retained_dur)
  };
  cmp:`compareCacheCost(usage,rates)`(non-overlapping;incl warmup,miss,expiry,refresh,retry):chk `usage[uncached,written,read,output,storageTokenHours]` & `rates[input,write,read,output,storage]` finite≥0(else throw);`out=output*r.output/1e6`;`stor=storageTokenHours*r.storage/1e6`;`base=(uncached+written+read)*r.input/1e6+out`;`actual=(uncached*r.input+written*r.write+read*r.read)/1e6+out+stor`;ret `{baseline:base,actual,savings:base-actual,outputCost:out,storageCost:stor}`;
  inv:10_calls(10k_pre,2k_suf,2k_out;1w+9r)⇒base=$0.6600,cached=$0.4245,out=$0.3000(fixed);¬discount out/total;1off⇒write>uncached;
  verify:[1:log min_pre+reqs,2:if authz cmp matched(cached,in_cats,out,stor,latency,cost,misses),3:report `token_hit_rate=cached_reads/total_input_tokens`&`request_hit_rate`+denoms+period,4:unmeasured⇒label_unmeasured]
}
§R{1:cheapest+low_effort->route_up;2:check_live_pricing(in,out,write,read) pre-budget;3:batch_cap+fail_early;4:log_routing+OTel(`gen_ai.usage.*`)+tune;5:models∈constants/cfg(¬hardcode_dated_IDs);6:¬retry auth/val}
