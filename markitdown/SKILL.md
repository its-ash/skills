---
name: markitdown
description: "MarkItDown converts PDF DOCX PPTX XLSX images audio HTML CSV JSON XML ZIP EPUB YouTube URLs and other formats to clean Markdown via CLI or Python API with optional OCR transcription Azure Document Intelligence or AI image captions. Use when you need to extract text from pdf docx pptx xlsx image audio html csv json xml zip epub youtube files convert documents to markdown for obsidian documentation writing batch process folders run ocr on scanned pdfs transcribe audio generate ai image captions parse scientific papers excel tables powerpoint slides."
---

# MarkItDown – File‑to‑Markdown Conversion

Convert a wide range of documents and media files to token‑efficient Markdown. The tool works from the command line, inside Python code, or in a Docker container. Optional features add OCR for scanned images, speech‑to‑text for audio, Azure Document Intelligence for complex PDFs, and LLM‑generated image descriptions.

## When to use
- You need plain‑text, structured content for LLM prompts or downstream processing.
- You have scientific papers, reports, presentations, spreadsheets, or e‑books to ingest.
- You want to extract tables, captions, or transcriptions automatically.
- You prefer a single tool that supports many file types and optional AI enhancements.

## Installation
```bash
# Core package with all optional features
pip install 'markitdown[all]'

# Install only needed formats, e.g., PDF and DOCX
pip install 'markitdown[pdf,docx]'
```

## Command‑line usage
```bash
# Basic conversion
markitdown input.pdf > output.md

# Write to a file
markitdown input.docx -o output.md

# Convert from stdin
cat input.pptx | markitdown > output.md

# List available plugins
markitdown --list-plugins

# Enable plugins for a run
markitdown --use-plugins input.zip -o output.md
```

## Python API
```python
from markitdown import MarkItDown

# Simple conversion
md = MarkItDown()
result = md.convert("document.pdf")
print(result.text_content)

# Stream conversion (useful for large files)
with open("large_file.pdf", "rb") as f:
    result = md.convert_stream(f, file_extension=".pdf")
    print(result.text_content)
```

## Advanced options
### AI‑enhanced image descriptions
```python
from openai import OpenAI
from markitdown import MarkItDown

client = OpenAI(
    api_key="YOUR_OPENROUTER_API_KEY",
    base_url="https://openrouter.ai/api/v1"
)

md = MarkItDown(
    llm_client=client,
    llm_model="anthropic/claude-sonnet-4.5",
    llm_prompt="Describe this image in detail for scientific documentation"
)

result = md.convert("presentation.pptx")
print(result.text_content)
```

### Azure Document Intelligence (PDF)
```bash
# CLI – add the -d flag and endpoint URL
markitdown complex.pdf -o output.md -d -e "https://<your-endpoint>.cognitiveservices.azure.com/"
```
```python
from markitdown import MarkItDown

md = MarkItDown(docintel_endpoint="https://<your-endpoint>.cognitiveservices.azure.com/")
result = md.convert("complex.pdf")
print(result.text_content)
```

### Plugin system
```bash
# List installed plugins
markitdown --list-plugins

# Activate plugins for a conversion
markitdown --use-plugins file.pdf -o output.md
```
Search GitHub for `#markitdown-plugin` to discover community extensions.

## Optional dependencies (extras)
- `pdf` – PDF parsing
- `docx` – Word documents
- `pptx` – PowerPoint files
- `xlsx` – Excel spreadsheets
- `az-doc-intel` – Azure Document Intelligence
- `audio-transcription` – WAV/MP3 speech‑to‑text
- `youtube-transcription` – YouTube video captions
- `outlook` – Outlook message files

Install a subset with `pip install 'markitdown[pdf,docx]'`.

## Common workflows
### Convert a scientific paper (PDF) to Markdown
```python
md = MarkItDown()
result = md.convert("research_paper.pdf")
with open("paper.md", "w") as f:
    f.write(result.text_content)
```

