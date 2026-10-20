---
name: background-jobs
description: "Implements production-grade background job processing in Node.js and TypeScript using BullMQ, Trigger.dev, or Inngest covering platform selection, Redis setup, worker configuration, job retries with exponential backoff, concurrency limits, cron scheduling, idempotency keys, dead letter queues, and deployment checklists. Use when adding async task queues, delayed execution, scheduled cron jobs, worker pools, rate limiting, webhook handlers, email sending, report generation, image processing, database cleanup, or migrating from setTimeout to durable Redis-backed BullMQ queues, serverless Trigger.dev tasks, or event-driven Inngest functions with TypeScript type safety."
---

# Background Jobs

Use this skill to design, implement, and operate reliable background processing in Node.js or TypeScript. Choose the right tool—BullMQ, Trigger.dev, or Inngest—based on infrastructure control, scaling needs, and developer experience.

## When to use
- You need to off‑load work from the request thread (email, image processing, AI calls).
- The work may run for seconds, minutes, or days.
- You need retries, back‑off, rate limiting, or job dependencies.
- You prefer:
  - **BullMQ**: self‑hosted Redis, fine‑grained control, high throughput.
  - **Trigger.dev**: managed TypeScript‑first task service with built‑in integrations.
  - **Inngest**: serverless step‑function style workflows, no worker management.

## Choose a platform
| Platform | Best for | Key characteristics |
|----------|----------|--------------------|
| **BullMQ** | Teams that already run Redis and want full control over queues, concurrency, and job lifecycles. | Requires a Redis instance, explicit worker processes, supports priorities, rate limits, dead‑letter queues. |
| **Trigger.dev** | Projects that want a managed service, automatic retries, and a rich library of integrations (e.g., OpenAI, Stripe). | Runs tasks in the cloud, uses a `trigger.config.ts` file, provides UI for monitoring, requires internet connectivity to Trigger.dev. |
| **Inngest** | Serverless applications that prefer event‑driven step functions without managing workers. | Deploys as serverless functions, each step is a checkpoint, built‑in scheduling and fan‑out. |

---

## BullMQ
### Installation
```bash
npm i bullmq ioredis
```
### Core setup
```ts
import { Queue, Worker, QueueEvents } from 'bullmq';
import IORedis from 'ioredis';

const connection = new IORedis({ host: 'localhost', port: 6379 });

// Queue definition
const emailQueue = new Queue('email', { connection, defaultJobOptions: {
  attempts: 5,
  backoff: { type: 'exponential', delay: 60000 },
  removeOnComplete: true,
}});

// Worker definition
const emailWorker = new Worker('email', async job => {
  // job.data must be a plain object
  await sendEmail(job.data);
}, { connection, concurrency: 10 });

// Event listener for failures
const events = new QueueEvents('email', { connection });
await events.on('failed', ({ jobId, failedReason }) => {
  console.error(`Job ${jobId} failed: ${failedReason}`);
});
```
### Common patterns
- **Delayed job**: `emailQueue.add('send', payload, { delay: 5 * 60 * 1000 });`
- **Repeatable job**: `emailQueue.add('dailyReport', payload, { repeat: { cron: '0 6 * * *' } });`
- **Priority**: `emailQueue.add('urgent', payload, { priority: 1 });`
- **Rate limiting**: `emailQueue.add('rateLimited', payload, { limiter: { max: 100, duration: 60000 } });`
- **Job dependencies**: Use `FlowProducer` to create parent‑child relationships.
- **Dead‑letter queue**: Create a separate queue and move failed jobs with `job.moveToFailed` and a custom handler.
### Rules & pitfalls
- Keep payload < 100 KB. Store large data in Redis, S3, or a database and reference it by ID.
- Set `concurrency` to a realistic number; infinite concurrency can overload Redis and downstream services.
- Always define `attempts` and `backoff` to avoid silent job loss.
- Monitor the queue with `QueueEvents` or a UI (e.g., Bull Board).
- Use plain JSON objects; functions or class instances break serialization.

---

## Trigger.dev
### Installation
```bash
npm i @trigger.dev/sdk
# Install the CLI globally for local development
npm i -g @trigger.dev/cli
```
### Configuration file (`trigger.config.ts`)
```ts
import { defineConfig } from '@trigger.dev/sdk';

export default defineConfig({
  apiKey: process.env.TRIGGER_API_KEY!,
  // Set a global concurrency limit for all tasks
  concurrency: 20,
});
```
### Defining a task
```ts
import { task } from '@trigger.dev/sdk';
import { openai } from '@trigger.dev/openai'; // built‑in integration

export const summarizeArticle = task({
  id: 'summarize-article',
  // Timeout in seconds; required to avoid runaway tasks
  timeout: 300,
  // Retries on failure; idempotent operations are recommended
  retries: 3,
}, async ({ payload, ctx }) => {
  // payload must be a plain object
  const { url } = payload;
  const content = await fetch(url).then(r => r.text());
  const summary = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [{ role: 'user', content }],
  });
  // Use idempotency key to avoid duplicate side effects
  await ctx.idempotent(() => saveSummary(url, summary));
});
```
### Scheduling a task (cron)
```ts
import { schedule } from '@trigger.dev/sdk';

schedule('daily-cleanup', '0 2 * * *', async () => {
  await cleanOldRecords();
});
```
### Rules & pitfalls
- **Payload must be serializable**: only plain objects, numbers, strings, booleans, arrays, and `null`.
- **Explicit timeouts**: avoid the default “kill after 30 s” behavior.
- **Idempotency**: wrap side‑effects with `ctx.idempotent` or provide a unique key.
- **Environment variables**: sync them in the Trigger.dev dashboard; missing vars cause runtime errors.
- **SDK version alignment**: keep CLI and package versions identical to prevent protocol mismatches.
- **Concurrency limits**: set `concurrency` in `trigger.config.ts` to protect downstream APIs.
- **Logging**: use `ctx.logger` for structured logs; the UI surfaces logs automatically.

