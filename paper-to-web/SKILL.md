---
name: paper-to-web
description: "Transform LaTeX manuscripts and PDF preprints into interactive project websites, narrated video abstracts, and print-ready conference posters through the Paper2All pipeline. Use when converting arxiv submissions, journal articles, or thesis chapters to web portals, mp4 summaries, or poster PDFs; triggers include latex source folders, bibtex bibliographies, figure directories, paper2all CLI commands, github actions workflows, vercel or netlify deployment, remotion rendering, and batch processing of multiple preprints for lab showcase pages."
---

# Paper-to-Web: Academic Paper Transformation Pipeline

This skill converts academic papers in LaTeX or PDF into interactive websites, presentation videos, and conference posters using the Paper2All pipeline. Use it for conference preparation, research promotion, preprint enhancement, and batch generation of promotional materials.

## When to use

- Create conference materials: posters, presentation videos, and companion websites.
- Promote published papers or preprints as interactive homepages.
- Generate video abstracts, conference talks, or course materials.
- Prepare materials for social media, lab websites, or institutional showcases.
- Process one paper or a batch of papers.

## Choose outputs

- **Paper2Web**: interactive academic homepage with responsive sections, interactive figures, tables, citations, mobile navigation, automatic logo discovery, and aesthetic refinement. Best for permanent online presence.
- **Paper2Video**: presentation video with generated slides, narration, synchronized cursor movements and highlights, optional talking-head video, and multi-language support. Best for video abstracts, talks, and online promotion.
- **Paper2Poster**: print-ready poster with custom dimensions, professional templates, institution branding, QR codes, and high-resolution output. Best for poster sessions and exhibitions.

## Prerequisites

Install Paper2All and dependencies:

```bash
git clone https://github.com/YuhangChen1/Paper2All.git
cd Paper2All
conda create -n paper2all python=3.11
conda activate paper2all
pip install -r requirements.txt
```

Create `.env`:

```text
OPENAI_API_KEY=your_openai_api_key_here
# Optional:
GOOGLE_API_KEY=your_google_api_key
GOOGLE_CSE_ID=your_custom_search_engine_id
```

Install system dependencies: LibreOffice and Poppler utilities. For talking-head video, use an NVIDIA GPU with about 48 GB VRAM.

## Input requirements

LaTeX source is recommended. Organize files like this:

```text
paper_directory/
├── main.tex
├── sections/
├── figures/
├── tables/
└── bibliography.bib
```

PDF input must have selectable text, embedded fonts, and high-resolution figures (300 DPI or higher).

For one paper:

```text
input/
└── paper_name/
    ├── main.tex or paper.pdf
    ├── figures/
    └── bibliography.bib
```

For batch processing:

```text
input/
├── paper1/
├── paper2/
└── paper3/
```

## Basic usage

Generate all components:

```bash
python pipeline_all.py \
  --input-dir "path/to/paper" \
  --output-dir "path/to/output" \
  --model-choice 1
```

Generate website only:

```bash
python pipeline_all.py \
  --input-dir "path/to/paper" \
  --output-dir "path/to/output" \
  --model-choice 1 \
  --generate-website
```

Generate poster with custom size:

```bash
python pipeline_all.py \
  --input-dir "path/to/paper" \
  --output-dir "path/to/output" \
  --model-choice 1 \
  --generate-poster \
  --poster-width-inches 60 \
  --poster-height-inches 40
```

Generate video with the lightweight pipeline:

```bash
python pipeline_light.py \
  --model_name_t gpt-4.1 \
  --model_name_v gpt-4.1 \
  --result_dir "path/to/output" \
  --paper_latex_root "path/to/paper"
```

## Workflow decision tree

```text
Need promotional materials?
├─ Need permanent online presence? -> Paper2Web
├─ Need physical conference materials?
│  ├─ Poster session? -> Paper2Poster
│  └─ Oral presentation? -> Paper2Video
├─ Need video content?
│  ├─ Video abstract? -> Paper2Video (5-10 min)
│  ├─ Conference talk? -> Paper2Video (15-20 min)
│  └─ Social media? -> Paper2Video (1-3 min)
└─ Need complete package? -> Generate all three
```

## Common parameters

Model selection:
- `--model-choice 1`: GPT-4. Balanced quality and cost.
- `--model-choice 2`: GPT-4.1. Latest features and highest quality.
- `--model_name_t gpt-3.5-turbo`: Faster and lower cost. Acceptable quality.

Component selection:
- `--generate-website`
- `--generate-poster`
- `--generate-video`
- `--enable-talking-head`: requires GPU.

Customization:
- `--poster-width-inches [width]`
- `--poster-height-inches [height]`
- `--video-duration [seconds]`
- `--enable-logo-search`

## Output structure

