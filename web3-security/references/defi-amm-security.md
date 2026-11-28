@REF:defi-amm-security

§SCOPE{Solidity_0.8+|OZ_v5|AMM|Uniswap_v4_hooks|ERC-4626_vault|swap|deposit|withdraw|mint|burn|`balanceOf(address(this))`_math|EIP-7702|oracles|admin(fee,pause,timelock)}

§SAFE_EXEC{
  cmds∈(trusted_checkout∨disposable_sandbox);
  ¬splice(untrusted_contract,path,RPC_URL,privkey,flags)→shell;
  ask_pre(tool_install∨long_fuzz/static/symbolic);
  NEVER_emit(secrets,privkeys,seeds,API_tokens,mainnet_creds)∈(cmds,logs,reports)
}

§PAT{
  reentrancy:CEI+`ReentrancyGuardTransient`(`@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol`,EIP-1153_post-Cancun_chains_only,verify_chain_support)+`nonReentrantView`(blocks_read_only_reentrancy)∨`ReentrancyGuard`(non-EIP-1153)+`SafeERC20`(`@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol`,¬custom_guard);
    `withdraw(uint256 amount) external nonReentrant`:`require(balances[msg.sender]>=amount,"Insufficient"); balances[msg.sender]-=amount; token.safeTransfer(msg.sender,amount);`
  erc4626_inflation:¬raw_`token.balanceOf(address(this))`_in_share_math;use_OZ_v5_`ERC4626`+`_decimalsOffset()`(virtual_shares/assets)∨burn_initial_dead_shares+enforce_`minSharesOut`/`minAssetsOut`_at_router;
    fee_on_transfer_deposit:`balBefore=token.balanceOf(address(this)); token.safeTransferFrom(msg.sender,address(this),assets); received=token.balanceOf(address(this))-balBefore; shares=totalShares==0?received:Math.mulDiv(received,totalShares,_totalAssets,Math.Rounding.Floor); _totalAssets+=received; totalShares+=shares;`
  math_oz5:OZ_v5_removed_`SafeMath`(0.8+_checked_math);use_`Math.mulDiv(a,b,c,Math.Rounding.Floor|Ceil)`(`@openzeppelin/contracts/utils/math/Math.sol`,512-bit_intermediate)∨`FullMath.mulDiv`(`@uniswap/v3-core`);round_against_user(`Floor`→mint/withdraw,`Ceil`→deposit/redeem_cost);OZ_v5_hooks_unified_in_`_update`∧upgradeables_use_ERC-7201_namespaced_storage;
  eip7702_ctx:EIP-7702_lets_EOAs_delegate_code⇒NEVER_rely_on_`tx.origin==msg.sender`∨`extcodesize(addr)==0`_to_assert_pure_EOA;assume_any_caller_can_reenter/callback;strictly_guard_`msg.sender`_on_ERC-7821/ERC-7579_batch_executors;
  uniswap_v4_hooks:enforce_`msg.sender==address(poolManager)`_on_all_hook_callbacks;verify_deployed_hook_addr_matches_permission_flag_bits(`BEFORE_SWAP_FLAG`,etc.);preserve_flash_accounting_delta_invariants_across_`unlock`;audit_dynamic_fee_and_custom_accounting_rounding;
  oracle_twap:spot_reserves=flash_loan_manipulable⇒TWAP(`IUniswapV3Pool(pool).observe([1800,0])`→`twapTick=int24((tc[1]-tc[0])/int56(uint56(30 minutes)))`→`TickMath.getSqrtRatioAtTick(twapTick)`);
  oracle_chainlink:require(`answer>0`∧`updatedAt!=0`∧`block.timestamp-updatedAt<=heartbeat`);on_L2(Arbitrum/Base/Optimism)⇒query_L2_Sequencer_Uptime_Feed(`answer==0`⇒up,else_revert_`SequencerDown`;`block.timestamp-startedAt>3600`⇒grace_elapsed,else_revert_`GracePeriodNotOver`);
  slippage:∀swap⇒`amountOutMin`+`deadline`:`require(block.timestamp<=deadline,"Expired"); ... require(amountOut>=amountOutMin,"Slippage exceeded");`
  admin:`Ownable2Step`(`@openzeppelin/contracts/access/Ownable2Step.sol`)∨OZ_v5_`AccessManager`(`@openzeppelin/contracts/access/manager/AccessManager.sol`)+timelock+`Pausable`(test_emergency_pause)
}

§ANTI{
  ¬`tx.origin==msg.sender`∨`extcodesize==0`_for_EOA_gating(broken_by_EIP-7702);
  ¬deploy_`ReentrancyGuardTransient`_without_verifying_EIP-1153_chain_support;
  ¬naked_`ERC4626`_wo_virtual_offset_or_dead_shares;
  ¬L2_Chainlink_feed_wo_sequencer_uptime+grace_period_check;
  ¬unprotected_Uniswap_v4_hook_callbacks(missing_`msg.sender==poolManager`)
}

§CHK{[`ReentrancyGuardTransient`/`ReentrancyGuard`+`nonReentrantView`,CEI,¬raw_`balanceOf(this)`,OZ_v5_`ERC4626`+`_decimalsOffset`/`dead_shares`,`SafeERC20`,measure_received,TWAP∨Chainlink(staleness+L2_sequencer),`amountOutMin`+`deadline`,`Math.mulDiv(Rounding)`,¬EOA_assumptions(EIP-7702),v4_hook_`onlyPoolManager`,`AccessManager`/`Ownable2Step`+pause_tested,static+invariant+fuzz+symbolic_pre_prod]}

§CMD{
  static_py:`slither . --exclude-dependencies`
  static_rs:`aderyn .`
  foundry_fuzz_inv:`forge test --fuzz-runs 10000` ∧ `forge test --match-test invariant_`
  fuzz_parallel:`medusa fuzz`
  fuzz_echidna:`echidna . --contract YourAMM --config echidna.yaml`
  symbolic:`halmos --function check_`
}
