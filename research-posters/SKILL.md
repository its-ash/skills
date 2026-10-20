---
name: research-posters
description: "Generate and audit conference-ready research posters using LaTeX beamerposter, tikzposter, baposter, handling page size A0 A1 A2 portrait landscape, grid layout columns blocks, font scaling, color palettes, vector graphics SVG PDF PNG embedding, QR codes, bibliography formatting, and prepress PDF/X compliance. Use when preparing academic conference poster session submission, designing scientific meeting visual abstract, formatting thesis defense display, creating lab presentation board, building department showcase signage, compiling literature review summary graphic, producing grant progress report placard, or troubleshooting latex compilation errors missing fonts oversized images bleed margin crop marks dpi resolution color profile cmyk rgb conversion."
---

# Research Posters

Create professional research posters, especially LaTeX posters with beamerposter, tikzposter, or baposter. Covers sizing, layout, typography, color, figures, QR codes, compilation, and print-quality review.

## When to use

- Creating posters for conferences, symposia, thesis defenses, or public engagement.
- Converting a paper into a poster format.
- Needing exact poster dimensions such as A0, A1, 36x48 in, 42x56 in, or 48x72 in.
- Building multi-column or block-based layouts.
- Integrating figures, tables, equations, citations, or QR codes.
- Preparing print-ready PDFs and checking quality before printing.

## Choose a LaTeX package

| Package | Strengths | Best for |
|---|---|---|
| beamerposter | Beamer syntax, themes, institutional branding | Familiar Beamer users; traditional academic posters |
| tikzposter | Modern flexible TikZ layouts and built-in themes | Colorful modern designs and custom graphics |
| baposter | Box-based layout with automatic spacing | Structured professional multi-column layouts |

- Choose one package per document.
- Match university or department branding when required.

## Poster sizes and orientation

- A0: 841 x 1189 mm.
- A1: 594 x 841 mm.
- A2: 420 x 594 mm.
- 36 x 48 in: 914 x 1219 mm.
- 42 x 56 in: 1067 x 1422 mm.
- 48 x 72 in: 1219 x 1829 mm.
- Portrait is most common; use landscape for wide content or timelines.
- Set the exact size in the document class and verify it with `pdfinfo`.

## Layout and content

### Common sections

- Header: title, authors, affiliations, logos.
- Introduction or background.
- Methods or approach.
- Results with figures and data visualizations.
- Conclusions and implications.
- References, usually abbreviated.
- Acknowledgments.

### Layout strategies

- Use 2, 3, or 4 columns.
- Use block-based layouts for flexible arrangement.
- Guide readers with a Z-pattern flow.
- Use size, color, and spacing to create visual hierarchy.
- Allocate roughly 10-15% to the title, 70-80% to content, and 5-10% to the footer.

### Content patterns

- Experimental poster: problem and hypothesis, methods diagram, 2-4 result figures, 3-5 conclusion bullets, future work, references.
- Computational poster: problem statement, algorithm or model flowchart, implementation details, metrics and comparisons, use cases, code QR code, references.
- Review poster: topic scope, search strategy, themes, trend visualizations, research gaps, conclusions, references.

## Design rules

### Typography

- Title: 72-120 pt.
- Section headers: 48-72 pt.
- Body text: at least 24-36 pt.
- Use sans-serif fonts such as Arial, Helvetica, or Calibri.
- Limit the design to 2-3 font families.
- Avoid italics for body text.

### Color and contrast

- Use high-contrast color schemes.
- Match institutional branding when required.
- Use color-blind friendly palettes.
- Avoid red-green combinations.
- Keep white space active and avoid overcrowding.

### Visual content

- Use high-resolution figures: at least 300 DPI at final print size.
- Use vector graphics when possible.
- Use large, clear labels.
- Keep figure styling consistent.
- Aim for 40-50% of poster area to be visual.
- Include at least 2-3 figures; aim for 3-4 on comprehensive posters.
- Generate diagrams with the scientific-schematics skill when available: describe the diagram in natural language and review the generated output.

### Content volume

- Aim for 300-800 words total.
- Use bullet points instead of paragraphs.
- Focus on 1-3 main messages.
- Make figures self-explanatory.
- Add QR codes for papers, code, data, or supplementary material.

## Figures and image integration

```latex
\usepackage{graphicx}
\includegraphics[width=0.8\linewidth]{figure.pdf}
```

- Group related figures.
- Use subfigures for comparisons.
- Keep captions readable.

## Color schemes and themes

- Use institutional RGB, CMYK, or LaTeX color definitions.
- Consider Viridis, ColorBrewer, or IBM Color Blind Safe palettes.

```latex
% beamerposter
\usetheme{Berlin}
\usecolortheme{beaver}
```

```latex
% tikzposter
\usetheme{Rays}
\usecolorstyle{Denmark}
```

```latex
% baposter
\begin{poster}{
  background=plain,
  bgColorOne=white,
  headerColorOne=blue!70,
  textborder=rounded
}
```

## Typography setup

```latex
\usepackage{helvet}
\renewcommand{\familydefault}{\sfdefault}
```

```latex
\setbeamerfont{title}{size=\VeryHuge}
\setbeamerfont{author}{size=\Large}
```

- Use bold for key terms: `\textbf{important}`.
- Use color highlights sparingly: `\textcolor{blue}{highlight}`.

## QR codes

```latex
\usepackage{qrcode}
\qrcode[height=2cm]{https://example.org}
```

- Link to papers, repositories, demos, visualizations, or supplementary data.
- Test every QR code before printing.

## Compilation

```bash
pdflatex poster.tex
```

```bash
pdflatex poster.tex
bibtex poster
pdflatex poster.tex
pdflatex poster.tex
```

