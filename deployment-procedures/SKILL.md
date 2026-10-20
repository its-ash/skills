---
name: deployment-procedures
description: "Provides a platform-agnostic procedure for safely deploying production services, covering pre-deployment checks, backup, rollout, verification, rollback, zero-downtime strategies, and emergency response. Use when deploying, releasing, shipping, promoting, or rolling out an app, service, container, API, or website to production, staging, or cloud environments; handling deploy failures, rollback, hotfix, canary, blue-green, health checks, smoke tests, incidents, and release checklists."
---

# Deployment Procedures

Use this guide to plan and execute a production release with minimal risk. Follow the steps, adapt them to your platform, and verify each phase before moving on.

## When to use
- Deploying a new version of a web site, API, or microservice.
- Updating database schemas or configuration files.
- Performing a hot‑fix or emergency rollback.
- Any change that will affect live users.

## Platform selection
Identify the target environment and choose the appropriate deployment method.

```
What are you deploying?
├─ Static site / JAMstack → Vercel, Netlify, Cloudflare Pages
├─ Simple web app
│   ├─ Managed service → Railway, Render, Fly.io
│   └─ Self‑hosted → VPS + PM2 or Docker
├─ Microservices → Container orchestration (Docker, Kubernetes)
└─ Serverless → Edge functions, AWS Lambda
```

| Platform | Typical method |
|----------|----------------|
| Vercel / Netlify | Git push → auto‑deploy |
| Railway / Render | Git push or CLI command |
| VPS + PM2 | SSH → pull code → restart |
| Docker | Build image → push → orchestrator |
| Kubernetes | `kubectl apply` or Helm |

## Pre‑deployment checks
Perform all checks before any code reaches production.

- **Code quality**: All tests pass, linting clean, code reviewed and approved.
- **Build**: Production build succeeds without warnings.
- **Environment**: Required environment variables and secrets are present and correct.
- **Safety**: Current state is backed up, and a rollback plan is documented.
- **Database**: Migration scripts are ready and tested in staging.
- **Team**: Stakeholders are notified and monitoring is enabled.

## Deployment workflow (5 phases)
Execute each phase in order. Do not skip or combine phases.

1. **Prepare** – Verify code, build, and environment.
2. **Backup** – Save the current application state, database dump, and configuration.
3. **Deploy** – Run the platform‑specific deployment command while watching logs.
4. **Verify** – Perform health‑check, review logs, and test key user flows.
5. **Confirm or rollback** – If verification succeeds, mark the release as successful; otherwise, initiate rollback immediately.

### Phase principles
- **Prepare**: Never deploy untested code.
- **Backup**: A rollback is impossible without a recent backup.
- **Deploy**: Keep a terminal open; watch for errors.
- **Verify**: Trust but verify every critical path.
- **Confirm**: Have a single, well‑defined rollback trigger.

## Post‑deployment verification
Monitor the release for the first hour and review metrics the next day.

- **Health endpoint** – Confirm the service returns `200 OK`.
- **Error logs** – Look for new stack traces or warnings.
- **Key flows** – Manually test the most important user journeys.
- **Performance** – Ensure response times are within the SLA.

**Verification timeline**
- 0‑5 min: Active monitoring, watch logs.
- 5‑15 min: Confirm stability, no new errors.
- 15‑60 min: Observe performance trends.
- Next day: Review dashboards and alert history.

## Rollback procedures
Rollback as soon as a critical issue is detected.

| Symptom | Action |
|---------|--------|
| Service down or crash | Rollback immediately |
| Critical runtime error | Rollback |
| Performance > 50 % degradation | Consider rollback |
| Minor UI glitch | Fix forward if quick |

### Platform‑specific rollback methods
- **Vercel / Netlify** – Redeploy the previous commit.
- **Railway / Render** – Use the dashboard “Rollback” button.
- **VPS + PM2** – Restore the backup, then restart the process.
- **Docker** – Deploy the previous image tag.
- **Kubernetes** – `kubectl rollout undo <deployment>`.

### Rollback principles
- Prioritize speed; debug after the service is stable.
- Perform only one rollback per incident.
- Communicate the action to the team immediately.
- Conduct a post‑mortem once the system is healthy.

## Zero‑downtime strategies
Choose a strategy that matches the risk level.

| Strategy | How it works |
|----------|--------------|
| Rolling update | Replace instances one at a time while keeping the old ones running.
| Blue‑green | Deploy to a parallel environment, then switch traffic.
| Canary | Route a small percentage of traffic to the new version, increase gradually.

**Selection guide**
- Standard release → Rolling update.
- High‑risk change → Blue‑green (easy rollback).
- Need real‑world validation → Canary.

## Emergency response
When the service is down, follow these steps quickly.

1. **Assess** – Identify the symptom (error, timeout, crash).
2. **Quick fix** – Restart the process or container if the cause is unclear.
3. **Rollback** – If restart does not restore service, roll back to the previous version.
4. **Investigate** – After stability, examine logs, resource usage, network, and dependencies.

**Investigation order**
- Logs → Look for exceptions.
- Resources → Check disk space, memory, CPU.
- Network → Verify DNS, firewall, and upstream connectivity.
- Dependencies → Confirm database and external APIs are reachable.

## Anti‑patterns to avoid
- Deploying on Fridays or before holidays.
- Rushing without completing the checklist.
- Skipping a staging environment.
- Deploying without a recent backup.
- Walking away immediately after the deploy command.
- Bundling multiple unrelated changes in one release.

## Checklist (run before every release)
- [ ] Platform‑specific deployment method selected?
- [ ] All tests pass and code is reviewed?
- [ ] Production build succeeded?
- [ ] Environment variables and secrets verified?
- [ ] Database migrations prepared and tested?
- [ ] Backup of current state completed?
- [ ] Rollback plan documented and accessible?
- [ ] Monitoring and alerting configured?
- [ ] Team and stakeholders notified?
- [ ] Post‑deployment verification window scheduled?

**Remember:** Risk is managed through preparation, not speed. Follow each step, verify continuously, and be ready to rollback at any moment.

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`cloud-architecture`](../cloud-architecture/SKILL.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
- [`java`](../java/SKILL.md) — Guidance, best practices, and checklists for modern Java 21+ development, covering language features, virtual…
- [`vercel`](../vercel/SKILL.md) — Deploy and optimize applications on Vercel. Use for tasks involving 'vercel', 'deploy', 'hosting', or 'product…
