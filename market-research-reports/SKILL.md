---
name: market-research-reports
description: "Generate 50-plus page market research reports with consulting-style analysis, strategic frameworks including Porter Five Forces, PESTLE, SWOT, TAM SAM SOM, BCG matrix, data-driven visualizations, and LaTeX PDF output. Use when you need market sizing, competitive landscape analysis, industry analysis, investment thesis writing, go-to-market strategy development, sector reports, equity research, due diligence documents, business plan appendices, or strategic planning deliverables requiring professional formatting and framework-driven insights."
---

# Market Research Reports

Generate professional 50+ page market research reports for strategic decisions. Reports combine market sizing, competitive analysis, industry trends, risk assessment, and actionable recommendations in consulting-firm style.

## When to use

- Investment or M&A due diligence
- Industry and market analysis
- Market entry or go-to-market planning
- TAM/SAM/SOM sizing
- Competitive landscape assessment
- Regulatory impact analysis
- Product launch business cases
- Thought leadership reports

## Visual requirements

Generate 6 core visuals before writing; add more as sections need them.

Core visuals:

1. Executive summary infographic
2. Market growth trajectory
3. TAM/SAM/SOM breakdown
4. Porter's Five Forces
5. Competitive positioning matrix
6. Risk heatmap

Tools:

- Use scientific-schematics for charts, diagrams, matrices, heatmaps, and timelines.
- Use generate-image for hero infographics and conceptual illustrations.

Recommended additional visuals by section:

| Section | Priority visuals | Optional visuals |
| --- | --- | --- |
| Executive summary | Executive infographic | - |
| Market size and growth | Growth trajectory, TAM/SAM/SOM | Regional breakdown, segment growth |
| Competitive landscape | Porter's Five Forces, positioning matrix | Market share chart, strategic groups |
| Risk analysis | Risk heatmap | Mitigation matrix |
| Strategic recommendations | Opportunity matrix | Priority framework |
| Implementation roadmap | Timeline/Gantt | Milestone tracker |
| Investment thesis | Financial projections | Scenario analysis |

## Report structure

### Front matter (~5 pages)

- Cover page with hero visual
- Table of contents
- List of figures and tables
- Executive summary: market snapshot, investment thesis, key findings, recommendations, infographic

### Core analysis (~35 pages)

- **Market overview and definition**: ecosystem, stakeholders, boundaries, history. Visuals: value chain, industry structure.
- **Market size and growth**: TAM, SAM, SOM, historical and projected growth, drivers and inhibitors, regional and segment breakdown. Visuals: growth trajectory, TAM/SAM/SOM, regional breakdown, segment growth.
- **Industry drivers and trends**: macro, technology, regulatory, social, environmental factors. Frameworks: PESTLE, trend impact matrix. Visuals: trends timeline or radar, driver impact matrix, PESTLE.
- **Competitive landscape**: market structure, players, share, positioning, barriers, dynamics. Frameworks: Porter's Five Forces, positioning matrix, strategic groups. Visuals: five forces, market share, positioning matrix, strategic groups.
- **Customer analysis and segmentation**: segments, size and growth, buying behavior, needs, decision process, value drivers. Frameworks: segmentation matrix, value proposition canvas, customer journey. Visuals: segment breakdown, attractiveness matrix, journey or value proposition.
- **Technology and innovation**: current stack, emerging technologies, adoption, R&D, patents. Frameworks: technology readiness, hype cycle, roadmap. Visuals: roadmap, adoption or hype cycle.
- **Regulatory and policy environment**: framework, bodies, compliance, upcoming changes, impact. Visual: regulatory timeline or framework.
- **Risk analysis**: market, competitive, regulatory, technology, operational, and financial risks with mitigations. Frameworks: risk heatmap, risk register, mitigation matrix. Visuals: heatmap, mitigation matrix.

### Strategic recommendations (~10 pages)

- **Opportunities and recommendations**: identify, size, analyze options, prioritize, define success factors. Frameworks: opportunity attractiveness, build/buy/partner/ignore, priority matrix. Visuals: opportunity matrix, options framework, priority matrix.
- **Implementation roadmap**: phases, milestones, resources, timeline, dependencies, governance. Visuals: Gantt or timeline, milestone tracker.
- **Investment thesis and projections**: summary, projections, scenarios, returns, assumptions, sensitivity. Visuals: projection chart, scenario comparison.

### Back matter (~5 pages)

- Methodology and data sources
- Detailed market data tables
- Company profiles
- References

## Workflow

### Phase 1: Research and data gathering

1. Define scope: market definition, geography, time horizon, key questions.
2. Gather data with research-lookup for market size and growth, competitors and share, trends and drivers, and regulations.
3. Cross-check sources where possible.
4. Organize notes by section and identify gaps.
5. Conduct follow-up research for missing data.

### Phase 2: Analysis and framework application

1. Size the market as TAM to SAM to SOM with clear assumptions.
2. Rate each Porter force as high, medium, or low with rationale.
3. Analyze PESTLE dimensions with trends and impacts.
4. Complete SWOT: strengths, weaknesses, opportunities, threats.
5. Define positioning axes and plot competitors.
6. Synthesize insights, implications, recommendations, and priorities.

### Phase 3: Visual generation

1. Generate all core visuals before writing.
2. Add section-specific visuals as needed.
3. Keep colors, labels, and source attribution consistent.

### Phase 4: Report writing

