---
name: image-generation
description: "Generate or edit images using OpenAI gpt-image-1.5 or OpenRouter FLUX.2 Pro and Gemini 3 Pro APIs for photos, illustrations, concept art, product mockups, UI mockups, logos, infographics, and general visual assets. Use when user says create image, generate picture, make illustration, design logo, produce mockup, render artwork, synthesize visual, draw graphic, craft photo, build infographic, edit photo, modify image, inpaint, outpaint, variation, batch generate, prompt engineering, gpt-image, flux, gemini, openrouter, png, jpg, webp, svg."
---

# Image Generation Skill

Generate and edit images using OpenAI Image API (gpt-image-1.5) or OpenRouter models (FLUX.2 Pro, Gemini 3 Pro). Covers generation, inpainting/masked edits, background removal/replacement, batch variants, and prompt engineering for reproducible results.

## When to use

- Generate new images: concept art, product shots, covers, website heroes, UI mockups, logos, infographics, illustrations
- Edit existing images: inpainting, masked edits, lighting/weather changes, background replacement, object removal, compositing, transparent backgrounds, text localization
- Batch runs: many prompts or many variants across prompts
- Choose OpenAI for gpt-image-1.5 quality and OpenAI ecosystem; choose OpenRouter for FLUX.2 Pro/Gemini 3 Pro access

## Decision tree (generate vs edit vs batch)

- If user provides an input image or says "edit/retouch/inpaint/mask/translate/localize/change only X" → **edit**
- Else if user needs many different prompts/assets → **generate-batch**
- Else → **generate**

## API selection

| Provider | Models | Environment variable | Best for |
|---|---|---|---|
| OpenAI | gpt-image-1.5 (default), gpt-image-1-mini | `OPENAI_API_KEY` | High-quality generation/editing, OpenAI ecosystem |
| OpenRouter | google/gemini-3-pro-image-preview, black-forest-labs/flux.2-pro, black-forest-labs/flux.2-flex | `OPENROUTER_API_KEY` | Model variety, cost optimization, FLUX/Gemini access |

**Default**: OpenAI `gpt-image-1.5` unless user specifies otherwise.

## Dependencies

```bash
# OpenAI path
uv pip install openai pillow
# or
python3 -m pip install openai pillow

# OpenRouter path
uv pip install requests pillow python-dotenv
# or
python3 -m pip install requests pillow python-dotenv
```

## Environment setup

