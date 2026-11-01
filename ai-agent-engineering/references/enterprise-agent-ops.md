# Enterprise Agent Ops

Operational controls for long-lived or cloud-hosted agent systems: lifecycle, observability, safety scopes, and change management.

## When to use

- You run a production agent fleet on PM2, systemd, or containers.
- The agents need monitoring, incident response, kill switches, or deployment gates.
- The system runs continuously, not as single CLI sessions.

## Operational Domains

1. runtime lifecycle (start, pause, stop, restart)
2. observability (logs, metrics, traces)
3. safety controls (scopes, permissions, kill switches)
4. change management (rollout, rollback, audit)

## Baseline Controls

- immutable deployment artifacts
- least-privilege credentials
- environment-level secret injection
- hard timeout and retry budgets
- audit log for high-risk actions

## Metrics to Track

- success rate
- mean retries per task
- time to recovery
- cost per successful task
- failure class distribution

## Incident Pattern

When failure spikes:
1. freeze new rollout
2. capture representative traces
3. isolate failing route
4. patch with smallest safe change
5. run regression + security checks
6. resume gradually

## Deployment Integrations

Use with:
- PM2 workflows
- systemd services
- container orchestrators (`devops-iac/references/kubernetes.md`)
- CI/CD gates (`devops-iac/references/github-actions.md`)
- metrics, logs, and traces (`devops-iac/references/observability.md`)
- security controls (`references/agent-security-hardening.md`)
