---
name: docx
description: "Create, read, edit, and analyze Microsoft Word .docx files with docx-js or python-docx, including page layout, styles, tables, images, TOC, headers, footers, tracked changes, comments, and PDF or PNG conversion. Use when working with Word documents, .docx files, docx-js, python-docx, Office Open XML, document generation, mail merge, reports, letters, resumes, manuscripts, or converting DOCX to PDF or PNG."
---

# DOCX (Word Document) Skill

Use this skill whenever a user needs to create, read, edit, or analyse a Microsoft Word `.docx` file. It covers generation with correct layout, extraction of text, manipulation of tables, images, headings, footers, tracked changes, comments, and conversion to PDF or PNG for visual review.

## When to use
- Produce a report, memo, letter, template, or any professional document as a `.docx` file.
- Extract or reorganise content from an existing `.docx`.
- Insert, replace, or resize images.
- Add or update tables, lists, footnotes, hyperlinks, or a table of contents.
- Apply or accept tracked changes and comments.
- Convert a document to PDF or PNG for visual inspection.

---

## Creating New Documents
### Choose a library
- **JavaScript** – `docx` (install with `npm install -g docx`).
- **Python** – `python-docx` (install with `pip install python-docx`).

Both libraries produce a valid `.docx` ZIP archive. The examples below use the JavaScript library because it offers fine‑grained control over layout. Adapt the same concepts to Python if preferred.

### Basic setup (JavaScript)
```javascript
const { Document, Packer, Paragraph, TextRun } = require('docx');
const fs = require('fs');

const doc = new Document({ sections: [{ children: [] }] });
Packer.toBuffer(doc).then(buffer => fs.writeFileSync('output.docx', buffer));
```

### Page size and margins (US Letter example)
```javascript
const { PageOrientation } = require('docx');

sections: [{
  properties: {
    page: {
      size: { width: 12240, height: 15840 }, // DXA units (1 inch = 1440)
      margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
      orientation: PageOrientation.PORTRAIT,
    },
  },
  children: []
}]
```
*Never rely on the library default (A4). Always set width and height explicitly.*

### Styles – override built‑in headings
```javascript
const doc = new Document({
  styles: {
    default: { document: { run: { font: 'Arial', size: 24 } } }, // 12 pt
    paragraphStyles: [
      {
        id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal',
        run: { size: 32, bold: true, font: 'Arial' },
        paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 },
      },
      {
        id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal',
        run: { size: 28, bold: true, font: 'Arial' },
        paragraph: { spacing: { before: 180, after: 180 }, outlineLevel: 1 },
      },
    ],
  },
  sections: [{ children: [] }],
});
```
*Use the exact IDs (`Heading1`, `Heading2`, …) and set `outlineLevel` – required for a Table of Contents.*

### Lists – use numbering config, never raw Unicode bullets
```javascript
const doc = new Document({
  numbering: {
    config: [
      {
        reference: 'bullets',
        levels: [{ level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }],
      },
      {
        reference: 'numbers',
        levels: [{ level: 0, format: LevelFormat.DECIMAL, text: '%1.', alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }],
      },
    ],
  },
  sections: [{
    children: [
      new Paragraph({ numbering: { reference: 'bullets', level: 0 }, children: [new TextRun('Bullet item')] }),
      new Paragraph({ numbering: { reference: 'numbers', level: 0 }, children: [new TextRun('Numbered item')] }),
    ],
  }],
});
```
*Each `reference` creates an independent sequence. Use the same reference to continue numbering.*

### Tables – set dual widths and use DXA units
```javascript
const border = { style: BorderStyle.SINGLE, size: 1, color: 'CCCCCC' };
new Table({
  width: { size: 9360, type: WidthType.DXA }, // content width for US Letter with 1" margins
  columnWidths: [4680, 4680], // must sum to table width
  rows: [
    new TableRow({
      children: [
        new TableCell({
          borders,
          width: { size: 4680, type: WidthType.DXA },
          shading: { fill: 'D5E8F0', type: ShadingType.CLEAR },
          margins: { top: 80, bottom: 80, left: 120, right: 120 },
          children: [new Paragraph({ children: [new TextRun('Cell')] })],
        }),
        // add more cells as needed
      ],
    }),
  ],
});
```
**Rules**
- Always use `WidthType.DXA`. Never use `WidthType.PERCENTAGE` (breaks in Google Docs).
- Table `width` must equal the sum of `columnWidths`.
- Each cell `width` must match its column width.
- Add `margins` for internal padding.
- Use `ShadingType.CLEAR`, not `SOLID`.

### Images – required fields
```javascript
new Paragraph({
  children: [
    new ImageRun({
      type: 'png', // png, jpg, jpeg, gif, bmp, svg
      data: fs.readFileSync('image.png'),
      transformation: { width: 200, height: 150 },
      altText: { title: 'Logo', description: 'Company logo', name: 'logo' },
    }),
  ],
});
```
*The `type` field is mandatory; all three alt‑text properties must be provided.*

