# Generative Engine Optimization (GEO)

Optimise web pages so that AI‑driven search engines treat them as authoritative, citable sources. GEO focuses on entities, structured data, and clear, extractable information rather than traditional keyword rankings.

## When to use
- You publish articles, guides, or data that you want AI models to reference.
- You target citation in ChatGPT, Claude, Perplexity, or Gemini responses.
- You need a checklist that aligns content, schema, and technical performance with AI crawler expectations.

## What is GEO?
**Generative Engine Optimization (GEO)** is the practice of shaping content for citation by generative AI engines. The primary goal is a high **citation rate**—the frequency an AI model includes a link or reference to your page when answering a query.

## GEO vs. Traditional SEO
| Aspect | SEO | GEO |
|--------|-----|-----|
| Goal | Rank #1 in Google results | Appear as a cited source in AI answers |
| Platform | Google search | ChatGPT, Claude, Perplexity, Gemini |
| Primary metric | Rankings, click‑through rate | Citation frequency |
| Focus | Keyword density, backlinks | Entities, structured data, clear definitions |

## AI Engine Landscape
| Engine | Citation style | Typical citation format |
|--------|----------------|------------------------|
| Perplexity | Numbered footnotes | `[1]` style references |
| ChatGPT (OpenAI) | Inline or footnote | "According to *Source* …" |
| Claude (Anthropic) | Contextual | Embedded source links |
| Gemini (Google) | Sources section | List of URLs at end |

## Retrieval Factors Used by AI Crawlers
AI engines rank candidate sources before citing them. Approximate weightings are:
- **Semantic relevance** – ~40 % (how well the content matches the query meaning)
- **Keyword match** – ~20 % (exact term overlap)
- **Authority signals** – ~15 % (author reputation, backlinks, schema)
- **Freshness** – ~10 % (publication date, recent updates)
- **Source diversity** – ~15 % (variety of domains, formats)

## Content Types That Attract Citations
- **Original statistics** – Unique, verifiable data with source links.
- **Expert quotes** – Name, title, and affiliation included.
- **Clear definitions** – Concise, single‑sentence explanations.
- **Step‑by‑step guides** – Actionable instructions in ordered lists.
- **Comparison tables** – Structured rows/columns for easy extraction.
- **FAQ sections** – Direct Q&A pairs that match common queries.

## GEO Content Checklist
### Content Elements
- ✅ Question‑oriented title that mirrors user intent.
- ✅ TL;DR or summary paragraph at the very top.
- ✅ Original data with explicit citations.
- ✅ Expert quote with name and credentials.
- ✅ FAQ block containing 3‑5 relevant Q&A pairs.
- ✅ Precise definitions for key terms.
- ✅ "Last updated" timestamp visible to readers.
- ✅ Author bio with credentials and affiliation.

### Technical Elements
- ✅ Article schema (`Article` or `NewsArticle`) including `datePublished` and `dateModified`.
- ✅ Person schema for the author (`Person` with `name`, `jobTitle`, `affiliation`).
- ✅ FAQPage schema for the FAQ block.
- ✅ Page load time < 2.5 seconds (measure with Lighthouse or WebPageTest).
- ✅ Clean, semantic HTML (use headings `<h1>`‑`<h3>`, `<section>`, `<article>`).
- ✅ Canonical URL set correctly.

## Entity Building
- Create or claim a **Google Knowledge Panel** for your brand or product to reinforce entity recognition.
- If notable, ensure a **Wikipedia** entry exists and is linked from your site.
- Maintain consistent name, logo, and description across the web to aid consolidation.
- Encourage industry publications to mention your entity; each mention adds an authority signal.

## AI Crawler Access
| Crawler | Engine | Typical User‑Agent |
|---------|--------|-------------------|
| GPTBot | ChatGPT/OpenAI | `Mozilla/5.0 (compatible; GPTBot/1.0; +https://openai.com/bot)` |
| Claude‑Web | Claude | `Mozilla/5.0 (compatible; Claude-Web/1.0; +https://anthropic.com/bot)` |
| PerplexityBot | Perplexity | `Mozilla/5.0 (compatible; PerplexityBot/1.0; +https://perplexity.ai/bot)` |
| Googlebot | Gemini (shared) | Standard Googlebot UA |

**Access strategy**
- **Allow all** if you want maximum AI citation.
- **Block specific bots** (e.g., `Disallow: /` for `GPTBot`) only when you wish to prevent training data use.
- Use `robots.txt` or `X-Robots-Tag` headers to manage access per crawler.

## Measurement & Monitoring
| Metric | How to track |
|--------|--------------|
| AI citations | Search the AI engine for your brand name and note linked sources. Record frequency weekly.
| "According to [Brand]" mentions | Use the engine’s search with the phrase "According to *Brand*".
| Competitor citation share | Compile a list of top competitors and compare citation counts.
| AI‑referred traffic | Append UTM parameters (`utm_source=ai`) to outbound links and monitor in analytics.

## Anti‑Patterns to Avoid
| ❌ Bad practice | ✅ Recommended practice |
|----------------|------------------------|
| No publication date | Include a visible `datePublished` and `dateModified`.
| Vague source attribution | Cite the exact source name, URL, and date.
| Missing author info | Show author name, title, and credentials.
| Thin, low‑value content | Provide comprehensive coverage, data, and expert insight.
| Slow page load | Optimize images, enable compression, and use a CDN.

## Quick GEO Checklist
- [ ] Title phrased as a question matching user intent.
- [ ] TL;DR summary at the top.
- [ ] Original data with citations.
- [ ] Expert quote with name and title.
- [ ] FAQ block (≥3 Q&A).
- [ ] Clear definitions for key terms.
- [ ] "Last updated" date displayed.
- [ ] Author bio with credentials.
- [ ] Article and Person schema present.
- [ ] FAQPage schema present.
- [ ] Page loads < 2.5 s.
- [ ] Clean semantic HTML.
- [ ] Robots.txt permits desired AI crawlers.
- [ ] Monitor citation frequency weekly.

**Remember:** AI engines cite content that is clear, authoritative, and easy to parse. Structure your pages to meet these criteria and you increase the chance of being referenced in future AI‑generated answers.
