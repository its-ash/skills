# SEO Audit Checklist and Report Format

Parent: [`seo`](../SKILL.md).

## Checklist

**Critical (fix before launch)**
- HTTPS site-wide.
- robots.txt allows all indexable pages; no `noindex` on important pages.
- Unique keyword-led titles (50-60 chars); one `<h1>` per page.
- Correct canonical on each page.
- Mobile-responsive.
- CWV pass: LCP < 2.5 s, INP < 200 ms, CLS < 0.1.

**High**
- Unique meta descriptions (150-160 chars).
- XML sitemap submitted to Search Console.
- Structured data: Article, Product, FAQ, BreadcrumbList.
- Internal links to all pillar and cluster pages.
- Image alt text and size attributes.

**Medium**
- Guides >= 1,500 words.
- E-E-A-T author bios and credentials.
- Organization and LocalBusiness schema.
- hreflang on multilingual sites.
- Font and resource preload.

**Ongoing**
- Watch Search Console crawl errors.
- Update sitemap when content is added.
- Track rankings and organic traffic.
- Refresh stale content quarterly.
- Audit backlinks; disavow toxic links.

## Process

1. Crawl the target with Lighthouse or Screaming Frog.
2. Record each finding: Issue, Impact, Evidence, Fix, Priority.
3. Apply fixes ([on-page-content.md](on-page-content.md), [technical-seo.md](technical-seo.md)).
4. Re-audit to confirm.
5. Run the keyword content plan; monitor monthly.

## Finding format

Tie each finding to a page, file, or asset:

```text
[HIGH] Duplicate title tags on product pages
Location: src/routes/products/[slug].tsx
Issue: Dynamic titles collapse to the same default string, which weakens relevance and creates duplicate signals.
Fix: Generate a unique title per product using the product name and primary category.
```
