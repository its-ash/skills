# Computer Vision Engineering

Create, train, and serve computer vision models in production. Use this skill when you need an end‑to‑end pipeline for image or video processing, object detection, segmentation, or real‑time inference.

## When to use
- Building a new vision model from data.
- Optimizing an existing model for low‑latency inference.
- Deploying a vision service at scale with Docker/Kubernetes.
- Monitoring model performance and data drift in production.

## Workflow Overview
- Define data ingestion and validation.
- Preprocess images with OpenCV.
- Train a model with PyTorch or TensorFlow.
- Evaluate accuracy and latency.
- Convert the model to an inference‑optimized format (ONNX, TensorRT, etc.).
- Containerize the service with Docker.
- Deploy to a Kubernetes cluster.
- Set up health checks, logging, and monitoring.

## Development Rules
- Write unit tests for each module. Run `python -m pytest`.
- Format code with `python -m black src/`.
- Lint code with `python -m pylint src/`.
- Store all code, data schemas, and configuration files in version control.
- Document data sources, preprocessing steps, and model architecture.

## Production Patterns
### Scalable Data Processing
- Use horizontal scaling for ingestion workers.
- Design pipelines for fault tolerance and retry.
- Support both batch and streaming modes.
- Validate data quality before training.
- Monitor processing latency and throughput.

### Model Deployment
- Serve models with low latency (e.g., FastAPI, TorchServe).
- Implement A/B testing to compare model versions.
- Integrate a feature store for consistent input preprocessing.
- Detect model drift and trigger automated retraining.
- Automate model promotion with CI/CD pipelines.

### Real‑Time Inference
- Batch incoming requests to improve GPU utilization.
- Cache recent inference results when appropriate.
- Use a load balancer to distribute traffic.
- Enable auto‑scaling based on request rate.
- Optimize latency budgets per service level agreement.

## Performance Targets
- **Latency**: P50 < 50 ms, P95 < 100 ms, P99 < 200 ms.
- **Throughput**: > 1 000 requests/second, > 10 000 concurrent users.
- **Availability**: 99.9 % uptime, error rate < 0.1 %.

## Security & Compliance
- Enforce authentication and role‑based authorization.
- Encrypt data at rest and in transit.
- Anonymize personally identifiable information.
- Follow GDPR, CCPA, and other regional regulations.
- Conduct regular security audits and vulnerability scans.

## Common Commands
```bash
# Run tests with coverage
python -m pytest tests/ -v --cov

# Format code
python -m black src/

# Lint code
python -m pylint src/

# Train model
python train.py --config config.yaml

# Evaluate model
python evaluate.py --model best.pth

# Build Docker image
docker build -t cv-service:latest .

# Deploy to Kubernetes
kubectl apply -f k8s/
helm upgrade cv-service ./charts/
```

## Pitfalls to Avoid
- Skipping data validation; it introduces silent errors.
- Deploying an unoptimized model; latency will exceed targets.
- Ignoring monitoring; drift and performance regressions go unnoticed.
- Hard‑coding file paths; the pipeline breaks in new environments.
- Forgetting encryption; it violates compliance requirements.

## Checklist
- [ ] Validate image size, format, and quality in the ingestion step.
- [ ] All unit and integration tests pass.
- [ ] Model meets defined accuracy and latency targets on a validation set.
- [ ] Model is converted to an inference‑optimized format.
- [ ] Docker image uses a minimal base and includes only required libraries.
- [ ] Deployment includes health‑check endpoints and structured logging.
- [ ] Monitoring dashboards track latency, error rate, and data drift.
- [ ] Security controls (auth, encryption, audit) are verified.
