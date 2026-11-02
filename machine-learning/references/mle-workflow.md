# MLE Workflow Reference

Templates, contracts, gates, checklists, and task coverage for production ML. Parent: [`machine-learning`](../SKILL.md).

## Scope calibration
- Do not assume labels, online serving, a feature store, PyTorch, GPUs, human review, A/B tests, or real-time feedback.
- Do not add heavy MLOps when a data contract, baseline, eval script, and rollback note make the change reviewable.
- State assumptions when the project lacks labels, delayed outcomes, slice definitions, production traffic, or monitoring owners.
- Treat examples as scaffolds. Replace metrics, serving mode, stores, and rollout with project-native equivalents.

## Iteration Compact (write before model code; fits in a PR description)
```text
Goal:
Who cares:
Decision owner:
User or system action changed by the model:
Success metric:
Guardrail metrics:
Mistake budget:
Unacceptable mistakes:
Acceptable mistakes:
Assumptions:
Constraints:
Labels and data snapshot:
Baseline:
Candidate signals:
Threshold or config plan:
Eval slices:
Known risks:
Next experiment:
Rollback or fallback:
```

## Decision loop (ambiguous, high-impact, or metric-heavy work)
1. Start from the decision. Name the action that changes downstream behavior.
2. Name who cares and the cost each pays for FP, FN, latency, compute, opacity, missed opportunity.
3. Convert ambiguity into hypotheses: what signal separates outcomes, what disproves it, which simple baseline is hard to beat.
4. Research prior art or a nearby known problem first.
5. Score choices with `(probability, confidence) x (cost, severity, importance, impact)`.
6. Consider adversarial behavior, incentives, selective disclosure, distribution shift, feedback loops.
7. Prefer the simplest change that reduces the most important mistake.
8. Record decision, evidence, counterargument, next reversible step.

## Feature hypotheses
- Signal families (text, categorical, numeric histories, graph, recency, frequency, aggregates) are candidates, not automatic features.
- Per family: state why it separates outcomes and how it can leak future data.
- Noisy labels: adjudication, label confidence, soft targets, confidence weighting.
- Class imbalance: compare weighted loss, resampling, threshold movement, calibrated decision rules.
- Missing values: decide informative, imputable, or abstain.
- Outliers: clip, bucket, investigate, or keep as rare signal.
- Correlated features: check redundancy, instability, proxies for unavailable future state.

## Error analysis loop
1. Split mistakes: FP, FN, abstentions, low-confidence, system failures.
2. Cluster by language, entity type, source, time, geography, device, sparsity, recency, feature freshness, label source, model version.
3. Separate model mistakes from data bugs, label ambiguity, product ambiguity, instrumentation gaps, serving mismatches.
4. Map each cluster to one move: better labels, features, threshold/config, or product fallback.
5. Keep each important mistake as a regression test, eval slice, dashboard panel, or runbook entry.
6. Write the next iteration as a falsifiable experiment.

Loop: mistake -> cluster -> hypothesis -> experiment -> evidence -> simpler system.

## Observation Ledger (beside code, PR, experiment report, or runbook)
```text
Iteration:
Change:
Why this mattered:
Metric movement:
Slice movement:
False positives:
False negatives:
Unexpected errors:
Decision:
Tradeoff accepted:
Lesson captured:
Regression added:
Debt created:
Next iteration:
```

## Prediction contract
- Target and decision owner.
- Input entity, output schema, confidence/calibration fields, allowed latency.
- Serving mode: batch, online, streaming, hybrid.
- Fallback when model, feature store, or dependency is down.
- Human review or override for high-impact decisions.
- Privacy, retention, audit for inputs, predictions, labels.

## Data contract
- Entity grain and primary key.
- Label definition, label timestamp, label delay.
- Feature timestamp, freshness SLA, point-in-time join rules.
- Train/validation/test/backtest split policy.
- Required columns, allowed nulls, ranges, categories, units.
- PII fields barred from artifacts and logs.
- Dataset version or snapshot ID.

## Reproducible pipeline
- Typed config (frozen dataclass or file) for all hyperparameters and paths.
- Pin package and model dependencies.
- Set seeds; document nondeterministic GPU ops.
- Record dataset version, code SHA, config hash, metrics, artifact URI.
- Save preprocessing with the model artifact.
- Share train/eval/inference transforms from one source.
- Make each step idempotent.
- Use pure transforms; do not mutate shared frames or global config.

```python
import hashlib
from dataclasses import dataclass
from pathlib import Path

@dataclass(frozen=True)
class TrainingConfig:
    dataset_uri: str
    model_dir: Path
    seed: int
    learning_rate: float
    batch_size: int

def artifact_name(config: TrainingConfig, code_sha: str) -> str:
    key = f"{config.dataset_uri}:{config.seed}:{config.learning_rate}:{config.batch_size}"
    return f"{code_sha[:12]}-{hashlib.sha256(key.encode()).hexdigest()[:12]}"
```

