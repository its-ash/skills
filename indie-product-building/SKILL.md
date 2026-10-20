---
name: indie-product-building
description: "Turns a validated problem into a profitable indie product such as an AI-wrapped SaaS, CLI tool, or digital template, covering idea validation, MVP architecture, prompt engineering, cost control, pricing, and launch. Use when building a micro-SaaS, side project, indie app, template, or solo product, validating ideas, choosing a stack, writing prompts, estimating API costs, setting prices, or avoiding launch pitfalls."
---

# Indie Product Building

Create a focused, revenue‑generating product fast. Use this skill when you have a concrete problem, want to wrap an AI API, build a solo‑founder SaaS, a personal CLI tool, or a digital template, and need a clear workflow from validation to launch.

## When to Use
- You have a specific pain point you or others experience.
- You plan to build a product around an AI model, a web service, a CLI, or a Notion template.
- You need a lean process to validate, prototype, price, launch, and grow with minimal resources.

---

## 1. Idea Validation
### The Validation Framework
| Question | How to Answer |
|----------|---------------|
| Does a real problem exist? | Interview ≥ 5 potential users. |
| Will users pay? | Run a pre‑sale, waitlist, or test a landing‑page conversion. |
| Can you build it in ≤ 2 weeks? | Sketch a minimal implementation. |
| Is there a distribution channel? | Identify a community, forum, or marketplace where the target lives. |

### Quick Validation Methods
1. **Landing‑page test** – Build a one‑page site, drive cheap ads or post in relevant forums, track sign‑ups.
2. **Pre‑sale** – Offer a discount for early buyers; if no sales, pivot.
3. **Competitor check** – Existing solutions validate demand; find a gap you can fill.

**Red flags**: vague “everyone needs this”, no clear buyer, requires massive scale, or needs a marketplace to function.

**Green flags**: specific pain, users already paying for alternatives, you have domain expertise, clear channel to reach them.

---

## 2. Product Architecture
### 2.1 AI‑Wrapper Stack (for SaaS powered by OpenAI, Anthropic, etc.)
```
User Input → Validation → Prompt Template + Context → AI API → Output Parsing → User‑Friendly Response
```
#### Minimal JavaScript Example
```javascript
import Anthropic from '@anthropic-ai/sdk';
const anthropic = new Anthropic();

async function generate(userInput, ctx) {
  if (!userInput || userInput.length > 5000) throw new Error('Invalid input');
  const system = `You are a ${ctx.role}. Respond in ${ctx.format} tone.`;
  const resp = await anthropic.messages.create({
    model: 'claude-3-haiku-20241001',
    max_tokens: 1000,
    system,
    messages: [{ role: 'user', content: userInput }]
  });
  const text = resp.content[0].text;
  return parseOutput(text);
}
```
#### Prompt Template Pattern
```javascript
const prompts = {
  emailWriter: {
    system: `You are an expert email writer. Write concise, professional emails matching the requested tone. Never include placeholders.`,
    user: i => `Write an email:
      Purpose: ${i.purpose}
      Recipient: ${i.recipient}
      Tone: ${i.tone}
      Points: ${i.points.join(', ')}
      Length: ${i.length} sentences`
  }
};
```
#### Structured Output Guard
```javascript
const system = `Always respond with valid JSON:
{ "title": "string", "content": "string", "suggestions": ["string"] }
Do not add any extra text.`;
function parseAI(text) {
  try { return JSON.parse(text); }
  catch {
    const m = text.match(/\{[\s\S]*\}/);
    if (m) return JSON.parse(m[0]);
    throw new Error('Invalid AI output');
  }
}
```
### 2.2 Personal CLI / Script Stack
#### Node.js CLI Boilerplate
```json
// package.json
{
  "name": "mytool",
  "version": "1.0.0",
  "bin": { "mytool": "./bin/cli.js" },
  "dependencies": { "commander": "^12.0.0", "chalk": "^5.3.0", "ora": "^8.0.0" }
}
```
```javascript
// bin/cli.js
#!/usr/bin/env node
import { Command } from 'commander';
import chalk from 'chalk';
const program = new Command();
program.name('mytool').description('One‑liner description').version('1.0.0');
program.command('run')
  .description('Execute main task')
  .option('-v, --verbose', 'Verbose output')
  .action(opts => {
    console.log(chalk.green('Running task'));
    // core logic here
  });
program.parse();
```
#### Python Click Boilerplate
```python
import click
@click.group()
def cli():
    """Tool description."""
    pass
@cli.command()
@click.option('--name', '-n', required=True)
@click.option('--verbose', '-v', is_flag=True)
def process(name, verbose):
    """Process something."""
    click.echo(f'Processing {name}')
if __name__ == '__main__':
    cli()
```
### 2.3 Local‑First App Pattern
Store data in a JSON file for tiny tools or SQLite for richer apps.
```javascript
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { homedir, join } from 'path';
const DIR = join(homedir(), '.mytool');
const FILE = join(DIR, 'data.json');
function load() { return existsSync(FILE) ? JSON.parse(readFileSync(FILE)) : { items: [] }; }
function save(data) { if (!existsSync(DIR)) mkdirSync(DIR); writeFileSync(FILE, JSON.stringify(data, null, 2)); }
```
---

