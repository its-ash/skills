@REF:agent-payment-x402

§SCOPE{
  use:agent_pay_402_API∨buy_service∨A2A_settle∨per_task_spend_limit∨non_custodial_wallet;
  pair:[llm-trading-agent-security.md](llm-trading-agent-security.md),[../../secure-coding/SKILL.md](../../secure-coding/SKILL.md)
}

§D{
  buyer∈Base|agentwallet_chain⇒opt_A(`agentwallet-sdk`@MCP+SpendingPolicy+ERC-8004);
  buyer∈X_Layer⇒opt_B(OKX_Agent_Payments_Protocol@`okx/onchainos-skills`;`okx-x402-payment`=deprecated_alias);
  buyer∈Solana|x402_v2⇒opt_C(wrap_HTTP:`@x402/fetch`∨`@x402/axios`+`@x402/{core,evm,svm}`;¬deprecated_`x402-fetch`_v1;server_facilitator_verifies_settles);
  seller∈Solana|multi_net⇒opt_C(`x402-foundation/x402`→TS:`@x402/{express,hono,next,fastify}`|Py:`x402`|Go:`github.com/x402-foundation/x402/go/v2`);
  seller_OKX∈TS⇒`okx/payments/typescript/SELLER.md`(Express|Hono|Fastify|Next.js);
  seller_OKX∈Go⇒`okx/payments/go/x402/SELLER.md`(Gin|Echo|`net/http`);
  seller_OKX∈Rust⇒`okx/payments/rust/x402/SELLER.md`(Axum);
  seller_OKX∈Java⇒`okx/payments/java/SELLER.md`(SpringBoot2/3|JavaEE|Jakarta);
  seller_OKX∈Python⇒check_`okx/payments`_repo_pre_impl(guide_may_be_absent)
}

§NET{
  agentwallet-sdk:{dev:Base_Sepolia,prod:Base_mainnet,verify:pkg_docs_pre_prod};
  OKX_X_Layer:{chain:`eip155:196`,asset:USDT0,verify:fetch_latest_SDK_docs_pre_prod};
  x402_upstream:{
    multi_net:single_route_advertises_Base+Solana_simultaneously;
    default_facilitator:`https://x402.org/facilitator`→TESTNET_ONLY(Base_Sepolia:`eip155:84532`,Solana_devnet:`solana:EtWTRABZaYq6iMfeYKouRu166VU2xqa1`,Stellar,Aptos,Hedera,XRPL_testnets;¬mainnet);
    mainnet:{Solana:`solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp`,Base:`eip155:8453`}⇒self_facilitate∨own_facilitator∨hosted_facilitator;
    verify:GET_`/supported`_pre_prod∧on_network_add(¬hardcode)
  }
}

§ARCH{
  x402:HTTP_402→negotiate_price→check_budget→sign_tx→retry∈(orchestrator_policy∧confirm_boundary);
  SpendingPolicy:{per_task_budget,per_session_budget,allowlisted_recipients,rate_limits(tx/min,tx/hr)};
  wallet:ERC-4337/ERC-7579/EIP-7702_smart_account(non_custodial,¬pooled_funds)∧orchestrator_sets_policy_pre_delegation
}

§OPT_A[agentwallet-sdk]{
  prereq:pin_verified_version(e.g.`npm install -g agentwallet-sdk@8.0.0`;v8_adds_ERC-8004_identity/reputation,ERC-6551,CCTP_V2,native_x402;¬unpinned_`npx`;`npx`_wo_`-y`_hangs_non_interactive;avoid_unreviewed_3p_MCP_`npx -y`_wrappers);
  cfg:`{"mcpServers":{"agentpay":{"command":"npx","args":["agentwallet-sdk@8.0.0"]}}}`(verify_MCP_entrypoint_for_installed_version);
  agent_tools:{`get_balance`,`send_payment`(addr|ENS),`check_spending`,`list_transactions`};
  R:orchestrator_only(`set_policy`/`update_budget`∈pre_task_hook∨orchestrator;¬agent_callable⇒blocks_self_escalation)
}

