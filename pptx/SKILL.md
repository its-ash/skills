---
name: pptx
description: "Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best practices, and validates content and visual quality. Use when user asks to make slides, edit a deck, read pptx, export presentation, fix slide layout, add charts or images, or mentions PowerPoint, slides, deck, .pptx, presentation."
---

# PPTX (PowerPoint) Processing Skill

Use this skill whenever a **.pptx** file is read, created, edited, or validated. It covers text extraction, slide generation from templates or from scratch, design guidelines, and quality‑assurance loops.

## When to Use
- You need to extract text or speaker notes from an existing presentation.
- You must create a new deck, a pitch deck, or a report‑style slide set.
- You want to edit a template, replace placeholders, or merge multiple decks.
- You need to split a large deck into smaller files or combine several decks.
- You must verify that a generated deck follows visual and content standards.

---

## Quick Reference
| Task | Command / Tool |
|------|----------------|
| Extract text | `python -m markitdown presentation.pptx` |
| Generate thumbnail overview | `python -c "import pptx, Pillow; ..."` (use `python-pptx` + Pillow to render slide thumbnails) |
| Unpack raw XML | `python -c "import zipfile, pathlib; zipfile.ZipFile('presentation.pptx').extractall('unpacked')"` |
| Edit or create from template | Follow **Editing Workflow** below |
| Create from scratch (JS) | `npm install -g pptxgenjs` then use the library |
| Convert to images for visual QA | See **Converting to Images** |

---

## Reading Content
1. **Text extraction** – installs a Markdown‑compatible extractor.
   ```bash
   pip install "markitdown[pptx]"
   python -m markitdown presentation.pptx   # prints Markdown of all slide text
   ```
2. **Visual overview** – create a grid of slide thumbnails.
   ```bash
   pip install Pillow python-pptx
   python - <<'PY'
   from pptx import Presentation
   from PIL import Image, ImageDraw
   import sys, os
   prs = Presentation(sys.argv[1])
   thumb_dir = 'thumbs'
   os.makedirs(thumb_dir, exist_ok=True)
   for i, slide in enumerate(prs.slides, 1):
       img_path = f"{thumb_dir}/slide-{i:02d}.png"
       slide.shapes._spTree.blob.save(img_path)  # simplified; replace with actual rendering library
   PY presentation.pptx
   ```
   *(Replace the placeholder rendering line with a real slide‑to‑image library such as `pptx2png` if available.)*
3. **Raw XML inspection** – a PowerPoint file is a zip archive of XML parts.
   ```bash
   python - <<'PY'
   import zipfile, pathlib, sys
   with zipfile.ZipFile(sys.argv[1]) as z:
       z.extractall('unpacked')
   PY presentation.pptx
   ```
   Inspect `unpacked/ppt/slides/slideX.xml` for low‑level changes.

---

## Editing Workflow
1. **Analyze the template** – generate a thumbnail grid (see above) to understand layout and visual style.
2. **Unpack** the .pptx if you need low‑level XML edits (step 3 above). Otherwise, use the high‑level `python-pptx` library.
3. **Manipulate slides**:
   ```python
   from pptx import Presentation
   prs = Presentation('template.pptx')
   # Example: replace placeholder text
   for slide in prs.slides:
       for shape in slide.shapes:
           if shape.has_text_frame and '[[TITLE]]' in shape.text:
               shape.text = shape.text.replace('[[TITLE]]', 'Quarterly Results')
   prs.save('output.pptx')
   ```
4. **Clean up** – remove unused placeholders, ensure consistent fonts, and re‑apply the chosen color palette.
5. **Pack** – the edited `Presentation` object is saved directly to a new .pptx file.

*For complex structural changes (adding/removing slide masters, custom layouts), edit the unpacked XML and re‑zip the archive.*

---

## Creating from Scratch
- **JavaScript option** – `pptxgenjs` lets you generate slides programmatically.
  ```bash
  npm install -g pptxgenjs
  node createDeck.js   # script uses pptxgenjs API
  ```
