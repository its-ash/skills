# Agent Engineering Operating Model

Detail for the core rules in [../SKILL.md](../SKILL.md).

## Eval-first loop
1. Define a capability eval and a regression eval.
2. Run a baseline. Record failure signatures.
3. Implement.
4. Run the evals again. Compare deltas.

Graders, pass@k, suites: [eval-harness.md](eval-harness.md).

## Task unit (15-minute rule)
Each unit must:
- be verifiable alone;
- have one dominant risk;
- have a clear done condition.

## Model routing
| Tier | Tasks |
|---|---|
| Small | classification, boilerplate transforms, narrow edits |
| Mid | implementation, refactors |
| Largest | architecture, root-cause analysis, multi-file invariants |

Escalate a tier only when the lower tier fails from a clear reasoning gap. Budgets and caching: [llm-cost-optimization.md](llm-cost-optimization.md).

## Session strategy
- Continue the session for closely coupled units.
- Start a new session after a major phase change.
- Compact after a milestone, not during active debugging: [strategic-compact.md](strategic-compact.md).

## Agent-friendly architecture
Prefer explicit boundaries, stable contracts, typed interfaces, deterministic tests. Do not spread behavior across hidden conventions.

## Review and test bar for generated code
Review for:
- invariants and edge cases;
- behavior regressions and data integrity;
- error boundaries and failure handling;
- security and auth assumptions;
- hidden coupling and rollout risk.

Skip style review when format and lint tools enforce it.

Test bar:
- regression coverage for each touched domain;
- explicit edge-case assertions;
- integration checks at interface boundaries.

## Interpret tool results before you compare data
For document reads and processing loops, check three boundaries in this order:
1. Tool or transport envelope: error or unknown outcome?
2. Decoded operation status, per the tool's documented contract. An outer success flag or a payload does not prove success. Keep a missing or unknown status as unknown.
3. Only after confirmed success: validate document shape, then compare fields. An operation failure is not a document mismatch.

Keep operation name, request ID, status, error details, and the original response for diagnosis. Remove secrets and private data before you log or share them.

If a write times out or its result is unknown, reconcile with a documented status call or a read-back before you retry. Do not repeat or overwrite a write only because a read failed or a field differs.

## Cost record (per task)
model · token estimate · retries · wall-clock time · success or failure.

## Signals of a strong agent engineer
- Breaks ambiguous work into clean units.
- Defines measurable acceptance criteria.
- Writes high-signal prompts and evals.
- Keeps risk controls under delivery pressure.
