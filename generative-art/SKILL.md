---
name: generative-art
description: "Create algorithmic generative art by defining a visual philosophy, then implementing interactive p5.js sketches with seeded parameter exploration or static PDF/PNG compositions. Use when building flow fields, particle systems, generative posters, procedural graphics, code-driven visuals, creative coding, seeded random art, visual algorithms, canvas rendering, or reproducible experiments in JavaScript, HTML, p5.js, PDF, or PNG."
---

# Generative Art

Create original generative art through a philosophy-first workflow. Define a computational or visual aesthetic as a manifesto, then implement it as either interactive p5.js sketches with seeded parameter controls or static museum-quality compositions. Never copy existing artists' work.

## When to use

- **Interactive generative sketches**: User requests algorithmic art, flow fields, particle systems, generative patterns, or code-driven visuals with parameter exploration. Output: self-contained HTML artifact with p5.js, seed navigation, and real-time controls.
- **Static compositions**: User requests posters, prints, design pieces, or fixed artworks for display. Output: PDF or PNG files with meticulous craftsmanship.
- **Both**: When the request spans exploration and final artifact (e.g., "explore variations then produce a print").

## Phase 1: Philosophy Creation

Before any code or canvas work, write a **philosophy document** (.md) that names and articulates a generative aesthetic movement. This guides all implementation decisions.

### Structure

1. **Name the movement** (1–2 words): "Organic Turbulence", "Chromatic Silence", "Recursive Whispers".
2. **Articulate the philosophy** (4–6 paragraphs): Describe how the aesthetic manifests through:
   - Computational processes / spatial relationships
   - Noise functions, randomness, or color systems
   - Particle behaviors, field dynamics, or form language
   - Temporal evolution / scale and rhythm
   - Parametric variation / visual hierarchy
3. **Deduce the conceptual seed**: Identify a subtle, niche reference embedded in the request. Weave it invisibly into parameters, behaviors, or composition—recognizable only to those who know, invisible to others.

### Critical guidelines

- **No redundancy**: Each principle appears once unless adding depth.
- **Emphasize craftsmanship repeatedly**: Use phrases like "meticulously crafted algorithm," "painstaking calibration," "master-level implementation," "countless iterations by a master of computational aesthetics." The philosophy must frame the output as expert work.
- **Leave creative space**: Be specific on direction, concise enough for interpretive implementation choices at the highest craft level.
- **Process over product**: Beauty emerges from execution; each run/render is unique.
- **Parametric expression**: Ideas communicate through mathematical relationships, forces, behaviors, or spatial logic—not static composition.

### Philosophy examples (condensed)

- **Organic Turbulence**: Chaos constrained by natural law. Flow fields from layered Perlin noise; thousands of particles accumulating into density maps. Color from velocity. Equilibrium tuned through countless iterations.
- **Quantum Harmonics**: Discrete entities with wave interference. Grid particles with evolving phase; constructive/destructive interference creates mandalas. Frequency ratios calibrated for resonance.
- **Recursive Whispers**: Self-similarity across scales. Branching via L-systems or subdivision, golden ratios, noise perturbations. Line weights diminish per recursion.
- **Field Dynamics**: Invisible forces made visible. Vector fields from math/noise; particles born at edges, tracing field lines. Ghost traces of force balance.
- **Stochastic Crystallization**: Randomness crystallizing into order. Circle packing or Voronoi relaxation to equilibrium. Color by cell properties. Unique per seed.
- **Chromatic Language**: Color as primary information. Geometric precision, Albers-like interaction, minimal typography. Painstaking chromatic calibration.
- **Analog Meditation**: Texture, negative space, quiet contemplation. Paper grain, ink bleeds, Japanese photobook aesthetic. Whispered text.

Output the philosophy as a `.md` file.

## Phase 2A: Interactive p5.js Implementation

Express the philosophy as a self-contained HTML artifact with p5.js, seeded randomness, and interactive parameter controls.

### Step 0: Read the template

**Required**: Read `templates/viewer.html` first. Use it as the literal starting point. Keep fixed sections exactly: header, sidebar structure, Anthropic branding (Poppins/Lora fonts, light colors, gradient backdrop), seed controls (display, prev/next/random/jump), action buttons (regenerate, reset, download). Replace only variable sections: the p5.js algorithm, parameter definitions, and parameter UI controls.

### Technical requirements

**Seeded randomness (Art Blocks pattern)**:
```javascript
let seed = 12345;
randomSeed(seed);
noiseSeed(seed);
```

**Parameter structure** (emerges from philosophy):
```javascript
let params = {
  seed: 12345,
  // Quantities, scales, probabilities, ratios, angles, thresholds
  // Example: particleCount, noiseScale, speed, colorRatio
};
```

**Core algorithm**: Let the philosophy dictate the code. Do not choose from a pattern menu.
- Organic emergence → accumulation, growth, feedback loops, constrained randomness
- Mathematical beauty → geometric relationships, trigonometry, harmonics, precise calculation
- Controlled chaos → variation within boundaries, bifurcation, order from disorder

**Canvas setup**:
```javascript
function setup() {
  createCanvas(1200, 1200);
  // Initialize system
}
function draw() {
  // Generative algorithm (static: noLoop; animated: continuous)
}
```

### Craftsmanship requirements

