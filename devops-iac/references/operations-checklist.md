# Operations: Observability, Security, Cost, DR, Checklist

Parent: [`devops-iac`](../SKILL.md). Deep observability: [observability.md](observability.md). Rollout and readiness: [deployment-patterns.md](deployment-patterns.md).

## Observability setup

1. Metrics: Prometheus Operator; scrape app metrics.
2. Logs: forward container logs to CloudWatch, Azure Monitor, or Elasticsearch.
3. Traces: OpenTelemetry SDK; export to Jaeger or AWS X-Ray.
4. Dashboards: Grafana panels for latency, error rate, CPU, memory.
5. Alerts: SLO-based (e.g. error rate > 1% for 5 min).

## Security

- Secrets in a cloud secret manager (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager).
- Encrypt YAML/JSON secrets in Git with SOPS.
- Least-privilege IAM, also for CI runners. Rotate credentials on a schedule.
- Scan IaC in CI (Checkov, tfsec, Terrascan); detect drift.
- Network policies restrict pod-to-pod traffic; RBAC on the API server.
- Encrypt data at rest and in transit.

## Cost

- Tag every resource: `owner`, `environment`, `project`.
- Budget alerts in the provider console.
- Right-size from utilization metrics; auto-scale compute and databases.
- Spot/preemptible instances for non-critical workloads.
- Review and delete unused resources weekly.

## Disaster recovery

1. Define RTO and RPO.
2. Automate backups for databases and state stores.
3. Replicate critical data to a second region.
4. Test failover quarterly with a staged rollout.
5. Write runbooks with exact recovery commands.
6. Train on-call engineers on DR steps.

## Delivery checklist

- [ ] Business, compliance, scale requirements captured.
- [ ] Architecture diagram with security zones.
- [ ] IaC tool chosen; remote backend configured.
- [ ] Modular Terraform; `fmt`, `validate`, `plan` in CI.
- [ ] Helm chart or Kustomize overlay per service.
- [ ] GitOps repo with Argo CD or Flux.
- [ ] CI: lint, test, security scan, plan, gated apply.
- [ ] Prometheus, Grafana, log aggregation deployed.
- [ ] Alerts on SLIs/SLOs.
- [ ] Secrets in a secret manager; repo files encrypted.
- [ ] Cost tags and budget alerts.
- [ ] DR strategy, backup schedule, runbooks documented.
- [ ] Post-deployment review with lessons learned.
