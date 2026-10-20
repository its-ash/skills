---
name: data-engineering
description: "This skill designs, builds, and operates scalable batch and streaming data pipelines, modern data warehouses, and lakehouse architectures using Spark, dbt, Airflow, Kafka, Flink, and cloud data platforms. Use when you need ETL ELT pipeline development, real-time streaming ingestion, change data capture CDC, data modeling dimensional modeling, data quality testing with Great Expectations, performance tuning cost optimization, Airflow DAG orchestration, Spark job optimization, Kafka topic design, Flink stateful processing, lakehouse migration, warehouse schema evolution, data governance compliance, monitoring alerting setup, or DevOps CI/CD for data infrastructure."
---

# Data Engineering

Design, build, and operate robust data pipelines and modern analytics platforms. Focus on reliability, performance, security, and cost efficiency.

## When to Use
- You need a batch or streaming pipeline that processes large volumes of data.
- You are building a data warehouse, lakehouse, or data mesh.
- You must enforce data quality, lineage, or governance.
- You require automated orchestration, monitoring, and alerting for data workflows.

## Architecture Design Workflow
1. **Gather Requirements** – Identify data sources, latency targets, SLA, volume, and compliance needs.
2. **Define Data Contracts** – Document schema, data types, partitioning, and quality expectations.
3. **Select Storage** – Choose lake (S3, ADLS, GCS), warehouse (Snowflake, BigQuery, Redshift, Databricks SQL), or lakehouse (Delta Lake, Iceberg, Hudi).
4. **Choose Processing Engine** – Spark for batch/ELT, Flink/Kafka Streams for low‑latency streaming, dbt for transformation‑as‑code.
5. **Pick Orchestration** – Airflow, Prefect, Dagster, or cloud‑managed Composer/ADF for workflow management.
6. **Implement Ingestion** – Use connectors (Kafka, Kinesis, Pub/Sub, CDC tools) to bring data into the landing zone.
7. **Apply Transformations** – Write Spark jobs, dbt models, or Flink operators. Include idempotent logic for late‑arriving data.
8. **Validate Data** – Run Great Expectations suites or custom checks after each stage.
9. **Load to Destination** – Write to warehouse tables, lakehouse files, or real‑time analytics stores (Pinot, ClickHouse).
10. **Monitor & Alert** – Track latency, error rates, cost, and data quality metrics with Prometheus/Grafana or cloud monitoring.
11. **Document** – Store schema definitions, lineage, and runbooks in a catalog (DataHub, Atlas, Amundsen).

## Tool Selection Guide
| Category | Recommended Tools |
|---|---|
| **Storage** | AWS S3, Azure Data Lake Storage Gen2, Google Cloud Storage; Snowflake, BigQuery, Redshift, Databricks SQL |
| **Lakehouse** | Delta Lake, Apache Iceberg, Apache Hudi |
| **Batch Processing** | Apache Spark (PySpark/Scala), Databricks Runtime, AWS Glue, Azure Synapse, Google Dataflow |
| **Streaming** | Apache Kafka, Confluent, Pulsar, Kinesis, Pub/Sub, Flink, Kafka Streams |
| **Orchestration** | Apache Airflow, Prefect, Dagster, Azure Data Factory, AWS Step Functions, Cloud Composer |
| **Transformation** | dbt Core/Cloud, Great Expectations, SQL, Python/Polars |
| **Data Quality** | Great Expectations, custom validators |
| **Governance** | DataHub, Apache Atlas, Collibra, Azure Purview |
| **Infrastructure** | Terraform, CloudFormation, Docker, Kubernetes |
| **CI/CD** | GitHub Actions, GitLab CI, Jenkins |
| **Monitoring** | Prometheus, Grafana, ELK stack, CloudWatch, Azure Monitor |

## Pipeline Implementation Patterns
### 1. Batch ETL/ELT with Spark and dbt
```python
# spark_job.py
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName('etl').getOrCreate()
# Read raw data
raw = spark.read.format('json').load('s3://landing-zone/events/')
# Basic transformation
clean = raw.filter('status IS NOT NULL')
# Write to warehouse (Parquet on S3 for downstream dbt models)
clean.write.mode('overwrite').partitionBy('date').parquet('s3://processed/events/')
```
```yaml
# dbt model: models/events.sql
{{ config(materialized='incremental', unique_key='event_id') }}
SELECT * FROM {{ source('processed', 'events') }}
WHERE event_date >= (SELECT max(event_date) FROM {{ this }})
```
### 2. Real‑Time Streaming with Kafka and Flink
```java
// FlinkKafkaJob.java
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
FlinkKafkaConsumer<String> consumer = new FlinkKafkaConsumer<>(
    "events", new SimpleStringSchema(), properties);
DataStream<String> stream = env.addSource(consumer);
DataStream<Event> parsed = stream.map(json -> parse(json))
    .keyBy(Event::getUserId)
    .window(TumblingEventTimeWindows.of(Time.minutes(5)))
    .reduce((e1, e2) -> e1.merge(e2));
parsed.addSink(new BigQuerySink());
env.execute("Real‑time event pipeline");
```
### 3. Change Data Capture (CDC) to Warehouse
- Use Debezium connectors for MySQL/PostgreSQL → Kafka.
- Stream CDC topics into a Flink job that upserts into BigQuery using the Storage Write API.

