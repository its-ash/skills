---
name: scientific-writing
description: "Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citations, figures and tables, reporting guidelines, and journal formatting. Use when drafting research papers, journal submissions, ML/AI conference papers (NeurIPS, ICML, ICLR, ACL, AAAI, COLM), systematic reviews, meta-analyses, literature review sections, abstracts, methods, results, discussion, or citation-checked academic writing."
---

# Scientific Writing

Write and revise scientific manuscripts as complete, flowing prose. Use a two-stage process: build section outlines with key points, then convert them into full paragraphs. Apply IMRAD or discipline-specific structure, verified citations, clear figures and tables, reporting guidelines, and journal formatting. For ML/AI conference papers, also apply narrative-driven structure, conference checklists, and LaTeX template workflows.

## When to use

- Draft or revise any manuscript section: abstract, introduction, methods, results, discussion.
- Structure a paper with IMRAD or another standard format.
- Format citations in APA, AMA, Vancouver, Chicago, IEEE, or another style.
- Create or improve figures, tables, and data visualizations.
- Apply reporting guidelines such as CONSORT, STROBE, PRISMA, STARD, TRIPOD, ARRIVE, CARE, SQUIRE, SPIRIT, or CHEERS.
- Prepare a manuscript for journal or conference submission.
- Improve clarity, conciseness, precision, terminology, or reviewer responses.
- Write ML/AI papers for NeurIPS, ICML, ICLR, ACL, AAAI, or COLM.

## Core principles

- Write the final manuscript in full paragraphs. Do not leave bullet points in the final text.
- Use bullet points only for planning, inclusion criteria, materials lists, or supplementary details.
- State the main contribution in one sentence before drafting.
- Verify every citation programmatically. Never write BibTeX from memory.
- Include at least one figure or schematic; prefer 2-3 for comprehensive papers.
- Start from the data story: figures and tables first, then text.

## Manuscript structure

### IMRAD

- Introduction: establish context, review literature, identify gaps, state objectives or hypotheses.
- Methods: describe design, population or samples, procedures, materials, analysis, ethics.
- Results: present findings objectively, from primary to secondary outcomes.
- Discussion: interpret results, compare with prior work, state limitations, propose implications and future work.

### Alternative structures

Use review articles, case reports, meta-analyses, theoretical papers, methods papers, or protocols when the study type requires them.

### ML/AI conference paper workflow

For top ML/AI venues, work in this order:

1. Define the one-sentence contribution with the scientist.
2. Draft Figure 1.
3. Draft the abstract.
4. Draft the introduction.
5. Draft methods.
6. Draft experiments.
7. Draft related work.
8. Draft limitations.
9. Complete the required paper checklist.
10. Revise and submit.

Each step should include drafting, feedback, and revision.

## Section writing guidance

### Abstract

- Write 100-250 words as a standalone summary.
- Include purpose, methods, results, and conclusions.
- Use structured or unstructured format as required by the journal.
- For ML papers, use a 5-sentence formula: what you achieved; why it is hard and important; how you did it with specialist keywords; what evidence you have; your most remarkable result.
- Delete generic openings such as "Large language models have achieved remarkable success..."

### Introduction

- Establish importance of the problem.
- Review relevant literature systematically.
- Identify gaps, controversies, or limitations.
- State clear research questions or hypotheses.
- Explain novelty and significance.
- Keep to about 1-1.5 pages in two-column ML formats.
- Include a 2-4 bullet contribution list with one to two lines per bullet.

### Methods

- Enable reimplementation.
- Include participant or sample descriptions, procedures, materials, equipment, and ethical approvals.
- List all hyperparameters, seeds, search ranges, and compute details for ML experiments.
- Present final design decisions; put ablations in experiments.
- Use lists only for inclusion criteria, materials, or reagents.

### Results

- Present findings objectively, without interpretation.
- Move from primary to secondary outcomes.
- Integrate figures and tables without duplicating their content.
- Report exact values, effect sizes, confidence intervals, and sample sizes.
- State what each experiment supports and how it connects to the main claim.

### Discussion

- Relate findings to research questions.
- Compare with existing literature.
- Acknowledge limitations honestly.
- Propose mechanisms, implications, and future research.
- Do not overstate findings.

## Two-stage writing process

### Stage 1: Outline with key points

Use literature search tools such as research-lookup to gather sources. Create a structured outline with bullet points for:

- Main arguments or findings.
- Key studies to cite.
- Data points and statistics.
- Logical order.

Example outline:

```text
- Background: AI in drug discovery is gaining traction
  - Cite recent reviews (Smith 2023, Jones 2024)
  - Traditional methods are slow and expensive
- Gap: limited application to rare diseases
  - Only two prior studies (Lee 2022, Chen 2023)
- Our approach: transfer learning from common diseases
  - Novel architecture combining X and Y
- Objective: validate on three rare disease datasets
```

### Stage 2: Convert to full paragraphs

Expand each point into complete sentences. Add transitions, integrate citations into sentences, add context, and check flow.

Example conversion:

```text
Artificial intelligence approaches have gained significant traction in drug discovery pipelines over the past decade (Smith, 2023; Jones, 2024). While these computational methods show promise for accelerating therapeutic candidate identification, traditional experimental approaches remain slow and resource-intensive. However, AI application to rare diseases has been limited, with only two prior studies demonstrating proof-of-concept results (Lee, 2022; Chen, 2023). The primary obstacle has been scarce training data for small patient populations.

To address this challenge, we developed a transfer learning approach that leverages knowledge from well-characterized common diseases to predict therapeutic targets for rare conditions. Our neural architecture combines convolutional layers for molecular feature extraction with attention mechanisms for protein-ligand interaction modeling. The objective of this study was to validate the approach across three independent rare disease datasets, assessing predictive accuracy and biological interpretability.
```

### Rules for lists

- Never leave bullet points in abstract, introduction, results, discussion, or conclusions.
- Lists are acceptable in methods for inclusion or exclusion criteria, materials, reagents, or participant characteristics.
- Lists are acceptable in supplementary materials for extended protocols, equipment lists, or detailed parameters.
- Read paragraphs aloud to check natural flow.

## Citations and references

### Citation styles

- AMA: numbered superscript citations, common in medicine.
- Vancouver: numbered citations in square brackets, biomedical standard.
- APA: author-date in-text citations, common in social sciences.
- Chicago: notes-bibliography or author-date.
- IEEE: numbered square brackets, engineering and computer science.

### Best practices

- Cite primary sources when possible.
- Include recent literature, usually the last 5-10 years in active fields.
- Balance citations across introduction and discussion.
- Verify all citations against original sources.
- Use reference management software such as Zotero, Mendeley, or EndNote.

### Citation verification

Never hallucinate citations. AI-generated citations have a high error rate.

- Search an API or database first.
- Verify author, title, year, venue, and DOI.
- Fetch BibTeX programmatically.
- If a citation cannot be verified, mark it explicitly as a placeholder and tell the scientist.

Example placeholder:

```latex
\cite{PLACEHOLDER_author2024_verify_this}  % TODO: Verify this citation exists
```

Optional paper search tools include Exa MCP and Semantic Scholar. Example setup:

```bash
claude mcp add exa -- npx -y mcp-remote "https://mcp.exa.ai/mcp"
```

MCP settings:

```json
{
  "mcpServers": {
    "exa": {
      "type": "http",
      "url": "https://mcp.exa.ai/mcp"
    }
  }
}
```

### Related work for ML papers

Organize related work by method or assumption, not paper by paper.

Good: "One line of work uses assumption A [refs], whereas we use assumption B because..."

Bad: "Snap et al. introduced X while Crackle et al. introduced Y."

Cite generously because reviewers may have authored relevant papers.

## Figures and tables

### When to use each

- Tables: precise numerical data, complex datasets, multiple variables requiring exact values.
- Figures: trends, patterns, relationships, comparisons best understood visually.

### Design principles

- Make each table or figure self-explanatory with a complete caption.
- Use consistent formatting and terminology across all display items.
- Label all axes, columns, and rows with units.
- Include sample sizes and statistical annotations.
- Avoid duplicating information between text, tables, and figures.
- Use about one table or figure per 1000 words as a guideline.
- Ensure Figure 1 conveys the core idea, approach, or most compelling result.
- Write captions that stand alone without the main text.
- Use vector graphics for plots.
- Ensure readability in black and white.
- Use a scientific-schematics tool for methodology flowcharts and conceptual diagrams when available.

### Common figure types

Bar graphs, line graphs, scatterplots, box plots, and heatmaps.

## Reporting guidelines

Use the guideline that matches the study type:

- CONSORT: randomized controlled trials.
- STROBE: observational studies.
- PRISMA: systematic reviews and meta-analyses.
- STARD: diagnostic accuracy studies.
- TRIPOD: prediction model studies.
- ARRIVE: animal research.
- CARE: case reports.
- SQUIRE: quality improvement studies.
- SPIRIT: study protocols for clinical trials.
- CHEERS: economic evaluations.

