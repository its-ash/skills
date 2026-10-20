---
name: pubmed-database
description: "This skill teaches advanced PubMed search construction using MeSH terms, field tags, Boolean operators, and filters for article type, date, and free full-text; it covers programmatic retrieval via NCBI E-utilities (esearch, efetch, esummary, elink) with Python requests or Biopython Entrez, including rate limits, citation matching, PICO strategy for systematic reviews, search history, related articles, and export to RIS, BibTeX, CSV. Use when building systematic-review queries, literature-monitoring alerts, bulk citation extraction, MeSH mapping, E-utilities API integration, Python Entrez scripting, NCBI rate-limit handling, citation deduplication, or exporting records to reference managers."
---

# PubMed Database

PubMed is the U.S. National Library of Medicine’s free database of biomedical literature. Use this skill to create precise search strings, filter by article type or date, and retrieve records with the E‑utilities REST API.

## When to Use
- Find biomedical or life‑science articles.
- Build Boolean, field‑tag, or MeSH queries.
- Conduct systematic reviews or meta‑analyses.
- Retrieve abstracts, citation data, or full‑text links programmatically.
- Monitor new publications automatically.

## Advanced Query Construction
- Combine concepts with **AND**, **OR**, **NOT**.
- Limit a term with a field tag in square brackets, e.g., `author[au]`, `title[ti]`, `abstract[ab]`, `mesh[mh]`.
- Use double quotes for exact phrases.
- Use `*` as a wildcard for term variations.
- Use proximity operators if needed (e.g., `term1 AND term2[tiab]` within a distance).

**Example Queries**
```text
# Recent systematic reviews on diabetes treatment
"diabetes mellitus"[mh] AND treatment[tiab] AND "systematic review"[pt] AND 2023:2024[dp]

# Clinical trials comparing two drugs
(metformin[nm] OR insulin[nm]) AND "diabetes mellitus, type 2"[mh] AND "randomized controlled trial"[pt]

# Author‑specific research
smith ja[au] AND cancer[tiab] AND 2023[dp] AND english[la]
```

## MeSH and Controlled Vocabulary
- Use the **[mh]** tag to search a MeSH term; narrower terms are added automatically.
- Use **[majr]** to restrict to articles where the term is the major focus.
- Combine MeSH terms with subheadings for specificity, e.g., `diabetes mellitus/therapy[mh]`.
- Common subheadings: `/diagnosis`, `/drug therapy`, `/epidemiology`, `/etiology`, `/prevention & control`, `/therapy`.

**Example**
```text
diabetes mellitus, type 2[mh]/drug therapy AND cardiovascular diseases[mh]/prevention & control
```

## Filter by Article Type, Date, and Text Availability
- Publication type: `"clinical trial"[pt]`, `"meta analysis"[pt]`, `"review"[pt]`.
- Date: single year `2024[dp]`, range `2020:2024[dp]`, exact date `2024/03/15[dp]`.
- Free full text: add `AND free full text[sb]`.
- Has abstract: add `AND hasabstract[text]`.

**Example**
```text
hypertension[mh] AND "randomized controlled trial"[pt] AND 2023:2024[dp] AND free full text[sb]
```

## Programmatic Access via E‑utilities API
### Core Endpoints
| Endpoint | Purpose |
|---|---|
| **esearch.fcgi** | Search PubMed, return PMIDs |
| **efetch.fcgi** | Retrieve full records (abstract, XML, MEDLINE) |
| **esummary.fcgi** | Get document summaries |
| **epost.fcgi** | Upload a list of UIDs for batch processing |
| **elink.fcgi** | Find related articles or linked NCBI data |

### Basic Python Workflow
```python
import requests

BASE = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
API_KEY = "YOUR_API_KEY"  # optional, raises rate limit
HEADERS = {"User-Agent": "MyPubMedApp/1.0"}

# 1. Search for PMIDs
search_params = {
    "db": "pubmed",
    "term": "diabetes[tiab] AND 2024[dp]",
    "retmax": 100,
    "retmode": "json",
    "api_key": API_KEY,
}
resp = requests.get(BASE + "esearch.fcgi", params=search_params, headers=HEADERS)
pmids = resp.json()["esearchresult"]["idlist"]

# 2. Fetch abstracts
fetch_params = {
    "db": "pubmed",
    "id": ",".join(pmids),
    "rettype": "abstract",
    "retmode": "text",
    "api_key": API_KEY,
}
resp = requests.get(BASE + "efetch.fcgi", params=fetch_params, headers=HEADERS)
print(resp.text)
```

### Rate Limits
- No API key: **3 requests/second**.
- With API key: **10 requests/second**.
- Always include a descriptive **User‑Agent** header.
- Use `usehistory=y` for result sets larger than 10 000.
- Cache responses locally to avoid repeated calls.