### Extract tables from an Excel workbook
```python
md = MarkItDown()
result = md.convert("data.xlsx")
print(result.text_content)  # Markdown table format
```

### Batch convert all PDFs in a folder
```python
from pathlib import Path
md = MarkItDown()
input_dir = Path("papers")
output_dir = Path("markdown_output")
output_dir.mkdir(exist_ok=True)

for pdf_path in input_dir.glob("*.pdf"):
    result = md.convert(str(pdf_path))
    (output_dir / f"{pdf_path.stem}.md").write_text(result.text_content)
    print(f"Converted {pdf_path.name}")
```

### Convert a PowerPoint with AI image captions
```python
from openai import OpenAI
from markitdown import MarkItDown

client = OpenAI(api_key="YOUR_KEY", base_url="https://openrouter.ai/api/v1")
md = MarkItDown(
    llm_client=client,
    llm_model="anthropic/claude-sonnet-4.5",
    llm_prompt="Describe each slide image with technical precision"
)
result = md.convert("presentation.pptx")
with open("presentation.md", "w") as f:
    f.write(result.text_content)
```

### Transcribe a YouTube video
```python
md = MarkItDown()
result = md.convert("https://www.youtube.com/watch?v=VIDEO_ID")
print(result.text_content)  # Full transcript in Markdown
```

## Docker usage
```bash
# Build the image
docker build -t markitdown:latest .

# Run a conversion (reads from stdin, writes to stdout)
cat document.pdf | docker run --rm -i markitdown:latest > output.md
```

## Best practices
- **Select the right engine**: use plain `MarkItDown()` for simple text, Azure Document Intelligence for complex PDFs, and AI image descriptions for visual content.
- **Handle errors**:
  ```python
  try:
      result = md.convert("file.pdf")
  except FileNotFoundError:
      print("File not found")
  except Exception as e:
      print(f"Conversion error: {e}")
  ```
- **Stream large files** to avoid high memory use (see `convert_stream`).
- **Reduce token count**: strip unnecessary whitespace and metadata after conversion.
  ```python
  import re
  clean = re.sub(r"\n{3,}", "\n\n", result.text_content).strip()
  ```
- **Batch processing**: loop over files and write each Markdown file with a consistent naming scheme.

## Troubleshooting
- **Missing optional packages**: install the required extra, e.g., `pip install 'markitdown[pdf]'`.
- **Binary file errors**: always open files in binary mode (`"rb"`) when using `convert_stream`.
- **OCR not working**: install Tesseract OCR.
  ```bash
  # macOS
  brew install tesseract
  # Ubuntu
  sudo apt-get install tesseract-ocr
  ```
- **Audio transcription fails**: verify that the `audio-transcription` extra is installed and that an API key for the transcription service is configured.

## Performance considerations
- Large PDFs may take minutes; limit page ranges if the library supports it.
- OCR and audio transcription are CPU‑intensive; run on a machine with adequate cores.
- AI image description calls incur network latency and cost; enable only when needed.

## Resources
- **GitHub repository**: https://github.com/microsoft/markitdown
- **PyPI package**: https://pypi.org/project/markitdown/
- **OpenRouter API** (for AI image captions): https://openrouter.ai
- **Azure Document Intelligence** documentation: https://learn.microsoft.com/azure/ai-services/document-intelligence

## Related skills

Load these when the task spans more than this skill.

- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`docx`](../docx/SKILL.md) — Create, read, edit, and analyze Word .docx files using docx‑js (JavaScript) or python‑docx, covering page layo…
- [`pptx`](../pptx/SKILL.md) — Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best‑practices, and…
- [`xlsx`](../xlsx/SKILL.md) — Handles creation, editing, analysis, formatting, and conversion of spreadsheet files (.xlsx, .xlsm, .csv, .tsv…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`web-scraping-apis`](../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
