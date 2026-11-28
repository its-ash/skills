@REF:evm-token-decimals

§SCOPE{ERC20_balance(Py|TS|Sol)|fiat_val|cross_chain_compare|bridged_assets|trackers_bots_aggregators}

§R{
  1:ALWAYS_query_`decimals()`_runtime(¬assume_stablecoins=6_or_18,¬hardcode_`1_000_000`);
  2:cache_by_`(chain_id,token_address)`(NEVER_by_symbol;symbols_collide_and_vary_across_chains);
  3:exact_math(`Decimal`|`BigInt`,NEVER_float);
  4:re-query_`decimals()`_post(bridge∨wrapper_change);
  5:normalize_internal_accounting_pre(compare∨price);guard_truncation_when_`d>18`;
  6:on_`decimals()`_revert⇒`logging.warning`+default_`18`(odd/legacy_tokens)
}

§PAT{
  ts_viem[preferred,`viem`_v2]:`import {createPublicClient,erc20Abi,formatUnits,http} from 'viem';` `const [d,raw]=await client.multicall({allowFailure:false,contracts:[{address:token,abi:erc20Abi,functionName:'decimals'},{address:token,abi:erc20Abi,functionName:'balanceOf',args:[wallet]}]}); formatUnits(raw,d)`(1_RPC_roundtrip_via_Multicall3);
  ts_ethers[`ethers`_v6]:`import {Contract,formatUnits} from 'ethers';` ABI=`['function decimals() view returns (uint8)','function balanceOf(address) view returns (uint256)']`; `const [d,raw]=await Promise.all([t.decimals(),t.balanceOf(wallet)]); formatUnits(raw,d)`;
  py_web3_v7[`web3.py`_v7,Py_3.10+,`decimal.Decimal`,`functools.lru_cache`]:
    exceptions:catch_`Web3Exception`/`ContractLogicError`(v7_unified_hierarchy,¬bare_`Exception`);use_`AsyncWeb3`+`w3.batch_requests()`_for_multi_token_reads;
    ABI:`decimals()->uint8`,`balanceOf(address)->uint256`(`stateMutability:"view"`);
    `@lru_cache(maxsize=512) get_decimals(chain_id:int,token_address:str)->int`:`c=w3.eth.contract(address=Web3.to_checksum_address(token_address),abi=ERC20_ABI); try: return c.functions.decimals().call() except Web3Exception: logging.warning("decimals() reverted",extra={"chain":chain_id,"token":token_address}); return 18`;
    `get_token_balance(w3:Web3,token_address:str,wallet:str)->Decimal`:`d=get_decimals(w3.eth.chain_id,token_address); Decimal(c.functions.balanceOf(Web3.to_checksum_address(wallet)).call())/Decimal(10**d)`;
  sol[18dec_WAD]:`interface IERC20Metadata{function decimals() external view returns (uint8);}`|`normalizeToWad(address token,uint256 amount)->uint256`:`uint8 d=IERC20Metadata(token).decimals(); d==18?amount:(d<18?amount*10**(18-d):Math.mulDiv(amount,1,10**(d-18),Math.Rounding.Floor))`(explicit_rounding_direction_on_`d>18`;reject_or_handle_non-standard_tokens_via_staticcall_len_check)
}

§ANTI{
  ¬`web3.js`(sunset_2025-03-04)⇒use_`viem`_v2∨`ethers`_v6;
  ¬float_division(`raw / 10**d`)⇒precision_loss_above_`2^53`;
  ¬cache_decimals_by_symbol(`USDC`/`USDT`_differ_by_chain_e.g.BSC_18_vs_Eth_6)
}

§CMD{`cast call <token_address> "decimals()(uint8)" --rpc-url <rpc>`}