```text
output/
└── paper_name/
    ├── website/
    │   ├── index.html
    │   ├── styles.css
    │   └── assets/
    ├── poster/
    │   ├── poster_final.pdf
    │   ├── poster_final.png
    │   └── poster_source/
    └── video/
        ├── final_video.mp4
        ├── slides/
        ├── audio/
        └── subtitles/
```

## Best practices

Input preparation:
- Use LaTeX when possible for better content extraction and structure.
- Keep all assets in the paper directory.
- Use vector formats (PDF, SVG, EPS) or 300+ DPI rasters.
- Remove compilation artifacts and verify the source compiles.

Model selection:
- Use GPT-4 for production-quality outputs.
- Use GPT-4.1 for latest features or best quality.
- Use GPT-3.5-turbo for drafts, tests, or simple papers.

Component priority for tight deadlines:
1. Website: fastest and most versatile, about 15-30 minutes.
2. Poster: moderate speed, about 10-20 minutes.
3. Video: slowest, about 20-60 minutes without talking-head.

Quality assurance:
- Website: test on multiple devices, verify links, check figure quality.
- Poster: print a test page, verify readability from 3-6 feet, check colors.
- Video: watch the full video, verify audio sync, test on different devices.

## Resource requirements

Processing time:
- Website: 15-30 minutes per paper.
- Poster: 10-20 minutes per paper.
- Video without talking-head: 20-60 minutes per paper.
- Video with talking-head: 60-120 minutes per paper.

Computational requirements:
- Multi-core CPU.
- 16 GB RAM minimum; 32 GB recommended for large papers.
- Optional GPU for standard outputs; NVIDIA A6000 with 48 GB for talking-head.
- 1-5 GB storage per paper.

Approximate API cost with GPT-4:
- Website: $0.50-2.00 per paper.
- Poster: $0.30-1.00 per paper.
- Video: $1.00-3.00 per paper.
- Complete package: $2.00-6.00 per paper.

## Troubleshooting

- LaTeX parsing errors: verify `pdflatex main.tex` succeeds; check referenced files; remove custom packages that block parsing.
- Poor figure quality: use vector formats or 300+ DPI rasters; verify figures render in the compiled PDF.
- Video generation failures: verify 5 GB+ free disk space; install LibreOffice and Poppler; review logs in the output directory.
- Poster layout issues: keep dimensions in a reasonable 24-72 inch range; curate very long papers; verify figure resolution for poster size.
- API errors: verify `.env` keys; check credit balance; wait and retry after rate limits.

## Platform and conference options

Social media optimization:
- Twitter/X: use numeric folder names, such as `input/001_twitter/`, for English promotional content.
- Xiaohongshu: use alphanumeric folder names, such as `input/xhs_paper/`, for Chinese promotional content.

Conference formatting:
- Use standard poster sizes such as 4x3 feet, 5x4 feet, A0, or A1.
- Respect video abstract length limits, often 3-5 minutes.
- Apply institution branding and color scheme requirements.

## Deployment

- Websites: GitHub Pages, university servers, personal servers, Netlify, or Vercel.
- Posters: professional print services, university print shops, online print services, or large-format printers.
- Videos: YouTube, institutional repositories, conference platforms, or social media.

## Batch processing

```bash
for paper in paper1 paper2 paper3; do
  python pipeline_all.py \
    --input-dir input/$paper \
    --output-dir output/$paper \
    --model-choice 1 &
done
wait
```

## Advanced options

- Custom branding: provide logo files, specify color schemes, use custom templates, or match conference themes.
- Multi-language support: specify target language; content is translated, voice selection adapts, and design conventions adjust.

## Quality criteria

Check outputs against:
- Content: completeness, accuracy, clarity, and prominence of key findings.
- Design: aesthetics, layout balance, readability, and consistency.
- Technical: performance, cross-browser and cross-device compatibility, accessibility, and valid print-ready files.

## Checklist

- [ ] Input paper compiles or PDF has selectable text and high-resolution figures.
- [ ] API keys and system dependencies are configured.
- [ ] Selected components match the audience and deadline.
- [ ] Generated website, poster, and video were reviewed on target devices.
- [ ] Output files are deployed or sent to print.

## Related skills

Load these when the task spans more than this skill.

- [`research-posters`](../research-posters/SKILL.md) — Create and review professional research posters in LaTeX (beamerposter, tikzposter, baposter), including sizin…
- [`scientific-slides`](../scientific-slides/SKILL.md) — Generates scientific presentation slides (PDF, PowerPoint, or LaTeX Beamer) using AI‑generated images, provide…
- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`remotion`](../remotion/SKILL.md) — Comprehensive guide for Remotion - programmatic video creation in React. Covers compositions, frame-based anim…
- [`vercel`](../vercel/SKILL.md) — Deploy and optimize applications on Vercel. Use for tasks involving 'vercel', 'deploy', 'hosting', or 'product…
- [`citation-management`](../citation-management/SKILL.md) — Manage academic citations: search Google Scholar and PubMed, extract metadata from DOI, PMID, arXiv ID, or URL…