§OPT_B[OKX_X_Layer]{
  flows:{x402,MPP(Multi-Party_Payment),session_payment,charge,A2A_charge};
  buyer:[`okx/onchainos-skills`,dispatcher:`skills/okx-agent-payments-protocol/SKILL.md`,deprecated:`skills/okx-x402-payment/SKILL.md`];
  R:explicit_user_confirm_pre(wallet_status_check∨payment)∧¬hide_behind_generic_tool;
  seller_docs:{
    TS:`https://raw.githubusercontent.com/okx/payments/main/typescript/SELLER.md`,
    Go:`https://raw.githubusercontent.com/okx/payments/main/go/x402/SELLER.md`,
    Rust:`https://raw.githubusercontent.com/okx/payments/main/rust/x402/SELLER.md`,
    Java:`https://raw.githubusercontent.com/okx/payments/main/java/SELLER.md`
  }
}

§OPT_C_BUYER[x402-foundation/x402]{
  ref:`https://github.com/x402-foundation/x402/tree/main/examples/typescript/clients`;
  R:{
    1:pin_lockstep_v2_versions(e.g.`@x402/fetch@2.23.0+`+matching_`@x402/{core,evm,svm}`;verify_latest_on_npm_pre_pin;¬deprecated_`x402-fetch`_v1);
    2:explicit_user_confirm_pre_1st_paid_req(¬generic_tool_hide;share_1_`sessionApproval`_promise_across_concurrent_calls;¬auto_reprompt);
    3:orchestrator_only_keys(`EVM_PRIVATE_KEY`=`0x...`,`SVM_PRIVATE_KEY`=base58;fail_closed_if_missing);
    4:normalize_addr:EVM(`0x...`)→`toLowerCase()`;Solana(base58)→CASE_SENSITIVE(NEVER_lowercase);
    5:assets_USDC_6dec:{Solana_main:`EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v`,Solana_dev:`4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU`(dev_only),Base:`0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`};
    6:`PaymentPolicy`_validates_server_402_challenge(`network`,`asset`,`payTo`,BigInt(`amount`)∈[0,`MAX_AMOUNT`]);prefer_`x402Client`+`registerPolicy`+`wrapFetchWithPayment`(over_bare_`wrapFetchWithPaymentFromConfig`_without_policy);empty_return⇒`createPaymentPayload`_throws(fail_closed);
    7:exact_SVM_buyer_needs_USDC_only(¬SOL_gas;facilitator=fee_payer);
    8:origin_gate(`ALLOWED_ORIGINS`∈orchestrator_HTTPS_origins;¬username∧¬password_in_URL;¬server/agent_populated);
    9:block_redirects(`redirect:"error"`∧`response.redirected||(status>=300&&status<400)`_throws);
    10:session_cap:reserve_`MAX_AMOUNT`_pre_`await`(prevents_race);release_in_`finally`_iff_`!signedRequestSent`(detect_`PAYMENT-SIGNATURE`∨`X-PAYMENT`);
    11:adv_test:challenge(`amount:"5000000"`,wrong_mint,unregistered_chain)⇒0_signatures
  };
  ```ts
import { x402Client, wrapFetchWithPayment } from "@x402/fetch";
import { ExactEvmScheme } from "@x402/evm/exact/client";
import { ExactSvmScheme } from "@x402/svm/exact/client";
import { privateKeyToAccount } from "viem/accounts";
import { createKeyPairSignerFromBytes } from "@solana/kit";
import { base58 } from "@scure/base";

const client = new x402Client()
  .register("eip155:*", new ExactEvmScheme(privateKeyToAccount(evmKey)))
  .register("solana:*", new ExactSvmScheme(await createKeyPairSignerFromBytes(base58.decode(svmKey))));
const norm = (a: string) => (a.startsWith("0x") ? a.toLowerCase() : a);
client.registerPolicy((_v, reqs) => reqs.filter(r => {
  if (!ALLOWED_NETWORKS.has(r.network) || !ALLOWED_ASSETS.has(norm(r.asset)) || !ALLOWED_PAY_TO.has(norm(r.payTo))) return false;
  try { const n = BigInt(r.amount); return n >= 0n && n <= MAX_AMOUNT; } catch { return false; }
}));
// payOnce: requireAllowedOrigin(url) -> check/reserve sessionSpent+=MAX_AMOUNT -> wrapFetchWithPayment(trackingFetch, client) -> finally release if !signedRequestSent
```
}

