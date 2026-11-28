@REF:llm-trading-agent-security

§SCOPE{AI_agent(sign∧send_tx)|bot_audit|wallet_key_mgmt|session_keys|LLM(order,swap,treasury)}

§ARCH{LLM(intent_only)→PolicyEngine+SessionKey(whitelists,selectors,caps,TTL)→PreFlight(`eth_simulateV1`)→SmartAccount(ERC-7579/EIP-7702)→PrivateRPC(Flashbots/MEV_Blocker)}

§R{
  threat:inj∨hallucination∨bad_tool⇒asset_loss;defense_in_depth(structural_isolation∧session_keys∧spend_caps∧sim∧breakers∧private_mempool);
  prompt_sep:¬inject(token_names,pair_labels,webhooks,social_feeds)→exec_prompt;treat_regex_filters_as_secondary_only(bypassable)⇒enforce_deterministic_typed_schemas+policy_engine_outside_LLM;
  wallet_auth:prefer_scoped_session_keys_on_modular_smart_accounts(ERC-7579/EIP-7702)limiting(target_contracts,function_selectors,max_value,TTL)¬unconstrained_master_EOA;
  hot_wallet:if_EOA_required⇒dedicated_hot(session_funds_only)∧¬primary_treasury;keys∈{secret_mgr,TEE/enclave,env}∧¬{code,logs,prompts};
  spend_guard:independent(LLM_out),persistent_atomic_store,exact_`Decimal`_math,fail_closed;
  sim:∀tx:simulate_pre_send(`eth_simulateV1`_preferred_for_multi-tx/state_overrides/asset_deltas;fallback_`eth_call`)∧verify(no_unexpected_drain,min_amount_out,gas_bounds);
  mev:private_mempool(Flashbots_Protect|MEV_Blocker|Solana_Jito)∧per_strategy(slippage_bps,deadline)∧drop_reverts;
  audit:log(all_intents,policy_rejects,sim_diffs,tx_hashes,¬only_sends;NEVER_log_keys)
}

§PAT{
  session_key_scope:{targets:[approved_DEX_routers],selectors:[`exactInputSingle`],deny:[arbitrary_`transfer`,`approve`_unlimited],max_per_tx_usd,max_24h_usd,ttl_s:3600..14400};
  inj_secondary:re.IGNORECASE⇒ValueError;INJECTION_PATTERNS=[r'ignore (previous|all) instructions',r'new (task|directive|instruction)',r'system prompt',r'send .{0,50} to 0x[0-9a-fA-F]{40}',r'transfer .{0,50} to',r'approve .{0,50} for'];sanitize_onchain_data(text:str)->str(pair_with_strict_policy_whitelist);
  spend:`Decimal`;`MAX_SINGLE_TX_USD=Decimal("500")`;`MAX_DAILY_SPEND_USD=Decimal("2000")`;`SpendLimitGuard.check_and_record(usd_amount:Decimal)->None`⇒(`usd_amount>MAX_SINGLE_TX_USD∨_get_24h_spend()+usd_amount>MAX_DAILY_SPEND_USD`)⇒`SpendLimitError`_else_atomic_`_record_spend(usd_amount)`;
  sim_v1:`rpc("eth_simulateV1",[{"blockStateCalls":[{"calls":[tx]}],"validation":True,"traceTransfers":True},"latest"])`⇒assert(all_calls_status==1∧unexpected_outgoing_transfers==∅∧out_amount>=expected_min_out);fallback:`sim=await w3.eth.call(tx)`→`decode_uint256(sim)<expected_min_out`⇒`SlippageError`;
  breaker:`TradingCircuitBreaker{MAX_CONSECUTIVE_LOSSES=3,MAX_HOURLY_LOSS_PCT=Decimal("0.05")}`;`check(portfolio_value:Decimal)`⇒`halt()`⇔`consecutive_losses>=3∨hour_start_value<=0∨(portfolio_value-hour_start_value)/hour_start_value<-MAX_HOURLY_LOSS_PCT`;
  wallet:`pk=os.environ.get("TRADING_WALLET_PRIVATE_KEY")`∨`EnvironmentError`;`eth_account.Account.from_key(pk)`(session_key_or_isolated_hot_only);
  mev:`PRIVATE_RPC="https://rpc.flashbots.net"`(or_MEV_Blocker);`MAX_SLIPPAGE_BPS={"stable":10,"volatile":50}`;`deadline=int(time.time())+60`
}

§ANTI{
  ¬give_LLM_master_treasury_key∨unbounded_ERC20_approvals;
  ¬rely_on_regex_prompt_filter_alone_without_onchain/enclave_policy_enforcement;
  ¬broadcast_swaps_to_public_mempool_without_MEV_protection+`amountOutMin`+`deadline`;
  ¬use_`float`_for_spend_caps_or_drawdown_breakers
}

§CHK{[session_key_or_isolated_hot_wallet,target+selector_whitelist,atomic_Decimal_spend_guard,eth_simulateV1_asset_delta_check,Decimal_circuit_breaker,private_MEV_RPC,full_decision_audit_log,zero_keys_in_prompts_or_logs]}
