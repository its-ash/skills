---
name: ml-engineering
description: "Provides guidance, best practices, and checklists for building production-grade machine-learning systems covering model training, serving, feature stores, monitoring, MLOps pipelines, and cloud deployment with PyTorch and TensorFlow. Use when implementing model training, model serving, feature store, MLOps, CI/CD, PyTorch, TensorFlow, object detection, segmentation, real-time inference, distributed training, Accelerate, DeepSpeed, FSDP, PyTorch Lightning, Megatron-Core, Ray Train, mixed precision, gradient accumulation, checkpointing, multi-node scaling, GPU acceleration, NeMo Curator, Ray Data, data cleaning, deduplication, training data preparation, Docker, Kubernetes, cloud deployment, computer vision, data processing pipelines."
---

# ML Engineering

**Purpose**: Provide concise, actionable guidance for designing, building, and operating production‑ready machine‑learning systems. Cover model training, serving, feature engineering, monitoring, CI/CD, and cost‑effective infrastructure.

## When to use
- You need to move a model from research to production.
- You must design a scalable inference service (real‑time or batch).
- You are building or extending a feature store or data pipeline.
- You require monitoring, A/B testing, or governance for deployed models.
- You are setting up MLOps CI/CD, experiment tracking, or automated retraining.

---

## Core Frameworks & Libraries
- **PyTorch 2.x** – `torch.compile`, Fully‑Sharded Data Parallel (FSDP), mixed precision.
- **TensorFlow 2.x / Keras** – `tf.function`, mixed precision, TensorFlow Serving.
- **JAX / Flax** – high‑performance research workloads.
- **Scikit‑learn, XGBoost, LightGBM, CatBoost** – classical algorithms.
- **ONNX** – model interchange and runtime optimization.
- **Hugging Face Transformers & Accelerate** – LLM fine‑tuning and deployment.
- **Ray / Ray Train** – distributed training and hyper‑parameter search.
- **Optuna, Ray Tune, Hyperopt** – automated hyper‑parameter optimization.
- **MLflow, Weights & Biases, Neptune** – experiment tracking and model registry.
- **DVC, Git LFS** – data and model versioning.

---

## Model Training & Optimization
1. **Define a reproducible training script** that logs parameters, metrics, and artifacts to MLflow or W&B.
2. **Enable mixed‑precision** (`torch.cuda.amp.autocast` or `tf.keras.mixed_precision.set_global_policy('mixed_float16')`).
3. **Scale out** with:
   - PyTorch Distributed Data Parallel (`torchrun --nproc_per_node=4 train.py`).
   - Horovod (`horovodrun -np 8 -H host1:4,host2:4 train.py`).
   - Ray Train (`ray train --address $RAY_HEAD train.py`).
4. **Apply gradient checkpointing** to reduce GPU memory (`torch.utils.checkpoint.checkpoint`).
5. **Run hyper‑parameter search**:
   ```bash
   optuna-run --study my_study --storage sqlite:///example.db train.py
   ```
6. **Validate** with cross‑validation and temporal hold‑out sets.
7. **Export** to ONNX for downstream serving if needed:
   ```python
   torch.onnx.export(model, dummy_input, "model.onnx", opset_version=16)
   ```

---

## Model Serving & Deployment
| Component | Recommended Tool | Key Options |
|---|---|---|
| **Serving** | TorchServe, TensorFlow Serving, MLflow, BentoML | Docker image, REST/gRPC endpoints |
| **Containerization** | Docker | `docker build -t my-model:latest .` |
| **Orchestration** | Kubernetes + Helm | Deploy with `helm install my-model ./chart` |
| **API Layer** | FastAPI, Flask, gRPC | Async endpoints for high throughput |
| **Real‑time streaming** | Kafka, Pulsar, Redis Streams | Pull features and push predictions |
| **Batch inference** | Spark, Ray, Dask | Parallel map over data partitions |
| **Edge** | TensorFlow Lite, PyTorch Mobile, ONNX Runtime | Convert model, quantize, and deploy on device |

**Serving pattern**
1. Containerize the model with its runtime (Python, TorchServe, etc.).
2. Expose a `/predict` endpoint that accepts JSON or protobuf.
3. Add request batching (`max_batch_size`, `batch_timeout_ms`).
4. Enable model versioning via a registry (MLflow Model Registry).
5. Configure auto‑scaling based on CPU/GPU utilization (`HorizontalPodAutoscaler`).
6. Use a load balancer (NGINX, Envoy) to distribute traffic.

---

## Feature Engineering & Feature Stores
- **Feature stores**: Feast, Tecton, AWS Feature Store, Databricks Feature Store.
- **Batch pipelines**: Spark or Dask jobs that compute nightly features.
- **Real‑time pipelines**: Kafka → Flink/Beam → Redis cache.
- **Data validation**: Great Expectations or TensorFlow Data Validation (TFDV) to enforce schema and detect anomalies.
- **Feature monitoring**: Track drift with statistical tests (Kolmogorov‑Smirnov) and alert when drift exceeds a threshold (e.g., 5% KL divergence).

**Typical workflow**
```bash
# Compute nightly batch features
spark-submit --master yarn batch_features.py

# Load real‑time features into Redis
python realtime_features.py --source kafka --sink redis
```

