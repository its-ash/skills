---
name: clear-writing
description: "The clear-writing skill edits human-focused prose—documentation, commit messages, UI copy, reports—to remove AI-generated patterns, add genuine voice, and apply Strunk's rules for concise, active, concrete writing. Use when rewriting drafts, polishing docs, commit messages, release notes, emails, essays, or UI text; fixing AI-sounding phrasing, inflated significance, vague attributions, promotional language, copula avoidance, negative parallelisms; editing Markdown, README, docs, messages."
---

# Clear Writing

Write prose that feels natural, purposeful, and easy to read. This skill combines William Strunk Jr.’s classic composition rules with a checklist of common AI‑generated patterns to eliminate. Use it for documentation, README files, commit messages, error messages, UI copy, reports, or any text a human will read.

---

## When to Use
- Drafting or revising technical documentation, tutorials, or API references.
- Writing commit messages, pull‑request descriptions, or changelogs.
- Creating error messages, help text, or UI copy.
- Preparing reports, summaries, or business communications.
- Editing any prose where clarity, brevity, and a human tone are required.

---

## Workflow
1. **Read the draft** fully to understand its purpose and audience.
2. **Identify** any of the AI patterns listed below.
3. **Rewrite** each flagged segment:
   - Replace inflated phrasing with concrete facts.
   - Use simple sentence structures (subject + verb + object).
   - Preserve the original meaning and intended tone.
4. **Apply Strunk’s rules** (active voice, positive form, omit needless words, etc.).
5. **Review** the revised text aloud to ensure it sounds natural and varied.
6. **Output** the edited version and optionally a short change summary.

---

## Strunk’s Core Rules (What to Do)
| # | Rule | How to Apply |
|---|------|--------------|
| 1 | **Active voice** | Subject performs the action (e.g., "The system saves files" instead of "Files are saved by the system"). |
| 2 | **Positive form** | State what is, not what isn’t (e.g., "Use the shortcut" rather than "Do not forget to avoid using the menu"). |
| 3 | **Definite, specific, concrete language** | Replace vague words with precise details ("3 GB of RAM" instead of "a lot of memory"). |
| 4 | **Omit needless words** | Delete filler ("in order to" → "to"). |
| 5 | **One idea per paragraph** | Start with a clear topic sentence; keep supporting sentences focused. |
| 6 | **Keep related words together** | Place modifiers next to the words they modify ("the rapidly expanding dataset" not "the dataset that is rapidly expanding"). |
| 7 | **Maintain a single tense** | Use past or present consistently within a summary or explanation. |
| 8 | **Place emphatic words at the end** | End sentences with the most important information for impact. |
| 9 | **Use commas correctly** | Follow Strunk’s comma rules (series, parenthetical, before coordinating conjunctions, etc.). |
|10| **Avoid dangling participles** | Ensure introductory phrases refer to the correct subject. |

---

## AI‑Generated Patterns to Avoid (What to Watch For)
### 1. Inflated Significance & Legacy
- Words: *pivotal, testament, crucial, enduring, landmark, key turning point*.
- Fix: State the fact plainly without grandiose framing.

### 2. Notability & Media‑Coverage Overkill
- Phrases: *cited in major outlets, active social‑media presence*.
- Fix: Cite a specific source or omit the claim.

### 3. Superficial “‑ing” Analyses
- Phrases ending in *highlighting, underscoring, ensuring, reflecting*.
- Fix: Use a simple verb and concrete detail.

### 4. Promotional Language
- Words: *boasts, vibrant, groundbreaking, stunning, must‑visit*.
- Fix: Describe the feature or fact without hype.

### 5. Vague Attributions & Weasel Words
- Phrases: *experts say, industry reports suggest, some critics argue*.
- Fix: Provide a named source or remove the attribution.

### 6. Formulaic “Challenges and Future Prospects” Sections
- Boilerplate headings and sentences.
- Fix: Replace with specific, data‑driven statements.

### 7. Overused AI Vocabulary
- Words: *additionally, align with, delve, foster, landscape, pivotal, showcase*.
- Fix: Use simpler alternatives ("also", "match", "explore", "support", "area", "important", "show").

### 8. Copula Avoidance
- Constructions like *serves as, stands as, boasts*.
- Fix: Use *is* or *has*.