Each guideline provides a checklist for completeness and transparency.

## Writing style and clarity

### Core principles

- Clarity: precise language, defined terms and abbreviations, logical flow, active voice when it improves clarity.
- Conciseness: remove redundant words, favor shorter sentences, remove unnecessary qualifiers, respect word limits.
- Accuracy: exact values, consistent terminology, distinguish observations from interpretations, acknowledge uncertainty.
- Objectivity: no bias, no overstated findings, acknowledge conflicting evidence, neutral tone.

### Sentence-level clarity

Apply these reader-expectation principles:

- Keep subject and verb close.
- Put emphasis at sentence ends.
- Put context before new information.
- Put familiar information before unfamiliar information.
- Give each paragraph one main point.
- Use verbs instead of nominalizations.
- Set the stage before presenting equations or results.

### Micro-level tips

- Minimize pronouns; replace "this" with a noun.
- Put verbs early in sentences.
- Unfold awkward apostrophes.
- Delete filler words such as actually, very, really, basically, quite, and essentially.
- Be specific: use accuracy or latency instead of performance.
- Eliminate hedging unless uncertainty is genuine.
- Avoid incremental vocabulary such as combine or modify when propose or introduce is more accurate.
- Delete intensifiers.

### Precision over brevity

- Use one term for one concept throughout.
- State assumptions explicitly before theorems.
- Pair intuition with rigor.

### Tense and terminology

- Use past tense for methods and results.
- Use present tense for established facts.
- Define abbreviations at first use.
- Match terminology to the target field and audience.
- Use person-first language where appropriate.

## Field-specific terminology

Adapt language to the discipline. Review recent high-impact papers in the target journal and follow their conventions.

Examples:

- Biomedical: use precise clinical terms, generic drug names first, patients for clinical studies, participants for community research, SI units.
- Molecular biology: italicize gene symbols, use species-specific capitalization, follow standard genetic notation.
- Chemistry: follow IUPAC nomenclature, report concentrations with standard units.
- Ecology: use binomial nomenclature and standardized ecological metrics.
- Physics and engineering: use SI units and standard notation.
- Neuroscience: use standardized brain region nomenclature and recording terms.
- Social and behavioral sciences: use person-first language and validated construct names.

General rules:

- Define technical terms strategically for the audience.
- Maintain consistent terminology and abbreviations.
- Avoid mixing terminology from adjacent fields.
- Verify uncertain terms against field style guides or recent papers.

## ML/AI conference requirements

### Narrative and contribution

- A paper is one clear, evidence-based technical story.
- State three pillars by the end of the introduction: what you claim, why the evidence supports it, and why readers should care.
- If you cannot state the contribution in one sentence, the paper is not ready.

### Abstract and introduction

- Spend roughly equal time on abstract, introduction, figures, and everything else combined.
- Most reviewers read abstract, introduction, and figures before methods.
- Front-load the contribution.

### Experiments

For each experiment, state:

- What claim it supports.
- How it connects to the main contribution.
- The experimental setting.
- What the reader should observe.

Include error bars with methodology, hyperparameter search ranges, compute infrastructure, and seed-setting methods.

### Limitations

All major conferences require a limitations section. Acknowledge weaknesses honestly and explain why they do not undermine the core claims.

### Conference quick reference

| Conference | Page limit | Extra camera-ready | Key requirement |
|---|---:|---:|---|
| NeurIPS 2025 | 9 | +0 | Mandatory checklist, lay summary for accepted papers |
| ICML 2026 | 8 | +1 | Broader Impact Statement required |
| ICLR 2026 | 9 | +1 | LLM disclosure required |
| ACL 2025 | 8 long | varies | Limitations section mandatory |
| AAAI 2026 | 7 | +1 | Strict style file adherence |
| COLM 2025 | 9 | +1 | Focus on language models |

Universal requirements: double-blind review, references not counted in page limit, unlimited appendices, LaTeX required.

### LaTeX template workflow

1. Copy the entire template directory, not only main.tex.
2. Compile the unmodified template first.
3. Keep template examples as comments while replacing content.
4. Replace content section by section.
5. Use template macros.
6. Clean template artifacts only at the end.

Compile frequently:

```bash
latexmk -pdf main.tex
```

Or manually:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

Template pitfalls:

- Copying only main.tex misses style files.
- Editing .sty files breaks formatting.
- Adding unnecessary packages causes conflicts.
- Deleting template content too early removes formatting reference.
- Infrequent compilation lets errors accumulate.

