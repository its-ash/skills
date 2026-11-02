# SEO Blog, Calendar, and Collaborative Writing

Templates and checklists for [`content-writing`](../SKILL.md). Voice profiles: [brand-voice.md](brand-voice.md). Social platform strategy: [social-content.md](social-content.md).

## Quick brand-voice guide (when no full VOICE PROFILE is needed)
1. Collect existing copy. 2. Note formality, perspective, recurring adjectives. 3. Pick 3-5 tone descriptors. 4. Write the guide. 5. Write three samples; refine until they match.
```markdown
# Brand Voice
- Tone: Friendly, confident, concise
- Perspective: First-person plural (we)
- Formality: Conversational, no undefined jargon
- Key vocabulary: "you", "our solution", "quick wins"
- Avoid: "utilize", unexplained acronyms, passive voice
- Good: "We help you launch faster."
- Bad: "Our platform enables utilization of resources."
```

## SEO blog post
Keyword research: one primary keyword (500-5,000 monthly searches), 3-5 secondary, 10-15 LSI terms; record search intent (informational, transactional, ...).

| Element | Rule |
|---|---|
| Title | Primary keyword; < 60 chars |
| URL | Primary keyword |
| Meta description | 150-160 chars; primary keyword; CTA |
| Intro | Primary keyword in first 100 words |
| Headings | H1 -> H2 -> H3; keywords in at least 2 H2s |
| Body | 1,500-2,500 words; keyword density 1-3% |
| Links | 2-3 internal; at least 2 external to reputable sources (.gov, .edu, industry leaders) |
| Images | Alt text with relevant keywords |
| Readability | Matches audience (e.g. Flesch-Kincaid grade 8-10) |
| Close | Summary + clear CTA |

## Platform quick limits
| Platform | Max length | Format | Hashtags |
|---|---|---|---|
| X/Twitter | 280 chars | Short hook + link | 1-3 |
| LinkedIn | 1,300 chars (post) | Professional, value-first | 3-5 industry |
| Instagram | 2,200 chars | Visual-first, emojis OK | 5-10 niche |
| Facebook | 63,206 chars | Conversational, story | 1-2 |

Steps: core message from the long piece -> adapt tone and length -> correctly sized visuals -> hashtags -> schedule.

## Content calendar
1. Set monthly KPIs (e.g. organic traffic +10%, 5 shares per post).
2. Pillar split default: 40% educational, 25% promotional, 25% community, 10% evergreen.
3. Map topics to launches, events, seasons.
4. Batch-write a week in one session for voice consistency.
5. Link each piece to its assets.
6. At month end, compare metrics to goals; adjust.

```markdown
| Date | Platform | Content Type | Topic | Owner | Status |
|------|----------|--------------|-------|-------|--------|
| 2026-11-01 | Blog | Long-form | AI in Marketing | Alice | Draft |
| 2026-11-02 | X | Post | AI stat #1 | Bob | Scheduled |
```

## Collaborative research-writing
- Outline skeleton:
```markdown
# Article Outline: [Title]
## Hook — opening line or statistic; why the reader cares
## Introduction — context; problem; what the article covers
## Section N: [Title] — key point; evidence / citation needed
## Conclusion — summary; CTA
## Research To-Do
- [ ] Find data on ...
```
- Research: ask for the citation style (inline, numbered, footnote). Use credible sources (industry reports, papers, reputable news). Extract facts, figures, quotes with citations.
- Hook help: analyze the current hook; give three revised hooks with rationale.
- Section feedback: strengths, specific fixes (clarity, flow, evidence, style), line edits, questions for next revision.
- Voice preservation: learn diction, sentence length, tone from the author's samples. Suggest, do not overwrite; ask "Does this sound like you?"
- Final review: structure, argument and evidence, grammar, readability, citation completeness, CTA; end with a short pre-publish checklist.

## Pre-publish checklist
- [ ] Voice guide applied
- [ ] Primary keyword in title, URL, first paragraph, 2+ headings
- [ ] Meta description < 160 chars with primary keyword
- [ ] Keyword density 1-3%
- [ ] Heading hierarchy correct
- [ ] 2+ internal and 2+ external links
- [ ] Alt text on every image
- [ ] Readability fits audience
- [ ] Citations consistent and complete
- [ ] CTA present
- [ ] Scheduled in calendar
- [ ] Final proofread for typos and facts

## Pitfalls
- Keywords forced in after skipped research; keyword stuffing.
- Platform length or image specs ignored.
- Voice drifts across pieces.
- No proofread, citation check, or CTA.
- No performance review feeding the next plan.

## Metrics (record monthly)
| Metric | Signal |
|---|---|
| Organic traffic growth | SEO effect |
| Avg time on page | Relevance, readability |
| Bounce rate | Expectation match |
| Shares, likes | Resonance |
| Backlinks | Authority |
| Conversion rate | Business impact |
| Email CTR (repurposed) | Cross-channel effect |

Example tool commands (replace with available tools): `python -m brand_voice_analyzer content.txt`; `python -m seo_optimizer article.md "primary keyword" "secondary,keywords"`.