## Promotion gates (declare before training ends)
- Compare against baseline and current production model.
- Primary metric tied to product behavior.
- Guardrails: latency, calibration, fairness slices, cost, error concentration.
- Slice metrics: cohorts, geographies, devices, languages, sources.
- Confidence intervals or repeated-run variance for noisy metrics.
- Human review of failure examples for high-impact models.
- Explicit "do not ship" thresholds. Offline gates are not guarantees: plan shadow, canary, or A/B when product behavior changes.

```python
PROMOTION_GATES = {"auc": ("min", 0.82), "calibration_error": ("max", 0.04), "p95_latency_ms": ("max", 80)}

def assert_promotion_ready(metrics: dict[str, float]) -> None:
    missing = sorted(n for n in PROMOTION_GATES if n not in metrics)
    if missing:
        raise ValueError(f"Model promotion metrics missing required gates: {missing}")
    failures = {
        n: metrics[n] for n, (d, t) in PROMOTION_GATES.items()
        if (d == "min" and metrics[n] < t) or (d == "max" and metrics[n] > t)
    }
    if failures:
        raise ValueError(f"Model failed promotion gates: {failures}")
```

## Serving package
- Artifact carries version, training data reference, config, preprocessing.
- Input schema rejects invalid, stale, out-of-range features.
- Output carries model version plus confidence or explanation when useful.
- Timeout, batching, resource limits, fallback.
- Explicit, tested CPU/GPU requirements.
- Prediction logs: no PII; enough IDs for debugging and label joins.
- Integration tests: missing features, stale features, bad types, empty batches, fallback path.

## Monitoring
- Availability, error rate, timeout rate, queue depth, p50/p95/p99 latency.
- Feature null rate, range drift, categorical drift, freshness drift.
- Prediction and confidence distribution drift.
- Label arrival health and delayed quality metrics.
- Business KPI guardrails and rollback triggers.
- Per-version dashboards for canaries and rollbacks.
- Rollback plan names previous artifact, config, data dependency, traffic-switch mechanism.

## Review checklist
- [ ] Prediction contract explicit and testable
- [ ] Data contract: entity grain, label timing, feature timing, snapshot/version
- [ ] Leakage checked against prediction-time availability
- [ ] Training reproducible from code, config, data version, seed
- [ ] Metrics vs baseline and production model
- [ ] Slice metrics and guardrails for high-risk cohorts
- [ ] Promotion gates automated and fail closed
- [ ] Train/serve transforms shared or equivalence-tested
- [ ] Artifact carries version, config, dataset reference, preprocessing
- [ ] Serving validates inputs; has timeout, fallback, rollback
- [ ] Monitoring: system health, feature drift, prediction drift, delayed labels
- [ ] No sensitive data in artifacts, logs, prompts, examples

## Anti-patterns
- Notebook state needed to reproduce the model.
- Random split leaks future data into validation/test.
- Feature joins ignore event time and label availability.
- Offline metric improves while key slices regress.
- Thresholds tuned on the test set repeatedly.
- Training preprocessing copied by hand into serving code.
- Model version missing from prediction logs.
- Monitoring checks uptime only, not data or prediction quality.
- Rollback needs retraining instead of an artifact switch.

## Task coverage (MLE-01..10)
| ID | Task | Required output |
|---|---|---|
| MLE-01 | Frame an ambiguous prediction/ranking/recsys/classifier/embedding/forecast | Iteration Compact |
| MLE-02 | Define metrics, labels, sources, mistake budget | Data + metric contract: grain, label timing/confidence, feature timing, point-in-time joins, split, snapshot |
| MLE-03 | Baseline before complexity | Baseline scorer, confusion matrix, calibration notes, latency/cost, weaknesses, score shape/determinism tests |
| MLE-04 | Features from separation hypotheses | Feature plan + transform module: source, missing, outliers, correlation, leakage, train/serve equivalence |
| MLE-05 | Tune thresholds/config/complexity | Report: precision, recall, F1, AUC, calibration, slices, latency, cost, acceptable error classes |
| MLE-06 | Error analysis -> next experiment | Error cluster report: FP, FN, ambiguous labels, stale features, missing signals, bug traces |
| MLE-07 | Package artifact | Versioned bundle: preprocessing, config, dependency pins, schema validation, safe loading, PII-safe logs |
| MLE-08 | Ship online or batch scoring | Endpoint/job: envelope, timeout, batching, fallback, version, confidence, feedback logging, product-flow tests |
| MLE-09 | Roll out | Plan: traffic split, dashboards, p95, cost, quality guardrails, rollback artifact and trigger |
| MLE-10 | Operate and refresh | Observation ledger + refresh plan: drift, delayed labels, alert owners, runbook, retrain criteria |
