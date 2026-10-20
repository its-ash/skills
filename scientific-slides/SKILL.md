---
name: scientific-slides
description: "Generates scientific presentation slides as PDF, PowerPoint PPTX, or LaTeX Beamer decks using AI‑generated images from Nano Banana Pro, applying slide structure templates, design principles, citation formatting, and command‑line workflows for automated deck assembly. Use when creating research presentations, conference talks, academic seminars, or thesis defenses needing PDF slides, PowerPoint editable decks, Beamer LaTeX source, AI slide images, Nano Banana Pro CLI, slide layout rules, data visualization charts, figure embedding, bibliography management, citation styles, or automated slide generation from markdown outlines."
---

# Scientific Slides

Create clear, visually engaging research presentations. The skill guides you through slide planning, AI‑generated visuals, citation insertion, and final assembly for PDF, PowerPoint, or LaTeX Beamer formats.

## When to Use
- Conference talks (5‑20 min)
- Academic seminars (45‑60 min)
- Thesis or dissertation defenses
- Grant pitch presentations
- Journal club talks
- Institutional research talks
- Teaching tutorials on scientific topics

## Workflow Overview
Choose one of three output formats. All formats start with a **slide plan** that lists title, key points, visual elements, color scheme, and citations.

### 1. PDF Workflow (default, most visually striking)
1. **Plan each slide** in a markdown block (see example below).
2. **Generate slide images** with the Nano Banana Pro CLI.
3. **Combine images into a PDF**.

#### Step 1 – Slide Plan Example
```markdown
# Presentation Plan: Introduction to Machine Learning

## Slide 1 – Title
- Title: "Machine Learning: From Theory to Practice"
- Subtitle: "AI Conference 2025"
- Speaker: Dr. Jane Smith
- Visual: Abstract neural‑network background
- Formatting: dark blue background, white text, gold accents

## Slide 2 – Why ML Matters
- Title: "Why Machine Learning Matters"
- Points: Industry adoption; Breakthrough applications; Future potential
- Visual: Icons for healthcare, finance, robotics
- Citations: (LeCun et al., 2015; Goodfellow et al., 2016)
- Formatting: same as Slide 1

... continue for all slides ...
```

#### Step 2 – Generate Slide Images
Run the generation command for each slide. Include the **Formatting Goal** and any **CITATIONS** in the prompt. Attach the previous slide image with `--attach` to keep style consistent.

```bash
# Title slide (establishes style)
python generate_slide_image.py "Title slide: 'Machine Learning: From Theory to Practice'. Subtitle: 'AI Conference 2025'. Speaker: Dr. Jane Smith. FORMATTING GOAL: dark blue background, white text, gold accents, minimal design." -o slides/01_title.png

# Content slide with citations (attach previous slide)
python generate_slide_image.py "Slide titled 'Why Machine Learning Matters'. Three bullet points as listed. CITATIONS: (LeCun et al., 2015; Goodfellow et al., 2016). FORMATTING GOAL: match attached slide style." -o slides/02_why_ml.png --attach slides/01_title.png

# Results slide – attach figure from your data directory
python generate_slide_image.py "Slide titled 'Model Performance'. Show attached accuracy_chart.png. Highlight: 95% accuracy, 12% improvement over baseline. CITATIONS: (Our results, 2025). FORMATTING GOAL: match attached style." -o slides/04_results.png --attach slides/03_background.png --attach figures/accuracy_chart.png
```

#### Step 3 – Assemble PDF
```bash
python slides_to_pdf.py slides/*.png -o presentation.pdf
```
Name files with a numeric prefix (`01_`, `02_`, …) to enforce correct order.

### 2. PowerPoint Workflow (editable slides)
1. **Generate visual assets only** (`--visual-only`).
2. **Create a PPTX** using the existing PPTX skill (e.g., `html2pptx`).
3. **Insert generated images** and add text manually or via the PPTX API.

#### Visual‑Only Generation Example
```bash
python generate_slide_image.py "Flat‑design icons for ML applications: healthcare, finance, robotics. White background, colorful icons." -o figures/ml_apps.png --visual-only
python generate_slide_image.py "Neural‑network architecture diagram, blue‑gray palette." -o figures/nn_arch.png --visual-only
python generate_slide_image.py "Before‑after comparison of data clarity. Arrow linking two panels." -o figures/comparison.png --visual-only
```
After the images are ready, run the PPTX skill to place them on slides and add titles, bullet points, and speaker notes.

### 3. LaTeX Beamer Workflow (for math‑heavy talks)
1. Choose a Beamer template that matches the talk length (conference, seminar, defense).
2. Edit the `.tex` file: replace placeholder titles, bullet lists, and include generated figures with `\includegraphics`.
3. Compile with `pdflatex` (or `latexmk`).
4. Optionally convert the PDF to images for visual review.

