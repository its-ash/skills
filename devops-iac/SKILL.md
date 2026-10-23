---
name: devops-iac
description: "This skill guides infrastructure as code workflows covering Terraform provisioning, Kubernetes cluster operations, GitHub Actions CI/CD pipelines, GitOps with ArgoCD and Flux, service mesh configuration, observability stacks, security hardening, cost optimization, and disaster recovery planning. Use when writing terraform hcl, managing kubernetes k8s clusters, building github actions workflows yaml, configuring argocd flux gitops, deploying helm charts, setting up istio linkerd service mesh, implementing prometheus grafana observability, hardening security compliance, optimizing cloud costs aws gcp azure, or planning disaster recovery backup restore. Sub-skills: docker, cloud-architecture, cloudflare-deploy, observability."
---

# DevOps IaC

**Purpose** – This skill guides you through building and operating cloud infrastructure as code. It covers requirements gathering, architecture design, Terraform provisioning, Kubernetes deployment, CI/CD pipeline creation, observability, security, cost optimization, and disaster‑recovery procedures.

## When to Use
- You need to provision new cloud resources (AWS, Azure, GCP) or modify existing ones.
- You are deploying containerized applications with Kubernetes or managed services.
- You want to automate build, test, and release with a CI/CD pipeline.
- You must add monitoring, logging, and alerting for reliability.
- You require security‑first practices, cost control, or DR planning.

---

## 1. Structured Workflow
| Phase | Goal | Key Actions |
|-------|------|-------------|
| **1. Requirements** | Capture business and technical needs. | Identify application purpose, scale, compliance, budget, and dependencies. |
| **2. Architecture Design** | Create a cloud‑native blueprint. | Choose cloud provider(s), design high‑availability zones, network topology, security boundaries, and data stores. Document with diagrams. |
| **3. IaC Tool Selection** | Pick the right provisioning tool. | Multi‑cloud → Terraform or Pulumi. AWS‑only → Terraform, AWS CDK, or CloudFormation. |
| **4. Terraform Implementation** | Write reusable, modular code. | Create `modules/`, configure remote state, enable versioning, follow naming conventions. |
| **5. Kubernetes Deployment** | Deploy containers safely. | Write Helm charts or Kustomize overlays, store in Git, apply via GitOps (ArgoCD/Flux). |
| **6. CI/CD Pipeline** | Automate build, test, and release. | Use GitHub Actions, GitLab CI, or Jenkins. Include lint, unit tests, security scans, Terraform plan, and apply stages. |
| **7. Observability** | Gain insight into system health. | Configure metrics (Prometheus), logs (ELK or CloudWatch), tracing (OpenTelemetry), dashboards, and alerts. |
| **8. Security** | Protect assets and data. | Use secret managers, enforce least‑privilege IAM, scan IaC for drift, run static analysis, encrypt data at rest and in transit. |
| **9. Cost Optimization** | Control spend. | Tag resources, set budgets, right‑size instances, enable auto‑scaling, use spot/preemptible VMs where appropriate. |
| **10. Disaster Recovery** | Prepare for failures. | Define RTO/RPO, schedule backups, test failover, document runbooks. |

---

## 2. Decision Framework for Tool Selection
- **Multi‑cloud** → Terraform or Pulumi.
- **AWS only** → Terraform, AWS CDK, or CloudFormation.
- **Container orchestration** → Kubernetes (EKS, GKE, AKS).
- **Simple container hosting** → AWS ECS, Cloud Run, Azure App Service.
- **Configuration management** → Ansible or native cloud solutions.
- **GitOps** → ArgoCD or Flux.
- **CI/CD** → GitHub Actions, GitLab CI, Jenkins.

---

## 3. Terraform Best Practices
- Store state in a remote backend (e.g., S3 with DynamoDB lock). 
- Split code into reusable modules.
- Use `variables.tf` for inputs and `outputs.tf` for exported values.
- Run `terraform fmt` and `terraform validate` on every commit.
- Enforce `terraform plan` in CI and require approval before `apply`.
- Enable `-refresh-only` to detect drift.