### Template quick reference

| Conference | Main file | Key style file |
|---|---|---|
| NeurIPS 2025 | main.tex | neurips.sty |
| ICML 2026 | example_paper.tex | icml2026.sty |
| ICLR 2026 | iclr2026_conference.tex | iclr2026_conference.sty |
| ACL | acl_latex.tex | acl.sty |
| AAAI 2026 | aaai2026-unified-template.tex | aaai2026.sty |
| COLM 2025 | colm2025_conference.tex | colm2025_conference.sty |

### Resubmission and format conversion

When moving between venues:

1. Start from the target template.
2. Copy only content sections, not preambles.
3. Adjust page limits and requirements.
4. Verify compilation and formatting.

Common adjustments:

- NeurIPS 9 to ICML 8: cut one page; add Broader Impact if missing.
- ICML 8 to ICLR 9: expand experiments; add LLM disclosure.
- NeurIPS 9 to ACL 8: restructure for NLP conventions; add Limitations.
- ICLR 9 to AAAI 7: make significant cuts; follow strict style.
- Any to COLM 9: reframe for language model focus.

When cutting pages, move proofs to appendices, condense related work, combine experiments, use smaller figures, and tighten prose.

## Collaboration and proactivity

For ML/AI papers, be proactive: deliver a complete first draft when the contribution is clear, then iterate.

- High confidence: write the full draft and flag uncertainties.
- Medium confidence: write the draft with flagged uncertainties.
- Low confidence: ask one or two targeted questions, then draft.

Draft autonomously and flag with the draft for abstract, introduction, methods, experiments, and related work. Block for input only when the venue is unclear, framings conflict, results seem inconsistent, or the scientist requests review.

## Common pitfalls

Top rejection reasons:

- Inappropriate, incomplete, or insufficiently described statistics.
- Over-interpretation or unsupported conclusions.
- Poorly described methods that harm reproducibility.
- Small, biased, or inappropriate samples.
- Poor writing quality or difficult-to-follow text.
- Inadequate literature review or context.
- Unclear or poorly designed figures and tables.
- Failure to follow reporting guidelines.

Writing quality issues:

- Mixing tenses inappropriately.
- Excessive jargon or undefined acronyms.
- Paragraph breaks that disrupt logical flow.
- Missing transitions between sections.
- Inconsistent notation or terminology.

## Checklist

- [ ] Target journal or venue and author guidelines identified.
- [ ] Applicable reporting guideline selected.
- [ ] Manuscript structure chosen.
- [ ] Figures and tables planned as the data story.
- [ ] Section outlines created with key points.
- [ ] Outlines converted to full paragraphs.
- [ ] No bullet points remain in final manuscript except allowed cases.
- [ ] Citations verified programmatically.
- [ ] Unverified citations marked as placeholders.
- [ ] Figures and tables are self-explanatory.
- [ ] Terminology is consistent and field-appropriate.
- [ ] Limitations stated honestly.
- [ ] Word counts checked.
- [ ] Reporting guideline checklist completed.
- [ ] Journal or conference formatting requirements met.
- [ ] Supplementary materials prepared.
- [ ] Final proofread completed.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/literature-review.md](references/literature-review.md) | Conduct systematic literature reviews across biomedical and scientific domains using multiple databases (PubMed, arXiv, bioRxiv, Semantic Scholar). Covers search strategy, screening, data extraction, thematic synthesis, citation verification, and professional document generation. Use for systematic reviews, meta-analyses, research synthesis, or literature review sections of papers. |

## Related skills

Load these when the task spans more than this skill.

- [`citation-management`](../citation-management/SKILL.md) — Manage academic citations: search Google Scholar and PubMed, extract metadata from DOI, PMID, arXiv ID, or URL…
- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`research-critique`](../research-critique/SKILL.md) — Systematically evaluate scientific research rigor, methodology, and claims. Use for peer review of manuscripts…
- [`pubmed-database`](../pubmed-database/SKILL.md) — Guides you to build advanced PubMed queries, use MeSH terms, filter results, and retrieve records programmatic…
- [`docx`](../docx/SKILL.md) — Create, read, edit, and analyze Word .docx files using docx‑js (JavaScript) or python‑docx, covering page layo…
- [`clear-writing`](../clear-writing/SKILL.md) — The clear‑writing skill helps you edit any human‑focused prose—documentation, commit messages, UI copy, report…
- [`hypothesis-generation`](../hypothesis-generation/SKILL.md) — Generate testable scientific hypotheses through structured ideation and evidence synthesis. Combines conversat…
