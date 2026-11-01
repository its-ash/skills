---
name: supply-chain-operations
description: "Expert playbooks for supply chain and operations: carrier management, customs and trade compliance, energy procurement, demand planning, freight exceptions, production scheduling, quality non-conformance, and returns. Use when onboarding carriers, running freight RFPs, classifying goods under HS codes, screening denied parties, buying electricity or gas, forecasting demand, setting safety stock, handling freight claims or delays, sequencing production, resolving bottlenecks, managing NCRs and CAPAs, reading SPC charts, or processing returns, refunds, and warranty claims. Sub-skills: carrier-relationship-management, customs-trade-compliance, energy-procurement, inventory-demand-planning, logistics-exception-management, production-scheduling, quality-nonconformance, returns-reverse-logistics."
---

# Supply Chain Operations

Each sub-skill gives a senior practitioner view of one operations function: core knowledge, decision frameworks, edge cases, communication patterns, escalation triggers, and KPIs. Load the sub-skill that matches the task.

## When to use

- You plan, buy, move, make, inspect, or return physical goods.
- You need a decision framework, threshold, or escalation rule for an operations problem.
- You draft supplier, carrier, customer, or regulator communication for an operations event.
- Do not use for software supply chain security; use [`secure-coding`](../secure-coding/SKILL.md).

## Common rules

- Decide with data. Quote the benchmark, metric, or threshold that supports the decision.
- Protect safety and regulatory compliance first, then customer commitments, then cost.
- Document evidence, rationale, and approvals at each step. Auditors and claims processes depend on it.
- Escalate on the defined triggers. Do not wait for a problem to become critical.
- Track the KPI targets and red flags for each function, and review trends, not single data points.
- Adapt the thresholds, templates, and escalation chains to your organization before production use.
- These playbooks give operational guidance, not legal, tax, or financial advice. Get counsel for regulatory filings, penalties, and contracts.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/carrier-relationship-management.md](references/carrier-relationship-management.md) | Onboard or vet carriers (FMCSA), run freight RFPs, negotiate linehaul, fuel surcharge, and accessorials, build routing guides and scorecards, or reallocate freight. |
| [references/customs-trade-compliance.md](references/customs-trade-compliance.md) | Classify goods under HS or HTS with GRI rules, prepare entry documents and ISF, apply Incoterms 2020, qualify FTAs (USMCA, RCEP), screen denied parties, or answer CBP audits and penalties. |
| [references/energy-procurement.md](references/energy-procurement.md) | Buy electricity or gas for C&I sites, optimize tariffs, reduce demand charges, structure fixed, index, or block-and-index hedges, evaluate PPAs and RECs, or report Scope 2. |
| [references/inventory-demand-planning.md](references/inventory-demand-planning.md) | Forecast demand, choose a forecast method, segment ABC/XYZ, set safety stock and reorder points, plan promotions and seasonal buys, or time markdowns. |
| [references/logistics-exception-management.md](references/logistics-exception-management.md) | Handle shipment delays, damage, loss, shortages, refusals, detention disputes, Carmack freight claims, or exception SOPs and escalations. |
| [references/production-scheduling.md](references/production-scheduling.md) | Sequence jobs, find and protect the bottleneck (drum-buffer-rope), reduce changeovers (SMED), measure OEE, or re-plan after breakdowns, shortages, or absenteeism. |
| [references/quality-nonconformance.md](references/quality-nonconformance.md) | Investigate NCRs, run 5-Why, Ishikawa, fault tree, or 8D analysis, manage CAPAs, read SPC charts, set AQL sampling, or manage supplier quality under FDA, IATF, or AS9100. |
| [references/returns-reverse-logistics.md](references/returns-reverse-logistics.md) | Process RMAs, grade and route returns, decide refunds and exceptions, score return fraud, recover cost from vendors, or handle warranty claims. |

## Related skills

Load these when the task spans more than this skill.

- [`software-architecture`](../software-architecture/SKILL.md) — Design TMS, WMS, ERP, or MES integrations that implement these workflows.
- [`database-design`](../database-design/SKILL.md) — Model shipments, inventory, NCRs, CAPAs, and returns data.