---

## Inngest
### Installation
```bash
npm i inngest
```
### Defining a function with steps
```ts
import { Inngest } from 'inngest';

export const inngest = new Inngest({ id: 'my-app' });

export const processUpload = inngest.createFunction(
  { name: 'process-upload', trigger: { event: 'file/uploaded' } },
  async ({ event, step }) => {
    // Step 1: download file
    const file = await step.run('download', async () => {
      return await fetch(event.data.url).then(r => r.buffer());
    });

    // Step 2: run AI analysis (could be long‑running)
    const analysis = await step.run('analyze', async () => {
      return await runAIModel(file);
    });

    // Step 3: store result
    await step.run('store', async () => {
      await saveResult(event.data.id, analysis);
    });
  }
);
```
### Scheduled (cron) function
```ts
export const dailyReport = inngest.createFunction(
  { name: 'daily-report', trigger: { cron: '0 6 * * *' } },
  async ({ step }) => {
    await step.run('generate', async () => generateReport());
    await step.run('email', async () => sendReportEmail());
  }
);
```
### Rules & pitfalls
- **Always use steps**: each `step.run` creates a checkpoint that survives crashes.
- **Payload size**: event payloads should stay under 100 KB; store large blobs elsewhere and reference them.
- **Concurrency control**: set `concurrency` in the function definition or via the dashboard to avoid overwhelming downstream services.
- **Error handling**: throw errors inside a step to trigger automatic retries based on the function’s `retries` setting.
- **Idempotency**: design each step to be safe to run multiple times; use deterministic IDs.

---

## Common Rules for All Background Job Systems
- **Small, serializable payloads** – keep data under 100 KB and use plain JSON.
- **Idempotent operations** – make side‑effects repeatable without adverse effects.
- **Explicit retries & back‑off** – configure attempts, delay strategy, and maximum retry count.
- **Dead‑letter handling** – route permanently failed jobs to a separate queue or log for manual inspection.
- **Concurrency limits** – set a realistic maximum to protect databases, APIs, and rate‑limited services.
- **Structured logging** – include job ID, type, start/end timestamps, and error details.
- **Monitoring** – expose metrics (queue length, processing time, failure rate) to Prometheus, Grafana, or the provider’s UI.
- **Testing** – simulate failures, timeouts, and payload corruption in a staging environment.

---

## Anti‑Patterns & Pitfalls
- **Giant job payloads** – store large files in external storage and pass a reference.
- **No dead‑letter queue** – lost jobs make debugging impossible.
- **Infinite or unbounded concurrency** – can crash Redis, exceed API rate limits, or cause OOM.
- **Monolithic tasks** – break long jobs into smaller steps or sub‑tasks.
- **Non‑serializable payloads** – functions, class instances, or circular references cause silent failures.
- **Missing environment sync** – cloud‑managed services need env vars mirrored locally.
- **Ignoring built‑in integrations** – re‑implementing existing connectors adds maintenance burden.
- **Using `wait.for` loops in Trigger.dev** – leads to memory leaks; batch work instead.

---

## Checklist for Production‑Ready Background Jobs
- [ ] Choose the appropriate platform (BullMQ, Trigger.dev, Inngest).
- [ ] Install the correct package versions and keep CLI in sync (if applicable).
- [ ] Create a plain‑object payload schema; validate with TypeScript or a runtime validator.
- [ ] Set explicit `attempts`, `backoff`, and `timeout` values.
- [ ] Configure a dead‑letter queue or error‑handling hook.
- [ ] Limit concurrency to a safe number for downstream services.
- [ ] Wrap side‑effects with idempotency logic (`ctx.idempotent`, step deduplication, or unique DB keys).
- [ ] Add structured logs at start, success, and failure of each job/task/step.
- [ ] Expose metrics for queue length, processing latency, and failure rate.
- [ ] Test failure scenarios: network errors, timeouts, payload corruption.
- [ ] Deploy environment variables to the provider’s dashboard (Trigger.dev) or ensure they are available to the worker process.
- [ ] Review and apply security best practices for Redis (TLS, auth) or serverless functions (least‑privilege IAM).

---

By following this guide, you can implement robust background processing that scales, recovers from failures, and remains observable regardless of whether you run your own Redis queues, use Trigger.dev’s managed task platform, or adopt Inngest’s serverless step functions.

## Related skills

Load these when the task spans more than this skill.

- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`php-laravel`](../php-laravel/SKILL.md) — Guidelines for writing idiomatic, high‑performance PHP 8+ code and building production‑grade Laravel applicati…
- [`ai-cli-delegation`](../ai-cli-delegation/SKILL.md) — Delegates user requests to AI command‑line tools (Gemini CLI or Codex CLI). Choose the appropriate model, sand…