- **Balance**: Complexity without noise, order without rigidity.
- **Color harmony**: Intentional palettes, never random RGB.
- **Composition**: Visual hierarchy and flow even in randomness.
- **Performance**: Smooth real-time execution if animated.
- **Reproducibility**: Same seed → identical output always.

### Artifact structure (single HTML file)

```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.7.0/p5.min.js"></script>
  <style>
    /* Inline styling: clean, minimal, canvas top, controls below */
    /* Match Anthropic branding from template */
  </style>
</head>
<body>
  <div id="canvas-container"></div>
  <div id="controls">
    <!-- Sidebar: Seed (fixed) → Parameters (variable) → Colors (optional) → Actions (fixed) -->
  </div>
  <script>
    // ALL p5.js code inline: parameters, classes, setup/draw, UI handlers
  </script>
</body>
</html>
```

**Sidebar implementation**:
- **Seed (fixed)**: Display, Prev/Next/Random/Jump buttons, seed input + Go.
- **Parameters (variable)**: One `.control-group` per parameter with `<label>`, `<input type="range" min max step value oninput="updateParam(...)">`, `<span class="value-display">`.
- **Colors (optional)**: Color pickers if palette is tunable; omit if fixed or monochrome.
- **Actions (fixed)**: Regenerate, Reset, Download PNG buttons—all functional.

### Variation exploration

Seed navigation (prev/next/random/jump) is built in. For highlighted variations:
- Add preset buttons: "Variation 1: Seed 42", "Variation 2: Seed 127".
- Optional "Gallery Mode": thumbnails of multiple seeds side-by-side.
- All within the same artifact.

## Phase 2B: Static Canvas Creation

Express the philosophy as a museum-quality PDF or PNG.

### Approach

- Single page unless multi-page requested. High visual density, design-forward.
- Use repeating patterns, perfect shapes, layered marks that reward sustained viewing.
- Sparse, clinical typography as visual accent—never paragraphs. Thin fonts preferred.
- Limited, intentional color palette. Every element contained with proper margins; nothing overlaps or falls off.
- Source fonts from `./canvas-fonts` or download as needed. Make typography part of the art.
- Treat the composition like a scientific bible: systematic observation, dense accumulation, reference markers of an imaginary discipline.

### Critical refinement pass

**Do not add more graphics**. Instead:
- Make existing composition more cohesive with the philosophy.
- Sharpen every detail: spacing, alignment, color precision, typography.
- Ask: "How can I make what's already here more of a piece of art?"
- Output must look like countless hours of master-level labor.

### Multi-page option

When requested, create additional pages as unique twists on the philosophy—distinct but related, almost telling a story. Bundle in one PDF or multiple PNGs. Full creative freedom.

## Output format

| Mode | Philosophy | Artifact |
|------|------------|----------|
| Interactive | `.md` | Single `.html` (p5.js + UI, self-contained) |
| Static | `.md` | `.pdf` or `.png` (downloadable) |
| Both | `.md` | Both artifact types |

## Resources

- `templates/viewer.html` — **Required starting point** for interactive artifacts. Fixed: layout, branding, seed controls, actions. Variable: algorithm, parameters, parameter UI, optional color UI.
- `templates/generator_template.js` — Reference for p5.js best practices: parameter organization, seeded randomness, class structure. Not a pattern menu; use principles to build unique algorithms.
- `./canvas-fonts` — Font directory for static compositions.

## Checklist

- [ ] Philosophy written (4–6 paragraphs, movement named, craftsmanship emphasized, conceptual seed deduced)
- [ ] Philosophy saved as `.md`
- [ ] **Interactive**: `viewer.html` read; algorithm expresses philosophy; parameters derived from philosophy; UI controls match parameters; seed navigation works; regenerate/reset/download work; Anthropic branding preserved; single self-contained HTML
- [ ] **Static**: Canvas expresses philosophy; typography minimal and visual; margins respected; no overlaps; color palette intentional; refinement pass completed; output as PDF/PNG
- [ ] Reproducibility verified (seeded) or craftsmanship verified (static)

## Related skills

Load these when the task spans more than this skill.

- [`d3-visualization`](../d3-visualization/SKILL.md) — Create custom interactive D3.js visualizations, including charts, graphs, networks, maps, transitions, and SVG…
- [`image-generation`](../image-generation/SKILL.md) — Generate or edit images using OpenAI (gpt-image-1.5) or OpenRouter (FLUX.2 Pro, Gemini 3 Pro) APIs. Use for ph…
- [`manim`](../manim/SKILL.md) — Provides concise guidance for creating mathematical animations with the Manim Community Python library, coveri…
- [`motion-canvas`](../motion-canvas/SKILL.md) — Set up and troubleshoot Motion Canvas projects, write TypeScript animation scenes with generator functions, si…
- [`web-artifacts`](../web-artifacts/SKILL.md) — Creates complex Claude.ai HTML artifacts using React, TypeScript, Vite, Tailwind CSS, and shadcn/ui, then bund…
- [`slack-gif-creator`](../slack-gif-creator/SKILL.md) — Create animated GIFs optimized for Slack emoji (128x128) and message (480x480) formats. Provides Slack constra…
- [`remotion`](../remotion/SKILL.md) — Comprehensive guide for Remotion - programmatic video creation in React. Covers compositions, frame-based anim…