### 9. Negative Parallelisms
- Structures: *not only … but also*, *it’s not just … it’s …*.
- Fix: State the single idea directly.

###10. Rule of Three Overuse
- Grouping three items for the sake of completeness.
- Fix: List only what is needed; avoid forced triples.

###11. Synonym Cycling (Elegant Variation)
- Repeating the same idea with different synonyms.
- Fix: Use one clear expression.

###12. False Ranges
- Phrases like *from X to Y* without meaningful scale.
- Fix: State the actual endpoints or omit the range.

###13. Em‑dash Overuse
- Frequent “—” for emphasis.
- Fix: Use commas or periods.

###14. Excessive Boldface or Formatting
- Bold every noun or phrase.
- Fix: Reserve bold for true headings or key terms.

###15. Inline‑Header Lists
- Bullets that start with bolded headers followed by a colon.
- Fix: Write a fluid sentence that combines the points.

###16. Title‑Case Headings
- Capitalize every major word.
- Fix: Use sentence case (only first word capitalized unless a proper noun).

###17. Emojis in Professional Text
- Decorative emojis.
- Fix: Remove; keep text plain.

###18. Curly Quotation Marks
- “smart quotes”.
- Fix: Use straight quotes (`"`).

###19. Chatbot‑style Conversational Artifacts
- Phrases like *I hope this helps*, *let me know*, *here is a…*.
- Fix: Deliver the content directly.

###20. Knowledge‑Cutoff Disclaimers
- *As of my last update…*.
- Fix: Verify current facts or omit the disclaimer.

###21. Sycophantic Tone
- Overly positive, people‑pleasing language.
- Fix: State facts neutrally.

###22. Filler & Hedging Phrases
- *In order to*, *due to the fact that*, *it could potentially possibly*.
- Fix: Use concise equivalents (*to*, *because*, *may*).

###23. Generic Positive Conclusions
- Vague upbeat endings.
- Fix: End with a concrete next step or factual statement.

---

## How to Rewrite – Practical Patterns
- **Before:** "The update serves as a testament to our commitment to innovation, and it provides a seamless, intuitive, and powerful user experience—ensuring users can accomplish tasks efficiently."
- **After:**  "The update adds batch processing, keyboard shortcuts, and offline mode. Beta testers report faster task completion."

- **Before:** "In a 2024 New York Times interview, she argued that AI regulation should focus on outcomes rather than methods."
- **After:**  "She told the New York Times in 2024 that AI regulation should target outcomes, not methods."

- **Before:** "The system can process up to 10 GB of data per minute, thereby enhancing overall throughput."
- **After:**  "The system processes 10 GB of data per minute, increasing throughput."

---

## Checklist (Before You Finish)
- [ ] Have I removed inflated adjectives and buzzwords?
- [ ] Are all sentences in active voice?
- [ ] Does each paragraph focus on a single idea with a clear topic sentence?
- [ ] Have I replaced vague attributions with specific sources or omitted them?
- [ ] Did I eliminate unnecessary “‑ing” phrases and filler words?
- [ ] Is the text free of em‑dashes, bold overuse, emojis, and curly quotes?
- [ ] Are numbers, dates, and measurements concrete and accurate?
- [ ] Have I varied sentence length and rhythm to avoid a robotic cadence?
- [ ] Does the final version sound like a real person speaking, not a statistical prediction?

---

**Bottom line:** Apply Strunk’s rules first, then scan for the AI patterns above. The result should be concise, active, specific, and infused with genuine human voice.

## Related skills

Load these when the task spans more than this skill.

- [`content-writing`](../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
- [`copywriting`](../copywriting/SKILL.md) — Creates clear, compelling marketing copy for webpages (home, landing, pricing, feature, about, product) and pr…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`professional-communication`](../professional-communication/SKILL.md) — Provides frameworks, templates, and checklists for writing professional emails, internal updates, chat message…
- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
- [`career-profile`](../career-profile/SKILL.md) — Step‑by‑step guidance to optimize a LinkedIn profile for recruiter searchability and to create a creative port…
- [`notion`](../notion/SKILL.md) — Creates structured Notion pages from conversations, decisions, how‑tos, FAQs, or research findings. Use when y…
