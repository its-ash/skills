---
name: image-enhancer
description: "Enhances image resolution, sharpness, and reduces compression artifacts for screenshots, photos, graphics, scanned images, and thumbnails. Use when upscaling, deblurring, denoising, sharpening, restoring JPEG artifacts, fixing pixelation, improving low-resolution PNG, JPG, or WebP assets, and preparing visuals for documentation, presentations, social media, print, or web publishing."
---

# Image Enhancer

Improves resolution, sharpness, and clarity of images. Keeps the original file unchanged and saves an enhanced copy.

## When to Use
- Screenshots for blog posts, documentation, or tutorials
- Photos that appear blurry or pixelated
- Low‑resolution graphics that need upscaling for presentations or print
- Images with visible compression artifacts
- Batch processing of many PNG or JPG files

## Workflow
1. **Provide the image path** – Use a natural‑language prompt that includes the file name or folder.
2. **Select the enhancement type** – Choose one or more of: upscale, sharpen, artifact reduction.
3. **Specify target parameters (optional)** – Indicate desired resolution (e.g., "4K"), output format (PNG for lossless, JPG for smaller size), or platform size (Twitter, Instagram).
4. **Run the enhancement** – The skill analyzes the image, applies the selected operations, and writes a new file.
5. **Review the result** – Open the enhanced file and compare it with the original.

### Basic Enhancement Prompt
```
Improve the image quality of screenshot.png
```
The skill will:
- Analyze resolution, sharpness, and compression
- Upscale intelligently if the source is low‑resolution
- Sharpen edges and text
- Reduce noise and compression artifacts
- Save `screenshot-enhanced.png` and keep `screenshot-original.png`

### Specific Operations
- **Upscale** – `Upscale this image to 4K resolution`
- **Sharpen** – `Sharpen this blurry screenshot`
- **Denoise** – `Reduce compression artifacts in this image`

### Batch Processing Prompt
```
Improve the quality of all PNG files in this directory
```
The skill processes each file, creates an enhanced version with the suffix `-enhanced`, and leaves originals untouched.

## Rules & Best Practices
- **Always keep a backup** – The skill writes a copy of the original with `-original` suffix.
- **Choose the correct output format** – Use PNG for lossless quality, JPG for smaller files.
- **Limit upscaling factor** – Upscaling beyond 4× can introduce artifacts; prefer 2× or 4×.
- **Apply sharpening only once** – Multiple sharpen passes cause halos.
- **Specify platform dimensions for social media** – e.g., 1080 × 1080 for Instagram, 1200 × 628 for Facebook.
- **Run a visual check** – Verify that text remains legible and no new noise appears.

## Common Pitfalls
- Over‑upscaling low‑resolution screenshots may produce blurry edges.
- Excessive sharpening on already crisp images creates halo artifacts.
- Converting a PNG to JPG after enhancement can re‑introduce compression loss; keep PNG if quality matters.
- Ignoring aspect ratio when resizing can distort UI elements.

## Checklist
- [ ] Identify the image(s) to enhance.
- [ ] Decide whether to upscale, sharpen, denoise, or combine.
- [ ] Choose target resolution or platform size.
- [ ] Select output format (PNG for lossless, JPG for size).
- [ ] Run the appropriate prompt.
- [ ] Verify the enhanced file visually.
- [ ] Keep the `-original` file as a backup.

---

**Example Interaction**
```
User: Improve the image quality of screenshot-2024.png
```
**Skill Output**
```
Analyzing screenshot-2024.png...
Current specs: 1920×1080, PNG, slight blur.
Enhancements applied:
- Upscaled to 2560×1440 (2×)
- Sharpened edges
- Reduced compression noise
Saved as: screenshot-2024-enhanced.png
Original preserved as: screenshot-2024-original.png
```

## Related skills

Load these when the task spans more than this skill.

- [`screenshot`](../screenshot/SKILL.md) — Capture a desktop screenshot (full screen, window, region, or app) on macOS, Linux, or Windows. Use when the u…
- [`image-generation`](../image-generation/SKILL.md) — Generate or edit images using OpenAI (gpt-image-1.5) or OpenRouter (FLUX.2 Pro, Gemini 3 Pro) APIs. Use for ph…
- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`design`](../design/SKILL.md) — Unified frontend design skill covering the full lifecycle from brief inference to production. Combines anti-sl…
- [`web-artifacts`](../web-artifacts/SKILL.md) — Creates complex Claude.ai HTML artifacts using React, TypeScript, Vite, Tailwind CSS, and shadcn/ui, then bund…
- [`file-organization`](../file-organization/SKILL.md) — Organizes files and folders intelligently: analyzes directory structure, finds duplicates, proposes logical fo…
