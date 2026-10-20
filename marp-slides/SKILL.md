---
name: marp-slides
description: "Generates Marp markdown presentation files with custom themes, structured slide layouts, embedded images, Mermaid diagrams, and export-ready HTML, PDF, or PPTX output. Use when a user requests marp slides, markdown presentation, slide deck, .md slides, marp file, presentation markdown, npx marp, marp-cli, @marp-team/marp-cli, vscode marp extension, marp build, export pdf, export pptx, export html, theme yaml, frontmatter theme, mermaid diagram, image syntax, slide separator, pagination, speaker notes, or design review for presentations."
---

# Marp Slide Creator
Create clean, attractive Marp slides with built‑in themes. Follow the workflow, apply the rules, and run the final checklist before delivering the `.md` file.

## When to Use
- The user asks for a Marp presentation.
- The user says “make the slides look good”, “nice design”, or similar.
- The user needs lecture, seminar, or business material.
- The user wants bullet‑point slides with occasional images.

## Theme Selection
| Content type | Recommended theme |
|--------------|-------------------|
| Technical / developer | **tech** |
| Business / corporate | **business** |
| Creative / event | **colorful** or **gradient** |
| Academic / simple | **minimal** |
| General or unknown | **default** |
| Dark background preferred | **dark** or **tech** |

**How to pick**
1. Identify the main audience and tone.
2. Match the audience to the table above.
3. If still unsure, fall back to **default**.

## Slide Structure and Syntax
### General rules
- Start with a title slide that uses the lead class.
- Use `##` for slide titles. Keep titles short (5‑7 characters for Japanese, 1‑3 words for English).
- Limit each slide to 3‑5 bullet points.
- Keep line length under 25 characters.
- Add whitespace between sections.

### Title slide example
```markdown
<!-- _class: lead -->
# Presentation Title

Subtitle or presenter name
```

### Content slide example
```markdown
## Overview

- First key point
- Second key point
- Third key point
```

### Sub‑section (optional)
Use `###` for sub‑headings when a slide needs hierarchy.

## Image Integration
Use Marpit image directives. Common patterns:
- **Side image** (text left, image right): `![bg right:40%](image.png)`
- **Centered image** with width: `![w:600px](image.png)`
- **Full‑screen background**: `![bg](image.png)`
- **Multiple images**: place several `![bg]` lines on the same slide.

**Example with side image**
```markdown
## Architecture Diagram

![bg right:40%](arch.png)

- Component A handles input
- Component B processes data
- Component C stores results
```

## Workflow
1. **Gather requirements**
   - Note title, main topics, audience, and any image assets.
2. **Select theme** using the table above.
3. **Create a new file** with a descriptive name, e.g., `presentation.md`.
4. **Add the title slide** using the lead class.
5. **Add content slides**
   - Write a concise `##` title.
   - Add 3‑5 bullet points.
   - Insert images with the proper directives.
6. **Apply theme**
   - Insert the theme directive at the top of the file:
     ```markdown
     <!-- theme: tech -->   <!-- replace "tech" with the chosen theme name -->
     ```
7. **Run quality checks** (see checklist).
8. **Save** the file with a `.md` extension in the output directory.

## Common Pitfalls
- **Too much text** – limit bullets and line length.
- **Inconsistent heading levels** – use only `##` for slide titles, `###` for sub‑headings.
- **Missing theme directive** – slides revert to the default Marp style.
- **Incorrect image syntax** – ensure `![bg …]` or `![w:…]` is used, not plain Markdown image syntax.
- **Overly long titles** – keep titles short to maintain visual hierarchy.
- **No whitespace** – dense slides look cluttered.

## Checklist
- [ ] Theme matches content and audience.
- [ ] File starts with `<!-- theme: <name> -->`.
- [ ] Title slide uses `<!-- _class: lead -->`.
- [ ] All slide titles use `##` and are concise.
- [ ] Each slide has 3‑5 bullet points.
- [ ] No line exceeds 25 characters.
- [ ] Images use Marpit directives (`![bg …]`, `![w:…]`).
- [ ] Consistent whitespace between sections.
- [ ] File saved with `.md` extension in the output folder.

## References (inline summary)
- **Marp syntax** – directives start with `<!--` and end with `-->`. Use `theme`, `paginate`, `class`, etc.
- **Image syntax** – `![bg]`, `![bg right:40%]`, `![w:600px]`.
- **Theme CSS** – themes are embedded in the file; no external CSS needed.
- **Marp CLI** – to render the file, run `marp presentation.md` (outside the scope of this skill).

## Related skills

Load these when the task spans more than this skill.

- [`mermaid-diagrams`](../mermaid-diagrams/SKILL.md) — Generates Mermaid diagram code for flowcharts, sequence diagrams, class diagrams, ERDs, C4 architecture, state…
- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`scientific-slides`](../scientific-slides/SKILL.md) — Generates scientific presentation slides (PDF, PowerPoint, or LaTeX Beamer) using AI‑generated images, provide…
- [`clear-writing`](../clear-writing/SKILL.md) — The clear‑writing skill helps you edit any human‑focused prose—documentation, commit messages, UI copy, report…
- [`pptx`](../pptx/SKILL.md) — Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best‑practices, and…
