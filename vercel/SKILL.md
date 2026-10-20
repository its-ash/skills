---
name: vercel
description: "Deploy, host, and optimize applications on Vercel. Use when deploying or hosting Next.js, React, Astro, Node.js, or static sites; configuring vercel.json, environment variables, serverless functions, edge runtime, build commands, domains, preview deployments, production releases, rewrites, redirects, headers, cron jobs, or troubleshooting Vercel build and deployment errors."
---

# Vercel Deployment

Manage the deployment, configuration, and optimization of applications on the Vercel platform. This skill covers CLI deployment workflows and architectural best practices for production-grade hosting.

## When to use
- Deploying a project to Vercel (Preview or Production).
- Configuring environment variables for different deployment stages.
- Choosing between Edge and Serverless runtimes.
- Optimizing build sizes and reducing cold starts.
- Troubleshooting deployment network errors or runtime failures.

## Deployment Workflow

### Standard Deployment
Always deploy as a **Preview** deployment unless the user explicitly requests a production build.

1. **Run Deployment Command**:
   Use a 10-minute (600,000ms) timeout to account for build times.
   ```bash
   vercel deploy [path] -y
   ```

2. **Production Deployment**:
   Only use the `--prod` flag if explicitly requested by the user.
   ```bash
   vercel deploy [path] --prod -y
   ```

3. **Handling Network Blocks**:
   If the deployment fails due to DNS errors, connection resets, or timeouts caused by sandbox restrictions, rerun the command with `sandbox_permissions=require_escalated`.

### Output
- Provide the deployment URL to the user immediately.
- Do not use `curl` or `fetch` to verify the deployed URL; return the link directly.

## Configuration and Optimization

### Environment Variables
- **Environment Segregation**: Maintain distinct variables for Development, Preview, and Production environments.
- **Security**: Never prefix secrets with `NEXT_PUBLIC_`. Only use `NEXT_PUBLIC_` for values that must be accessible to the browser.
- **Database Isolation**: Use separate databases for Preview and Production environments to prevent data corruption.

### Runtime Selection
- **Edge Runtime**: Use for low-latency, globally distributed logic. Note that Edge runtime lacks some Node.js APIs; verify compatibility before implementation.
- **Serverless Functions**: Use for heavier compute tasks or when full Node.js API support is required.

### Build Optimization
- **Cold Start Reduction**: Minimize the serverless function bundle size to reduce cold start latency.
- **Caching**: Implement a build cache to speed up subsequent deployments.
- **CORS**: Add appropriate CORS headers to API routes when calling them from different domains.

## Pitfalls and Solutions

| Issue | Severity | Solution |
| :--- | :--- | :--- |
| `NEXT_PUBLIC_` exposes secrets | Critical | Remove secrets from public prefixes. |
| Preview uses Production DB | High | Configure environment-specific database connection strings. |
| Slow cold starts | High | Reduce function size and dependencies. |
| Missing Node.js APIs in Edge | High | Switch to Serverless runtime for incompatible APIs. |
| Function timeouts | Medium | Optimize long-running operations or use background jobs. |
| Stale data after deploy | Medium | Configure appropriate cache-control headers. |

## Checklist
- [ ] Deployment target is Preview (unless Production was requested).
- [ ] Timeout is set to 600,000ms for the deploy command.
- [ ] No secrets are prefixed with `NEXT_PUBLIC_`.
- [ ] Separate databases are configured for Preview and Production.
- [ ] Runtime (Edge vs Serverless) matches the API requirements.

## Related skills

Load these when the task spans more than this skill.

- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`performance`](../performance/SKILL.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`web-performance`](../web-performance/SKILL.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`astro`](../astro/SKILL.md) — Astro is a web framework for content‑heavy sites that ships zero JavaScript by default and hydrates interactiv…
- [`paper-to-web`](../paper-to-web/SKILL.md) — Convert academic papers (LaTeX or PDF) into interactive websites, presentation videos, and conference posters…
