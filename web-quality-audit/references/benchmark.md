# Benchmark — Performance Baseline, Regression Detection, and Optimization Loop

Measure performance baselines, find regressions, and change "make it faster" requests into a bounded, measured optimization loop.

## When to use
- Before and after a PR, to measure the performance effect.
- To set performance baselines for a project.
- When users report "it feels slow".
- Before a launch, to make sure that the project meets its performance targets.
- When the user asks to speed up a job, try many variants, or select the best implementation by repeated measurement.

## Mode 1: Page Performance
Measure real browser metrics with a browser tool (see [performance.md](performance.md) and [web-performance.md](web-performance.md)):

| Metric | Target |
|--------|--------|
| LCP (Largest Contentful Paint) | < 2.5 s |
| CLS (Cumulative Layout Shift) | < 0.1 |
| INP (Interaction to Next Paint) | < 200 ms |
| FCP (First Contentful Paint) | < 1.8 s |
| TTFB (Time to First Byte) | < 800 ms |
| Total page weight | < 1 MB |
| JS bundle (gzipped) | < 200 KB |

Also record CSS size, image weight, third-party script weight, request count, and render-blocking resources.

## Mode 2: API Performance
1. Send each endpoint 100 requests.
2. Measure p50, p95, and p99 latency.
3. Record response size and status codes.
4. Test with load: 10 concurrent requests.
5. Compare the results with the SLA targets.

```bash
# Example with a third-party load tool
npx autocannon -c 10 -a 100 http://localhost:3000/api/items
```

## Mode 3: Build Performance
Measure the development feedback loop: cold build, hot reload (HMR), test suite duration, type check, lint, and Docker build time.

## Mode 4: Before/After Comparison
1. Save the current metrics as a baseline (for example `benchmarks/baseline.json`, tracked in Git so the team shares it).
2. Make the change.
3. Measure again with the same input and environment, and compare:

```text
| Metric | Before | After | Delta  | Verdict |
|--------|--------|-------|--------|---------|
| LCP    | 1.2s   | 1.4s  | +200ms | WARN    |
| Bundle | 180KB  | 175KB | -5KB   | BETTER  |
| Build  | 12s    | 14s   | +2s    | WARN    |
```

In CI, run the comparison on each PR. After deploy, use [canary-watch.md](canary-watch.md). For a full pre-ship check, add [browser-qa](../../unit-testing-patterns/references/browser-qa.md).

## Optimization Loop
### Required baseline
Do not optimize until these items exist:
- The operation that you optimize.
- The correctness gate that must stay green.
- The metric: wall time, p95 latency, rows/sec, cost/run, memory, or error rate.
- The current baseline value.
- The search budget: maximum variants, time, spend, and data impact.

If the target is not realistic, keep the ambition, but make the loop bounded and measurable.

### Loop steps
1. Measure the baseline.
2. Find bottlenecks from evidence.
3. Make variants that each test one hypothesis.
4. Run all variants with the same input shape.
5. Reject variants that fail correctness, safety, or reproducibility.
6. Promote the fastest safe variant.
7. Record the winner in a script, command, test, config, or document.
8. Run the baseline and the winner again to confirm the delta.

### Variant table
```text
Variant    | Hypothesis        | Command                       | Time | Correct? | Notes
baseline   | current path      | npm run job                   | 120s | yes      | stable
batch-500  | fewer round trips | npm run job -- --batch 500    | 42s  | yes      | winner
parallel-8 | more workers      | npm run job -- --workers 8    | 31s  | no       | rate limited
```

### Recursive or hyperparameter search
- Write each run to a ledger.
- Compare with the last accepted winner, not only with the previous run.
- Keep a holdout or replay check.
- Stop when the improvement is in the noise, correctness fails, cost goes above the budget, or the search changes more variables than it can explain.

Say "best measured safe variant", not "global optimum", unless the search was exhaustive.

### Promotion gate
A variant becomes the new default only when:
- Correctness tests pass.
- The performance delta is repeated or explained.
- Rollback is clear.
- The change is in source control or in a durable runbook.
- The final summary gives the exact commands and measurements.