§OPT_C_FACILITATOR{
  trust_asc:[
    self_in_process:`https://github.com/x402-foundation/x402/tree/main/examples/typescript/servers/self-facilitation`,
    self_hosted_shared,
    `https://x402.org/facilitator`(testnet_default,¬mainnet),
    hosted_prod:`https://docs.x402.org/dev-tools/facilitators`(e.g.CDP[KYT/OFAC],PayAI,Corbits,Dexter,Solvador;verify_`/supported`_pre_prod)
  ];
  disclosure:PayAI_contributor_note(self_hosted∧upstream_listed_first)
}

§OPT_C_SELLER{
  pkgs:{TS:`@x402/{express,hono,next,fastify}@<pinned_v2>`(e.g.`2.23.0+`,lockstep_with_`@x402/core`),Py:`x402`(PyPI),Go:`github.com/x402-foundation/x402/go/v2`,ex:`https://github.com/x402-foundation/x402/tree/main/examples/typescript/servers`};
  Solana_ATA:{
    R:exact-SVM_transfers_to_canonical_ATA(never_creates);missing⇒402_`transaction_simulation_failed`;
    derive:`findAssociatedTokenPda({mint,owner:payToAddress,tokenProgram:TOKEN_PROGRAM_ADDRESS|TOKEN_2022_PROGRAM_ADDRESS})`(@solana-program/token);
    check_exact_ATA(¬scan_owner_accounts):`curl -s https://api.mainnet-beta.solana.com -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1,"method":"getAccountInfo","params":["<DERIVED_ATA>",{"encoding":"base64"}]}' | jq '.result.value != null'`;
    provision(creator_pays_rent):`getCreateAssociatedTokenIdempotentInstruction`(@solana-program/token) | `spl-token create-account <MINT> --owner <PAYTO_ADDRESS>` | `spl-token transfer --fund-recipient`(¬bare_`transferChecked`)
  };
  replay_guard[x402#1169:`https://github.com/x402-foundation/x402/issues/1169`]:{
    bug:middleware_verifies→handler→settles;verify_¬consumes_auth(concurrent_requests_w_same_auth⇒multiple_handlers+1_settle);count_revenue_post_settle;
    fix:claim_once_in_`onAfterVerify`_using_shared_durable_non_evicting_atomic_insert(Redis_`NX EXAT`|DynamoDB_`attribute_not_exists`|Postgres_unique_idx);
    thresholds:{CLAIM_MIN_S:900,CLAIM_MAX_S:366*86_400,CLAIM_TIMEOUT_MS:250,FAIL_CLOSED:true};
    redis_cfg:`createClient({url:process.env.REDIS_URL,disableOfflineQueue:true,commandsQueueMaxLength:1_000,socket:{connectTimeout:2_000}})`+`on("error",...)`+`connect().catch(()=>{})`;
    claim_keys:{
      EIP3009(`p.authorization?.nonce`):`x402:${network}:${asset.toLowerCase()}:${from.toLowerCase()}:${nonce.toLowerCase()}`,until:`validBefore+60n`;
      Permit2(`p.permit2Authorization?.nonce!==undefined`):`x402:${network}:permit2:${from.toLowerCase()}:${BigInt(nonce)}`,until:`deadline+60n`;
      SVM(`typeof p.transaction==="string"`):`x402:${network}:${createHash("sha256").update(new Uint8Array(getTransactionDecoder().decode(getBase64Encoder().encode(p.transaction)).messageBytes)).digest("hex")}`(`node:crypto`,`@solana/kit`),until:`now+CLAIM_MIN_S`;
      expiry_guard:`validUntil<0n||validUntil+60n>BigInt(now+CLAIM_MAX_S)`⇒reject(¬shorten_claim_lifetime)
    };
    R:{
      1:hook_MUST_return_`{abort:true,reason,message}`(`claim_unsupported`|`payment_replayed`|`claim_unavailable`),NEVER_throw(thrown_hook_skipped⇒unguarded_handler);
      2:on_`FAIL_CLOSED`_catch,release_late_Redis_claim(`set?.then(r=>r==="OK"&&claim?redis.del(claim.key):0)`);
      3:keep_claim_if_handler_throws(side_effects_may_exist);
      4:fail_open_only_if_handler_idempotent;
      5:`payment_replayed`≠1st_failed(reconcile_pre_resign);
      6:payer_moving_funds_verify→settle_still_runs_1_handler(hold_funds_pre_work_for_expensive_routes)
    };
    ```ts
const withTimeout = <T>(p: Promise<T>, ms: number) =>
  Promise.race([p, new Promise<T>((_, rej) => setTimeout(rej, ms, new Error("timeout")).unref())]);
const resourceServer = new x402ResourceServer(new HTTPFacilitatorClient({ url: process.env.FACILITATOR_URL }))
  .register("eip155:8453", new ExactEvmScheme())
  .onAfterVerify(async ({ paymentPayload, requirements, result }) => {
    if (!result.isValid) return;
    let claim, set;
    try {
      claim = claimOf(paymentPayload, requirements);
      if (!claim) return { abort: true, reason: "claim_unsupported", message: "Authorization cannot be guarded." };
      set = redis.set(claim.key, "1", { condition: "NX", expiration: { type: "EXAT", value: claim.until } });
      if ((await withTimeout(set, CLAIM_TIMEOUT_MS)) === "OK") return;
      return { abort: true, reason: "payment_replayed", message: "This payment authorization was already presented." };
    } catch {
      if (FAIL_CLOSED) {
        set?.then(r => (r === "OK" && claim ? redis.del(claim.key) : 0)).catch(() => {});
        return { abort: true, reason: "claim_unavailable", message: "Retry shortly." };
      }
    }
  });
app.use(paymentMiddleware({ "POST /report": { accepts: [{ scheme: "exact", price: "$0.01", network: "eip155:8453", payTo: process.env.PAY_TO! }] } }, resourceServer));
```
  };
  discovery:{CDP:`https://api.cdp.coinbase.com/platform/v2/x402/discovery/resources`,PayAI:`https://facilitator.payai.network/discovery/resources`,Solana:`https://pay.sh`}
}