```bash
# Initialise backend
terraform init -backend-config="bucket=my-tf-state" -backend-config="key=prod/terraform.tfstate"

# Validate syntax
terraform validate

# Show execution plan (CI step)
terraform plan -out=plan.out

# Apply after manual approval
terraform apply "plan.out"
```

## 4. Kubernetes Deployment Patterns
- Keep manifests declarative; store in Git.
- Use Helm charts for reusable applications.
- Separate environment overlays with Kustomize.
- Apply the principle of immutable infrastructure – replace pods instead of patching live.
- Protect the API server with RBAC and network policies.

```yaml
# Example Helm values.yaml (partial)
replicaCount: 3
image:
  repository: myapp/backend
  tag: "{{ .Chart.AppVersion }}"
service:
  type: LoadBalancer
  port: 80
resources:
  limits:
    cpu: "500m"
    memory: "256Mi"
  requests:
    cpu: "250m"
    memory: "128Mi"
```

Deploy with:
```bash
helm upgrade --install myapp ./chart -f values.yaml --namespace prod
```

---

## 5. CI/CD Pipeline Design (GitHub Actions Example)
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Lint Terraform
        run: terraform fmt -check
  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v3
      - name: Run Unit Tests
        run: ./run_tests.sh
  security:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - name: Scan IaC
        uses: bridgecrewio/checkov-action@v2
        with:
          directory: .
  plan:
    runs-on: ubuntu-latest
    needs: security
    steps:
      - uses: actions/checkout@v3
      - name: Terraform Init
        run: terraform init
      - name: Terraform Plan
        run: terraform plan -out=tfplan
      - name: Upload Plan
        uses: actions/upload-artifact@v3
        with:
          name: tfplan
          path: tfplan
  apply:
    runs-on: ubuntu-latest
    needs: plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3
      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