**OpenAI**: Set `OPENAI_API_KEY` (get from https://platform.openai.com/api-keys). Never paste the key in chat.

**OpenRouter**: Set `OPENROUTER_API_KEY` (get from https://openrouter.ai/keys). Create a `.env` file with `OPENROUTER_API_KEY=your-key` or export in shell.

## Workflow

1. **Decide intent**: generate vs edit vs batch (see decision tree).
2. **Collect inputs up front**: prompt(s), exact text (verbatim), constraints/avoid list, input image(s)/mask(s). For multi-image edits, label each input by index and role; for edits, list invariants explicitly.
3. **If batch**: write a temporary JSONL under `tmp/imagegen/` (one job per line), run once, then delete the JSONL.
4. **Augment prompt** into a short labeled spec (structure + constraints) without inventing new creative requirements.
5. **Run generation/edit** via API (see code patterns below).
6. **Inspect outputs**: validate subject, style, composition, text accuracy, invariants/avoid items.
7. **Iterate**: make a single targeted change (prompt or mask), re-run, re-check.
8. **Save final outputs** under `output/imagegen/` with stable, descriptive filenames. Note final prompt + flags used.

## Temp and output conventions

- Intermediate files: `tmp/imagegen/` (delete when done)
- Final artifacts: `output/imagegen/`
- Use descriptive filenames: `<slug>_<variant>_<timestamp>.png`

## Prompt augmentation (structured spec)

Classify each request into a taxonomy slug and fill the template. Only make implicit details explicit; do not invent new requirements.

### Taxonomy slugs

**Generate**:
- `photorealistic-natural` — candid/editorial lifestyle scenes with real texture and natural lighting
- `product-mockup` — product/packaging shots, catalog imagery, merch concepts
- `ui-mockup` — app/web interface mockups that look shippable
- `infographic-diagram` — diagrams/infographics with structured layout and text
- `logo-brand` — logo/mark exploration, vector-friendly
- `illustration-story` — comics, children's book art, narrative scenes
- `stylized-concept` — style-driven concept art, 3D/stylized renders
- `historical-scene` — period-accurate/world-knowledge scenes

**Edit**:
- `text-localization` — translate/replace in-image text, preserve layout
- `identity-preserve` — try-on, person-in-scene; lock face/body/pose
- `precise-object-edit` — remove/replace a specific element (incl. interior swaps)
- `lighting-weather` — time-of-day/season/atmosphere changes only
- `background-extraction` — transparent background / clean cutout
- `style-transfer` — apply reference style while changing subject/scene
- `compositing` — multi-image insert/merge with matched lighting/perspective
- `sketch-to-render` — drawing/line art to photoreal render

### Template (include only relevant lines)

```
Use case: <taxonomy slug>
Asset type: <where the asset will be used>
Primary request: <user's main prompt>
Scene/background: <environment>
Subject: <main subject>
Style/medium: <photo/illustration/3D/etc>
Composition/framing: <wide/close/top-down; placement>
Lighting/mood: <lighting + mood>
Color palette: <palette notes>
Materials/textures: <surface details>
Quality: <low/medium/high/auto>
Input fidelity (edits): <low/high>
Text (verbatim): "<exact text>"
Constraints: <must keep/must avoid>
Avoid: <negative constraints>
```

### Augmentation rules

- Keep it short; add only details the user already implied or provided elsewhere.
- Always classify into a taxonomy slug and tailor constraints/composition/quality to that bucket.
- For broad requests ("Generate images for this website"), propose tasteful, context-appropriate assets and map each to a slug.
- For edits, explicitly list invariants ("change only X; keep Y unchanged").
- If any critical detail is missing and blocks success, ask a question; otherwise proceed.

### Examples

**Generation (hero image)**:
```
Use case: stylized-concept
Asset type: landing page hero
Primary request: a minimal hero image of a ceramic coffee mug
Style/medium: clean product photography
Composition/framing: centered product, generous negative space on the right
Lighting/mood: soft studio lighting
Constraints: no logos, no text, no watermark
```

**Edit (invariants)**:
```
Use case: precise-object-edit
Asset type: product photo background replacement
Primary request: replace the background with a warm sunset gradient
Constraints: change only the background; keep the product and its edges unchanged; no text; no watermark
```

## Prompting best practices

- Structure prompt as scene → subject → details → constraints.
- Include intended use (ad, UI mock, infographic) to set mode and polish level.
- Use camera/composition language for photorealism (e.g., "85mm lens, f/1.8, shallow depth of field").
- Quote exact text and specify typography + placement.
- For tricky words, spell them letter-by-letter and require verbatim rendering.
- For multi-image inputs, reference images by index and describe how to combine them.
- For edits, repeat invariants every iteration to reduce drift.
- Iterate with single-change follow-ups.
- For latency-sensitive runs, start with `quality=low`; use `quality=high` for text-heavy or detail-critical outputs.
- For strict edits (identity/layout lock), consider `input_fidelity=high`.
- If results feel "tacky", add an "Avoid:" line (stock-photo vibe; cheesy lens flare; oversaturated neon; harsh bloom; oversharpening; clutter) and specify restraint ("editorial", "premium", "subtle").

## OpenAI API patterns

```python
from openai import OpenAI
import os

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Generate
response = client.images.generate(
    model="gpt-image-1.5",
    prompt=augmented_prompt,
    size="1024x1024",  # or 1536x1024, 1024x1536
    quality="high",    # low, medium, high, auto
    background="auto", # auto, transparent, opaque
    n=1,
)

# Edit (with mask for inpainting)
with open("input.png", "rb") as img, open("mask.png", "rb") as msk:
    response = client.images.edit(
        model="gpt-image-1.5",
        image=img,
        mask=msk,
        prompt=edit_prompt,
        size="1024x1024",
        quality="high",
    )

# Save
image_data = response.data[0].b64_json
import base64
with open("output/imagegen/result.png", "wb") as f:
    f.write(base64.b64decode(image_data))
```

**Key parameters**:
- `size`: `1024x1024`, `1536x1024` (landscape), `1024x1536` (portrait)
- `quality`: `low` (fast/cheap), `medium`, `high` (best for text/detail), `auto`
- `background`: `auto`, `transparent`, `opaque`
- `input_fidelity` (edit only): `low` (more creative), `high` (strict adherence)

## OpenRouter API patterns

```python
import requests
import os
import base64
from pathlib import Path

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
MODEL = "google/gemini-3-pro-image-preview"  # or flux.2-pro, flux.2-flex

headers = {
    "Authorization": f"Bearer {OPENROUTER_API_KEY}",
    "Content-Type": "application/json",
}

# Generate
payload = {
    "model": MODEL,
    "prompt": augmented_prompt,
    "width": 1024,
    "height": 1024,
}

# Edit
with open("input.png", "rb") as f:
    img_b64 = base64.b64encode(f.read()).decode()
payload = {
    "model": MODEL,
    "prompt": edit_prompt,
    "images": [f"data:image/png;base64,{img_b64}"],
    "width": 1024,
    "height": 1024,
}

response = requests.post(
    "https://openrouter.ai/api/v1/images/generations",
    headers=headers,
    json=payload,
    timeout=120,
)
response.raise_for_status()

# Handle both response formats
result = response.json()
if "images" in result:
    img_url = result["images"][0]["url"]  # data URL
elif "choices" in result:
    img_url = result["choices"][0]["message"]["content"][0]["image_url"]["url"]

# Save data URL
if img_url.startswith("data:"):
    _, b64data = img_url.split(",", 1)
    with open("output/imagegen/result.png", "wb") as f:
        f.write(base64.b64decode(b64data))
```

**Model selection (OpenRouter)**:
- `google/gemini-3-pro-image-preview` — high quality, generation + editing (default)
- `black-forest-labs/flux.2-pro` — fast, high quality, generation + editing
- `black-forest-labs/flux.2-flex` — fast/cheap, generation only

## Batch generation (OpenAI)

Write JSONL to `tmp/imagegen/batch_<timestamp>.jsonl`:
```jsonl
{"model": "gpt-image-1.5", "prompt": "prompt 1", "size": "1024x1024", "quality": "high"}
{"model": "gpt-image-1.5", "prompt": "prompt 2", "size": "1024x1024", "quality": "high"}
```

Run via OpenAI Batch API or loop sequentially. Delete JSONL after completion.

## Common pitfalls

- **Missing API key**: Check environment variable before any call; give setup steps if missing.
- **Wrong model for edit**: `flux.2-flex` and `gpt-image-1-mini` do not support editing.
- **Text rendering failures**: Use `quality=high`, spell words letter-by-letter, specify font/style/placement.
- **Edit drift**: Repeat invariants every iteration; use `input_fidelity=high` for strict lock.
- **Aspect ratio mismatch**: Match `size` to composition (landscape/portrait/square).
- **Transparent background not working**: Set `background="transparent"` (OpenAI) or ensure model supports it.
- **Batch cost overruns**: Estimate cost per image × count before running large batches.
- **Network/sandbox blocks**: If API calls fail with connection errors, check environment network approvals.

## Checklist

- [ ] API key set in environment (`OPENAI_API_KEY` or `OPENROUTER_API_KEY`)
- [ ] Intent classified: generate / edit / batch
- [ ] Taxonomy slug assigned
- [ ] Prompt augmented with structured spec
- [ ] Invariants listed (for edits)
- [ ] Exact text quoted verbatim (if any)
- [ ] Size/orientation matches composition
- [ ] Quality setting chosen for task
- [ ] Output path under `output/imagegen/` with descriptive name
- [ ] Results validated against constraints
- [ ] Iteration log kept (prompt + flags per version)
- [ ] Temp files cleaned up

## Quick reference: when to use which provider

| Need | Recommended |
|---|---|
| Highest quality, OpenAI ecosystem | OpenAI `gpt-image-1.5` |
| Cost-sensitive, FLUX quality | OpenRouter `flux.2-pro` or `flux.2-flex` |
| Best text rendering | OpenAI `gpt-image-1.5` quality=high or Gemini 3 Pro |
| Editing + generation in one model | OpenAI `gpt-image-1.5` or OpenRouter Gemini/FLUX Pro |
| Transparent background required | OpenAI `background="transparent"` |
| Batch API (async, cheaper) | OpenAI Batch API |

## Integration notes

- For technical diagrams (flowcharts, circuits, pathways, architecture): use **scientific-schematics** skill instead.
- For presentations: combine with **scientific-slides** or **latex-posters**.
- For scientific documents: generate conceptual illustrations here, schematics via scientific-schematics.

## Related skills

Load these when the task spans more than this skill.

- [`design`](../design/SKILL.md) — Unified frontend design skill covering the full lifecycle from brief inference to production. Combines anti-sl…
- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`brand-theming`](../brand-theming/SKILL.md) — Applies Anthropic’s official brand colors and typography to slides, documents, or other visual artifacts. Use…
- [`figma`](../figma/SKILL.md) — Provides a step‑by‑step workflow to fetch design context, screenshots, and assets from a Figma MCP server and…
- [`marketing-strategy`](../marketing-strategy/SKILL.md) — Comprehensive playbook for product marketing, positioning, GTM planning, demand generation, paid media, SEO, p…
- [`slack-gif-creator`](../slack-gif-creator/SKILL.md) — Create animated GIFs optimized for Slack emoji (128x128) and message (480x480) formats. Provides Slack constra…
- [`image-enhancer`](../image-enhancer/SKILL.md) — Enhances image resolution, sharpness, and reduces compression artifacts for screenshots, photos, and graphics.…
