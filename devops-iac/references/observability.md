# Observability

Design, query, and visualize production‑grade telemetry. This skill covers monitoring, logging, tracing, SLO/alerting, and dashboard creation with Datadog CLI and Grafana.

## When to use
- You need to investigate a production incident using logs, metrics, or traces.
- You must design or extend Grafana dashboards for infrastructure, applications, or business KPIs.
- You are defining SLIs/SLOs, alerts, and error‑budget policies.
- You are setting up or improving an observability stack (Prometheus, OpenTelemetry, Datadog, etc.).

---

## 1. Core Observability Concepts
| Concept | Goal | Typical Tool |
|---------|------|--------------|
| **Metrics** | Quantify system behavior over time. | Prometheus, Datadog, CloudWatch |
| **Logs** | Record discrete events with context. | ELK, Loki, Datadog Logs |
| **Traces** | Follow a request across services. | Jaeger, Zipkin, AWS X‑Ray, Datadog APM |
| **SLI / SLO** | Measure and commit to reliability targets. | Custom dashboards, alert policies |
| **Alerting** | Notify on SLO breach or abnormal behavior. | PagerDuty, Grafana alerts, Datadog monitors |

### Design Principles
1. **RED** for services – Rate, Errors, Duration.
2. **USE** for resources – Utilization, Saturation, Errors.
3. **Hierarchy of Information** – big numbers → trends → detailed tables.
4. **Signal‑to‑Noise** – collect only useful data, avoid high‑cardinality explosion.
5. **Observability as Code** – version dashboards, alerts, and collector configs.

---

## 2. Datadog CLI – Quick Incident Triage
> Install the CLI with `npx @leoflores/datadog-cli`. Set environment variables `DD_API_KEY` and `DD_APP_KEY`.

### Global Flags
- `--pretty` – colorized, human‑readable output.
- `--output <file>` – write JSON results.
- `--site <site>` – e.g., `datadoghq.eu` for EU region.
- Time formats: relative (`30m`, `1h`) or ISO‑8601.

### Common Commands
| Command | Use case |
|---------|----------|
| `logs search` | Find logs matching a query. |
| `logs tail` | Stream logs in real time. |
| `logs trace` | Show logs for a specific trace ID. |
| `logs context` | Get logs before/after a timestamp. |
| `logs patterns` | Group similar log messages. |
| `logs compare` | Compare log volume between periods. |
| `metrics query` | Run a PromQL‑like metric query. |
| `errors` | Summarize errors by service/type. |
| `services` | List services with recent log activity. |
| `dashboards` | CRUD operations on dashboards. |

### Incident Triage Workflow
```bash
# 1. Overview of recent errors
npx @leoflores/datadog-cli errors --from 1h --pretty

# 2. Is the error new? Compare to previous hour
npx @leoflores/datadog-cli logs compare \
    --query "status:error" --period 1h --pretty

# 3. Identify dominant error patterns
npx @leoflores/datadog-cli logs patterns \
    --query "status:error" --from 1h --pretty

# 4. Narrow by service
npx @leoflores/datadog-cli logs search \
    --query "status:error service:api" --from 1h --pretty

# 5. Get surrounding context for a timestamp
npx @leoflores/datadog-cli logs context \
    --timestamp "2024-01-15T10:30:00Z" --service api --pretty

# 6. Follow the distributed trace
npx @leoflores/datadog-cli logs trace \
    --id "TRACE_ID" --pretty
```

### Tips & Pitfalls
- **Use facets** (`service:`, `host:`, `status:`) to limit result size.
- **Avoid `*` queries** on high‑traffic services; they can time out.
- **Export large result sets** with `--output file.json` for offline analysis.
- **Combine queries** with `logs multi` to run several searches in parallel.

---

## 3. Grafana Dashboard Design
> Grafana visualizes metrics from Prometheus, Loki, InfluxDB, etc. Store dashboards as JSON and provision them via Terraform or Ansible.

