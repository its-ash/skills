# On-Page, Content, and Keywords

Parent: [`seo`](../SKILL.md). Schema details: [schema-markup.md](schema-markup.md).

## Tags

| Element | Rule |
|---|---|
| `<title>` | 50-60 chars, primary keyword near start, unique, brand at end optional |
| Meta description | 150-160 chars, primary + secondary keyword, clear CTA, unique |
| `<h1>` | One per page, contains primary keyword |
| Headings | H1 -> H2 -> H3, no skipped levels, describe the section |
| URL | Short, keyword-rich |
| First paragraph | Primary keyword in first 100 words |
| Images | Descriptive filename, alt text for purpose, WebP/AVIF, `width`/`height`, `loading="lazy"` below fold |

```html
<title>Primary Topic - Specific Modifier | Brand</title>
<meta name="description" content="Action + topic + value proposition + one supporting detail.">
<link rel="canonical" href="https://example.com/current-page">
<img src="react-hooks-diagram.webp" alt="Diagram of React useState and useEffect hooks" width="800" height="600" loading="lazy">
```

Social tags:

```html
<meta property="og:title" content="Page Title">
<meta property="og:description" content="Page description">
<meta property="og:image" content="https://example.com/image.jpg">
<meta property="og:url" content="https://example.com/page">
<meta property="og:type" content="website">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Page Title">
<meta name="twitter:description" content="Page description">
<meta name="twitter:image" content="https://example.com/image.jpg">
```

## Content

- Use semantic variations; keyword density about 1-2%.
- Length: in-depth guide 1,500-2,500 words; product page 300-500 words; pillar 3,000+; cluster article 1,500-2,000.
- Cover follow-up questions. Refresh at least yearly (quarterly for fast topics). No thin or duplicate pages.
- Watch engagement: time on page, bounce rate, pages per session.

| E-E-A-T pillar | Signals |
|---|---|
| Experience | First-hand examples, case studies, original data |
| Expertise | Author credentials, detailed explanations |
| Authoritativeness | Citations, backlinks, industry recognition |
| Trustworthiness | HTTPS, clear contact info, privacy policy |

## Internal links

- 3-5 contextual links per 1,000 words; descriptive anchors (not "click here").
- Link from strong pages to pages you want to rank. Backfill links to each new page.
- Audit for broken links. Avoid excess footer or nav links that dilute link equity.

## Keyword research and mapping

1. Take seed keywords from business goals.
2. Expand with Keyword Planner, Ahrefs, Semrush.
3. Group into topical clusters: one pillar page per core topic, cluster articles linking to and from the pillar.
4. Rank variants by intent match, value, competition. Prefer long-tail for quick wins.
5. Map one primary keyword/theme to one URL (keep the map in a spreadsheet).
6. Check cannibalization: no two pages compete for one keyword unless intentional.

## Local

- Keep NAP (name, address, phone) the same across all citations.
- Fill Google Business Profile: photos, posts, reviews.
- Add `LocalBusiness` schema ([schema-markup.md](schema-markup.md#localbusiness)).
