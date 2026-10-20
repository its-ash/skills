---
name: citation-management
description: "Search Google Scholar and PubMed for papers, then resolve DOI, PMID, arXiv ID, or URL to structured metadata via CrossRef, PubMed, arXiv, and DataCite APIs; format, validate, and repair BibTeX entries and assemble complete bibliographies. Use when you need to find articles, convert doi pmid arxiv to bibtex, fix broken references, clean .bib files, generate citations, extract metadata from pdfs, query crossref datacite, or build reference lists for manuscripts theses grant proposals."
---

# Citation Management

Citation Management helps you find papers, extract accurate metadata, format BibTeX, and validate references. Use it to keep bibliographies correct and consistent.

## When to use

- Search Google Scholar or PubMed for papers.
- Convert a DOI, PMID, arXiv ID, or URL to BibTeX.
- Extract complete metadata for a citation.
- Validate an existing BibTeX file.
- Remove duplicates and standardize formatting.
- Build a bibliography for a manuscript or thesis.

## Search strategies

### Google Scholar

- Use specific technical terms and acronyms.
- Put exact phrases in quotation marks.
- Filter by year for fast-moving fields.
- Check "Cited by" to find seminal papers.
- Search by author with `author:lastname`.
- Search titles with `intitle:keyword`.
- Exclude terms with `-term`.
- Use year ranges such as `2020..2024`.
- Sort by citations to find influential work.
- Search a specific source with `source:journal`.

Examples:

```
"CRISPR" intitle:review 2023..2024
author:Church "synthetic biology"
"deep learning" 2012..2015
"protein folding" -survey -review intitle:method
```

### PubMed

- Use MeSH terms for controlled vocabulary.
- Find MeSH terms in the MeSH Browser.
- Combine MeSH terms with keywords.
- Use field tags: `[Title]`, `[Title/Abstract]`, `[Author]`, `[Journal]`, `[Publication Date]`, `[Publication Type]`, `[MeSH]`.
- Use Boolean operators `AND`, `OR`, `NOT`.
- Filter by publication type and date.
- Retrieve PMIDs for metadata extraction.
- Use NCBI E-utilities for automation: ESearch, EFetch, ESummary, ELink.
- Export results to JSON or BibTeX for downstream processing.

Examples:

```
"Diabetes Mellitus, Type 2"[MeSH] AND "Drug Therapy"[MeSH]
AND "Clinical Trial"[Publication Type] AND 2020:2024[Publication Date]
"CRISPR-Cas Systems"[MeSH] AND "Nature"[Journal] AND "Review"[Publication Type]
"Smith AB"[Author] AND cancer[Title/Abstract] AND 2022:2024[Publication Date]
```

## Metadata extraction

- Prefer DOIs. They are permanent and resolve through doi.org.
- Extract from PMID for biomedical literature.
- Extract from arXiv ID for preprints.
- Extract from URL when no identifier is available.
- Process identifiers in batches when building large bibliographies.
- Use these metadata sources:
  - CrossRef API: primary source for DOIs; publisher-provided journal metadata.
  - PubMed E-utilities: official NCBI metadata; includes MeSH terms and abstracts.
  - arXiv API: preprint metadata, versions, and author affiliations.
  - DataCite API: datasets, software, and other non-traditional outputs.
- Extract these fields:
  - Required: author, title, year.
  - Journal article: journal, volume, number, pages, DOI.
  - Book: publisher, ISBN, edition.
  - Conference paper: booktitle, conference location, pages.
  - Preprint: repository, preprint ID.
  - Additional: abstract, keywords, URL.
- Verify extracted metadata against the original source.
- Use the published version when a preprint has been published.
- Keep author names, journal abbreviations, and DOI format consistent.

## BibTeX formatting

Entry types:

- `@article`: journal article.
- `@book`: book.
- `@inproceedings`: conference paper.
- `@incollection`: book chapter.
- `@phdthesis`: dissertation.
- `@misc`: preprint, software, dataset.

Required fields:

```
@article{citationkey,
  author = {Last1, First1 and Last2, First2},
  title = {Article Title},
  journal = {Journal Name},
  year = {2024},
  volume = {10},
  number = {3},
  pages = {123--145},
  doi = {10.1234/example}
}
```

