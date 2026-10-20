---
name: it-operations
description: "Manages IT infrastructure operations including monitoring, incident response, change management, capacity planning, and backup/recovery to maintain service reliability and uptime. Use when configuring Prometheus Grafana Datadog alerting, responding to PagerDuty Opsgenie pages, writing runbooks playbooks, conducting postmortems RCA, defining SLI SLO SLA targets, planning disaster recovery failover, executing change advisory board CAB requests, forecasting CPU memory disk capacity, automating remediation with Ansible Terraform, managing on-call rotations escalations, or implementing ITIL ITSM processes."
---

# IT Operations

This skill provides frameworks for managing IT infrastructure, ensuring service reliability, and maintaining operational excellence through automation and structured service management.

## When to use
- Implementing observability, monitoring, and alerting strategies.
- Managing incident response, root cause analysis, and post-mortems.
- Executing change management and capacity planning.
- Reducing operational toil through Infrastructure as Code (IaC) and automation.
- Aligning IT services with business objectives using ITIL frameworks.

## Core Principles

### Service Reliability
- **Proactive Monitoring**: Implement observability before incidents occur.
- **Incident Management**: Use structured response processes with clear escalation paths.
- **SLA/SLO Management**: Define service level objectives aligned with business needs.
- **Continuous Improvement**: Use blameless post-mortems to learn from failures.

### Automation
- **Infrastructure as Code**: Manage configuration through version-controlled code.
- **Runbook Automation**: Convert manual procedures into automated workflows.
- **Self-Healing**: Implement automated remediation for common, known issues.
- **Consistency**: Use configuration management to maintain environment parity.

### Operational Excellence
- **Documentation**: Maintain current runbooks, procedures, and architecture diagrams.
- **Knowledge Management**: Build searchable knowledge bases from incident resolutions.
- **Capacity Planning**: Forecast and provision resources proactively.
- **Cost Optimization**: Balance performance requirements with infrastructure costs.

## Operational Workflows

### 1. Monitoring & Observability
- Define SLIs/SLOs/SLAs for critical services.
- Implement metrics collection (infrastructure, application, business).
- Configure alerting with precise thresholds and escalation paths.
- Build dashboards for different audiences (ops, devs, executives).
- Establish on-call rotations.

### 2. Incident Management
- **Triage**: Receive alert, assess severity (P1-P4), and engage responders.
- **Resolution**: Investigate root cause, implement fix or workaround, and communicate status.
- **Closure**: Document resolution in the knowledge base and conduct a post-incident review.

### 3. Change Management
- **Request**: Submit change request with impact assessment and rollback plan.
- **Approval**: Review via Change Advisory Board (CAB) or automated policy.
- **Execution**: Schedule window, execute change, and validate success criteria.
- **Closure**: Document actual vs. planned results.

### 4. Capacity Planning
- Collect resource utilization trends and analyze growth patterns.
- Forecast future requirements and plan procurement/provisioning.
- Execute capacity additions and monitor effectiveness.

## Decision Frameworks

### Alert Configuration Matrix

| Scenario | Alert Type | Threshold | Response Time | Escalation |
| :--- | :--- | :--- | :--- | :--- |
| Service down | Page | Immediate | < 5 min | Immediate to on-call |
| Service degraded | Page | 2-3 failures | < 15 min | After 15 min to on-call |
| High resource usage | Warning | > 80% sustained | < 1 hour | After 2 hours to lead |
| Approaching capacity | Info | > 70% trend | < 24 hours | Weekly review |
| Config drift | Ticket | Any deviation | < 7 days | Monthly review |

### Incident Severity Classification

- **Priority 1 (Critical)**: Complete outage, data loss, or security breach. Immediate 24/7 response.
- **Priority 2 (High)**: Partial outage or significant degradation. Response < 30 min (business hours).
- **Priority 3 (Medium)**: Minor degradation, workaround available. Response < 4 hours (business hours).
- **Priority 4 (Low)**: Cosmetic issues or enhancement requests. Response next business day.

### Change Risk Assessment
`Risk Level = Impact (1-5) × Likelihood (1-5) × Complexity (1-5)`

- **1-20**: Standard change (pre-approved).
- **21-50**: Normal change (CAB review).
- **51-75**: High-risk change (extensive testing, senior approval).
- **76-125**: Emergency change (executive approval).

## Common Challenges & Solutions

### Alert Fatigue
- **Tuning**: Categorize alerts by actionability. Keep urgent/actionable as pages; move non-urgent to tickets; remove non-actionable.
- **Aggregation**: Group similar alerts to reduce noise.
- **Context**: Add runbook links and relevant metrics directly to the alert.
- **Metrics**: Target MTTA < 5 min and False Positive Rate < 20%.

### Knowledge Silos
- **Cross-Training**: Allocate 20% of capacity to pair programming or shadowing.
- **Mandatory Docs**: Require a runbook for every production system.
- **Rotation**: Rotate on-call duties across the entire team to spread knowledge.

### Stability vs. Innovation
- **Risk Mitigation**: Use blue-green or canary deployments.
- **Safe Spaces**: Create sandbox environments for experimentation.
- **Toil Reduction**: Set OKR targets specifically for reducing manual work.

## Key Metrics & KPIs

### Reliability Metrics
- **Availability**: `(Total Time - Downtime) / Total Time × 100` (Target: 99.9%+).
- **MTTR (Mean Time to Recovery)**: Average time to restore service. (Target: < 30m for P1).
- **MTBF (Mean Time Between Failures)**: Average time between incidents.
- **Change Success Rate**: `Successful changes / Total changes × 100` (Target: > 95%).

### Efficiency Metrics
- **Toil Percentage**: Time spent on manual, repetitive tasks (Target: < 30%).
- **Automation Coverage**: `Automated tasks / Total repetitive tasks × 100` (Target: > 70%).
- **Runbook Coverage**: Percentage of services with updated runbooks (Target: 100%).

## Best Practices

### Blameless Post-Mortems
- **Focus**: Analyze systems and processes, not individual people.
- **Template**: Include Incident Summary, Timeline, Root Cause (5 Whys), What Went Well, Improvements, and tracked Action Items.

### Runbook Standards
- **Contents**: Service overview, dependencies, SLIs/SLOs, troubleshooting steps, escalation paths, and copy-paste ready commands.
- **Maintenance**: Review quarterly or after every major incident.

### Change Management Discipline
- **Standard Process**: Request $\rightarrow$ Document (What, Why, When, Who, How, Risk, Rollback, Testing) $\rightarrow$ CAB Review $\rightarrow$ Implement $\rightarrow$ Validate $\rightarrow$ Close.
- **Emergency Process**: Executive approval $\rightarrow$ Implement with high monitoring $\rightarrow$ Document within 24 hours $\rightarrow$ Mandatory review.

## Checklist
- [ ] Are SLIs/SLOs defined and monitored for this service?
- [ ] Is there a version-controlled runbook for common failure modes?
- [ ] Does the change request include a tested rollback plan?
- [ ] Has a blameless post-mortem been scheduled for the recent P1/P2 incident?
- [ ] Is the current resource utilization within the forecasted capacity limits?

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`cloud-architecture`](../cloud-architecture/SKILL.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`security-compliance`](../security-compliance/SKILL.md) — Guides security and compliance work: risk assessment, control selection, framework mapping, ISMS implementatio…
- [`powershell`](../powershell/SKILL.md) — Provides Windows PowerShell best‑practice patterns: required parentheses for logical operators, ASCII‑only scr…