```bash
lualatex poster.tex
xelatex poster.tex
```

## Full-page setup

### beamerposter

```latex
\documentclass[final,t]{beamer}
\usepackage[size=a0,scale=1.4,orientation=portrait]{beamerposter}
\setbeamersize{text margin left=0mm, text margin right=0mm}
\usepackage[margin=10mm]{geometry}
\setbeamertemplate{navigation symbols}{}
\setbeamertemplate{footline}{}
\setbeamertemplate{headline}{}
```

### tikzposter

```latex
\documentclass[
  25pt,
  a0paper,
  portrait,
  margin=10mm,
  innermargin=15mm,
  blockverticalspace=15mm,
  colspace=15mm,
  subcolspace=8mm
]{tikzposter}
```

### baposter

```latex
\documentclass[a0paper,portrait,fontscale=0.285]{baposter}
\begin{poster}{
  grid=false,
  columns=3,
  colspacing=1.5em,
  eyecatcher=true,
  background=plain,
  bgColorOne=white,
  borderColor=blue!50,
  headerheight=0.12\textheight,
  textborder=roundedleft,
  headerborder=closed,
  boxheaderheight=2em
}
% Content here
\end{poster}
```

## Common layout problems

- Large margins: reduce margin settings.
- Content not filling height: use `\vfill` or adjust spacing.
- Content beyond page: check total width and height.
- Blurry images: replace with images of at least 300 DPI.
- Missing fonts: embed fonts during compilation.
- Wrong page size: verify the document class settings.
- Colors look wrong: match RGB or CMYK to the output method.
- Large digital file: optimize images or compress only for email and web.

## PDF quality review

### Verify page size

```bash
pdfinfo poster.pdf | grep "Page size"
```

### Visual inspection

- Content fills the page without large white margins.
- Column and block spacing are consistent.
- Elements are aligned and do not overlap.
- Title, headers, and body text meet size minimums.
- No text is cut off at edges.
- Figures, captions, colors, logos, and QR codes render correctly.
- All sections, references, contact details, and acknowledgments are present.
- No placeholder text remains.
- All citations and cross-references resolve.

### Reduced-scale print test

- Print at about 25% scale: A0 on A4, or 36x48 in on letter paper.
- Check title readability from about 6 feet.
- Check headers from about 4 feet.
- Check body text from about 2 feet.
- Check figure clarity and color accuracy.

### Digital checks

```bash
pdffonts poster.pdf
pdfimages -list poster.pdf
```

- Embed all fonts.
- Keep images at least 300 DPI.
- Compress only for email or web; keep the original for printing.

### Accessibility

- Text-background contrast should be at least 4.5:1.
- Important elements should be at least 7:1.
- Avoid red-green combinations.
- Test with a color-blindness simulator.
- Use large clear fonts and a clear visual hierarchy.

### Proofreading and validation

- Spell-check all text.
- Verify author names, affiliations, numbers, citations, and figure labels.
- Ask a colleague to review the poster.
- Use a 30-second test for the main message and a 5-minute test for conclusions.
- Review the LaTeX log for warnings and fix overfull or underfull boxes.

### Pre-print checklist

- PDF size exactly matches requirements.
- All fonts are embedded.
- Color mode matches print or screen use.
- Bleed and crop marks are included if required.
- Test print is completed and reviewed.
- File name is clear and a backup copy exists.
- Paper type, printing method, color profile, deadline, and packaging are confirmed.

## Presentation tips

- Tell a story with 1-3 main messages.
- Use a visual abstract or graphical summary.
- Leave room for conversation.
- Prepare 30-second, 2-minute, and 5-minute summaries.
- Stand to the side and engage viewers with questions.
- Bring handouts or business cards with a QR code.
- Keep a PDF copy on a mobile device for digital sharing.

## Workflow

### Plan

- Confirm size, orientation, and submission requirements.
- Identify 1-3 core messages.
- Select 3-6 key figures.
- Draft concise bullet-point text.
- Choose beamerposter, tikzposter, or baposter.

### Design

- Start from a minimal template for the chosen package.
- Customize colors and page size.
- Plan columns, content flow, and space allocation.
- Set typography for each hierarchy level.

### Integrate

- Build the header with title, authors, affiliations, and logos.
- Populate sections with minimal scannable text.
- Add high-resolution figures and QR codes.
- Include 5-10 key references.

### Review and print

- Compile and inspect the PDF.
- Run digital and accessibility checks.
- Complete a reduced-scale print test.
- Proofread and obtain peer review.
- Confirm print specifications and submit.

## Checklist

- [ ] Requirements and exact poster size confirmed.
- [ ] LaTeX package selected.
- [ ] 1-3 core messages defined.
- [ ] Word count is 300-800 and text uses bullets.
- [ ] At least 2-3 figures occupy 40-50% of poster area.
- [ ] Typography meets minimum sizes.
- [ ] Color contrast and color-blind checks pass.
- [ ] Full-page setup is verified.
- [ ] PDF size, fonts, and image resolution are checked.
- [ ] Reduced-scale print test is passed.
- [ ] Proofreading and peer review are complete.
- [ ] Print specifications are confirmed.

## Related skills

Load these when the task spans more than this skill.

- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
- [`scientific-schematics`](../scientific-schematics/SKILL.md) — Create publication-quality scientific diagrams with Nano Banana Pro AI and Gemini 3 Pro quality review. Use fo…
- [`citation-management`](../citation-management/SKILL.md) — Manage academic citations: search Google Scholar and PubMed, extract metadata from DOI, PMID, arXiv ID, or URL…
- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`paper-to-web`](../paper-to-web/SKILL.md) — Convert academic papers (LaTeX or PDF) into interactive websites, presentation videos, and conference posters…