### Dashboard Structure
1. **Critical Metrics** – big numbers (stat panels).
2. **Key Trends** – time‑series graphs.
3. **Detailed Views** – tables, heatmaps, or drill‑down panels.

### Common Panel Types
#### Stat Panel (single value)
```json
{
  "type": "stat",
  "title": "Total Requests",
  "targets": [{"expr": "sum(http_requests_total)"}],
  "options": {"colorMode": "value"},
  "fieldConfig": {
    "defaults": {
      "thresholds": {"mode": "absolute","steps": [{"value": 0,"color": "green"},{"value": 80,"color": "yellow"},{"value": 90,"color": "red"}]}
    }
  }
}
```
#### Time‑Series Graph
```json
{
  "type": "graph",
  "title": "CPU Usage",
  "targets": [{"expr": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"}],
  "yaxes": [{"format": "percent","max": 100,"min": 0},{"format": "short"}]
}
```
#### Table Panel
```json
{
  "type": "table",
  "title": "Service Status",
  "targets": [{"expr": "up","format": "table","instant": true}],
  "transformations": [{"id": "organize","options": {"renameByName": {"instance": "Instance","job": "Service","Value": "Status"}}}]
}
```
#### Heatmap
```json
{
  "type": "heatmap",
  "title": "Latency Heatmap",
  "targets": [{"expr": "sum(rate(http_request_duration_seconds_bucket[5m])) by (le)","format": "heatmap"}],
  "yAxis": {"format": "s"},
  "dataFormat": "tsbuckets"
}
```

### Variables for Flexibility
```json
{
  "templating": {
    "list": [
      {"name": "namespace","type": "query","datasource": "Prometheus","query": "label_values(kube_pod_info, namespace)"},
      {"name": "service","type": "query","datasource": "Prometheus","query": "label_values(kube_service_info{namespace=\"$namespace\"}, service)"}
    ]
  }
}
```
Use variables in queries, e.g.
```
sum(rate(http_requests_total{namespace="$namespace",service=~"$service"}[5m]))
```

### Alert Example (Grafana UI JSON)
```json
{
  "alert": {
    "name": "High Error Rate",
    "conditions": [{
      "evaluator": {"type": "gt","params": [5]},
      "operator": {"type": "and"},
      "query": {"params": ["A", "5m", "now"]},
      "reducer": {"type": "avg"},
      "type": "query"
    }],
    "for": "5m",
    "frequency": "1m",
    "message": "Error rate > 5%",
    "notifications": [{"uid": "slack-channel"}]
  }
}
```

### Provisioning as Code
#### Terraform
```hcl
resource "grafana_dashboard" "api_monitoring" {
  config_json = file("${path.module}/dashboards/api-monitoring.json")
  folder      = grafana_folder.monitoring.id
}

resource "grafana_folder" "monitoring" {
  title = "Production Monitoring"
}
```
#### Ansible
```yaml
- name: Deploy Grafana dashboards
  copy:
    src: "{{ item }}"
    dest: /etc/grafana/dashboards/
  with_fileglob:
    - "dashboards/*.json"
  notify: restart grafana
```

### Best Practices
1. Start from community templates; adapt names and units.
2. Keep panel titles concise and include units.
3. Use consistent color palettes across dashboards.
4. Set sensible default time range (e.g., last 6 h).
5. Document each variable and panel purpose.
6. Add thresholds that match SLO targets.
7. Test panels with both recent and historic data.

---

### Build Dashboards From Operator Questions
Use this method for Grafana, SigNoz, or a similar platform. A dashboard must answer four questions: Is it healthy? Where is the bottleneck? What changed? What must the operator do?

**Guardrails**
- Start from operator questions, not from the visual layout.
- Do not add a metric only because it exists.
- Do not mix health, throughput, and resource panels with no structure.
- Each panel has a title, a unit, and correct thresholds.

