---
name: xlsx
description: "Creates, edits, analyzes, formats, and converts spreadsheet workbooks in .xlsx, .xlsm, .csv, and .tsv formats, including formulas, financial-model standards, and clean Excel output. Use when the task involves Excel, spreadsheets, workbooks, worksheets, cells, formulas, openpyxl, pandas, LibreOffice, CSV, TSV, data tables, financial models, or converting tabular data."
---

# xlsx

**Purpose** – Create, modify, analyze, or convert spreadsheet files. The skill works with Excel workbooks, CSV/TSV files, and financial models. It ensures professional formatting, zero formula errors, and preservation of existing templates.

## When to use
- Build a new workbook from scratch or from other data sources.
- Add, edit, or fix data, formulas, charts, or formatting in an existing workbook.
- Clean messy tabular data (mis‑aligned rows, missing headers, junk values) and output a proper spreadsheet.
- Convert between .xlsx, .xlsm, .csv, and .tsv.
- Deliver a spreadsheet as the final artifact (not a Word doc, HTML report, or Python script).

---

## Requirements for all Excel outputs
- **Professional font** – Use a consistent font such as Arial or Times New Roman unless the user specifies otherwise.
- **Zero formula errors** – The workbook must contain no `#REF!`, `#DIV/0!`, `#VALUE!`, `#N/A`, or `#NAME?` errors.
- **Preserve existing templates** – When updating a template, match its style, colors, and layout exactly. Existing conventions override generic guidelines.

## Financial‑model specific standards (apply if the workbook is a model)
### Color coding (unless the user provides a different scheme)
| Color | RGB | Meaning |
|-------|-----|----------|
| Blue  | 0,0,255 | Hard‑coded inputs that users will change |
| Black | 0,0,0   | All formulas and calculations |
| Green | 0,128,0 | Links to other worksheets in the same workbook |
| Red   | 255,0,0 | Links to external files |
| Yellow background | 255,255,0 | Key assumptions that need review |

### Number formatting
- **Years** – Store as text strings, e.g., `"2024"`.
- **Currency** – Use `$#,##0` and include units in the header (e.g., `Revenue ($mm)`).
- **Zeros** – Display as a dash `-` (including percentages).
- **Percentages** – Default to one decimal place (`0.0%`).
- **Multiples** – Use `0.0x` (e.g., EV/EBITDA = `8.5x`).
- **Negatives** – Show in parentheses and red, e.g., `(123)`.

## Formula construction rules
1. **Assumptions placement** – Put every assumption (growth rate, margin, multiple) in a dedicated cell. Reference that cell in formulas, never embed a literal number.
   ```excel
   =B5*(1+$B$6)   // correct
   =B5*1.05       // wrong
   ```
2. **Error prevention** – Verify each reference, avoid off‑by‑one range errors, keep formulas consistent across periods, test edge cases (zero, negative), and ensure no unintended circular references.
3. **Documentation** – Add a comment or adjacent note for any hard‑coded value. Use the format:
   `Source: Company 10‑K, FY2024, Page 45, Revenue Note, https://...`

---

## Common workflow
1. **Identify file type & goal** – create, edit, analyze, or convert.
2. **Choose library** –
   - `pandas` for bulk data manipulation, analysis, and CSV/TSV handling.
   - `openpyxl` for Excel‑specific tasks: formulas, styling, charts.
3. **Load or create workbook**.
4. **Modify data, add formulas, apply formatting**.
5. **Save the workbook**.
6. **Recalculate formulas** – run LibreOffice in headless mode to force Excel to evaluate all formulas.
7. **Verify** – run the verification checklist and fix any errors.

---

## Reading & analyzing data (pandas)
```python
import pandas as pd

# Read first sheet
df = pd.read_excel('input.xlsx')

# Read all sheets as a dict of DataFrames
sheets = pd.read_excel('input.xlsx', sheet_name=None)

# Quick inspection
print(df.head())
print(df.describe())
```
*Use `dtype`, `usecols`, and `parse_dates` arguments for large or complex files.*

## Creating a new workbook (openpyxl)
```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
ws = wb.active
ws.title = 'Data'

# Header row with styling
headers = ['Year', 'Revenue', 'Cost', 'Profit']
for col, title in enumerate(headers, start=1):
    cell = ws.cell(row=1, column=col, value=title)
    cell.font = Font(bold=True, color='FFFFFFFF')
    cell.fill = PatternFill('solid', start_color='FF0000FF')
    cell.alignment = Alignment(horizontal='center')

# Sample data rows
ws.append(['2024', 1200000, 800000, '=C2-B2'])
ws.append(['2025', 1300000, 850000, '=C3-B3'])

# Column widths
for col in ['A', 'B', 'C', 'D']:
    ws.column_dimensions[col].width = 15

wb.save('model.xlsx')
```
*All calculations are expressed as Excel formulas (`=C2-B2`).*