## Citation Matching and Retrieval
- By PMID: `12345678[pmid]`
- By DOI: `10.1056/NEJMoa123456[doi]`
- By PMC ID: `PMC123456[pmc]`
- Use the **ECitMatch** service to locate a PMID from a partial citation (journal, year, volume, page, author).

**Example ECitMatch format**
```
Science|2008|320|5880|1185|key1|
```

## Systematic Review Search Strategy (PICO)
1. Identify **Population**, **Intervention**, **Comparison**, **Outcome**.
2. Translate each element into MeSH terms and synonyms.
3. Combine with Boolean operators.
4. Add study‑design filter (`"randomized controlled trial"[pt]` or `"systematic review"[pt]`).
5. Add date and language limits.

**PICO Example**
```text
# Population
"diabetes mellitus, type 2"[mh]
# Intervention
metformin[nm]
# Comparison
"lifestyle modification"[tiab]
# Outcome
"glycemic control"[tiab]
# Combined query
"diabetes mellitus, type 2"[mh] AND (metformin[nm] OR "lifestyle modification"[tiab]) AND "glycemic control"[tiab] AND "randomized controlled trial"[pt]
```

## Search History and Saved Searches
- PubMed stores up to **100** recent searches for 8 hours.
- Reference previous searches with `#n` (e.g., `#1 AND #2`).
- Use **My NCBI** to save searches permanently, set email alerts, and create RSS feeds.

## Related Articles and Citation Discovery
- Use the **Similar Articles** link on a PubMed record for algorithmic recommendations.
- Programmatically retrieve related IDs with **elink.fcgi**:
```
https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=pubmed&db=pubmed&id=PMID&cmd=neighbor
```
- Follow **LinkOut** URLs for publisher full‑text or PubMed Central free versions.

## Export and Citation Management
- Export formats: **.nbib** (Zotero, EndNote), **MEDLINE**, **CSV**, **XML**.
- Batch export via API:
```text
https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=PMID1,PMID2&rettype=medline&retmode=text
```
- Use the **Clipboard** (temporary, 500 items, 8 h) or **Collections** (permanent, My NCBI) to store results.

## Common Workflows
### 1. Basic Literature Search
1. List key concepts and synonyms.
2. Build a Boolean query with field tags.
3. Run the query in PubMed web UI.
4. Refine with filters (date, type, language).
5. Export results.

### 2. Systematic Review Search
1. Write a PICO statement.
2. Identify all relevant MeSH terms.
3. Create a comprehensive query covering synonyms and study designs.
4. Run the query, document the exact string and date.
5. Export to .nbib for screening.

### 3. Programmatic Data Extraction
1. Test the query in the web UI.
2. Use **esearch** to obtain PMIDs.
3. If >10 000 results, enable the history server (`usehistory=y`).
4. Retrieve records with **efetch** (abstract, XML, or MEDLINE).
5. Parse the response (XML library or plain text).
6. Cache locally and respect rate limits.

### 4. Citation Discovery
1. Start with a known PMID.
2. Call **elink** with `cmd=neighbor` to get similar IDs.
3. Retrieve details for the new IDs.
4. Add relevant IDs to your collection.

### 5. Ongoing Literature Monitoring
1. Build a stable query for your topic.
2. Save the query in My NCBI.
3. Enable email alerts or create an RSS feed.
4. Review new items weekly and add to your collection.

## Checklist
- [ ] Define search concepts and synonyms.
- [ ] Choose appropriate field tags (`[tiab]`, `[mh]`, `[au]`).
- [ ] Add MeSH terms and subheadings where possible.
- [ ] Apply study‑design filters (`[pt]`).
- [ ] Set date and language limits.
- [ ] Test the query in the PubMed UI and verify translation.
- [ ] Obtain an NCBI API key for higher rate limits.
- [ ] Use `usehistory=y` for large result sets.
- [ ] Implement exponential back‑off for rate‑limit errors.
- [ ] Cache API responses locally.
- [ ] Export results in a format compatible with your reference manager.
- [ ] Document the final query string and retrieval date for reproducibility.

## Related skills

Load these when the task spans more than this skill.

- [`citation-management`](../citation-management/SKILL.md) — Manage academic citations: search Google Scholar and PubMed, extract metadata from DOI, PMID, arXiv ID, or URL…
- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
- [`research-critique`](../research-critique/SKILL.md) — Systematically evaluate scientific research rigor, methodology, and claims. Use for peer review of manuscripts…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`clinical-reports`](../clinical-reports/SKILL.md) — Write comprehensive clinical reports including case reports (CARE guidelines), diagnostic reports (radiology/p…
