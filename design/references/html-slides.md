# HTML Slides

Make zero-dependency, animated HTML presentations that run in the browser, from scratch or from a PowerPoint file. Detail files are in `html-slides/`.

## When to use

- You make a talk deck, pitch deck, workshop deck, or internal presentation.
- You convert `.ppt` or `.pptx` slides into an HTML presentation.
- You improve the layout, motion, or typography of existing HTML slides.
- The user does not know the style they want and must see examples.

For decks in PowerPoint format, use the `pptx` skill instead.

## Mandatory rules

1. **Zero dependencies:** one self-contained HTML file with inline CSS and JS. Use an `assets/` folder only for images or self-hosted fonts.
2. **Viewport fit:** each slide fits in one viewport, with no scroll inside a slide. This is a hard gate.
3. **Show, do not tell:** show visual previews, not abstract style questions.
4. **Distinctive design:** no generic purple gradients, Inter-on-white, or template-like decks. The parent [`design`](../SKILL.md) anti-slop rules (§10) apply.
5. **Production quality:** commented, accessible, responsive, and fast code.

Before you generate, read [style-presets.md](html-slides/style-presets.md) for the viewport-safe CSS base, density limits, presets, and CSS gotchas.

## Workflow

### 1. Find the mode
- **New presentation:** the user has a topic, notes, or a full draft.
- **PPT conversion:** the user has a `.ppt` or `.pptx` file.
- **Enhancement:** the user has HTML slides and wants improvements.

### 2. Find the content
Ask only the minimum:
- purpose: pitch, teaching, conference talk, internal update
- length: short (5-10), medium (10-20), long (20+)
- content state: final copy, rough notes, topic only

If the user has content, ask for it before you style.

### 3. Find the style
If the user names a preset, use it. If not:
1. Ask which feeling the deck must give: impressed, energized, focused, inspired.
2. Make **3 single-slide preview files** in a temporary folder (for example `slide-previews/`).
3. Each preview is self-contained, shows type, color, and motion, and has less than about 100 lines of slide content.
4. Ask which preview to keep, or which parts to mix.

Use the mood-to-preset table in [style-presets.md](html-slides/style-presets.md).

### 4. Build
Output `presentation.html` or `<name>.html`. Follow [html-template.md](html-slides/html-template.md). Required structure:
- semantic slide sections (`main`, `section`, `nav`)
- the viewport-safe CSS base from [viewport-base.css](html-slides/viewport-base.css)
- CSS custom properties for theme values
- a presentation controller class for keyboard, wheel, and touch navigation
- `IntersectionObserver` for reveal animations
- reduced-motion support

### 5. Enforce viewport fit
- Each `.slide` has `height: 100vh; height: 100dvh; overflow: hidden;`.
- All type and spacing scale with `clamp()`.
- If content does not fit, split it into more slides.
- Do not make text smaller than readable sizes to stop overflow.
- No scrollbars inside a slide.

### 6. Validate
Check the deck at 1920x1080, 1280x720, 768x1024, 375x667, and 667x375. If browser automation is available, use it to make sure no slide overflows and keyboard navigation works.

### 7. Deliver
- Delete the temporary preview files, unless the user wants them.
- Open the deck when useful: `open file.html` (macOS), `xdg-open file.html` (Linux), `start "" file.html` (Windows).
- Give the file path, the preset, the slide count, and the theme variables to change.

## PPT / PPTX conversion

1. Use `python3` with `python-pptx` to extract text, images, and speaker notes. If `python-pptx` is not installed, ask before you install it, or use a manual export.
2. Keep the slide order, speaker notes, and extracted assets.
3. Then use the same style workflow as a new presentation.

```python
# extract_pptx.py <input.pptx> [output_dir]  (pip install python-pptx)
import json, os, sys
from pptx import Presentation
from pptx.enum.shapes import MSO_SHAPE_TYPE

def extract(path: str, out: str = ".") -> list[dict]:
    assets = os.path.join(out, "assets")
    os.makedirs(assets, exist_ok=True)
    slides = []
    for n, slide in enumerate(Presentation(path).slides, 1):
        data = {"number": n, "title": "", "content": [], "images": [], "notes": ""}
        for shape in slide.shapes:
            if shape.has_text_frame and shape.text_frame.text.strip():
                text = shape.text_frame.text.strip()
                if shape == slide.shapes.title:
                    data["title"] = text
                else:
                    data["content"].append(text)
            if shape.shape_type == MSO_SHAPE_TYPE.PICTURE:
                img = shape.image
                name = f"slide{n}_{shape.shape_id}.{img.ext}"
                with open(os.path.join(assets, name), "wb") as f:
                    f.write(img.blob)
                data["images"].append(f"assets/{name}")
        if slide.has_notes_slide:
            data["notes"] = slide.notes_slide.notes_text_frame.text.strip()
        slides.append(data)
    return slides

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("usage: extract_pptx.py <input.pptx> [output_dir]")
    print(json.dumps(extract(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "."), indent=2))
```

Keep conversion cross-platform. Do not use macOS-only tools when Python can do the work.

## Implementation

### HTML / CSS
- Inline CSS and JS, unless the user asks for a multi-file project.
- Self-host fonts as WOFF2 in `assets/`. Use a font service link only when the user accepts a network dependency.
- Use a strong type hierarchy and one clear visual direction. Use abstract shapes, grids, noise, and geometry, not illustrations.

### JavaScript
Include keyboard navigation, touch/swipe navigation, mouse-wheel navigation, a progress indicator or slide index, and reveal-on-enter triggers.

### Accessibility
- Semantic structure (`main`, `section`, `nav`).
- Readable contrast (AA).
- Full keyboard-only navigation.
- Respect `prefers-reduced-motion`.

### Motion
See [animation-patterns.md](html-slides/animation-patterns.md). Each animation must have a purpose (parent §5.B).

## Content density limits

| Slide type | Limit |
|------------|-------|
| Title | 1 heading + 1 subtitle + optional tagline |
| Content | 1 heading + 4-6 bullets or 2 short paragraphs |
| Feature grid | 6 cards max |
| Code | 8-10 lines max |
| Quote | 1 quote + attribution |
| Image | 1 image, constrained by the viewport |

## Anti-patterns

- Generic startup gradients with no visual identity.
- System-font decks, unless intentionally editorial.
- Long walls of bullets.
- Code blocks that need scrolling.
- Fixed-height content boxes that break on short screens.
- Invalid negated CSS functions such as `-clamp(...)`. Use `calc(-1 * clamp(...))`.

## Deliverable checklist

- The presentation runs from a local file in a browser.
- Each slide fits the viewport without scrolling.
- The style is distinctive and intentional.
- Animation has a purpose and is not noisy.
- Reduced motion is respected.
- File paths and customization points are given at handoff.

## Related skills

- [`design`](../SKILL.md) - visual rules and anti-slop list.
- [`motion-react`](motion-react.md) - React motion patterns, if the deck is a React app.
- [`playwright`](../../unit-testing-patterns/references/playwright.md) - automated browser checks of the final deck.
