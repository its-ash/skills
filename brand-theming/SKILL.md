---
name: brand-theming
description: "Applies Anthropic brand colors, typography, and visual identity rules to slides, documents, presentations, reports, spreadsheets, and other visual artifacts. Use when enforcing corporate brand guidelines, brand palette, font styles, color schemes, style guides, visual identity, or document theming in PPTX, DOCX, XLSX, PDF, Markdown slides, Marp, or design files."
---

# Brand‑Theming Skill

Apply Anthropic’s brand identity consistently to any visual artifact (e.g., PowerPoint decks, PDFs, HTML pages). The skill enforces the official color palette, font pairings, and shape styling while handling missing fonts and ensuring contrast.

## When to Use
- The artifact will be shared externally or internally under the Anthropic brand.
- Corporate style guidelines require specific colors, fonts, and visual hierarchy.
- You need a quick, repeatable way to enforce brand consistency across many files.

## Workflow
1. **Select the artifact** – open the file you want to style (PowerPoint, PDF, HTML, etc.).
2. **Load brand resources** – retrieve the color palette and font definitions from this skill.
3. **Apply typography**
   - Use **Poppins** for headings ≥ 24 pt. Fallback to **Arial** if Poppins is unavailable.
   - Use **Lora** for body text. Fallback to **Georgia** if Lora is unavailable.
4. **Apply colors**
   - Set background and text colors using the main palette.
   - Use accent colors (orange, blue, green) for non‑text shapes, charts, and call‑outs.
5. **Validate contrast** – ensure a minimum 4.5:1 contrast ratio between text and background.
6. **Save the artifact** – export or overwrite the original file.

## Rules & Guidelines
### Color Palette
| Role | Hex | Use |
|------|-----|-----|
| **Dark** | `#141413` | Primary text, dark backgrounds |
| **Light** | `#faf9f5` | Light backgrounds, text on dark |
| **Mid Gray** | `#b0aea5` | Secondary UI elements |
| **Light Gray** | `#e8e6dc` | Subtle backgrounds |
| **Accent – Orange** | `#d97757` | Primary accent, call‑outs |
| **Accent – Blue** | `#6a9bcc` | Secondary accent, charts |
| **Accent – Green** | `#788c5d` | Tertiary accent, highlights |

- Use main colors for all text and large background areas.
- Cycle accent colors for shapes, icons, and data visualizations to create visual interest while staying on‑brand.
- Never combine two accent colors on the same element.

### Typography
- **Headings**: Poppins (fallback Arial) – 24 pt and larger.
- **Body text**: Lora (fallback Georgia) – 12‑18 pt.
- Keep line spacing at 1.2 × font size for readability.
- Do not use bold or italics on body text unless required for emphasis; rely on hierarchy instead.

### Shape Styling
- Apply accent colors to non‑text shapes (rectangles, circles, arrows).
- Maintain a minimum 2 pt stroke width for visibility.
- Preserve rounded corners where the original design uses them.

## Technical Details
### Font Management
- The skill checks the system for **Poppins** and **Lora**. If missing, it automatically selects the fallback fonts.
- No automatic font installation is performed; pre‑install the fonts for optimal branding.

### Color Application (Python‑pptx example)
```python
from pptx import Presentation
from pptx.dml.color import RGBColor

# Load presentation
prs = Presentation('input.pptx')

# Define brand colors
BRAND = {
    'dark': RGBColor(0x14, 0x14, 0x13),
    'light': RGBColor(0xfa, 0xf9, 0xf5),
    'mid_gray': RGBColor(0xb0, 0xae, 0xa5),
    'accent_orange': RGBColor(0xd9, 0x77, 0x57),
    'accent_blue': RGBColor(0x6a, 0x9b, 0xcc),
    'accent_green': RGBColor(0x78, 0x8c, 0x5d),
}

for slide in prs.slides:
    for shape in slide.shapes:
        if not shape.has_text_frame:
            # Apply accent colors cyclically
            shape.fill.solid()
            shape.fill.fore_color.rgb = BRAND['accent_orange']
        else:
            tf = shape.text_frame
            for paragraph in tf.paragraphs:
                # Simple rule: headings >= 24pt -> Poppins, else Lora
                size = paragraph.font.size.pt if paragraph.font.size else 12
                if size >= 24:
                    paragraph.font.name = 'Poppins'
                    paragraph.font.color.rgb = BRAND['dark']
                else:
                    paragraph.font.name = 'Lora'
                    paragraph.font.color.rgb = BRAND['dark']

prs.save('output.pptx')
```
- Replace the accent selection logic with a round‑robin iterator for varied accents.

## Pitfalls & Mitigations
- **Missing fonts** – Verify fonts are installed before processing; otherwise, the fallback may not match brand tone.
- **Insufficient contrast** – Use a contrast‑checking tool (e.g., WCAG 2.1) after styling; adjust background or text color if the ratio falls below 4.5:1.
- **Over‑use of accents** – Limit accent colors to ≤ 30 % of total visual elements to keep the design clean.
- **Hard‑coded colors** – Always reference the brand palette dictionary; avoid manual hex entries that can drift over time.

## Checklist
- [ ] Confirm Poppins and Lora fonts are installed (or accept fallbacks).
- [ ] Load the correct artifact type (PowerPoint, PDF, HTML).
- [ ] Apply main colors to all text and large backgrounds.
- [ ] Cycle accent colors for shapes and data visualizations.
- [ ] Set heading fonts to Poppins ≥ 24 pt; body fonts to Lora.
- [ ] Verify contrast ≥ 4.5:1 for every text/background pair.
- [ ] Review the final artifact for visual consistency with Anthropic brand.
- [ ] Save/export the styled file.

## Related skills

Load these when the task spans more than this skill.

- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`pptx`](../pptx/SKILL.md) — Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best‑practices, and…
- [`docx`](../docx/SKILL.md) — Create, read, edit, and analyze Word .docx files using docx‑js (JavaScript) or python‑docx, covering page layo…
- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`web-artifacts`](../web-artifacts/SKILL.md) — Creates complex Claude.ai HTML artifacts using React, TypeScript, Vite, Tailwind CSS, and shadcn/ui, then bund…
- [`domain-name-brainstormer`](../domain-name-brainstormer/SKILL.md) — Generates creative, brand‑able domain name ideas for a project, product, or personal brand and checks their av…
- [`image-generation`](../image-generation/SKILL.md) — Generate or edit images using OpenAI (gpt-image-1.5) or OpenRouter (FLUX.2 Pro, Gemini 3 Pro) APIs. Use for ph…
