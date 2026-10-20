---
name: pdf
description: "Process PDF files by extracting text and tables, merging, splitting, rotating pages, creating documents, adding watermarks, encrypting with passwords, pulling embedded images, running OCR on scans, filling form fields, and executing validated batch jobs. Use when the user mentions .pdf, asks to convert PDF to text or CSV, combine multiple PDFs, split by page range, rotate pages 90 or 180 degrees, generate PDF from HTML or Markdown, apply background stamp or logo overlay, set owner or user passwords, extract figures as PNG or JPG, recognize text in image-only scans, populate AcroForm or XFA fields, or automate high-volume PDF workflows with checksum verification."
---

# PDF Processing

Process PDF files with Python libraries and command-line tools. Choose the tool by task: pypdf for structure and security, pdfplumber for text and tables, reportlab for creation, pytesseract for OCR, and poppler/qpdf/pdftk for command-line operations.

## When to use

- The user mentions a `.pdf` file or asks to produce one.
- Extract text, tables, metadata, or images from a PDF.
- Merge, split, rotate, reorder, watermark, encrypt, or decrypt PDFs.
- Create a new PDF from text, data, or generated content.
- Fill or validate PDF forms.
- OCR scanned or image-based PDFs.
- Process many PDFs in a batch with validation and error handling.

## Quick start

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")
print(f"Pages: {len(reader.pages)}")

text = ""
for page in reader.pages:
    text += page.extract_text() or ""
```

## Read, merge, split, and rotate

```python
from pypdf import PdfReader, PdfWriter

# Merge PDFs
writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf", "doc3.pdf"]:
    reader = PdfReader(pdf_file)
    for page in reader.pages:
        writer.add_page(page)
with open("merged.pdf", "wb") as output:
    writer.write(output)

# Split into one file per page
reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i + 1}.pdf", "wb") as output:
        writer.write(output)

# Rotate one page 90 degrees clockwise
reader = PdfReader("input.pdf")
writer = PdfWriter()
page = reader.pages[0]
page.rotate(90)
writer.add_page(page)
with open("rotated.pdf", "wb") as output:
    writer.write(output)
```

## Metadata

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Subject: {meta.subject}")
print(f"Creator: {meta.creator}")
```

## Text and table extraction

Use pdfplumber when layout or tables matter.

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)

        tables = page.extract_tables()
        for table in tables:
            for row in table:
                print(row)
```

Combine tables across pages with pandas:

```python
import pandas as pd
import pdfplumber

all_tables = []
with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        for table in page.extract_tables() or []:
            if table:
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)

if all_tables:
    combined_df = pd.concat(all_tables, ignore_index=True)
    combined_df.to_excel("extracted_tables.xlsx", index=False)
```

## Create PDFs

Use reportlab. Prefer `Platypus` for multi-page documents and `canvas` for precise placement.

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("hello.pdf", pagesize=letter)
width, height = letter
c.drawString(100, height - 100, "Hello World!")
c.drawString(100, height - 120, "This is a PDF created with reportlab")
c.line(100, height - 140, 400, height - 140)
c.save()
```

```python
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import PageBreak, Paragraph, SimpleDocTemplate, Spacer

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []
story.append(Paragraph("Report Title", styles["Title"]))
story.append(Spacer(1, 12))
story.append(Paragraph("This is the body of the report. " * 20, styles["Normal"]))
story.append(PageBreak())
story.append(Paragraph("Page 2", styles["Heading1"]))
story.append(Paragraph("Content for page 2", styles["Normal"]))
doc.build(story)
```

Do not use Unicode subscript or superscript characters in ReportLab PDFs. Built-in fonts lack those glyphs and render them as solid black boxes. Use XML markup in `Paragraph` objects:

```python
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Paragraph

styles = getSampleStyleSheet()
chemical = Paragraph("H<sub>2</sub>O", styles["Normal"])
squared = Paragraph("x<super>2</super> + y<super>2</super>", styles["Normal"])
```

For canvas-drawn text, adjust font size and position manually instead of using Unicode subscripts or superscripts.

## Command-line tools

Extract text with poppler:

```bash
pdftotext input.pdf output.txt
pdftotext -layout input.pdf output.txt
pdftotext -f 1 -l 5 input.pdf output.txt
```

Merge, split, rotate, and decrypt with qpdf:

