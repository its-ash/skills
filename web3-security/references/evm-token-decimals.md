@REF:evm-token-decimals

§SCOPE{ERC20_balance(Py|TS|Sol)|fiat_val|cross_chain_compare|bridged_assets|trackers_bots_aggregators}

§R{
  1:ALWAYS_query_`decimals()`_runtime(¬assume_stablecoins,¬hardcode_`1_000_000`);
  2:cache_by_`(chain_id,token_address)`(NEVER_by_symbol);
  3:exact_math(`Decimal`|`BigInt`,NEVER_float);
  4:re-query_`decimals()`_post(bridge∨wrapper_change);
  5:normalize_internal_accounting_pre(compare∨price);
  6:on_`decimals()`_revert⇒`logging.warning`+default_`18`(odd/legacy_tokens)
}

§PAT{
  py[`web3.Web3`,`decimal.Decimal`,`functools.lru_cache`]:
    ABI:`decimals()->uint8`,`balanceOf(address)->uint256`(`stateMutability:"view"`);
    `@lru_cache(maxsize=512) get_decimals(chain_id:int,token_address:str)->int`:`c=w3.eth.contract(address=Web3.to_checksum_address(token_address),abi=ERC20_ABI); try: return c.functions.decimals().call() except Exception: logging.warning("decimals() reverted",...); return 18`;
    `get_token_balance(w3:Web3,token_address:str,wallet:str)->Decimal`:`Decimal(c.functions.balanceOf(Web3.to_checksum_address(wallet)).call())/Decimal(10**c.functions.decimals().call())`
  sol[18dec_WAD]:`interface IERC20Metadata{function decimals() external view returns (uint8);}`|`normalizeToWad(address token,uint256 amount)->uint256`:`uint8 d=IERC20Metadata(token).decimals(); d==18?amount:(d<18?amount*10**(18-d):amount/10**(d-18))`
  ts[`ethers`]:`import {Contract,formatUnits} from 'ethers';` ABI=`['function decimals() view returns (uint8)','function balanceOf(address) view returns (uint256)']`; `const [d,raw]=await Promise.all([t.decimals(),t.balanceOf(wallet)]); formatUnits(raw,d)`
}

§CMD{`cast call <token_address> "decimals()(uint8)" --rpc-url <rpc>`}
