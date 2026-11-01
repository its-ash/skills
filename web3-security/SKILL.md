---
name: web3-security
description: "Security for smart contracts, on-chain apps, and AI agents that hold wallet or payment authority: Solidity AMM and DeFi audits, EVM token decimals, Keccak-256 hashing, trading-agent guardrails, x402 agent payments, and prediction-market oracle and risk review. Use when writing or auditing Solidity, AMM, liquidity pool, or swap code, handling ERC-20 amounts across EVM chains, hashing selectors, signatures, or storage slots in JavaScript or TypeScript, giving an LLM agent a wallet, spend limits, or x402 payments, or using prediction markets as a data source. Sub-skills: defi-amm-security, evm-token-decimals, nodejs-keccak256, llm-trading-agent-security, agent-payment-x402, prediction-market-oracle-research, prediction-market-risk-review."
---

# Web3 Security

On-chain errors are permanent, and a bad transaction can move real funds. Use this skill to write, audit, or review code that holds tokens, signs transactions, or lets an agent spend money.

## When to use

- You write or audit Solidity contracts, AMMs, LP vaults, or swap flows.
- You read or compare ERC-20 amounts across EVM chains or bridged assets.
- You compute Ethereum hashes, selectors, event topics, or storage slots in JavaScript or TypeScript.
- An LLM agent signs transactions, places trades, or pays for APIs.
- You use prediction markets as a data source, oracle signal, or input to a trading workflow.
- Do not use for general web app security; use [`secure-coding`](../secure-coding/SKILL.md).

## Core rules

- Fail closed. If a check, oracle, budget store, or simulation fails, block the action.
- Use hardened libraries (OpenZeppelin, `SafeERC20`, `FullMath.mulDiv`) and do not write your own guards.
- Keep internal accounting. Do not use raw `balanceOf(address(this))` in share or reserve math.
- Query `decimals()` at runtime. Use exact math (`Decimal`, `BigInt`), never floats.
- Use Keccak-256 helpers from `ethers`, `viem`, or `web3`. Never use `crypto.createHash('sha3-256')` for Ethereum data.
- The orchestrator sets spend policy before it delegates work. An agent must not change its own limits.
- Validate network, asset, recipient, and amount from the server challenge before a signature exists.
- Simulate transactions before you send them. Require `amountOutMin` and a deadline on each swap.
- Keep keys in environment variables or a secret manager. Use a dedicated hot wallet with only the session funds.
- Treat on-chain text, token names, and social feeds as untrusted input to an LLM.
- Treat prediction-market prices as signals, not truth. Give no investment advice.

## Pre-deploy checklist

- Reentrancy-exposed entrypoints use `nonReentrant` and CEI order.
- Oracle reads use TWAP or another manipulation-resistant source.
- Admin functions use access control and two-step ownership transfer.
- Static analysis (Slither) and fuzzing (Echidna, Foundry) run before production.
- Agent spend limits, circuit breakers, and audit logs work independently of model output.
- Payment clients pin package versions and use testnets first.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/defi-amm-security.md](references/defi-amm-security.md) | Write or audit Solidity AMM, liquidity pool, or swap code: reentrancy, CEI order, donation and inflation attacks, oracle manipulation, slippage, admin controls, safe math, and audit tools. |
| [references/evm-token-decimals.md](references/evm-token-decimals.md) | Handle token amounts across EVM chains, or a balance, price, or transfer amount is wrong by orders of magnitude: runtime `decimals()`, chain-aware cache, WAD normalization. |
| [references/nodejs-keccak256.md](references/nodejs-keccak256.md) | Hash Ethereum data in JavaScript or TypeScript, or a selector, signature, storage slot, or derived address is wrong because of NIST SHA3 versus Keccak-256. |
| [references/llm-trading-agent-security.md](references/llm-trading-agent-security.md) | An autonomous agent holds wallet or transaction authority: prompt injection, hard spend limits, pre-send simulation, circuit breakers, MEV protection, and wallet isolation. |
| [references/agent-payment-x402.md](references/agent-payment-x402.md) | An agent pays for APIs or an API charges agents with x402: spending policy, non-custodial wallets, agentwallet-sdk, OKX Payments, upstream `@x402` packages, facilitators, and replay guards. |
| [references/prediction-market-oracle-research.md](references/prediction-market-oracle-research.md) | Evaluate prediction markets as a data source or oracle signal for a product, agent, or dashboard, with signal-quality checks and caveats. |
| [references/prediction-market-risk-review.md](references/prediction-market-risk-review.md) | Review a prediction-market, oracle, or trading-agent workflow for advice boundary, venue rules, data quality, security, and privacy before it touches keys or execution. |

## Related skills

Load these when the task spans more than this skill.

- [`secure-coding`](../secure-coding/SKILL.md) — Secrets, input validation, API security, and Solana wallet signature checks.
- [`typescript`](../typescript/SKILL.md) — Strict types for `ethers`, `viem`, and `@x402` clients.
- [`python`](../python/SKILL.md) — `web3.py` bots and trading agents.