### Page breaks
```javascript
new Paragraph({ children: [new PageBreak()] }); // inside a Paragraph
// or
new Paragraph({ pageBreakBefore: true, children: [new TextRun('New page')] });
```

### Hyperlinks
```javascript
// External link
new Paragraph({
  children: [new ExternalHyperlink({
    children: [new TextRun({ text: 'Visit site', style: 'Hyperlink' })],
    link: 'https://example.com',
  })],
});

// Internal link (bookmark)
new Paragraph({ heading: HeadingLevel.HEADING_1, children: [
  new Bookmark({ id: 'ch1', children: [new TextRun('Chapter 1')] }),
]});
new Paragraph({ children: [new InternalHyperlink({
  children: [new TextRun({ text: 'See Chapter 1', style: 'Hyperlink' })],
  anchor: 'ch1',
})]});
```

### Footnotes
```javascript
const doc = new Document({
  footnotes: {
    1: { children: [new Paragraph('Source: Annual Report 2024')] },
    2: { children: [new Paragraph('See appendix for methodology')] },
  },
  sections: [{
    children: [new Paragraph({
      children: [
        new TextRun('Revenue grew 15%'),
        new FootnoteReferenceRun(1),
        new TextRun(' using adjusted metrics'),
        new FootnoteReferenceRun(2),
      ],
    })],
  }],
});
```

### Tab stops (right‑aligned date, dot leaders)
```javascript
// Right‑aligned date on same line
new Paragraph({
  children: [new TextRun('Company Name'), new TextRun('\tJanuary 2025')],
  tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }],
});

// Dot leader for a TOC‑style line
new Paragraph({
  children: [
    new TextRun('Introduction'),
    new TextRun({ children: [
      new PositionalTab({ alignment: PositionalTabAlignment.RIGHT, relativeTo: PositionalTabRelativeTo.MARGIN, leader: PositionalTabLeader.DOT }),
      '3',
    ]}),
  ],
});
```

### Multi‑column layouts
```javascript
// Equal‑width columns (2 columns, 0.5" gap)
sections: [{
  properties: { column: { count: 2, space: 720, equalWidth: true, separate: true } },
  children: [/* content flows across columns */],
}];

// Custom widths (must set equalWidth: false)
sections: [{
  properties: { column: { equalWidth: false, children: [
    new Column({ width: 5400, space: 720 }),
    new Column({ width: 3240 }),
  ] } },
  children: [/* content */],
}];
```
*Force a column break with a new section using `type: SectionType.NEXT_COLUMN`.*

### Table of Contents
```javascript
new TableOfContents('Table of Contents', { hyperlink: true, headingStyleRange: '1-3' });
```
*Headings must use `HeadingLevel` only; custom styles are ignored.*

### Headers and Footers
```javascript
sections: [{
  properties: { page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
  headers: { default: new Header({ children: [new Paragraph({ children: [new TextRun('Header')] })] }) },
  footers: { default: new Footer({ children: [new Paragraph({ children: [new TextRun('Page '), new TextRun({ children: [PageNumber.CURRENT] })] })] }) },
  children: [/* document body */],
}];
```

## Critical Rules for docx‑js (and any DOCX generation)
- Set page size explicitly; default is A4.
- For landscape, pass portrait dimensions and set `orientation: PageOrientation.LANDSCAPE`.
- Never embed raw `\n` characters; use separate `Paragraph` objects.
- Never insert Unicode bullet characters directly; use `LevelFormat.BULLET`.
- `PageBreak` must be inside a `Paragraph`.
- `ImageRun` requires a `type` field.
- Table `width` and all `columnWidths` must use DXA units; never use percentages.
- Provide both table‑level `columnWidths` **and** per‑cell `width` values.
- Cell `margins` are internal padding; they do not affect overall width.
- Use `ShadingType.CLEAR` for table shading.
- Do not use tables as visual dividers; use paragraph borders instead.
- TOC works only with built‑in heading levels (`HeadingLevel`).
- Override built‑in styles by using the exact IDs (`Heading1`, `Heading2`, …) and include `outlineLevel`.

---

## Editing Existing Documents
### Overview
A `.docx` file is a ZIP archive of XML parts. Editing can be done by unpack‑editing‑repacking or by using a high‑level library (`python-docx`). The low‑level method gives full control over tracked changes and comments.

### Step 1 – Unpack the document
```bash
# Unzip to a temporary folder
mkdir -p /tmp/docx_unpacked
unzip -q input.docx -d /tmp/docx_unpacked
```
The main content resides in `word/document.xml`. Other parts (styles, media, relationships) are in sibling folders.

