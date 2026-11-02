---
name: supply-chain-operations
description: "Supply chain and operations playbooks. Use for carrier onboarding, freight RFPs, HS codes, denied-party screening, electricity or gas buying, demand forecasts, safety stock, freight claims, production sequencing, NCRs, CAPAs, SPC, returns, and warranty claims. Sub-skills: carrier-relationship-management, customs-trade-compliance, energy-procurement, inventory-demand-planning, logistics-exception-management, production-scheduling, quality-nonconformance, returns-reverse-logistics."
---

# Supply Chain Operations
Senior-practitioner playbooks for planning, buying, moving, making, inspecting, and returning physical goods. Each reference gives knowledge, decision frameworks, edge cases, communication templates, escalation triggers, and KPIs.

## Core rules
- Decide with data. Quote the benchmark, metric, or threshold that supports the decision.
- Priority order: safety and regulatory compliance, then customer commitments, then cost.
- Document evidence, rationale, and approvals at each step. Audits and claims depend on it.
- Escalate on the defined triggers. Do not wait for a problem to become critical.
- Track KPI targets and red flags per function. Review trends, not single data points.
- Adapt thresholds, templates, and escalation chains to the organization before production use.
- Give operational guidance only, not legal, tax, or financial advice. Get counsel for filings, penalties, and contracts.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Physical goods operations problem | Load the one matching reference below | Loading all references |
| Software supply chain security | Use [`secure-coding`](../secure-coding/SKILL.md) | This skill |
| Build TMS, WMS, ERP, or MES software | Use [`software-architecture`](../software-architecture/SKILL.md) | Encoding playbooks as ad hoc code |

## Load on demand
| Need | Read |
|---|---|
| Carrier vetting (FMCSA), freight RFPs, linehaul, fuel surcharge, accessorials, routing guides, scorecards | [references/carrier-relationship-management.md](references/carrier-relationship-management.md) |
| HS/HTS classification (GRI), entry docs, ISF, Incoterms 2020, FTAs (USMCA, RCEP), denied-party screening, CBP audits | [references/customs-trade-compliance.md](references/customs-trade-compliance.md) |
| C&I electricity or gas buying, tariffs, demand charges, fixed/index/block-and-index hedges, PPAs, RECs, Scope 2 | [references/energy-procurement.md](references/energy-procurement.md) |
| Demand forecast method, ABC/XYZ, safety stock, reorder points, promotions, seasonal buys, markdowns | [references/inventory-demand-planning.md](references/inventory-demand-planning.md) |
| Delays, damage, loss, shortages, refusals, detention disputes, Carmack claims, exception SOPs | [references/logistics-exception-management.md](references/logistics-exception-management.md) |
| Job sequencing, bottleneck (drum-buffer-rope), SMED, OEE, re-plan after breakdown or shortage | [references/production-scheduling.md](references/production-scheduling.md) |
| NCRs, 5-Why, Ishikawa, fault tree, 8D, CAPA, SPC, AQL, supplier quality (FDA, IATF, AS9100) | [references/quality-nonconformance.md](references/quality-nonconformance.md) |
| RMAs, return grading and routing, refunds, fraud scoring, vendor recovery, warranty claims | [references/returns-reverse-logistics.md](references/returns-reverse-logistics.md) |

## Related skills
- [`software-architecture`](../software-architecture/SKILL.md) — TMS, WMS, ERP, MES integration design
- [`database-design`](../database-design/SKILL.md) — model shipments, inventory, NCRs, returns