```

Key points:
- Lint before any other step.
- Run unit tests after lint.
- Perform security scanning on IaC.
- Require manual approval for `apply` in production (use environment protection rules).

---

## 6. Observability Setup
1. **Metrics** – Deploy Prometheus Operator; scrape application metrics.
2. **Logs** – Forward container logs to CloudWatch, Azure Monitor, or Elasticsearch.
3. **Tracing** – Instrument code with OpenTelemetry SDK; export to Jaeger or AWS X-Ray.
4. **Dashboards** – Create Grafana panels for latency, error rate, CPU, memory.
5. **Alerts** – Define SLO‑based alerts (e.g., error rate > 1% for 5 min).

---

## 7. Security Practices
- Store secrets in cloud secret managers (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager).
- Encrypt Terraform state at rest and in transit.
- Use IAM least‑privilege roles for CI runners.
- Scan IaC with tools like Checkov, tfsec, or Terrascan in CI.
- Enable SOPS to encrypt YAML/JSON files in Git.
- Apply network policies to restrict pod‑to‑pod traffic.
- Rotate credentials regularly.

---

## 8. Cost Optimization Checklist
- Tag every resource with `owner`, `environment`, and `project`.
- Set budget alerts in the cloud provider console.
- Right‑size instances based on utilization metrics.
- Use spot or preemptible instances for non‑critical workloads.
- Enable auto‑scaling for compute and databases.
- Review unused resources weekly and delete them.

---

## 9. Disaster Recovery Steps
1. Define RTO (Recovery Time Objective) and RPO (Recovery Point Objective).
2. Enable automated backups for databases and state stores.
3. Replicate critical data to a secondary region.
4. Test failover quarterly using a staged rollout.
5. Document runbooks with step‑by‑step recovery commands.
6. Train on‑call engineers on DR procedures.

---

## 10. Checklist
- [ ] Capture business, compliance, and scaling requirements.
- [ ] Produce architecture diagram and security zones.
- [ ] Choose IaC tool (Terraform) and configure remote backend.
- [ ] Write modular Terraform code; run `fmt`, `validate`, `plan` in CI.
- [ ] Create Helm chart or Kustomize overlay for each service.
- [ ] Set up GitOps repository and configure ArgoCD/Flux.
- [ ] Implement CI pipeline with lint, test, security scan, plan, and gated apply.
- [ ] Deploy Prometheus, Grafana, and log aggregation.
- [ ] Configure alerts based on SLIs/SLOs.
- [ ] Store secrets in cloud secret manager; encrypt repo files.
- [ ] Apply cost‑allocation tags and enable budget alerts.
- [ ] Document DR strategy, backup schedule, and runbooks.
- [ ] Conduct a post‑deployment review and capture lessons learned.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/github-actions.md](references/github-actions.md) | Creates and optimizes GitHub Actions workflows for CI/CD, testing, linting, deployment, security scanning, scheduled tasks, and other automation needs. |
| [references/kubernetes.md](references/kubernetes.md) | Expert Kubernetes architect for cloud-native infrastructure, GitOps workflows (ArgoCD, Flux), and enterprise orchestration. Use for cluster design, multi-cluster strategy, service mesh, and platform engineering. |

## Related skills

Load these when the task spans more than this skill.

- [`cloud-architecture`](references/cloud-architecture.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`docker`](references/docker.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`observability`](references/observability.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`cloudflare-deploy`](references/cloudflare-deploy.md) — Deploy applications and infrastructure to Cloudflare using Workers, Pages, and related services. Use this skil…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
| [references/docker.md](references/docker.md) | Optimizes Dockerfiles with multi-stage builds, BuildKit cache mounts, build-time secrets, and distroless images; hardens container security through non-root users, read-only filesystems, and capability dropping; configures production Docker Compose with healthchecks, resource limits, and override patterns; enables cross-platform builds via buildx. Use when writing Dockerfile, docker-compose.yml, .dockerignore, or buildx commands; debugging image bloat, slow builds, permission errors, CVE scans, OOM kills, or architecture mismatches; optimizing layer caching, reducing attack surface, injecting SSH keys or tokens at build time, or targeting linux/amd64 and linux/arm64 simultaneously. |
| [references/cloud-architecture.md](references/cloud-architecture.md) | Designs and optimizes cloud architectures across AWS, Azure, and GCP with secure, cost-effective, resilient patterns, IaC, FinOps, and DevOps integration. Use when planning cloud infrastructure, Terraform modules, AWS CDK constructs, serverless APIs, event-driven pipelines, service mesh, Kubernetes, VPC, IAM, cost optimization, multi-cloud, high availability, disaster recovery, or troubleshooting cloud deployment architecture. |
| [references/cloudflare-deploy.md](references/cloudflare-deploy.md) | Deploy applications and infrastructure to Cloudflare using Workers, Pages, D1, KV, R2, Vectorize, and AI Gateway via wrangler CLI or Terraform. Use when publishing code to Cloudflare Workers, configuring Pages builds, binding D1 databases, KV namespaces, R2 buckets, Vectorize indexes, setting up AI Gateway, managing DNS records, configuring Zero Trust tunnels, applying WAF rules, or running wrangler deploy, wrangler pages deploy, wrangler secret put, terraform apply for cloudflare provider. |
| [references/observability.md](references/observability.md) | This skill teaches production-grade observability: instrumenting metrics, logs, and traces; querying and visualizing with Datadog CLI and Grafana; defining SLOs and alerting rules. Use when you need to set up monitoring, create dashboards, configure alerts, investigate incidents, troubleshoot latency, debug errors, analyze traces, query logs, build SLO burn-rate alerts, design panels (stat, time-series, table), run datadog cli for triage, or architect observability for Kubernetes, microservices, or serverless. |