---

## MLOps & CI/CD Integration
1. **Source control** – Store code, configs, and Dockerfiles in Git.
2. **CI pipeline** – Run lint, unit tests, and security scans on each PR.
   ```bash
   python -m black . && python -m pylint src/
   python -m pytest tests/ --cov
   ```
3. **CD pipeline** – Build Docker image, push to registry, and apply Helm chart.
4. **Automated testing** – Include data validation tests, model contract tests, and inference sanity checks.
5. **Continuous training** – Trigger retraining when monitoring detects performance drop or data drift.
6. **Infrastructure as Code** – Use Terraform or Pulumi to provision cloud resources (EKS, GKE, SageMaker endpoints).
7. **Security** – Enforce IAM roles, encrypt model artifacts at rest (`aws kms encrypt`), and use TLS for API traffic.

---

## Production Infrastructure & Scalability
- **Auto‑scaling**: HorizontalPodAutoscaler based on custom metrics (GPU utilization, request latency).
- **Load balancing**: Use canary or blue‑green deployments with traffic splitting (e.g., Istio `VirtualService`).
- **Caching**: Cache recent predictions in Redis; cache feature vectors in Memcached.
- **Cost optimization**: Prefer spot instances for training; enable GPU autoscaling; shut down idle workers.
- **Hardware acceleration**: Deploy on GPUs, TPUs, or AWS Inferentia for high‑throughput inference.
- **Latency tricks**: Warm‑up model on pod start, keep a pool of pre‑loaded workers, use async I/O.

---

## Monitoring, A/B Testing & Governance
- **Metrics**: latency, QPS, error rate, CPU/GPU usage, model‑specific metrics (accuracy, business KPI).
- **Drift detection**: Compare feature distributions and prediction confidence over time.
- **A/B testing**: Route a percentage of traffic to a candidate model using feature flags or traffic split.
- **Canary release**: Deploy new version to 5 % of pods, monitor, then ramp up.
- **Logging**: Structured JSON logs with request ID, model version, and inference time.
- **Alerting**: Prometheus alerts for latency > P95 target or error rate > 0.1 %.
- **Governance**: Store lineage in MLflow, retain audit logs, enforce data‑privacy policies.

---

## Common Pitfalls
- **Skipping data validation** – leads to silent model degradation.
- **Hard‑coding paths or credentials** – break deployments and create security risks.
- **Running inference on CPU when GPU is available** – unnecessary latency.
- **Not versioning feature pipelines** – makes reproducing predictions impossible.
- **Ignoring cold‑start latency** – causes spikes in latency for autoscaled pods.
- **Deploying without canary** – risks large‑scale outages.
- **Missing health checks** – orchestration cannot replace application‑level liveness probes.

---

## Checklist
- [ ] Define clear business metric and success criteria.
- [ ] Store data, code, and model artifacts in version‑controlled locations.
- [ ] Write a reproducible training script with experiment logging.
- [ ] Enable mixed‑precision and distributed training if dataset is large.
- [ ] Export model to a serving‑compatible format (TorchServe, TF Serving, ONNX).
- [ ] Containerize the serving code and push image to a registry.
- [ ] Deploy with Helm/Kubernetes, configure auto‑scaling and health probes.
- [ ] Set up feature store and data validation pipelines.
- [ ] Implement monitoring (Prometheus + Grafana) for latency, error rate, and drift.
- [ ] Create A/B testing or canary rollout plan.
- [ ] Add alerts for performance degradation and security incidents.
- [ ] Document architecture, runbooks, and rollback procedures.
- [ ] Review cost estimates and enable spot/auto‑scale where possible.

---

**End of skill**

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/computer-vision.md](references/computer-vision.md) | Provides step‑by‑step guidance for building, training, optimizing, deploying, and monitoring production computer vision systems, including object detection, segmentation, and real‑time inference using Python, PyTorch, OpenCV, Docker, and Kubernetes. |
| [references/distributed-training.md](references/distributed-training.md) | Provides a unified guide for distributed training in PyTorch using Accelerate, DeepSpeed, FSDP, PyTorch Lightning, Megatron‑Core, and Ray Train. Shows when to choose each tool, how to add minimal code changes, configure mixed precision, gradient accumulation, checkpointing, and scale from a single GPU to multi‑node clusters. |
| [references/ml-data-processing.md](references/ml-data-processing.md) | Provides GPU‑accelerated and distributed pipelines for cleaning, deduplicating, and preparing text, image, video, or audio data for LLM or ML training. Use NeMo Curator for fast GPU curation and Ray Data for scalable streaming transforms. |

## Related skills

Load these when the task spans more than this skill.

- [`data-engineering`](../data-engineering/SKILL.md) — Guides the design, implementation, and operation of scalable batch and streaming data pipelines, modern data w…
- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`pymoo`](../pymoo/SKILL.md) — Use pymoo to solve single- and multi-objective optimization problems, find Pareto fronts, handle constraints,…
- [`llm-advanced-techniques`](../llm-advanced-techniques/SKILL.md) — Advanced LLM Techniques for compressing models with knowledge distillation, extending transformer context wind…
