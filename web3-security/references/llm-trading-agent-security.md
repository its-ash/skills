@REF:llm-trading-agent-security
§SCOPE{AI_agent(sign∧send_tx)|bot_audit|wallet_key_mgmt|LLM(order,swap,treasury)}
§R{
  threat:inj∨bad_tool⇒asset_loss;defense_in_depth(prompt∧spend∧sim∧limits∧wallet);
  ¬inject(token_names,pair_labels,webhooks,social_feeds)→exec_prompt;
  spend_guard:independent(LLM_out);
  ∀tx:sim(eth.call)∧req(min_amount_out)∧audit_log(all_decisions,¬only_sends);
  wallet:dedicated_hot(session_funds_only)∧¬primary_treasury;keys∈{env,secret_mgr}∧¬{code,logs};
  mev:private_mempool∨protected_routing;per_strategy(slippage,deadline)
}
§PAT{
  inj:re.IGNORECASE⇒ValueError;INJECTION_PATTERNS=[r'ignore (previous|all) instructions',r'new (task|directive|instruction)',r'system prompt',r'send .{0,50} to 0x[0-9a-fA-F]{40}',r'transfer .{0,50} to',r'approve .{0,50} for'];sanitize_onchain_data(text:str)->str;
  spend:Decimal;MAX_SINGLE_TX_USD=Decimal("500");MAX_DAILY_SPEND_USD=Decimal("2000");SpendLimitGuard.check_and_record(usd_amount:Decimal)->None⇒(usd_amount>500∨_get_24h_spend()+usd_amount>2000)⇒SpendLimitError else _record_spend(usd_amount);
  sim:safe_execute(tx:dict,expected_min_out:int|None=None)->str:`sim=await w3.eth.call(tx)`;None⇒ValueError;`decode_uint256(sim)<expected_min_out`⇒SlippageError;`signed=account.sign_transaction(tx)`→`await w3.eth.send_raw_transaction(signed.raw_transaction)`;
  breaker:TradingCircuitBreaker{MAX_CONSECUTIVE_LOSSES=3,MAX_HOURLY_LOSS_PCT=0.05};check(portfolio_value:float)⇒halt()⇔consecutive_losses>=3∨hour_start_value<=0∨(portfolio_value-hour_start_value)/hour_start_value<-0.05;
  wallet:`pk=os.environ.get("TRADING_WALLET_PRIVATE_KEY")`∨EnvironmentError;`eth_account.Account.from_key(pk)`;
  mev:`PRIVATE_RPC="https://rpc.flashbots.net"`;`MAX_SLIPPAGE_BPS={"stable":10,"volatile":50}`;`deadline=int(time.time())+60`
}