#### Minimal Beamer Example
```latex
\documentclass{beamer}
\usetheme{Madrid}
\usecolortheme{dove}
\title{Machine Learning: From Theory to Practice}
\author{Dr. Jane Smith}
\date{AI Conference 2025}

\begin{document}
\frame{\titlepage}

\begin{frame}{Why Machine Learning Matters}
  \begin{itemize}
    \item Industry adoption
    \item Breakthrough applications
    \item Future potential
  \end{itemize}
  \includegraphics[width=0.6\textwidth]{figures/ml_apps.png}
  \tiny{(LeCun et al., 2015; Goodfellow et al., 2016)}
\end{frame}

... other frames ...
\end{document}
```
Compile with `pdflatex presentation.tex`.

## Slide Design Principles
- **Visual‑First**: Start with a strong figure, diagram, or icon. Text should support, not replace, the visual.
- **One Idea per Slide**: Limit to a single concept or result.
- **Minimal Text**: 3‑4 bullets, 4‑6 words each.
- **Typography**: Sans‑serif fonts; titles 36‑44 pt, body 24‑28 pt.
- **Color**: Use a palette of 3‑5 colors. Ensure contrast ≥ 4.5:1; avoid red‑green combos for accessibility.
- **White Space**: Keep at least 40 % of the slide empty to improve readability.
- **Consistent Layout**: Define a Formatting Goal (background, text color, accent) and repeat it on every slide. Attach the previous slide when generating the next one.
- **Citations**: Add citations in small text at the bottom. Use the format `(Author et al., Year)`.
- **Data Figures**: When presenting results, attach the original chart image. Keep fonts ≥ 18 pt, label axes directly, and avoid legends when possible.

## Data Visualization for Slides
| Chart Type | When to Use | Key Adjustments |
|------------|--------------|-----------------|
| Bar chart | Compare discrete categories | Larger fonts, single‑panel, direct value labels |
| Line graph | Show trends over time | Highlight key points with markers, simplify grid |
| Scatter plot | Show correlation | Use color or shape to encode a third variable, add regression line |
| Heatmap | Show matrix patterns | Use color‑blind safe palette, annotate extreme cells |
| Network diagram | Show relationships | Simplify nodes, use consistent edge style |

**Common pitfalls**: tiny fonts, crowded legends, more than three panels per slide, low contrast, excessive text.

## Talk‑Specific Structure
| Talk Type | Recommended Time | Slide Allocation |
|-----------|------------------|------------------|
| Conference (15 min) | 1‑2 min intro, 2‑3 min methods, 6‑8 min results, 2 min conclusion | 8‑12 slides |
| Seminar (45‑60 min) | 5 min intro, 10‑15 min methods, 20‑25 min results, 5‑10 min discussion | 20‑30 slides |
| Thesis Defense (60 min) | Full dissertation overview, all chapters | 30‑40 slides |
| Grant Pitch (15 min) | Problem, significance, approach, preliminary data, impact | 10‑12 slides |
| Journal Club (30 min) | Context, methods, results, critical analysis, take‑aways | 12‑15 slides |

## Checklist
- [ ] Define audience and talk length.
- [ ] Draft a slide plan with titles, key points, visual ideas, and citations.
- [ ] Choose a Formatting Goal (colors, fonts, layout).
- [ ] Generate slide images (or visual‑only assets) with Nano Banana Pro.
- [ ] Attach the previous slide image for style continuity.
- [ ] Verify that all data figures are attached and correctly described.
- [ ] Assemble slides into PDF, PPTX, or Beamer source.
- [ ] Review each slide for: visual dominance, minimal text, high contrast, accessible colors, correct citations.
- [ ] Export PDF for visual validation; iterate if needed.
- [ ] For PPTX, replace placeholder text with final wording; for Beamer, compile and check PDF.
- [ ] Perform a timed run‑through to ensure the slide count matches the allotted time.

---
**Tip**: Keep slide filenames prefixed with numbers (`01_`, `02_`, …) to guarantee correct ordering when combining images.

## Related skills

Load these when the task spans more than this skill.

- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`scientific-schematics`](../scientific-schematics/SKILL.md) — Create publication-quality scientific diagrams with Nano Banana Pro AI and Gemini 3 Pro quality review. Use fo…
- [`citation-management`](../citation-management/SKILL.md) — Manage academic citations: search Google Scholar and PubMed, extract metadata from DOI, PMID, arXiv ID, or URL…
- [`marp-slides`](../marp-slides/SKILL.md) — Creates professional Marp presentation slides. Use when a user asks for a Marp file, wants a slide deck, or re…
- [`pptx`](../pptx/SKILL.md) — Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best‑practices, and…
- [`manim`](../manim/SKILL.md) — Provides concise guidance for creating mathematical animations with the Manim Community Python library, coveri…
- [`paper-to-web`](../paper-to-web/SKILL.md) — Convert academic papers (LaTeX or PDF) into interactive websites, presentation videos, and conference posters…
