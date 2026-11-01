# Prediction Market Oracle Research

Research prediction markets as a data source, forecast input, oracle-like signal, or decision-intelligence layer, without investment advice.

## When to use

- You evaluate prediction markets as a data source or oracle signal for a product, agent, or dashboard.
- You need source-grounded analysis of market-implied probabilities and their caveats.

## Guardrails

- Do not treat market prices as objective truth.
- Do not provide investment advice or trading recommendations.
- Separate venue mechanics, liquidity, incentives, and resolution rules from the
  implied signal.
- Call out manipulation, thin liquidity, stale markets, and ambiguous outcomes.
- For on-chain or execution-linked systems, apply
  [llm-trading-agent-security.md](llm-trading-agent-security.md) and
  [prediction-market-risk-review.md](prediction-market-risk-review.md) before
  you grant write authority.

## Research Workflow

1. Define the decision the signal is meant to inform.
2. Find relevant markets, events, tags, and venues.
3. Record market-implied probabilities with timestamps and source links.
4. Evaluate signal quality:
   - liquidity
   - spread
   - market age
   - trader/incentive concentration if known
   - resolution authority
   - geography or account restrictions
5. Compare against non-market sources such as filings, news, polls, research,
   customer data, or internal KPIs.
6. Recommend whether the signal is usable, weak, or unsuitable for the stated
   decision.

## Integration Patterns

- Research assistant: source-grounded context for a human analyst.
- Dashboard signal: market-implied probability alongside internal metrics.
- Agent memory input: a time-stamped signal that can be retrieved later.
- Alerting input: notify when probabilities, spreads, or liquidity cross a
  threshold.
- Scenario planning: compare multiple event outcomes without automating trades.

## Output Contract

Use:

1. decision context
2. market sources
3. signal quality
4. comparison sources
5. integration recommendation
6. caveats

End with:

```text
Prediction-market signals are informational inputs, not investment advice.
```
