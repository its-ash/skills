---
name: machine-learning
description: "Production ML engineering: data contracts, leakage checks, reproducible training, metric economics, error analysis, promotion gates, serving, monitoring, rollback. Use when hardening ML beyond notebooks, adding first ML to a codebase, writing PyTorch training loops or DataLoaders, designing recsys, ranking, or reranker pipelines, tuning thresholds, precision, recall, AUC, calibration, debugging drift, label leakage, train/serve skew, or speeding up slow ETL or backfill. Sub-skills: pytorch-patterns, ml-adoption-playbook, recsys-pipeline-architect, data-throughput-accelerator."
---
# Machine Learning Engineering
Turn model work into a production system: data contracts, repeatable training, quality gates, deployable artifacts, monitoring.

## Core rules
- Start from the decision the model changes, not the model. Reject "improve the model" as a requirement.
- Write the Iteration Compact before model code ([template](references/mle-workflow.md#iteration-compact-write-before-model-code-fits-in-a-pr-description)).
- Lock a data contract: entity grain, label timing, feature timing, point-in-time joins, split policy, snapshot ID.
- Check leakage first. Remove any feature not available at prediction time or joined with future data.
- Build a baseline before complexity. Add capacity only when error analysis shows a fixable cause.
- Make training reproducible: typed config, pinned deps, seeds, dataset version, code SHA, config hash, artifact URI.
- Ship preprocessing inside the artifact. Share train/serve transforms or prove equivalence with a test.
- Declare promotion gates before training ends. Automate them and fail closed.
- Compare against baseline and current production model, per slice, not only in aggregate.
- Treat offline metrics as gates, not guarantees. Use shadow, canary, or A/B when product behavior changes.
- Serve with input validation, timeout, fallback, model version in output and logs, no PII in logs.
- Monitor system health, feature drift, prediction drift, and delayed-label quality.
- Keep a rollback that switches to a known-good artifact without retraining.
- Keep each important production mistake as a regression test, eval slice, or runbook entry.
- Match scope to the system. Do not add heavy MLOps when a contract, baseline, eval script, and rollback note suffice.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Wrong positive costs most | Favor precision | Accuracy as headline metric |
| Missed positive costs most | Favor recall | Default 0.5 threshold |
| Order matters more than one cutoff | AUC or ranking metrics | F1 for ranking |
| Precision/recall cost truly balanced | F1, with the reason stated | F1 by habit |
| Any metric choice | State which mistake it makes cheaper, which more likely, who pays | Metric with no cost owner |
| Real-world feedback as labels | Treat as delayed, biased, partial labels | Treat as ground truth |
| Latency/cost limits | Track as first-class metrics | Ignore until serving |

| Situation | Do | Avoid |
|---|---|---|
| Noisy labels | Adjudicate, confidence weights, soft targets | Train on raw labels blindly |
| Class imbalance | Compare weighted loss, resampling, threshold move, calibration | Resample without comparison |
| Missing values | Decide: informative, imputable, or abstain | Silent fill with 0 |
| Time-dependent data | Time-based split, point-in-time joins | Random split |
| Threshold tuning | Tune on validation | Repeat tuning on test set |
| Mistakes after a run | Cluster FP/FN, map to labels, features, threshold, or fallback | Vague "improve model" next task |

## Load on demand
| Need | Read |
|---|---|
| Iteration Compact, decision loop, feature hypotheses, error analysis, Observation Ledger, contracts, pipeline and gate code, serving, monitoring, checklist, anti-patterns, MLE-01..10 task map | [references/mle-workflow.md](references/mle-workflow.md) |
| PyTorch models, train/val loops, Datasets, DataLoaders, checkpoints, AMP, `torch.compile`, non-reproducible runs | [references/pytorch-patterns.md](references/pytorch-patterns.md) |
| First ML feature in a codebase: framing, heuristic check, data readiness, decoupled inference API, flag, baseline | [references/ml-adoption-playbook.md](references/ml-adoption-playbook.md) |
| Recsys, ranking, feed, notification triage, RAG reranker (Source, Hydrator, Filter, Scorer, Selector, SideEffect) | [references/recsys-pipeline-architect.md](references/recsys-pipeline-architect.md) |
| Slow ingestion, backfill, export, ETL, warehouse load; prove correctness by row and timestamp counts | [references/data-throughput-accelerator.md](references/data-throughput-accelerator.md) |

## Related skills
- [`python`](../python/SKILL.md) — layout, uv, ruff, mypy; [`python-testing`](../python/references/python-testing.md) for transform tests.
- [`eval-harness`](../ai-agent-engineering/references/eval-harness.md) — regression gates; also [`ai-regression-testing`](../unit-testing-patterns/references/ai-regression-testing.md).
- [`ai-agent-engineering`](../ai-agent-engineering/SKILL.md) — LLM agents, RAG, [`llm-cost-optimization`](../ai-agent-engineering/references/llm-cost-optimization.md), [`search-first`](../ai-agent-engineering/references/search-first.md).
- [`software-architecture`](../software-architecture/SKILL.md) — record hard-to-reverse data, model, rollout choices.
- [`api-design`](../backend-development/references/api-design.md), [`fastapi`](../backend-development/references/fastapi.md) — prediction APIs, batch jobs, idempotent retrain.
- [`database-design`](../database-design/SKILL.md) — label, feature, prediction stores; [`postgresql`](../database-design/references/postgresql.md), [`clickhouse`](../database-design/references/clickhouse.md).
- [`docker`](../devops-iac/references/docker.md), [`observability`](../devops-iac/references/observability.md) — reproducible images; version, slice, drift dashboards.
- [`secure-coding`](../secure-coding/SKILL.md) — secrets, PII, unsafe deserialization in artifacts, notebooks, logs.
- [`devops-iac`](../devops-iac/SKILL.md) — CI/CD, Kubernetes for training and serving.