## Data Modeling & Warehousing
- **Dimensional Modeling** – Star schema for reporting, snowflake schema for normalized dimensions.
- **Data Vault** – Hub, Link, Satellite tables for auditability and agility.
- **Slowly Changing Dimensions** – Use Type‑2 tables with effective dates; implement with dbt `snapshot`.
- **Partitioning** – Partition by ingestion date or high‑cardinality column; cluster on frequently filtered columns.
- **Incremental Loads** – Leverage watermark columns (`updated_at`) to load only changed rows.

## Data Quality & Governance
1. **Define Expectations** – Column types, nullability, range checks.
2. **Run Validation** – Execute Great Expectations suites after ingestion and transformation.
3. **Alert on Failures** – Send alerts to Slack or PagerDuty via Airflow on_failure callbacks.
4. **Catalog Metadata** – Register tables in DataHub with owners, tags, and lineage.
5. **PII Handling** – Mask or encrypt sensitive columns before storage; enforce row‑level security.

### Example Great Expectations Suite (Python)
```python
import great_expectations as ge
batch = ge.read_parquet('s3://processed/events/')
batch.expect_column_values_to_not_be_null('event_id')
batch.expect_column_values_to_be_in_set('event_type', ['click','view','purchase'])
batch.validate()
```

## Performance & Cost Optimization
- **Partition & Cluster** – Align partitions with query filters; use clustering for high‑cardinality filters.
- **Columnar Storage** – Store in Parquet/ORC with compression (snappy, zstd).
- **Auto‑Scaling** – Configure EMR Serverless or Databricks autoscaling clusters; use spot instances for non‑critical jobs.
- **Caching** – Materialized views or result caches for repeated analytics queries.
- **Cost Monitoring** – Tag resources; set budget alerts in AWS/GCP/Azure.

## Security & Compliance
- Encrypt data at rest (S3 SSE‑KMS, GCS CMEK) and in transit (TLS).
- Apply least‑privilege IAM policies for each service account.
- Implement row‑level security in warehouses (Snowflake RLS, BigQuery policy tags).
- Log all access events; forward to a SIEM.
- Conduct periodic GDPR/CCPA audits; anonymize PII where required.

## DevOps & Infrastructure
- **IaC** – Define storage buckets, IAM roles, and networking with Terraform.
- **Containerization** – Package Spark jobs or Flink tasks in Docker images.
- **CI/CD** – Build images, run unit tests, and deploy DAGs via GitHub Actions.
```yaml
# .github/workflows/ci.yml
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest tests/ -v --cov
  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t my-pipeline:latest .
      - name: Push DAGs to Airflow
        run: aws s3 cp dags/ s3://airflow-dags/ --recursive
```
- **Version Control** – Store dbt models, Spark scripts, and Airflow DAGs in Git.
- **Secrets Management** – Use AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault.

## Monitoring & Alerting
- Export metrics from Spark (`spark.metrics.conf`) and Airflow (`statsd`) to Prometheus.
- Create Grafana dashboards for pipeline latency, success rate, and cost.
- Set alerts for:
  * DAG failure > 1 occurrence in 5 min.
  * Data quality check failure rate > 0.5%.
  * Unexpected cost spikes (> 20% week‑over‑week).

## Common Pitfalls
- **Hard‑coded credentials** – Use secret stores instead.
- **Unbounded state in streaming jobs** – Enable checkpointing and state TTL.
- **Schema drift without versioning** – Enforce schema registry (Confluent Schema Registry) and backward compatibility.
- **Over‑partitioning** – Leads to small files and query overhead; balance partition granularity.
- **Missing idempotency** – Ensure retries do not duplicate records.
- **Neglecting data lineage** – Without lineage, impact analysis becomes impossible.

## Checklist
- [ ] Document data contracts, SLA, and compliance requirements.
- [ ] Choose storage and processing tools that match latency and volume.
- [ ] Implement ingestion with reliable connectors and CDC where needed.
- [ ] Write transformations as code (dbt, Spark) and store in Git.
- [ ] Add Great Expectations suites for every critical table.
- [ ] Register assets in a data catalog and define owners.
- [ ] Configure auto‑scaling and spot instances for cost control.
- [ ] Apply encryption, IAM least‑privilege, and row‑level security.
- [ ] Deploy DAGs and jobs via CI/CD pipelines.
- [ ] Set up Prometheus metrics, Grafana dashboards, and alerting rules.
- [ ] Conduct regular security and cost audits.

## Related skills

Load these when the task spans more than this skill.

- [`database-design`](../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-optimization`](../database-optimization/SKILL.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`cloud-architecture`](../cloud-architecture/SKILL.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`ml-engineering`](../ml-engineering/SKILL.md) — Guidance, best practices, and checklists for building production-grade machine-learning systems. Use for model…
- [`research-engineer`](../research-engineer/SKILL.md) — Research Engineer skill for rigorous, correctness-first engineering. Use when implementing algorithms, optimiz…
- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