§MCP_BUDGET{
  imports:`Client`(`@modelcontextprotocol/sdk/client/index.js`),`StdioClientTransport`(`@modelcontextprotocol/sdk/client/stdio.js`);
  R:{
    1:require_`WALLET_PRIVATE_KEY`_pre_transport;
    2:`StdioClientTransport({command:"npx",args:["agentwallet-sdk@8.0.0"],env:{PATH,NODE_ENV,WALLET_PRIVATE_KEY}})`(pin_verified_version;env_whitelist_only;¬forward_full_`process.env`);
    3:call_`set_policy({per_task_budget,per_session_budget,allowlisted_recipients})`∧assert_`!policyResult.isError`_pre_delegation;
    4:`preToolCheck`_fail_closed_5_paths:[
      1:`!Number.isFinite(apiCost)||apiCost<0`(blocks_`NaN`/`Infinity`),
      2:transport_err_on_`check_spending`,
      3:`result.isError`,
      4:`!Number.isFinite(JSON.parse(result.content[0].text)?.remaining)`,
      5:`remaining<apiCost`
    ];
    5:post_task_hook⇒`list_transactions`_audit_trail
  }
}

§REF{
  npm:[`https://www.npmjs.com/package/agentwallet-sdk`,`https://www.npmjs.com/org/x402`(@x402/{core,fetch,axios,express,hono,next,fastify,evm,svm})];
  NVIDIA_NeMo_PR17:`https://github.com/NVIDIA/NeMo-Agent-Toolkit-Examples/pull/17`;
  x402:[`https://x402.org`,`https://docs.x402.org`,`https://docs.x402.org/dev-tools/facilitators`,`https://github.com/x402-foundation/x402`];
  OKX:[`https://github.com/okx/payments`,`https://github.com/okx/onchainos-skills/tree/main/skills/okx-agent-payments-protocol`,`https://web3.okx.com/onchainos/dev-docs/payments/overview`]
}
