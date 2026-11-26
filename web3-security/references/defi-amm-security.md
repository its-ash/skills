@REF:defi-amm-security

§SCOPE{Solidity_AMM|LP_vault|swap|deposit|withdraw|mint|burn|`balanceOf(address(this))`_math|admin(fee,pause,oracle)}

§SAFE_EXEC{
  cmds∈(trusted_checkout∨disposable_sandbox);
  ¬splice(untrusted_contract,path,RPC_URL,privkey,flags)→shell;
  ask_pre(tool_install∨long_fuzz/static);
  NEVER_emit(secrets,privkeys,seeds,API_tokens,mainnet_creds)∈(cmds,logs,reports)
}

§PAT{
  reentrancy:CEI+`nonReentrant`(`@openzeppelin/contracts/utils/ReentrancyGuard.sol`)+`SafeERC20`(`@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol`,¬custom_guard);
    `withdraw(uint256 amount) external nonReentrant`:`require(balances[msg.sender]>=amount,"Insufficient"); balances[msg.sender]-=amount; token.safeTransfer(msg.sender,amount);`
  donation_inflation:¬raw_`token.balanceOf(address(this))`_in_share_math;track_`_totalAssets`∧measure_actual_`received`;
    `deposit(uint256 assets) external nonReentrant returns (uint256 shares)`:`balBefore=token.balanceOf(address(this)); token.safeTransferFrom(msg.sender,address(this),assets); received=token.balanceOf(address(this))-balBefore; shares=totalShares==0?received:(received*totalShares)/_totalAssets; _totalAssets+=received; totalShares+=shares;`
  oracle:spot=flash_loan_manipulable⇒TWAP;
    `secondsAgos=[1800,0]`:`(int56[] memory tc,)=IUniswapV3Pool(pool).observe(secondsAgos); twapTick=int24((tc[1]-tc[0])/int56(uint56(30 minutes))); sqrtPriceX96=TickMath.getSqrtRatioAtTick(twapTick);`
  slippage:∀swap⇒`amountOutMin`+`deadline`:
    `swap(uint256 amountIn,uint256 amountOutMin,uint256 deadline)`:`require(block.timestamp<=deadline,"Expired"); ... require(amountOut>=amountOutMin,"Slippage exceeded");`
  reserve_math:¬naive_`a*b/c`⇒`FullMath.mulDiv(a,b,c)`(`@uniswap/v3-core/contracts/libraries/FullMath.sol`);
  admin:`Ownable2Step`(`@openzeppelin/contracts/access/Ownable2Step.sol`)+`onlyOwner`(`setFee(uint256)`,`pause()`)∧test_emergency_pause
}

§CHK{[`nonReentrant`,CEI,¬raw_`balanceOf(this)`,`SafeERC20`,measure_received,TWAP,`amountOutMin`+`deadline`,`FullMath.mulDiv`,`Ownable2Step`+pause_tested,static+fuzz_pre_prod]}

§CMD{
  `pip install slither-analyzer`
  `slither . --exclude-dependencies`
  `echidna-test . --contract YourAMM --config echidna.yaml`
  `forge test --fuzz-runs 10000`
}
