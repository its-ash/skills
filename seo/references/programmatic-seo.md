# Programmatic SEO

Create SEO‑driven pages at scale with templates, data, and quality controls. The goal is to rank, provide real value, and avoid thin‑content penalties.

---

## When to Use
- You have a repeatable search‑intent pattern (e.g., "[service] in [city]", "[tool] vs [tool]", "convert [X] to [Y]").
- You possess proprietary, product‑derived, or curated data that can populate many pages.
- You need to capture local, comparison, or utility traffic without building each page manually.
- You want a systematic process that includes keyword research, template design, internal linking, and quality checks.

---

## Core Principles
1. **Unique Value per Page** – Each page must contain data, analysis, or insights that differ from every other page.
2. **Defensible Data** – Prioritize data you own (proprietary → product‑derived → user‑generated → licensed → public).
3. **Clean URL Structure** – Use subfolders, not subdomains. Keep URLs short, descriptive, and keyword‑rich.
4. **Match Search Intent** – Deliver the complete answer or tool the user expects.
5. **Scalable Quality** – Favor 100 high‑quality pages over 10,000 thin pages.
6. **Avoid Penalties** – No doorway pages, keyword stuffing, or duplicate content.

---

## 12 Proven Playbooks
| Playbook | Typical Search Pattern | Example URL | Key Value Add |
|---|---|---|---|
| **Templates** | "free [type] template" | `/templates/resume/` | Downloadable, usable templates |
| **Curation** | "best [category]" or "top 10 …" | `/best/website-builders/` | Expert‑tested rankings |
| **Conversions** | "[X] to [Y]" | `/convert/usd-to-gbp/` | Real‑time tool, high utility |
| **Comparisons** | "[X] vs [Y]" | `/compare/webflow-vs-wordpress/` | Balanced feature analysis |
| **Examples** | "[type] examples" | `/examples/landing-page/` | Real‑world screenshots & commentary |
| **Locations** | "[service] in [city]" | `/coworking/spokane/` | Local provider list, city stats |
| **Personas** | "[product] for [audience]" | `/for/freelancers/` | Tailored benefits & testimonials |
| **Integrations** | "[product] + [product] integration" | `/integrations/slack/` | Setup steps, use‑case demos |
| **Glossary** | "what is [term]" | `/glossary/seo/` | Clear definition, examples |
| **Translations** | Same content in another language | `/es/que-es-seo/` | High‑quality, localized copy |
| **Directory** | "[category] tools" | `/directory/ai-copywriting/` | Comprehensive, filterable listings |
| **Profiles** | "[person/company]" | `/people/elon-musk/` | Accurate bio, sourced data |

### Combining Playbooks
- **Location + Persona** → `/marketing-agencies/startups/austin/`
- **Curation + Location** → `/best/coworking-spaces/san-diego/`
- **Integration + Persona** → `/integrations/slack/for/sales-teams/`

---

## Implementation Framework
### 1. Keyword Pattern Research
- Identify the repeatable pattern and its variables.
- Use keyword tools to aggregate total search volume, head vs. long‑tail split, and seasonal trends.
- Evaluate competition: domain authority, content depth, and backlink profile.
- Choose patterns where you can realistically outrank.

### 2. Data Requirements
1. **Source Identification** – List where each variable comes from (internal DB, API, licensed feed, public scrape).
2. **Schema Design** – Example for "[Service] in [City]":
```yaml
city:
  name: string
  population: integer
  stats: {average_price: number, regulation: string}
service:
  name: string
  description: string
providers:
  - name: string
    rating: number
    reviews: integer
    specialty: string
```
3. **Update Cadence** – Define how often data refreshes (daily, weekly, monthly).

### 3. Template Design
- **Header** – H1 with keyword and year if relevant.
- **Intro** – Unique paragraph mixing city/service data.
- **Data‑Driven Sections** – Use conditional blocks to show only available data.
- **Related Links** – Auto‑generate links to similar pages.
- **CTA** – Align with user intent (download, sign‑up, contact).

#### Minimal Template Example (Markdown)
```markdown
# {{service}} in {{city}} – {{year}}

{{intro_paragraph}}

## Why {{city}} is Ideal for {{service}}
{{city_insights}}

## Top {{service}} Providers in {{city}}
{% for provider in providers %}
- **{{provider.name}}** – Rating {{provider.rating}} ({{provider.reviews}} reviews)
  {{provider.specialty}}
{% endfor %}

## Pricing Overview
{{pricing_table}}

## Frequently Asked Questions
{{faq_section}}

[Related: {{related_links}}]
```