## 3. Cost Management (AI‑Powered Products)
### Token Economics Example (Claude 3‑Haiku)
```javascript
function calculateCost({ input_tokens, output_tokens }) {
  const rates = { input: 0.25, output: 1.25 }; // $ per 1M tokens
  return (input_tokens * rates.input + output_tokens * rates.output) / 1_000_000;
}
```
Log each call to a database and enforce monthly caps:
```javascript
async function checkLimits(userId) {
  const monthUsage = await db.usage.sum({ where: { userId, createdAt: { gte: startOfMonth() } } });
  const limit = await getUserLimits(userId);
  if (monthUsage.cost >= limit.monthlyCost) throw new Error('Monthly limit reached');
}
```
### Cost‑Reduction Strategies
- Choose the cheapest model that meets quality (e.g., Claude Haiku for high volume).
- Limit `max_tokens` to the minimum needed.
- Cache frequent queries.
- Batch similar requests.
- Trim input context when possible.
---

## 4. MVP Development (2‑Week Sprint)
### Recommended Stack for Solo Founders
| Layer | Choice | Reason |
|-------|--------|--------|
| Frontend | **Next.js** (Vercel) | Full‑stack, zero‑config deployment |
| Backend | Next.js API routes **or** Supabase | Fast, managed auth & DB |
| Database | Supabase Postgres | Free tier, built‑in auth |
| Auth | Supabase Auth or Clerk | No custom auth code |
| Payments | Stripe | Industry standard, easy checkout |
| Email | Resend / Loop | Transactional + marketing |
| Hosting | Vercel | Auto‑scaling, CDN |

### Two‑Week Timeline
**Week 1 – Core**
- Day 1‑2: Set up auth and basic UI.
- Day 3‑4: Implement the single core feature (the “one thing”).
- Day 5‑6: Add Stripe checkout (single price tier).
- Day 7: Polish UI, add basic error handling.

**Week 2 – Launch Ready**
- Day 1‑2: Build a simple landing page with value proposition.
- Day 3: Configure welcome & receipt emails.
- Day 4: Add privacy policy, terms, and GDPR notice.
- Day 5: Run end‑to‑end tests.
- Day 6‑7: Soft launch to a small audience (email list, Discord, Reddit).

### What to Skip in MVP
- Perfect design – use a clean UI library.
- Multiple pricing tiers – start with a single price.
- Custom auth – use a managed provider.
- Scaling optimizations – defer until you have paying users.
---

## 5. Pricing Strategy
### General Formula
```
Value = (Hours saved per month) × (Your hourly rate) × 12
Price ≈ 20‑50 % of Value
```
### Tier Options
| Tier | When to Use |
|------|-------------|
| Single price | Simple tool, clear ROI |
| Two tiers (Free/Pro) | Need a lead‑magnet and paid upgrade |
| Three tiers (Basic/Pro/Enterprise) | SaaS with expanding feature set |
| Usage‑based | API‑style products, variable consumption |

### Example for a Notion Template
- Saves 5 h/month → 5 × $50 × 12 = $3000 value.
- Price $49‑99 (≈ 1‑3 % of value) gives strong ROI.

### Common Mistakes
- **Too cheap** – undervalues product, attracts price‑sensitive churners.
- **Too complex** – confusing tier matrix reduces conversions.
- **No trial/free tier** – users can’t evaluate risk.
- **Waiting to charge** – validate with real money early.
---