1. Create a project folder with drafts, references, figures, sources, and final outputs.
2. Write each section with full coverage.
3. Support claims with data and cite sources.
4. Reference all generated figures.
5. Use consulting-style tone.
6. Lead with insights and support with data.
7. Use numbered lists for recommendations.
8. Do not abbreviate content to save space.

### Phase 5: Compilation and review

1. Compile LaTeX with XeLaTeX and BibTeX in this order: xelatex, bibtex, xelatex, xelatex.
2. Validate the report against quality standards.
3. Review for comprehensiveness, accuracy, logical flow, and recommendation quality.

## Quality standards

### Page targets

| Section | Minimum pages | Target pages |
| --- | ---: | ---: |
| Front matter | 4 | 5 |
| Market overview | 4 | 5 |
| Market size and growth | 5 | 7 |
| Industry drivers | 4 | 6 |
| Competitive landscape | 5 | 7 |
| Customer analysis | 3 | 5 |
| Technology landscape | 3 | 5 |
| Regulatory environment | 2 | 4 |
| Risk analysis | 2 | 4 |
| Strategic recommendations | 3 | 5 |
| Implementation roadmap | 2 | 4 |
| Investment thesis | 2 | 4 |
| Back matter | 4 | 5 |
| Total | 43 | 66 |

### Visual quality

- Use at least 300 DPI resolution.
- Use PNG for raster images and PDF for vector images.
- Use colorblind-friendly palettes.
- Keep one consistent color scheme throughout.
- Label all axes, legends, and data points.
- Cite sources in figure captions.

### Data quality

- Use data no older than 2 years when possible.
- Attribute every statistic to a specific source.
- Cross-reference multiple sources when possible.
- State assumptions behind projections.
- Acknowledge data limitations and gaps.

### Writing quality

- Present balanced analysis and acknowledge uncertainty.
- Avoid jargon and define technical terms.
- Use specific numbers instead of vague qualifiers.
- Use clear headings, logical flow, and smooth transitions.
- Make recommendations specific and implementable.

## LaTeX formatting

Use the report class and a consistent custom style. If a market research style package is available, use it; otherwise define equivalent colors, boxes, and table styles.

Box environments:

```latex
\begin{keyinsightbox}[Key Finding]
The market is projected to grow at 15.3% CAGR through 2030.
\end{keyinsightbox}

\begin{marketdatabox}[Market Snapshot]
\begin{itemize}
\item Market Size (2024): $45.2B
\item Projected Size (2030): $98.7B
\item CAGR: 15.3%
\end{itemize}
\end{marketdatabox}

\begin{riskbox}[Critical Risk]
Regulatory changes could impact 40% of market participants.
\end{riskbox}

\begin{recommendationbox}[Strategic Recommendation]
Prioritize market entry in the Asia-Pacific region.
\end{recommendationbox}

\begin{calloutbox}[Definition]
TAM (Total Addressable Market) represents the total revenue opportunity.
\end{calloutbox}
```

Figure formatting:

```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=0.9\textwidth]{../figures/market_growth.png}
\caption{Market Growth Trajectory (2020-2030). Source: Industry analysis, company data.}
\label{fig:market_growth}
\end{figure}
```

Table formatting:

```latex
\begin{table}[htbp]
\centering
\caption{Market Size by Region (2024)}
\begin{tabular}{@{}lrrr@{}}
\toprule
\textbf{Region} & \textbf{Size (USD)} & \textbf{Share} & \textbf{CAGR} \\
\midrule
North America & $18.2B & 40.3\% & 12.5\% \\
\rowcolor{tablealt} Europe & $12.1B & 26.8\% & 14.2\% \\
Asia-Pacific & $10.5B & 23.2\% & 18.7\% \\
\rowcolor{tablealt} Rest of World & $4.4B & 9.7\% & 11.3\% \\
\midrule
\textbf{Total} & \textbf{$45.2B} & \textbf{100\%} & \textbf{15.3\%} \\
\bottomrule
\end{tabular}
\label{tab:market_by_region}
\end{table}
```

## Integration

This skill works with research-lookup, scientific-schematics, generate-image, peer-review, and citation-management.

## Checklist

- Cover page with hero visual
- Table of contents
- List of figures and tables
- Executive summary of 2-3 pages
- All chapters complete
- Total length of 50+ pages
- At least 6 core visuals
- All statistics sourced
- Frameworks applied
- Recommendations prioritized
- Clean PDF without errors

## Related skills

Load these when the task spans more than this skill.

- [`marketing-strategy`](../marketing-strategy/SKILL.md) — Comprehensive playbook for product marketing, positioning, GTM planning, demand generation, paid media, SEO, p…
- [`pricing-strategy`](../pricing-strategy/SKILL.md) — A step‑by‑step framework for SaaS pricing and monetization, covering research methods, value‑metric selection,…
- [`lead-research`](../lead-research/SKILL.md) — Lead Research skill finds and qualifies high‑quality prospects for a product or service. Provide product detai…
- [`research-engineer`](../research-engineer/SKILL.md) — Research Engineer skill for rigorous, correctness-first engineering. Use when implementing algorithms, optimiz…
- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`perplexity-research`](../perplexity-research/SKILL.md) — Perplexity‑Research runs real‑time web searches with Perplexity models via OpenRouter. Use for generic look‑up…
- [`app-store-optimization`](../app-store-optimization/SKILL.md) — Provides end‑to‑end guidance for researching keywords, optimizing metadata, managing reviews, planning launche…