```bash
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf
qpdf input.pdf --pages . 6-10 -- pages6-10.pdf
qpdf input.pdf output.pdf --rotate=+90:1
qpdf --password=mypassword --decrypt encrypted.pdf decrypted.pdf
```

Use pdftk when available:

```bash
pdftk file1.pdf file2.pdf cat output merged.pdf
pdftk input.pdf burst
pdftk input.pdf rotate 1east output rotated.pdf
```

Extract embedded images:

```bash
pdfimages -j input.pdf output_prefix
```

## Scanned PDFs and OCR

Convert pages to images, then run OCR. Install `pytesseract`, `pdf2image`, and the Tesseract system package.

```python
import pytesseract
from pdf2image import convert_from_path

images = convert_from_path("scanned.pdf")
text = ""
for i, image in enumerate(images):
    text += f"Page {i + 1}:\n"
    text += pytesseract.image_to_string(image)
    text += "\n\n"
print(text)
```

## Watermarks

```python
from pypdf import PdfReader, PdfWriter

watermark = PdfReader("watermark.pdf").pages[0]
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as output:
    writer.write(output)
```

## Password protection

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()
for page in reader.pages:
    writer.add_page(page)
writer.encrypt("userpassword", "ownerpassword")
with open("encrypted.pdf", "wb") as output:
    writer.write(output)
```

## Forms

Use a form workflow: inspect the form fields, validate the submitted data, fill the form, then validate the output PDF. With pypdf, read fields from `PdfReader.get_fields()` and write values with the writer's form-field update method. Keep field names and expected types in a schema, and reject missing or invalid values before filling. After filling, reopen the output and confirm that the expected fields contain the submitted values.

## Batch processing and production use

- Process large PDFs page by page instead of loading all content at once.
- Validate inputs before processing and fail fast on missing files or invalid data.
- Log each operation with enough context to debug failures.
- Check process exit codes in automation.
- Use timeouts for long-running OCR or batch jobs.
- Back up original files before modifying them.
- Cache extracted data when reprocessing the same PDF.
- Use multiprocessing only where the chosen tool supports it.

For automation, use consistent exit codes:

- `0`: success
- `1`: file not found
- `2`: invalid input
- `3`: processing error
- `4`: validation error

## Troubleshooting

- Missing Python modules: install required packages such as `pypdf`, `pdfplumber`, `reportlab`, `pillow`, `pytesseract`, and `pandas`.
- Tesseract not found: install the Tesseract system package.
- Memory errors on large PDFs: process one page at a time and release intermediate objects.
- Permission errors: ensure scripts and output directories are writable.
- Encrypted PDFs: provide the password before reading or decrypt with qpdf.
- Empty text extraction: the PDF may be scanned; use OCR.
- Broken tables: inspect table settings, merged cells, and page boundaries; export to CSV or Excel for review.

## Checklist

- [ ] Identify whether the PDF is text-based or scanned.
- [ ] Choose pypdf, pdfplumber, reportlab, OCR, or a CLI tool by task.
- [ ] Preserve layout with `pdftotext -layout` when needed.
- [ ] Validate form data before filling and verify the output afterward.
- [ ] Process large PDFs page by page.
- [ ] Check output files, page counts, and extracted content.
- [ ] Keep originals unchanged until the output is verified.

## Related skills

Load these when the task spans more than this skill.

- [`docx`](../docx/SKILL.md) — Create, read, edit, and analyze Word .docx files using docx‑js (JavaScript) or python‑docx, covering page layo…
- [`xlsx`](../xlsx/SKILL.md) — Handles creation, editing, analysis, formatting, and conversion of spreadsheet files (.xlsx, .xlsm, .csv, .tsv…
- [`markitdown`](../markitdown/SKILL.md) — MarkItDown converts PDF, DOCX, PPTX, XLSX, images, audio, HTML, CSV, JSON, XML, ZIP, EPUB, YouTube URLs and ot…
- [`file-organization`](../file-organization/SKILL.md) — Organizes files and folders intelligently: analyzes directory structure, finds duplicates, proposes logical fo…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`pptx`](../pptx/SKILL.md) — Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best‑practices, and…
- [`brand-theming`](../brand-theming/SKILL.md) — Applies Anthropic’s official brand colors and typography to slides, documents, or other visual artifacts. Use…