## 6. Launch & Distribution
### Landing‑Page Checklist
- Clear headline stating the problem solved.
- One‑sentence value proposition.
- Screenshot or demo video.
- Social proof (testimonials, early‑user quotes).
- Call‑to‑action (sign‑up, purchase button).

### Primary Channels
| Channel | Typical Cost | Best For |
|---------|--------------|----------|
| Product Hunt | Free (optional boost) | Early‑tech audience |
| Reddit / niche forums | Free | Community‑driven traffic |
| Twitter / X | Low (organic) | Founder visibility |
| Gumroad / Lemon Squeezy | 5‑10 % fee | Digital goods |
| Notion Marketplace | 0 % fee | Notion‑centric users |
| Your own site (Stripe) | 2‑3 % fee | Full branding control |

### Email Capture & Nurture
1. Offer a free mini‑template or cheat‑sheet as lead magnet.
2. Send a welcome series: problem recap → solution demo → limited‑time discount.
3. After purchase, deliver onboarding video and invite to a private community.
---

## 7. Anti‑Patterns & Sharp Edges
### Common Anti‑Patterns
| Pattern | Why Bad | Remedy |
|----------|----------|--------|
| Thin Wrapper Syndrome | No differentiation; users just use the raw AI. | Add domain expertise, custom UX, post‑processing, and value‑added features. |
| Building in Secret | No feedback; risk of building the wrong thing. | Launch an ugly MVP, collect feedback publicly. |
| Feature Creep | Never ships, dilutes focus. | Commit to one core feature, iterate based on user requests. |
| Ignoring Costs | Surprise bills, negative unit economics. | Track every token, set per‑user caps, price with margin. |
| Over‑Engineering Personal Tools | Takes forever, kills motivation. | Start with a script that works for you; refactor only when pain points appear. |

### Sharp Edge Mitigations
| Issue | Severity | Fix |
|-------|----------|-----|
| API cost spirals | High | Implement token tracking, model selection, and usage limits (see Cost Management). |
| Rate‑limit errors | High | Add exponential back‑off and fallback to a cheaper model. |
| Hallucinated output | High | Enforce structured JSON responses and validate/parsing logic. |
| Slow latency | Medium | Cache frequent prompts, reduce max tokens, use faster models for simple tasks. |
| Template piracy | Medium | Offer regular updates, add a license key, and provide premium support to incentivize purchase. |
| High churn on sign‑up | High | Improve onboarding, collect early feedback, and iterate on core value. |
---

## 8. Checklist
- [ ] Interview ≥ 5 potential users and record pain points.
- [ ] Build a one‑page landing site with headline, demo, and CTA.
- [ ] Run a traffic test (ads or community posts) and measure sign‑ups.
- [ ] Validate willingness to pay with pre‑sale or waitlist.
- [ ] Choose stack (Next.js + Supabase + Stripe) or CLI/local‑first stack.
- [ ] Implement AI wrapper (if applicable) with prompt template and output guard.
- [ ] Add token usage logging and monthly cost caps.
- [ ] Ship MVP in ≤ 2 weeks following the sprint plan.
- [ ] Set a price using the 20‑50 % of value rule.
- [ ] Publish on at least two sales channels (e.g., Gumroad + Notion Marketplace).
- [ ] Capture emails, send onboarding sequence, and collect NPS feedback.
- [ ] Monitor costs, latency, and error rates; iterate weekly.
- [ ] Avoid thin‑wrapper, feature creep, and hidden costs.

---

**Related Skills**: `llm-architect`, `micro-saas-launcher`, `frontend`, `backend`, `stripe`, `landing-page-design`, `seo`, `copywriting`

## Related skills

Load these when the task spans more than this skill.

- [`product-management`](../product-management/SKILL.md) — A comprehensive product‑management skill that guides product managers, strategists, and agile owners through d…
- [`pricing-strategy`](../pricing-strategy/SKILL.md) — A step‑by‑step framework for SaaS pricing and monetization, covering research methods, value‑metric selection,…
- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`ai-cli-delegation`](../ai-cli-delegation/SKILL.md) — Delegates user requests to AI command‑line tools (Gemini CLI or Codex CLI). Choose the appropriate model, sand…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
