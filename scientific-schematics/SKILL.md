---
name: scientific-schematics
description: "Generate publication-ready scientific schematics including neural network architectures, system diagrams, flowcharts, biological pathways, and circuit diagrams using Nano Banana Pro AI with Gemini 3 Pro quality review. Use when creating figures for papers, theses, posters, or presentations requiring IEEE, Nature, Science, or journal-specific quality thresholds; prompting for iterative refinement of diagram layout, notation, color schemes, labels, legends, and resolution; exporting vector SVG, PDF, or high-DPI PNG for LaTeX, Word, or web; configuring generator options for schematic type, style guides, and document-class presets."
---

# Scientific Schematics and Diagrams

Create publication-quality scientific diagrams with Nano Banana Pro AI and Gemini 3 Pro quality review. Describe the diagram in natural language; the generator handles layout, labels, styling, review, and refinement. Smart iteration stops early when the quality score meets the threshold for the selected document type.

## When to use

- Create neural network architecture diagrams, including Transformers, CNNs, and RNNs.
- Illustrate system architectures and data-flow diagrams.
- Draw methodology flowcharts such as CONSORT and PRISMA.
- Visualize algorithm workflows and processing pipelines.
- Create circuit diagrams and electrical schematics.
- Depict biological pathways and molecular interactions.
- Generate network topologies and hierarchical structures.
- Illustrate conceptual frameworks and theoretical models.
- Design block diagrams for technical papers.

## Quality thresholds by document type

| Document type | Threshold | Typical use |
|---|---:|---|
| journal | 8.5/10 | Nature, Science, peer-reviewed journals |
| conference | 8.0/10 | Conference papers |
| thesis | 8.0/10 | Dissertations and theses |
| grant | 8.0/10 | Grant proposals |
| preprint | 7.5/10 | arXiv, bioRxiv, and similar |
| report | 7.5/10 | Technical reports |
| poster | 7.0/10 | Academic posters |
| presentation | 6.5/10 | Slides and talks |
| default | 7.5/10 | General purpose |

## How generation works

1. Generate an initial image from the prompt plus scientific diagram guidelines.
2. Review quality with Gemini 3 Pro.
3. If the score meets or exceeds the threshold, stop.
4. If the score is below the threshold, improve the prompt from the critique and regenerate.
5. Repeat until the threshold is met or the maximum of 2 iterations is reached.

Output includes versioned images and a JSON review log with scores, critiques, and early-stop information.

## Prompting guidelines

Effective prompts are specific and detailed. Include:
- Type: flowchart, architecture diagram, pathway, circuit, block diagram, or other.
- Components: exact elements to include.
- Flow or direction: left-to-right, top-to-bottom, clockwise, and similar.
- Labels: key annotations, counts, dimensions, or units.
- Style: minimalist, detailed, technical, or publication-specific requirements.

Good prompts:
- "CONSORT flowchart showing participant flow from screening (n=500) through randomization to final analysis"
- "Transformer neural network architecture with encoder stack on left, decoder stack on right, showing multi-head attention and cross-attention connections"
- "Biological signaling cascade: EGFR receptor → RAS → RAF → MEK → ERK → nucleus, with phosphorylation steps labeled"
- "Block diagram of IoT system: sensors → microcontroller → WiFi module → cloud server → mobile app"

Avoid vague prompts such as "Make a flowchart", "Neural network", or "Pathway diagram".

Scientific quality guidelines are applied automatically:
- Clean white or light background.
- High contrast for readability.
- Clear, readable labels, minimum 10 pt.
- Professional sans-serif typography.
- Colorblind-friendly colors, such as the Okabe-Ito palette.
- Proper spacing to prevent crowding.
- Scale bars, legends, and axes where appropriate.

## Quality review criteria

Gemini 3 Pro scores each diagram from 0 to 2 points in five categories:
- Scientific accuracy: correct concepts, notation, and relationships.
- Clarity and readability: easy to understand with clear hierarchy.
- Label quality: complete, readable, and consistent labels.
- Layout and composition: logical flow, balanced spacing, no overlaps.
- Professional appearance: publication-ready quality.

The total score is out of 10. A review may report strengths, issues, and a verdict such as acceptable for the selected document type.

## Generator options

- `--doc-type`: select the document type and its quality threshold.
- `--iterations`: set the maximum number of iterations, from 1 to 2.
- `-v`: enable verbose output.
- `--api-key`: provide an OpenRouter API key.
- Output path: specify the destination image file.
- Environment variable: `OPENROUTER_API_KEY`.

Set the key with:
```bash
export OPENROUTER_API_KEY='your_api_key_here'
```
Get a key at https://openrouter.ai/keys.

## Prompt engineering tips

1. Be specific about layout.
   - "Flowchart with vertical flow, top to bottom"
   - "Architecture diagram with encoder on left, decoder on right"
   - "Circular pathway diagram with clockwise flow"
2. Include quantitative details.
   - "Neural network with input layer (784 nodes), hidden layer (128 nodes), output (10 nodes)"
   - "Flowchart showing n=500 screened, n=150 excluded, n=350 randomized"
   - "Circuit with 1kΩ resistor, 10µF capacitor, 5V source"
3. Specify visual style.
   - "Minimalist block diagram with clean lines"
   - "Detailed biological pathway with protein structures"
   - "Technical schematic with engineering notation"