### Step 2 – Edit XML directly
- Open `word/document.xml` in a text editor.
- **Smart quotes**: use XML entities for typographic quotes.
  ```xml
  <w:t>Here&#x2019;s a quote: &#x201C;Hello&#x201D;</w:t>
  ```
- **Tracked changes** – insert `<w:ins>` for insertions and `<w:del>` for deletions. Preserve the original `<w:rPr>` block to keep formatting.
  ```xml
  <w:ins w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
    <w:r><w:t>new text</w:t></w:r>
  </w:ins>
  <w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
    <w:r><w:delText>old text</w:delText></w:r>
  </w:del>
  ```
- **Comments** – add `<w:commentRangeStart>` and `<w:commentRangeEnd>` as siblings of `<w:r>`. Then add a `<w:commentReference>` run.
  ```xml
  <w:commentRangeStart w:id="0"/>
  <w:r><w:t>Commented text</w:t></w:r>
  <w:commentRangeEnd w:id="0"/>
  <w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r>
  ```
- **Images** – place the image file in `word/media/`, add a relationship entry in `word/_rels/document.xml.rels`, and add a content‑type entry in `[Content_Types].xml`. Then reference the image in `document.xml` using the relationship ID.

### Step 3 – Repack the document
```bash
cd /tmp/docx_unpacked
zip -r ../output.docx *
```
Optionally run a validation step (e.g., `python -m zipfile -t output.docx`) to ensure the archive is well‑formed.

### Common pitfalls when editing XML
- **Do not replace only part of a `<w:r>`**; replace the whole run with `<w:ins>`/`<w:del>` siblings.
- **Always copy the original `<w:rPr>`** into change runs to keep bold/italic/size.
- **When deleting an entire paragraph**, also add an empty `<w:del/>` inside `<w:pPr><w:rPr>` so the paragraph mark is removed.
- **RSID values** must be 8‑digit hexadecimal strings.
- **Whitespace**: add `xml:space="preserve"` to `<w:t>` if leading or trailing spaces are required.

## High‑level editing with python‑docx (optional)
```python
from docx import Document

# Load existing file
doc = Document('input.docx')

# Add a heading
doc.add_heading('Executive Summary', level=1)

# Insert a table
table = doc.add_table(rows=2, cols=2)
for row in table.rows:
    for cell in row.cells:
        cell.text = 'Data'

# Save
doc.save('output.docx')
```
*python‑docx does not expose tracked‑change XML. Use the low‑level method if you need precise change markup.*

## Converting for visual review
```bash
# Convert DOCX → PDF (LibreOffice headless)
soffice --headless --convert-to pdf --outdir /tmp pdf_input.docx

# Convert PDF → PNG pages (Poppler)
pdftoppm -png -r 150 /tmp/pdf_input.pdf /tmp/page
```
*If LibreOffice or Poppler is unavailable, instruct the user to install them (`brew install libreoffice poppler` on macOS or `sudo apt-get install libreoffice poppler-utils` on Debian/Ubuntu).*

---

## Checklist
- [ ] Set explicit page size (US Letter or desired dimensions).
- [ ] Override built‑in heading styles and include `outlineLevel`.
- [ ] Use numbering config for bullets and numbered lists.
- [ ] Define table `width`, `columnWidths`, and per‑cell `width` (DXA units).
- [ ] Provide `type` and full alt‑text for every `ImageRun`.
- [ ] Place `PageBreak` inside a `Paragraph`.
- [ ] Use `LevelFormat.BULLET` for bullet lists; never embed raw bullet characters.
- [ ] Add `ShadingType.CLEAR` for table shading.
- [ ] When editing XML, use smart‑quote entities and preserve `<w:rPr>`.
- [ ] For tracked changes, insert complete `<w:ins>` and `<w:del>` elements.
- [ ] For comments, ensure range markers are siblings of `<w:r>` and add a `commentReference` run.
- [ ] Validate the final `.docx` by opening in Word or LibreOffice.
- [ ] Convert to PDF/PNG and visually inspect pagination, tables, and images.
- [ ] Clean up temporary folders (`/tmp/docx_unpacked`, rendered images) unless retention is requested.

## Related skills

Load these when the task spans more than this skill.

- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`pptx`](../pptx/SKILL.md) — Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best‑practices, and…
- [`xlsx`](../xlsx/SKILL.md) — Handles creation, editing, analysis, formatting, and conversion of spreadsheet files (.xlsx, .xlsm, .csv, .tsv…
- [`markitdown`](../markitdown/SKILL.md) — MarkItDown converts PDF, DOCX, PPTX, XLSX, images, audio, HTML, CSV, JSON, XML, ZIP, EPUB, YouTube URLs and ot…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`brand-theming`](../brand-theming/SKILL.md) — Applies Anthropic’s official brand colors and typography to slides, documents, or other visual artifacts. Use…
- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