## Editing an existing workbook (openpyxl)
```python
from openpyxl import load_workbook

wb = load_workbook('existing.xlsx')
ws = wb['Sheet1']

# Update a cell
ws['B2'] = 1_250_000  # hard‑coded input – keep blue text later

# Insert a row after the header
ws.insert_rows(2)
ws['A2'] = '2026'
ws['B2'] = '=B1*1.05'  # formula example

wb.save('updated.xlsx')
```
*Opening with `data_only=True` reads calculated values but overwriting will lose formulas – avoid unless you intend to replace them.*

## Recalculating formulas with LibreOffice (headless)
```bash
# Recalculate all formulas and save the workbook
libreoffice --headless "macro:///Standard.Module1.recalc('model.xlsx')"
# Simple alternative – open and save forces recalculation
libreoffice --headless --convert-to xlsx --outdir . model.xlsx
```
The command updates every formula, then you can run the verification checklist.

---

## Formula verification checklist
- [ ] Test 2‑3 sample references to ensure they return expected values.
- [ ] Confirm column letters match expected positions (e.g., column 64 = BL).
- [ ] Remember Excel rows are 1‑indexed; DataFrame row 5 maps to Excel row 6.
- [ ] Guard against division by zero (`#DIV/0!`).
- [ ] Scan for `#REF!` or other error codes after recalculation.
- [ ] Verify cross‑sheet references use `SheetName!A1` syntax.
- [ ] Ensure all assumption cells are clearly labeled and documented.

## Common pitfalls
- **NaN handling** – Replace or flag nulls before referencing them in formulas.
- **Far‑right columns** – Financial models often extend beyond column `Z`; double‑check column letters.
- **Multiple matches** – Search the entire workbook for a reference, not just the active sheet.
- **Volatile functions** – Avoid `INDIRECT`, `OFFSET` unless required; they impede auditability.
- **Saving with `data_only=True`** – This strips formulas; only use for reading calculated results, never for saving.

---

## Best practices
- **Library choice** – Use `pandas` for bulk data work, `openpyxl` for formatting, formulas, and chart creation.
- **Performance** – Read only needed columns (`usecols`) and process large files in chunks (`chunksize`).
- **Formatting** – Apply number formats, date formats, and conditional styles after data is written.
- **Documentation** – Add cell comments for assumptions and data sources. Include a “Source” column for any imported data.
- **Version control** – Keep a copy of the original file before making destructive changes.

## Code style guidelines
- Write concise Python code; avoid unnecessary comments and prints.
- Use clear variable names (`wb`, `ws`, `df`).
- Keep one responsibility per function.
- When generating Excel formulas, embed them as strings starting with `=`.
- Do not hard‑code calculated results; always prefer a formula.

---

## Example: Clean a messy CSV and export to a styled Excel file
```python
import pandas as pd
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill

# Load CSV, drop duplicates, trim whitespace, fill missing values
raw = pd.read_csv('messy.csv')
clean = (
    raw.drop_duplicates()
       .applymap(lambda x: x.strip() if isinstance(x, str) else x)
       .fillna(0)
)

# Write to Excel with pandas (no formatting yet)
clean.to_excel('temp.xlsx', index=False, sheet_name='Clean')

# Re‑open with openpyxl for styling
wb = Workbook()
ws = wb.active
ws.title = 'Clean'
for r in clean.itertuples(index=False, name=None):
    ws.append(r)

# Header styling
header_fill = PatternFill('solid', start_color='FFCCCCFF')
for cell in ws[1]:
    cell.font = Font(bold=True)
    cell.fill = header_fill

wb.save('cleaned_styled.xlsx')
```
After saving, run the LibreOffice recalculation command to ensure any formulas added later evaluate correctly.

## Related skills

Load these when the task spans more than this skill.

- [`docx`](../docx/SKILL.md) — Create, read, edit, and analyze Word .docx files using docx‑js (JavaScript) or python‑docx, covering page layo…
- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`pptx`](../pptx/SKILL.md) — Processes PowerPoint (.pptx) files: extracts text, creates or edits decks, applies design best‑practices, and…
- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`markitdown`](../markitdown/SKILL.md) — MarkItDown converts PDF, DOCX, PPTX, XLSX, images, audio, HTML, CSV, JSON, XML, ZIP, EPUB, YouTube URLs and ot…
- [`file-organization`](../file-organization/SKILL.md) — Organizes files and folders intelligently: analyzes directory structure, finds duplicates, proposes logical fo…