4. Request specific labels.
   - "Label all arrows with activation or inhibition"
   - "Include layer dimensions in each box"
   - "Show time progression with timestamps"
5. Mention color requirements.
   - "Use colorblind-friendly colors"
   - "Grayscale-compatible design"
   - "Color-code by function: blue for input, green for processing, red for output"

## Examples

CONSORT flowchart:
"CONSORT participant flow diagram for a randomized controlled trial. Start with 'Assessed for eligibility (n=500)'. Show 'Excluded (n=150)' with reasons. Then 'Randomized (n=350)' splits into treatment and control arms. Each arm shows lost to follow-up. End with analyzed counts. Use blue boxes for process steps, orange for exclusion, and green for final analysis."

Transformer architecture:
"Transformer encoder-decoder architecture diagram. Left side: encoder stack with input embedding, positional encoding, multi-head self-attention, add and norm, feed-forward, add and norm. Right side: decoder stack with output embedding, positional encoding, masked self-attention, add and norm, cross-attention from encoder, add and norm, feed-forward, add and norm, linear and softmax. Show cross-attention with a dashed line. Use light blue for encoder and light red for decoder."

Biological pathway:
"MAPK signaling pathway diagram. Start with EGFR receptor at the cell membrane. Arrow down to RAS with GTP label. Arrow to RAF kinase, then MEK kinase, then ERK kinase. Final arrow to the nucleus showing gene transcription. Label each arrow with phosphorylation or activation. Use rounded rectangles for proteins and different colors for each. Include a membrane boundary line at top."

System architecture:
"IoT system architecture block diagram. Bottom layer: sensors in green boxes. Middle layer: microcontroller in a blue box. Connections to WiFi module and display. Top layer: cloud server connected to mobile app. Show data-flow arrows and label connections with protocols."

## Best practices

Design principles:
- Prefer clarity over complexity.
- Use consistent styling across figures.
- Use colorblind-accessible palettes and redundant encoding.
- Use sans-serif fonts and minimum 7-8 pt text at final size.
- Use vector formats for publication when possible.

Technical requirements:
- Use vector output or 300+ DPI raster output.
- Use PDF for LaTeX, SVG for web, and PNG as fallback.
- Use RGB for digital and CMYK for print when required.
- Use line weights of at least 0.5 pt, typically 1-2 pt.
- Keep text at 7-8 pt minimum at final size.

Integration:
- Include generated images in LaTeX with `\includegraphics{}`.
- Write comprehensive captions and define abbreviations.
- Reference each diagram in the manuscript text.
- Maintain consistent style across all figures in a paper.
- Keep prompts and generated images under version control.

## Troubleshooting

Overlapping text or elements:
- Make the prompt more specific about layout and spacing.
- Use the maximum of 2 iterations for refinement.

Elements not connecting properly:
- Describe connections and layout explicitly in the prompt.
- Increase iterations for better refinement.

Poor image quality:
- Increase iterations for better results.
- Make the prompt more specific about required components and labels.

Colorblind or grayscale issues:
- Use the Okabe-Ito palette explicitly.
- Add redundant encoding with shapes, patterns, or line styles.
- Increase color saturation and lightness differences.

Text too small when printed:
- Design at final size.
- Use minimum 7-8 pt fonts.
- Check physical dimensions before finalizing.

## Checklist

Visual quality:
- [ ] High-quality image format
- [ ] No overlapping elements
- [ ] Adequate spacing between components
- [ ] Clean, professional alignment
- [ ] All arrows connect to intended targets

Accessibility:
- [ ] Colorblind-safe palette used
- [ ] Works in grayscale
- [ ] Sufficient contrast between elements
- [ ] Redundant encoding where appropriate
- [ ] Colorblind simulation passes

Typography and readability:
- [ ] Text minimum 7-8 pt at final size
- [ ] All elements labeled clearly
- [ ] Consistent font family and sizing
- [ ] No text overlaps or cutoffs
- [ ] Units included where applicable

Publication standards:
- [ ] Consistent styling with other figures
- [ ] Comprehensive caption written
- [ ] Referenced in manuscript text
- [ ] Meets journal dimension requirements
- [ ] Exported in required format

Documentation and version control:
- [ ] Source prompts saved
- [ ] Generated images saved
- [ ] Configuration parameters documented
- [ ] Review log archived with figure files

Final integration:
- [ ] Figure displays correctly in compiled manuscript
- [ ] Cross-references point to correct figure
- [ ] Figure number matches text citations
- [ ] Caption appears on correct page
- [ ] No compilation warnings related to figure

## Environment setup

```bash
export OPENROUTER_API_KEY='your_api_key_here'
```

Get a key at https://openrouter.ai/keys.

## Getting started

Describe the diagram, choose the document type, and set the output path. Use specific prompts with components, flow, labels, and style. Review the generated image and JSON log, then refine the prompt if needed.

## Related skills

Load these when the task spans more than this skill.

- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`scientific-slides`](../scientific-slides/SKILL.md) — Generates scientific presentation slides (PDF, PowerPoint, or LaTeX Beamer) using AI‑generated images, provide…
- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
- [`mermaid-diagrams`](../mermaid-diagrams/SKILL.md) — Generates Mermaid diagram code for flowcharts, sequence diagrams, class diagrams, ERDs, C4 architecture, state…
- [`research-posters`](../research-posters/SKILL.md) — Create and review professional research posters in LaTeX (beamerposter, tikzposter, baposter), including sizin…