```
@inproceedings{citationkey,
  author = {Last, First},
  title = {Paper Title},
  booktitle = {Conference Name},
  year = {2024},
  pages = {1--10}
}
```

```
@book{citationkey,
  author = {Last, First},
  title = {Book Title},
  publisher = {Publisher Name},
  year = {2024}
}
```

Formatting rules:

- Use meaningful citation keys, such as `FirstAuthor2024keyword`.
- Protect capitalization in titles with braces, for example `{DNA}`.
- Use two hyphens for page ranges: `123--145`.
- Include a DOI for every modern publication.
- Standardize field order, indentation, and spacing.
- Remove unnecessary fields.
- Fix missing commas, braces, and quoting.
- Sort entries by citation key, year, or author.
- Remove duplicate entries.
- Validate syntax before submission.

## Citation validation

Validate every bibliography before submission. Check:

- DOI resolves through doi.org.
- BibTeX metadata matches CrossRef metadata.
- All required fields exist for the entry type.
- Author names are formatted correctly.
- Year is a four-digit value in a reasonable range.
- Volume and number are numeric.
- Page ranges use two hyphens.
- URLs are accessible.
- Citation keys are unique.
- No duplicate DOI, title, or author/year/title combination.
- BibTeX syntax is valid.
- Special characters are escaped or encoded correctly.

Auto-fix common issues when safe. Review remaining errors manually.

## Workflow

1. Search Google Scholar and PubMed for the topic.
2. Save search queries, dates, filters, and result counts.
3. Extract metadata from identifiers in the search results.
4. Add known papers by DOI.
5. Combine all BibTeX entries.
6. Format, sort, and deduplicate the file.
7. Validate citations and review the report.
8. Fix broken DOIs, missing fields, and duplicates.
9. Use the final file in the manuscript.

## Best practices

### Search

- Start broad, then narrow the query.
- Use multiple databases for comprehensive coverage.
- Include synonyms and related terms.
- Review references from key papers.
- Track new citations with alerts.

### Metadata

- Always use DOIs when available.
- Spot-check extracted metadata.
- Handle preprints, conference papers, and book chapters explicitly.
- Use the published version of a preprint when available.

### BibTeX quality

- Follow one citation key convention.
- Keep formatting consistent.
- Organize files by project.
- Merge files carefully to avoid duplicates.

### Validation

- Validate citations when adding them.
- Validate the complete bibliography before submission.
- Re-validate after manual edits.
- Manually verify key citations.

## Integration with literature review

- Use literature review for systematic search and synthesis.
- Use citation management for metadata extraction and validation.
- Validate the final bibliography after synthesis.
- Keep citation handling separate from thematic analysis.

## Common pitfalls

- Using only one database. Search multiple sources.
- Accepting metadata without verification. Spot-check it.
- Leaving broken DOIs. Validate before submission.
- Mixing citation key styles. Standardize them.
- Keeping duplicate entries. Run duplicate detection.
- Omitting required fields. Validate completeness.
- Citing an outdated preprint. Update to the journal version.
- Breaking LaTeX with special characters. Escape or encode them.
- Typing BibTeX by hand. Extract from metadata sources.

## Checklist

- [ ] Search queries and filters are documented.
- [ ] Results come from more than one database.
- [ ] All citations have complete metadata.
- [ ] DOIs resolve correctly.
- [ ] BibTeX entries use consistent formatting.
- [ ] Duplicates are removed.
- [ ] Required fields are present.
- [ ] Citation keys are unique.
- [ ] Validation report has no high-severity errors.
- [ ] Final bibliography is validated before submission.

## Related skills

Load these when the task spans more than this skill.

- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
- [`research-critique`](../research-critique/SKILL.md) — Systematically evaluate scientific research rigor, methodology, and claims. Use for peer review of manuscripts…
- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`pubmed-database`](../pubmed-database/SKILL.md) — Guides you to build advanced PubMed queries, use MeSH terms, filter results, and retrieve records programmatic…
- [`paper-to-web`](../paper-to-web/SKILL.md) — Convert academic papers (LaTeX or PDF) into interactive websites, presentation videos, and conference posters…
- [`scientific-slides`](../scientific-slides/SKILL.md) — Generates scientific presentation slides (PDF, PowerPoint, or LaTeX Beamer) using AI‑generated images, provide…
- [`content-writing`](../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
