# Kubernetes Architecture and Orchestration

This skill provides expert guidance on designing, implementing, and managing enterprise-grade Kubernetes platforms. It focuses on cloud-native infrastructure, GitOps delivery, and scalable platform engineering.

## When to use
- Designing Kubernetes platform architecture or multi-cluster strategies.
- Implementing GitOps workflows and progressive delivery.
- Planning service mesh, security, or multi-tenancy patterns.
- Improving reliability, cost, or developer experience in K8s.
- Provisioning managed (EKS, AKS, GKE) or self-managed (kubeadm, kops) clusters.

## Workflow
1. **Requirements Gathering**: Identify workload requirements, compliance needs, and scale targets.
2. **Topology Design**: Define cluster topology, networking, and security boundaries.
3. **Delivery Strategy**: Choose GitOps tooling and rollout strategies (Canary, Blue/Green).
4. **Security Baseline**: Configure Pod Security Standards, RBAC, and Network Policies.
5. **Observability Setup**: Implement metrics, logging, and tracing stacks.
6. **Scalability Planning**: Configure HPA, VPA, and Cluster Autoscaler.
7. **Validation**: Test policy changes and admission controls in staging before production.

## Kubernetes Platform Patterns

### GitOps & Continuous Delivery
Follow OpenGitOps principles: Declarative, Versioned/Immutable, Pulled Automatically, and Continuously Reconciled.
- **Tools**: ArgoCD, Flux v2, Tekton.
- **Progressive Delivery**: Use Argo Rollouts or Flagger for canary deployments and A/B testing.
- **Repository Patterns**: Use App-of-apps or environment-specific overlays (Kustomize).
- **Secret Management**: Use External Secrets Operator, Sealed Secrets, or HashiCorp Vault.

### Infrastructure as Code (IaC)
- **K8s-native**: Helm 3.x, Kustomize, cdk8s, Pulumi.
- **Provisioning**: Terraform/OpenTofu, Cluster API.
- **Policy as Code**: OPA Gatekeeper, Kyverno, Falco.

### Cloud-Native Security
- **Pod Security**: Implement Restricted, Baseline, or Privileged policies based on workload.
- **Network**: Use Cilium (eBPF) or standard NetworkPolicies for micro-segmentation.
- **Supply Chain**: Implement image signing (Sigstore), SBOM generation, and vulnerability scanning.
- **Runtime**: Use Falco or Sysdig for threat detection.

### Service Mesh & Networking
- **Traffic Management**: Istio (advanced), Linkerd (lightweight), or Cilium.
- **Ingress**: Use the Kubernetes Gateway API for next-generation routing.
- **Connectivity**: Implement mTLS for service-to-service encryption.

### Observability Stack
- **Metrics**: Prometheus, VictoriaMetrics, Thanos (long-term storage).
- **Logging**: Fluent Bit, Loki.
- **Tracing**: OpenTelemetry, Jaeger.
- **Visualization**: Grafana.

### Resource & Cost Management
- **Autoscaling**: Use KEDA for event-driven scaling; HPA/VPA for resource-based scaling.
- **FinOps**: Use KubeCost or OpenCost for allocation; optimize via spot instances and right-sizing.
- **Multi-tenancy**: Use Namespace isolation, ResourceQuotas, and LimitRanges.

## Pitfalls and Safety
- **Production Changes**: Never apply changes to production without a validated rollback plan.
- **Admission Controllers**: Test new OPA/Kyverno policies in a non-blocking (audit) mode first.
- **Resource Limits**: Avoid omitting resource requests/limits, as this leads to node instability and unpredictable scheduling.
- **Stateful Workloads**: Ensure PersistentVolumes (PV) have appropriate StorageClasses and backup strategies (e.g., Velero).

## Checklist
- [ ] Are all manifests declarative and stored in version control?
- [ ] Is there a defined strategy for secret management (no plain-text secrets in Git)?
- [ ] Are NetworkPolicies configured to restrict traffic by default?
- [ ] Do all containers have CPU/Memory requests and limits defined?
- [ ] Is there a multi-region or multi-cluster disaster recovery plan (RTO/RPO)?
- [ ] Are Pod Security Standards enforced via an admission controller?
- [ ] Is the observability stack capturing metrics, logs, and traces for all critical paths?
