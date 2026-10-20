---
name: workflow-automation
description: "Design and deploy reliable workflow automation using n8n, Zapier, Make, and durable engines like Temporal or Inngest to orchestrate webhooks, REST and GraphQL APIs, scheduled cron jobs, ETL pipelines, database transactions, and multi-step AI agent chains with retries, idempotency keys, and observability. Use when building webhook receivers, syncing SaaS data via API, scheduling recurring tasks, transforming CSV JSON SQL data, chaining LLM calls with tools, implementing saga patterns, configuring Zapier Make n8n nodes, debugging failed executions, adding dead-letter queues, or migrating from brittle cron scripts to durable workflows."
---

# Workflow Automation

This skill provides architectural patterns and implementation guidelines for building reliable automations across no-code and code-based platforms. It focuses on moving from brittle scripts to production-grade durable execution.

## When to use
- **n8n**: When you need a self-hosted, node-based visual builder with strong AI agent integration.
- **Zapier**: When you need maximum app integrations (7,000+) and simple, fast setup.
- **Make (Integromat)**: When you need complex branching, advanced data transformation, and better cost-efficiency than Zapier.
- **Temporal / Inngest**: When you require "durable execution" for critical business processes (e.g., payments) where workflows must resume exactly where they left off after a failure.

## Core Workflow Patterns

### 1. Webhook Processing
Receive external HTTP requests and trigger immediate actions.
- **Pattern**: Webhook $\rightarrow$ Validate $\rightarrow$ Transform $\rightarrow$ Respond/Notify.
- **Use Case**: Stripe payment notifications, GitHub webhooks, form submissions.

### 2. HTTP API Integration
Fetch data from REST APIs and synchronize it with other services.
- **Pattern**: Trigger $\rightarrow$ HTTP Request $\rightarrow$ Transform $\rightarrow$ Action $\rightarrow$ Error Handler.
- **Use Case**: Fetching GitHub issues to create Jira tickets.

### 3. Database Operations / ETL
Read, write, or sync data between databases on a schedule.
- **Pattern**: Schedule $\rightarrow$ Query $\rightarrow$ Transform $\rightarrow$ Write $\rightarrow$ Verify.
- **Use Case**: Syncing Postgres records to MySQL every 15 minutes.

### 4. AI Agent Workflow
AI agents equipped with tools, memory, and reasoning capabilities.
- **Pattern**: Trigger $\rightarrow$ AI Agent (Model + Tools + Memory) $\rightarrow$ Output.
- **Use Case**: A chatbot that can search documentation, query a database, and send emails.

### 5. Scheduled Tasks
Recurring automation for reports or maintenance.
- **Pattern**: Schedule $\rightarrow$ Fetch $\rightarrow$ Process $\rightarrow$ Deliver $\rightarrow$ Log.
- **Use Case**: Daily analytics summaries emailed to a team.

## Advanced Orchestration Patterns

- **Sequential**: Steps execute in order; output of step $N$ is input for $N+1$.
- **Parallel**: Independent steps run simultaneously; results are aggregated at a merge node.
- **Orchestrator-Worker**: A central coordinator dispatches specific tasks to specialized worker nodes/services.
- **Loop/Batch**: Using "Split in Batches" to process large datasets in chunks to avoid timeouts or API rate limits.

## Implementation Rules

### Reliability & Durable Execution
- **Idempotency**: Always use idempotency keys for external API calls to prevent duplicate actions during retries.
- **Timeouts**: Set explicit timeouts on all activities and HTTP requests.
- **Backoff**: Use exponential backoff for retrying failed API calls.
- **Checkpointing**: Break long, complex workflows into smaller, checkpointed steps.
- **Side Effects**: In durable execution (Temporal/Inngest), never put side effects (like random numbers or current time) directly in workflow code; wrap them in activities.

### No-Code Best Practices (Zapier/Make/n8n)
- **Dropdowns over Text**: Always use dropdown selectors for app fields; never type IDs or names manually to avoid breaking on updates.
- **Data Access**: In n8n webhooks, access payload data via `{{$json.body.field}}` rather than `{{$json.field}}`.
- **Execution Order**: Use connection-based execution (v1) rather than top-to-bottom (v0) in n8n.
- **Credential Management**: Store credentials in the platform's dedicated credential manager; never hardcode API keys in parameters.

## Pitfalls and Anti-Patterns

| Anti-Pattern | Risk | Solution |
| :--- | :--- | :--- |
| **Monolithic Workflows** | Hard to debug and maintain | Break into sub-workflows or modular steps |
| **No Error Handling** | Silent failures in production | Use Error Trigger nodes or `onFailure` handlers |
| **Hardcoded Values** | Brittle workflows that break on env change | Use environment variables or configuration tables |
| **Large Data in Workflow** | Memory exhaustion/timeouts | Pass references (IDs) instead of full objects |
| **No Observability** | Impossible to trace failures | Implement centralized logging and execution monitoring |

## Workflow Creation Checklist

### Planning
- [ ] Identify the primary pattern (Webhook, API, DB, AI, Scheduled).
- [ ] Map the data flow: Input $\rightarrow$ Transformation $\rightarrow$ Output.
- [ ] Define the error handling strategy (Retry, Alert, or Stop).

### Implementation
- [ ] Configure trigger and authentication/credentials.
- [ ] Implement transformation logic (Set, Code, IF/Switch).
- [ ] Add output/action nodes.
- [ ] Set "Continue on Fail" or Error Trigger nodes for critical paths.

### Validation & Deployment
- [ ] Test with sample data and edge cases (e.g., empty payloads).
- [ ] Validate node configurations and workflow structure.
- [ ] Activate and monitor the first few live executions.
- [ ] Document the purpose and data flow in the workflow notes.

## Related skills

Load these when the task spans more than this skill.

- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`background-jobs`](../background-jobs/SKILL.md) — Provides guidance for implementing reliable background jobs in Node.js/TypeScript using BullMQ, Trigger.dev, o…
- [`data-engineering`](../data-engineering/SKILL.md) — Guides the design, implementation, and operation of scalable batch and streaming data pipelines, modern data w…
- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`speech-audio`](../speech-audio/SKILL.md) — Skill for robust speech‑audio processing: transcribe audio (Whisper or OpenAI API, with optional diarization)…
- [`medical-device-quality`](../medical-device-quality/SKILL.md) — Manage medical device quality documentation and ISO 14971 risk management across the product lifecycle. Use fo…