- **Python option** – use `python-pptx` to build a deck from data.
  ```python
  from pptx import Presentation
  from pptx.util import Inches
  prs = Presentation()
  title_slide = prs.slides.add_slide(prs.slide_layouts[0])
  title = title_slide.shapes.title
  subtitle = title_slide.placeholders[1]
  title.text = "Project Overview"
  subtitle.text = "Prepared by Jane Doe"
  # Add a content slide
  content = prs.slides.add_slide(prs.slide_layouts[1])
  content.shapes.title.text = "Key Metrics"
  body = content.shapes.placeholders[1].text_frame
  body.text = "- Revenue: $1.2M\n- Growth: 15%"
  prs.save('new_deck.pptx')
  ```
- Choose the language that matches your pipeline.

---

## Design Guidelines
### 1. Color Strategy
- Pick **one dominant color** (60‑70 % visual weight).
- Add **1‑2 supporting tones** and **one accent** for highlights.
- Ensure **dark‑light contrast**: dark background for title/conclusion slides, light for body slides, or a uniform dark theme.
- Use a **single visual motif** (e.g., rounded image frames, colored icon circles, thick side border) on every slide.

#### Sample Palettes (hex values)
| Theme | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| Midnight Executive | #1E2761 | #CADCFC | #FFFFFF |
| Forest & Moss | #2C5F2D | #97BC62 | #F5F5F5 |
| Coral Energy | #F96167 | #F9E795 | #2F3C7E |
| Warm Terracotta | #B85042 | #E7E8D1 | #A7BEAE |
| Ocean Gradient | #065A82 | #1C7293 | #21295C |
| Charcoal Minimal | #36454F | #F2F2F2 | #212121 |
| Teal Trust | #028090 | #00A896 | #02C39A |
| Berry & Cream | #6D2E46 | #A26769 | #ECE2D0 |
| Sage Calm | #84B59F | #69A297 | #50808E |
| Cherry Bold | #990011 | #FCF6F5 | #2F3C7E |

### 2. Layout Patterns
- **Two‑column** – text left, illustration right.
- **Icon‑row** – small colored‑circle icon, bold header, brief description.
- **Grid** – 2×2 or 2×3 blocks mixing images and short text.
- **Half‑bleed image** – full‑height image on one side, overlay text on the opposite side.

### 3. Data Display
- **Stat callouts** – numbers 60‑72 pt, label in smaller font.
- **Comparison columns** – side‑by‑side pros/cons or before/after.
- **Timeline / process flow** – numbered steps with arrows.

### 4. Typography
| Header Font | Body Font |
|------------|----------|
| Georgia | Calibri |
| Arial Black | Arial |
| Calibri | Calibri Light |
| Cambria | Calibri |
| Trebuchet MS | Calibri |
| Impact | Arial |
| Palatino | Garamond |
| Consolas | Calibri |

| Element | Size |
|---------|------|
| Slide title | 36‑44 pt bold |
| Section header | 20‑24 pt bold |
| Body text | 14‑16 pt |
| Caption | 10‑12 pt muted |

### 5. Spacing & Margins
- Minimum margin: **0.5 in** from slide edge.
- Gap between blocks: **0.3‑0.5 in**.
- Keep breathing room; avoid filling every inch.

### 6. Common Mistakes to Avoid
- Repeating the same layout on every slide.
- Center‑aligning body paragraphs (left‑align only).
- Insufficient size contrast (titles must be noticeably larger than body).
- Defaulting to generic blue palettes.
- Inconsistent spacing between elements.
- Text‑only slides – always add an image, icon, or chart.
- Ignoring text‑box padding – set `margin: 0` or offset shapes accordingly.
- Low‑contrast text or icons against the background.
- Adding decorative underline lines under titles (looks AI‑generated).

---

## QA (Required)
Treat the first render as a **bug‑hunt**. Perform both content and visual checks before declaring success.