**Steps**
1. Define the questions: health/availability, latency, throughput, saturation, and service-specific risk.
2. Study the platform schema in the existing dashboards: JSON structure, query language, variables, threshold styles, and section layout.
3. Build the minimum useful board in this order: overview, performance, resources, service-specific section.
4. Remove vanity panels. If a panel does not answer a real question, delete it.

**Example panel sets**
| Service | Panels |
|---------|--------|
| Elasticsearch | Cluster health, shard allocation, search latency, indexing rate, JVM heap / GC |
| Kafka | Broker count, under-replicated partitions, messages in/out, consumer lag, disk and network pressure |
| API gateway / ingress | Request rate, p50/p95/p99 latency, error rate, upstream health, active connections |

**Quality checklist**
- [ ] Dashboard JSON is valid.
- [ ] Sections are grouped clearly.
- [ ] Titles and units are present.
- [ ] Threshold and status colors have meaning.
- [ ] Variables exist for common filters.
- [ ] Default time range and refresh are correct for the use.
- [ ] No vanity panels.

## 4. End‑to‑End Observability Workflow
1. **Identify Critical Paths** – list user journeys, services, and reliability targets (e.g., 99.9 % API availability).
2. **Define Signals** – decide which metrics, logs, and traces are needed for each path.
3. **Instrument** – use OpenTelemetry auto‑instrumentation or language‑specific SDKs to emit data.
4. **Collect & Store** – route telemetry to Prometheus (metrics), Loki/ELK (logs), Jaeger/Datadog (traces).
5. **Create SLI / SLO** – e.g., SLI = `request_success_rate = 1 - (error_requests / total_requests)`. Define SLO = 99.9 % over 30 days.
6. **Build Dashboards** – follow the hierarchy; include a stat panel for the SLO burn rate.
7. **Configure Alerts** – fire when burn rate > 20 % of the error budget or when a RED metric exceeds thresholds.
8. **Validate** – simulate failures (Chaos Monkey) and verify alerts fire and dashboards update.
9. **Iterate** – tune sampling rates, retention policies, and alert thresholds to reduce noise.

### Alert Noise Reduction Tips
- **Multi‑dimensional suppression** – require both error rate and latency increase before firing.
- **Rate‑limit alerts** – use `for: 5m` to avoid flapping.
- **Group related alerts** – send a single notification with a list of affected services.
- **Use severity levels** – critical vs. warning based on impact.

---

## 5. Checklist for a Production‑Ready Observability Setup
- [ ] Export `DD_API_KEY` and `DD_APP_KEY` (if using Datadog).
- [ ] Install Datadog CLI (`npx @leoflores/datadog-cli`).
- [ ] Verify Prometheus targets are up and scraping.
- [ ] Deploy OpenTelemetry Collector with exporters for metrics, logs, traces.
- [ ] Define at least one SLI per critical service.
- [ ] Create Grafana dashboards with:
  - Stat panel for SLO compliance.
  - Time‑series for RED metrics.
  - Table or heatmap for detailed view.
  - Variables for namespace/service.
- [ ] Add alerts for:
  - SLO breach (error‑budget burn rate).
  - Sudden spikes in error rate or latency.
  - Resource saturation (CPU > 80 %).
- [ ] Configure notification channels (PagerDuty, Slack).
- [ ] Document runbooks for each alert type.
- [ ] Test alerting paths with a controlled failure.
- [ ] Review data retention policies to balance cost vs. compliance.
- [ ] Ensure no sensitive data is logged (PII redaction).
- [ ] Version control all dashboard JSON and Terraform/Ansible manifests.

---

## 6. References & Further Reading
- Datadog Log & Metric Query Syntax – official docs.
- Grafana Dashboard Design Guide – community best practices.
- Google SRE Book – SLI/SLO methodology.
- OpenTelemetry Collector Configuration – vendor‑agnostic pipeline.
- Prometheus Recording Rules – pre‑compute common aggregates.

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`cloud-architecture`](cloud-architecture.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`systematic-debugging`](../../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`performance`](../../web-quality-audit/references/performance.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
