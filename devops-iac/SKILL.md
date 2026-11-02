---
name: devops-iac
description: "Infrastructure as code: Terraform, Kubernetes, GitHub Actions CI/CD, GitOps, Helm, service mesh, observability, security, cost, disaster recovery. Use when writing terraform hcl, managing k8s clusters, building github actions yaml, configuring argocd or flux, deploying helm charts, setting up istio or linkerd, prometheus grafana, hardening compliance, cutting aws gcp azure costs, or planning backup restore. Sub-skills: github-actions, kubernetes, docker, cloud-architecture, cloudflare-deploy, observability, deployment-patterns, flox-environments, uncloud."
---

# DevOps IaC

Provision, deploy, and operate cloud infrastructure from code in Git.

## Core rules

- Work in phases: requirements (scale, compliance, budget, dependencies) -> architecture (regions, HA zones, network, security boundaries, data stores, diagram) -> IaC -> deploy -> CI/CD -> observability -> security -> cost -> DR.
- Keep all infrastructure and manifests declarative and in Git. Apply Kubernetes changes through GitOps.
- Use a remote, locked, encrypted Terraform state. Split code into modules.
- Run `fmt` + `validate` on every commit and `plan` in CI. Apply only a reviewed saved plan, gated by environment protection.
- Order CI stages: lint -> test -> IaC security scan -> plan -> gated apply.
- Treat infrastructure as immutable: replace pods and instances, do not patch live.
- Store secrets in a cloud secret manager; encrypt repo secrets with SOPS. Never commit plain secrets.
- Grant least-privilege IAM, also to CI runners. Restrict pod traffic with RBAC and network policies.
- Alert on SLOs, not on raw resource noise.
- Tag every resource with `owner`, `environment`, `project`; set budget alerts.
- Define RTO/RPO, automate backups, and test failover quarterly.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Multi-cloud | Terraform or Pulumi | Provider-native IaC per cloud |
| AWS only | Terraform, AWS CDK, or CloudFormation | Console click-ops |
| Container orchestration at scale | Kubernetes (EKS, GKE, AKS) | Self-managed control plane without need |
| Simple container hosting | ECS, Cloud Run, Azure App Service | Kubernetes for one small service |
| Small self-hosted cluster with Compose | Uncloud | Full Kubernetes |
| Edge apps, Workers, Pages | Cloudflare with wrangler | Generic VMs |
| Config management | Ansible or native cloud tools | Ad-hoc SSH scripts |
| GitOps | Argo CD or Flux | `kubectl apply` from laptops |
| CI/CD | GitHub Actions, GitLab CI, Jenkins | Manual deploys |
| Reusable app packaging / env differences | Helm chart / Kustomize overlays | Copy-pasted manifests |
| Infra drift suspected | `terraform plan -refresh-only` | Manual fixes in console |
| Non-critical batch workload | Spot or preemptible instances | On-demand by default |

## Load on demand

| Need | Read |
|---|---|
| Terraform rules, commands, IaC CI pipeline with gated apply | [terraform.md](references/terraform.md) |
| Observability setup steps, security, cost, DR, delivery checklist | [operations-checklist.md](references/operations-checklist.md) |
| GitHub Actions workflows: CI, tests, lint, deploy, scans, schedules | [github-actions.md](references/github-actions.md) |
| Cluster design, GitOps, mesh; Deployment, probes, RBAC, HPA, PDB, Jobs YAML; Helm values; kubectl debugging | [kubernetes.md](references/kubernetes.md) |
| Dockerfiles, multi-stage builds, Compose, BuildKit, hardening | [docker.md](references/docker.md) |
| AWS, Azure, GCP architecture, reliability, security, FinOps | [cloud-architecture.md](references/cloud-architecture.md) |
| Cloudflare Workers, Pages, D1, KV, R2 via wrangler | [cloudflare-deploy.md](references/cloudflare-deploy.md) |
| Metrics, logs, traces, SLO alerts, Grafana, Datadog CLI triage | [observability.md](references/observability.md) |
| Rolling, blue-green, canary; health checks; rollback; production readiness | [deployment-patterns.md](references/deployment-patterns.md) |
| Reproducible dev environments with Flox | [flox-environments.md](references/flox-environments.md) |
| Uncloud cluster with `uc` CLI | [uncloud.md](references/uncloud.md) |

## Related skills

- [`backend-development`](../backend-development/SKILL.md) - services and APIs that run on this infra
- [`secure-coding`](../secure-coding/SKILL.md) - secrets, auth, cloud security hardening
- [`git-workflow`](../git-workflow/SKILL.md) - branching and releases for GitOps repos