### Content QA
```bash
python -m markitdown output.pptx   # verify extracted markdown
```
- Look for missing slides, typos, or wrong order.
- Detect leftover placeholder text:
```bash
python -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum|this.*(page|slide).*layout"
```
If any match, replace the placeholder.

### Visual QA
1. **Convert to images** (see section below).
2. Use a fresh reviewer (human or sub‑agent) to inspect each slide image.
3. Checklist for each slide:
   - No overlapping elements.
   - No text cut‑off or overflow.
   - No decorative lines that only fit single‑line titles.
   - No footers or citations colliding with main content.
   - Minimum gap **≥ 0.3 in** between adjacent elements.
   - Consistent alignment of columns or grids.
   - Margins **≥ 0.5 in** from slide edges.
   - Sufficient contrast for text and icons.
   - No narrow text boxes causing excessive wrapping.
   - No leftover placeholder words.
4. Document every issue, even minor.

### Verification Loop
1. Generate slides.
2. Convert to images.
3. Run visual QA.
4. Fix all reported issues.
5. Re‑run QA on the affected slides.
6. Repeat until a full pass reports **no new** issues.
7. Only then mark the deck as **ready**.

---

## Converting to Images
Convert a .pptx to high‑resolution JPEGs for visual inspection.
```bash
# Convert PPTX → PDF using LibreOffice in headless mode
soffice --headless --convert-to pdf output.pptx
# Convert PDF → JPEG (150 dpi) using Poppler
pdftoppm -jpeg -r 150 output.pdf slide
# Result: slide-1.jpg, slide-2.jpg, …
```
To render only specific slides (e.g., slide 5):
```bash
pdftoppm -jpeg -r 150 -f 5 -l 5 output.pdf slide-5
```
Use the generated JPEGs in the visual QA step.

---

## Dependencies
- **Python**
  - `pip install "markitdown[pptx]"` – text extraction.
  - `pip install python-pptx Pillow` – slide manipulation and thumbnail creation.
- **Node.js** (optional) – `npm install -g pptxgenjs` for JavaScript‑based deck generation.
- **LibreOffice** (`soffice`) – headless conversion of PPTX to PDF.
- **Poppler** (`pdftoppm`) – PDF‑to‑image conversion.

---

## Checklist
- [ ] Install required Python/Node packages.
- [ ] Extract raw text and verify with `markitdown`.
- [ ] Generate thumbnail overview for layout reference.
- [ ] Apply chosen color palette and visual motif.
- [ ] Use varied slide layouts; avoid text‑only slides.
- [ ] Ensure typography follows size hierarchy.
- [ ] Maintain minimum margins and consistent spacing.
- [ ] Run content QA (placeholder detection, order check).
- [ ] Convert to images and run visual QA checklist.
- [ ] Perform at least one fix‑and‑verify cycle.
- [ ] Save final deck as `final.pptx`.

## Related skills

Load these when the task spans more than this skill.

- [`docx`](../docx/SKILL.md) — Create, read, edit, and analyze Word .docx files using docx‑js (JavaScript) or python‑docx, covering page layo…
- [`xlsx`](../xlsx/SKILL.md) — Handles creation, editing, analysis, formatting, and conversion of spreadsheet files (.xlsx, .xlsm, .csv, .tsv…
- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`marp-slides`](../marp-slides/SKILL.md) — Creates professional Marp presentation slides. Use when a user asks for a Marp file, wants a slide deck, or re…
- [`scientific-slides`](../scientific-slides/SKILL.md) — Generates scientific presentation slides (PDF, PowerPoint, or LaTeX Beamer) using AI‑generated images, provide…
- [`brand-theming`](../brand-theming/SKILL.md) — Applies Anthropic’s official brand colors and typography to slides, documents, or other visual artifacts. Use…
- [`markitdown`](../markitdown/SKILL.md) — MarkItDown converts PDF, DOCX, PPTX, XLSX, images, audio, HTML, CSV, JSON, XML, ZIP, EPUB, YouTube URLs and ot…
