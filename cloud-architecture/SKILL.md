---
name: cloud-architecture
description: "Designs and optimizes cloud architectures across AWS, Azure, and GCP with secure, cost-effective, resilient patterns, IaC, FinOps, and DevOps integration. Use when planning cloud infrastructure, Terraform modules, AWS CDK constructs, serverless APIs, event-driven pipelines, service mesh, Kubernetes, VPC, IAM, cost optimization, multi-cloud, high availability, disaster recovery, or troubleshooting cloud deployment architecture."
---

# cloud-architecture

Design, build, and optimize cloud solutions that are secure, cost‑aware, and resilient. The skill covers AWS, Azure, and GCP, Infrastructure as Code, FinOps, and modern architectural patterns.

## When to use
- You need a new cloud environment or a major redesign.
- You are migrating workloads to one or more public clouds.
- You must reduce cost, improve performance, or meet compliance.
- You are adopting serverless, microservices, or event‑driven patterns.
- You require a multi‑cloud or hybrid‑cloud strategy.

## Workflow
1. **Gather requirements**
   - Business goals, traffic volume, latency, data residency, compliance.
2. **Select provider(s)**
   - Match services to workload characteristics.
   - Document reasons for multi‑cloud or hybrid choice.
3. **Choose architecture pattern**
   - Microservices, serverless, event‑driven, data lake, etc.
4. **Design network**
   - Create VPC/VNet, subnets, routing, and peering.
   - Reserve CIDR blocks for future growth.
5. **Define security**
   - Create IAM roles with least‑privilege permissions.
   - Enable encryption at rest and in transit.
   - Apply provider‑specific security baselines (AWS Config, Azure Policy, GCP Organization Policy).
6. **Plan resiliency**
   - Deploy across multiple Availability Zones or regions.
   - Define backup, snapshot, and point‑in‑time recovery.
   - Set RPO/RTO targets.
7. **Estimate cost and tag resources**
   - Use provider cost calculators.
   - Apply a mandatory tagging schema (e.g., `Environment`, `Owner`, `CostCenter`).
8. **Select IaC tool and structure**
   - Terraform/OpenTofu, CDK, Pulumi, ARM/Bicep, or CloudFormation.
   - Organize code into `modules/` and `environments/`.
9. **Implement CI/CD pipeline**
   - Include `plan`, `apply`, security scan (Checkov, OPA), and automated tests.
10. **Add observability**
    - Enable metrics, logs, tracing.
    - Configure alerts for cost spikes and security events.
11. **Validate**
    - Run integration tests (Terratest, InSpec).
    - Perform a DR drill.
12. **Document**
    - Architecture diagram, decision log, and run‑books.

## Rules & Decision Criteria
- **Least‑privilege IAM**: Grant only the actions required for each role.
- **Managed services first**: Prefer fully managed services to reduce operational overhead.
- **Multi‑AZ deployment**: Deploy critical resources in at least two AZs.
- **Spot/Preemptible for non‑critical workloads**: Use spot instances for batch jobs, dev environments, or fault‑tolerant services.
- **Tag‑all‑resources**: Enforce tagging at creation time; block untagged resources.
- **Encryption**: Enable default encryption for storage services; enforce TLS for all network traffic.
- **Well‑Architected Framework**: Follow the provider’s framework pillars (operational excellence, security, reliability, performance efficiency, cost optimization).
- **State storage**: Store IaC state in a versioned, locked backend (e.g., S3 + DynamoDB lock, Azure Storage with lease, GCS with object versioning).
- **Cost‑benefit threshold**: Only provision resources that improve performance by >10 % for a cost increase <15 %.
- **Latency budget for multi‑cloud data replication**: Keep end‑to‑end latency <500 ms for real‑time pipelines.

## Common Patterns
### Terraform module layout
```hcl
terraform {
  required_version = ">= 1.5"
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "envs/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
    encrypt        = true
  }
}

module "vpc" {
  source = "./modules/vpc"
  cidr   = var.vpc_cidr
}
```
### AWS CDK construct for a serverless API
```typescript
import * as cdk from 'aws-cdk-lib';
import { LambdaFunction } from 'aws-cdk-lib/aws-events-targets';
import * as apigw from 'aws-cdk-lib/aws-apigateway';
import * as lambda from 'aws-cdk-lib/aws-lambda';

export class ServerlessApi extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const fn = new lambda.Function(this, 'Handler', {
      runtime: lambda.Runtime.NODEJS_18_X,
      code: lambda.Code.fromAsset('lambda'),
      handler: 'index.handler',
    });

    new apigw.LambdaRestApi(this, 'Api', { handler: fn });
  }
}
```
### Event‑driven pipeline (AWS example)
- SNS topic → Lambda consumer → DynamoDB write.
- Use dead‑letter queue for failed events.
### Service mesh for microservices (Istio)
- Deploy Istio control plane.
- Define `VirtualService` and `DestinationRule` for each service.
- Apply mutual TLS for intra‑service traffic.

## Pitfalls to avoid
- Hard‑coding credentials or secrets in code.
- Over‑provisioning instances without right‑sizing analysis.
- Ignoring IAM policy scope; granting `*` permissions.
- Skipping encryption for storage buckets or databases.
- Forgetting to enable multi‑AZ for stateful services.
- Not applying cost tags; leads to untracked spend.
- Deploying IaC without a lock on the state backend; causes race conditions.
- Relying on a single region for disaster recovery.
- Missing automated security scans in the CI pipeline.

## Checklist
- [ ] Business and technical requirements documented.
- [ ] Cloud provider(s) selected with justification.
- [ ] Architecture diagram created (network, compute, data flow).
- [ ] VPC/VNet CIDR plan includes growth margin.
- [ ] IAM roles defined with least‑privilege permissions.
- [ ] Encryption enabled for all storage and transit.
- [ ] Multi‑AZ or multi‑region deployment planned.
- [ ] Backup and snapshot policies defined.
- [ ] Cost‑allocation tags added to every resource.
- [ ] IaC repository initialized with modules and environment folders.
- [ ] Remote state backend configured with locking.
- [ ] CI/CD pipeline includes `plan`, `apply`, security scan, and tests.
- [ ] Monitoring dashboards and alerts set for latency, error rate, and cost.
- [ ] DR run‑book written and scheduled for quarterly testing.
- [ ] Documentation of decisions, trade‑offs, and alternatives stored in version control.

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`security-compliance`](../security-compliance/SKILL.md) — Guides security and compliance work: risk assessment, control selection, framework mapping, ISMS implementatio…
- [`cloudflare-deploy`](../cloudflare-deploy/SKILL.md) — Deploy applications and infrastructure to Cloudflare using Workers, Pages, and related services. Use this skil…
- [`diagrams`](../diagrams/SKILL.md) — Skill for creating, editing, converting, and reviewing diagram files. Handles draw.io .drawio XML editing and…
