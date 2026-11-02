---
name: systematic-debugging
description: "Four-phase method to isolate the root cause of bugs, test failures, crashes, and unexpected behavior in any language or stack. Use for stack traces, assertion errors, segfaults, memory leaks, flaky tests, CI failures, silent data corruption, race conditions, off-by-one errors, null pointer exceptions, dependency conflicts, or performance regressions; covers repro steps, git bisect, logging, state inspection, hypotheses, minimal repro, fixes, and regression checks."
---
# Systematic Debugging
Find and confirm the root cause before you write a fix.

## Core rules
- Never fix a symptom before you confirm the root cause.
- Read the full error: message, stack trace, line numbers, codes.
- Reproduce reliably and write the steps. Cannot reproduce → gather more data; do not guess.
- Check recent changes first: `git diff`, new dependencies, config, environment.
- Multi-component system: log input and output at each boundary; verify env and config propagate.
- Trace the bad value up the call stack to its origin. Fix at the origin.
- Compare with a working example in the same repo. List every difference. Read reference code fully before you adapt it.
- State one written hypothesis. Test it with one change or one log line. Never combine fixes.
- Hypothesis wrong → form a new one. Stuck → say so; research or ask.
- Write a failing test that shows the bug before the fix.
- Apply one root-cause fix. No "while I am here" changes.
- Verify: new test passes and the full suite passes.
- After three failed fixes, stop. Look for coupling, hidden shared state, or design flaws; discuss before a large refactor.

## Decisions
| Phase | Do | Avoid |
|---|---|---|
| 1 Investigate | Error text, repro, recent changes, boundary logs, trace data flow | Editing code first |
| 2 Pattern | Diff broken vs working code line by line | Skimming the reference |
| 3 Hypothesis | One hypothesis, one minimal change | Shotgun edits |
| 4 Implement | Failing test → single fix → full suite | Fix without test |

| Situation | Do | Avoid |
|---|---|---|
| Worked before, now broken | `git bisect` | Reading the whole history by hand |
| Large code path, unclear failure point | Binary search: disable half, rerun | Adding logs everywhere |
| Complex context | Minimal repro from an empty file | Debugging inside the full app |
| CI-only failure | Print env/config per layer (SET/UNSET, not values) | Assuming local == CI |
| Flaky test | Loop the test, record seed/order/timing; check shared state and races | Adding retries or sleeps |
| Performance regression | Profile and measure baseline vs now | Optimizing by intuition |
| Unknown error class | Use the error-class table | Deep dive before narrowing |

## Load on demand
| Need | Read |
|---|---|
| Error-class table, boundary logging example, bisect, Node/Python/system commands, checklist | [references/techniques.md](references/techniques.md) |

## Related skills
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — write the failing regression test
- [`observability`](../devops-iac/references/observability.md) — logs, metrics, traces in production
- [`performance`](../web-quality-audit/references/performance.md) — DevTools traces for web slowness
- [`code-review`](../code-review/SKILL.md) — review the fix before merge
- [`ai-agent-engineering`](../ai-agent-engineering/SKILL.md) — debug failed agent runs