### 4. Internal Linking Architecture
- **Hub‑and‑Spoke**: Create a category hub page that links to all programmatic pages (spokes).
- **Cross‑link**: Within each page, link to other pages sharing a variable (e.g., other cities for the same service).
- **Breadcrumbs** – Implement structured data breadcrumbs for navigation and SEO.
- **Avoid Orphans** – Every page must be reachable from the hub or sitemap.

### 5. Indexation & Crawl Budget
- Add all high‑value pages to an XML sitemap; split sitemaps by playbook if large.
- Use `noindex` on very low‑volume or thin variations.
- Set `robots.txt` to block crawl traps and unnecessary parameters.
- Monitor Google Search Console for crawl errors and indexation rate.

---

## Quality Checks
### Pre‑Launch Checklist
- **Content**: Unique intro, data‑driven sections, answer intent, no duplicated paragraphs.
- **Meta**: Unique title (≤ 60 chars) and meta description (≤ 160 chars) with keyword.
- **Headings**: Proper H1‑H3 hierarchy, one H1 per page.
- **Schema**: Add appropriate structured data (e.g., `LocalBusiness`, `Product`, `FAQ`).
- **Canonical**: Correct canonical URL; no self‑referencing loops.
- **Performance**: Page load < 3 s on mobile, image optimization, lazy loading.
- **Links**: Internal links to hub and related pages; no broken links.
- **Sitemap**: Page listed, priority set according to importance.

### Post‑Launch Monitoring
- **Indexation** – % of pages indexed vs. submitted.
- **Rankings** – Track average position for the pattern (e.g., "[service] in [city]").
- **Traffic** – Sessions, bounce rate, time on page per playbook.
- **Conversions** – Goal completions (lead, download, sign‑up).
- **Search Console** – Thin content warnings, manual actions, crawl errors.
- **Data Freshness** – Verify that automated data feeds are updating correctly.

---

## Common Mistakes to Avoid
| Mistake | Why It Hurts | Remedy |
|---|---|---|
| **Thin content** – only swapping variables | Google may label as doorway pages and de‑index | Add city‑specific stats, unique analysis, user‑generated reviews |
| **Keyword cannibalization** – multiple pages target same exact term | Splits ranking signal | Consolidate similar pages or use canonical tags |
| **Over‑generation** – creating pages with negligible search volume | Dilutes authority, wastes crawl budget | Set a minimum volume threshold (e.g., > 50 monthly searches) |
| **Bad data** – outdated or incorrect information | Users bounce, rankings drop | Automate data validation and schedule regular audits |
| **Poor UX** – pages exist only for bots, no clear CTA | High bounce, low conversions | Design with user journey in mind; include clear calls to action |

---

## Quick Launch Checklist
- [ ] Identify keyword pattern and validate demand (> 50 monthly searches).
- [ ] Secure data source and define schema.
- [ ] Build page template with conditional sections for uniqueness.
- [ ] Generate URLs using subfolder structure.
- [ ] Populate first batch of pages (e.g., 100) and run quality audit.
- [ ] Add pages to XML sitemap; submit to Google Search Console.
- [ ] Implement internal linking (hub + cross‑links).
- [ ] Perform pre‑launch SEO checks (titles, meta, schema, speed).
- [ ] Launch and monitor indexation, rankings, and traffic.
- [ ] Schedule regular data refresh and content updates.

---

## Questions to Clarify Your Project
- What keyword pattern(s) are you targeting?
- Which data sources are available and how often can they be refreshed?
- How many pages do you plan to create in the first phase?
- What is your site’s current authority and backlink profile?
- Who are the top competitors for these queries?
- Which CMS or static site generator will you use for page generation?

---

**Related Skills**: `seo-audit` (post‑launch health checks), `schema-markup` (add structured data), `copywriting` (craft non‑templated copy), `analytics-tracking` (measure performance).

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/competitor-pages.md](programmatic-seo/competitor-pages.md) | Creates SEO‑focused competitor comparison and alternative pages (singular alternative, plural alternatives, you‑vs‑competitor, competitor‑vs‑competitor). Use when you need to rank for competitor terms, help prospects decide, and provide sales‑enablement content. |

## Related skills

Load these when the task spans more than this skill.

- [`seo`](../SKILL.md) — SEO provides a complete audit and optimization guide covering technical SEO, on-page elements, content quality…
- [`content-writing`](../../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
- [`web-scraping-apis`](../../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
