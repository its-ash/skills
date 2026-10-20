---
name: file-organization
description: "Organizes files and folders by analyzing directory structure, finding duplicates, proposing logical layouts, renaming files consistently, executing moves with confirmation, and generating summaries; includes invoice and receipt mode that extracts vendor, date, amount, and description from PDFs and images, renames to YYYY-MM-DD Vendor - Invoice - Description, sorts by year, category, and vendor, and creates CSV summaries for tax preparation. Use when cleaning up downloads, decluttering folders, deduplicating files, sorting documents, renaming invoices, extracting receipt data, preparing tax documents, or organizing PDFs, JPGs, PNGs, CSVs, and spreadsheets."
---

# File Organization

Organizes files and folders by analyzing structure, finding duplicates, proposing logical layouts, renaming consistently, and executing moves with confirmation. Includes a specialized invoice/receipt mode that extracts metadata from PDFs and images, renames to standard format, sorts by year/category/vendor, and generates CSV summaries for tax preparation.

## When to Use This Skill

- Downloads, Documents, or project folders are chaotic and hard to navigate
- Duplicate files waste space and cause confusion
- No consistent folder structure exists or current structure doesn't match workflow
- Invoices, receipts, or financial documents need tax-ready organization
- Preparing for tax season, expense reconciliation, or accountant handoff
- Starting a new project and need a good initial structure
- Archiving old projects or completed work

## General File Organization Workflow

### 1. Understand Scope
Ask clarifying questions:
- Which directory needs organization? (Downloads, Documents, entire home folder, specific project?)
- What's the main problem? (Can't find things, duplicates, too messy, no structure?)
- Any files or folders to avoid? (Current projects, sensitive data?)
- How aggressively to organize? (Conservative vs. comprehensive cleanup)

### 2. Analyze Current State
Run these commands to understand the target directory:

```bash
# Overview of current structure
ls -la [target_directory]

# File types and sizes (first 20)
find [target_directory] -type f -exec file {} \; | head -20

# Largest directories
find [target_directory] -maxdepth 1 -type d -exec du -sh {} \; | sort -rh | head -20

# File type breakdown
find [target_directory] -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

Summarize findings:
- Total files and folders
- File type breakdown
- Size distribution
- Date ranges
- Obvious organization issues

### 3. Identify Organization Patterns
Based on files, determine logical groupings:

**By Type**:
- Documents (PDF, DOCX, TXT)
- Images (JPG, PNG, SVG)
- Videos (MP4, MOV)
- Archives (ZIP, TAR, DMG)
- Code/Projects (directories with code)
- Spreadsheets (XLSX, CSV)
- Presentations (PPTX, KEY)

**By Purpose**:
- Work vs. Personal
- Active vs. Archive
- Project-specific
- Reference materials
- Temporary/scratch files

**By Date**:
- Current year/month
- Previous years
- Very old (archive candidates)

### 4. Find Duplicates
When requested, search for duplicates:

```bash
# Exact duplicates by hash
find [directory] -type f -exec md5 {} \; | sort | uniq -d

# Similar names
find [directory] -type f -printf '%f\n' | sort | uniq -d

# Similar-sized files
find [directory] -type f -printf '%s %p\n' | sort -n
```

For each duplicate set:
- Show all file paths
- Display sizes and modification dates
- Recommend which to keep (usually newest or best-named)
- **Always ask for confirmation before deleting**

### 5. Propose Organization Plan
Present a clear plan before making changes:

```markdown
# Organization Plan for [Directory]

## Current State
- X files across Y folders
- [Size] total
- File types: [breakdown]
- Issues: [list problems]

## Proposed Structure
[Directory]/
├── Work/
│   ├── Projects/
│   ├── Documents/
│   └── Archive/
├── Personal/
│   ├── Photos/
│   ├── Documents/
│   └── Media/
└── Downloads/
    ├── To-Sort/
    └── Archive/

## Changes I'll Make
1. Create new folders: [list]
2. Move files:
   - X PDFs → Work/Documents/
   - Y images → Personal/Photos/
   - Z old files → Archive/
3. Rename files: [any renaming patterns]
4. Delete: [duplicates or trash files]

## Files Needing Your Decision
- [List any files you're unsure about]

Ready to proceed? (yes/no/modify)
```

### 6. Execute Organization
After approval, organize systematically:

```bash
# Create folder structure
mkdir -p "path/to/new/folders"

# Move files with clear logging
mv "old/path/file.pdf" "new/path/file.pdf"

# Rename files with consistent patterns
# Example: "YYYY-MM-DD - Description.ext"
```

**Important Rules**:
- Always confirm before deleting anything
- Log all moves for potential undo
- Preserve original modification dates
- Handle filename conflicts gracefully
- Stop and ask if you encounter unexpected situations

### 7. Provide Summary and Maintenance Tips

```markdown
# Organization Complete! ✨

## What Changed
- Created [X] new folders
- Organized [Y] files
- Freed [Z] GB by removing duplicates
- Archived [W] old files

## New Structure
[Show the new folder tree]

## Maintenance Tips
1. Weekly: Sort new downloads
2. Monthly: Review and archive completed projects
3. Quarterly: Check for new duplicates
4. Yearly: Archive old files

## Quick Commands
# Find files modified this week
find . -type f -mtime -7

# Find duplicates
find . -type f -exec md5 {} \; | sort | uniq -d
```

## Invoice & Receipt Organization (Specialized Mode)

### When to Use Invoice Mode
- Preparing for tax season
- Managing business expenses across vendors
- Organizing receipts from messy folder or email downloads
- Setting up automated invoice filing for ongoing bookkeeping
- Reconciling expenses for reimbursement

### Invoice Workflow

#### 1. Scan the Folder
```bash
# Find all invoice-related files
find . -type f \( -name "*.pdf" -o -name "*.jpg" -o -name "*.png" \) -print
```
Report: total files, file types, date range, current organization.

#### 2. Extract Information from Each File
**From PDF invoices**: Use text extraction to read:
- Vendor/company name (usually at top)
- Invoice date: "Invoice Date:", "Date:", "Issued:"
- Invoice number: "Invoice #:", "Invoice Number:"
- Amount: "Amount Due:", "Total:", "Amount:"
- Description: "Description:", "Service:", "Product:"

**From image receipts**: Read visible text for vendor, date, total amount.

**Fallback for unclear files**:
- Use filename clues
- Check file creation/modification date
- Flag for manual review if critical info missing

#### 3. Determine Organization Strategy
Ask user preference if not specified:

```markdown
I found [X] invoices from [date range].

How would you like them organized?
1. By Vendor (Adobe/, Amazon/, Stripe/, etc.)
2. By Category (Software/, Office Supplies/, Travel/, etc.)
3. By Date (2024/Q1/, 2024/Q2/, etc.)
4. By Tax Category (Deductible/, Personal/, etc.)
5. Custom (describe your structure)

Default: Year/Category/Vendor
```

#### 4. Create Standardized Filename
Pattern: `YYYY-MM-DD Vendor - Invoice - Description.ext`

Examples:
- `2024-03-15 Adobe - Invoice - Creative Cloud.pdf`
- `2024-01-10 Amazon - Receipt - Office Supplies.pdf`
- `2023-12-01 Stripe - Invoice - Monthly Payment Processing.pdf`

**Filename Best Practices**:
- Remove special characters except hyphens
- Capitalize vendor names properly
- Keep descriptions concise but meaningful
- Use consistent date format (YYYY-MM-DD) for sorting
- Preserve original file extension

#### 5. Execute Organization
Show plan before moving:

```markdown
# Organization Plan

## Proposed Structure
Invoices/
├── 2023/
│   ├── Software/
│   │   ├── Adobe/
│   │   └── Microsoft/
│   ├── Services/
│   └── Office/
└── 2024/
    ├── Software/
    ├── Services/
    └── Office/

## Sample Changes
Before: `invoice_adobe_march.pdf`
After: `2024-03-15 Adobe - Invoice - Creative Cloud.pdf`
Location: `Invoices/2024/Software/Adobe/`

Process [X] files? (yes/no)
```

After approval:
```bash
# Create folder structure
mkdir -p "Invoices/2024/Software/Adobe"

# Copy (don't move) to preserve originals
cp "original.pdf" "Invoices/2024/Software/Adobe/2024-03-15 Adobe - Invoice - Creative Cloud.pdf"

# Or move if user prefers
mv "original.pdf" "new/path/standardized-name.pdf"
```

#### 6. Generate Summary Report
Create CSV with all invoice details:

```csv
Date,Vendor,Invoice Number,Description,Amount,Category,File Path
2024-03-15,Adobe,INV-12345,Creative Cloud,52.99,Software,Invoices/2024/Software/Adobe/2024-03-15 Adobe - Invoice - Creative Cloud.pdf
2024-03-10,Amazon,123-4567890-1234567,Office Supplies,127.45,Office,Invoices/2024/Office/Amazon/2024-03-10 Amazon - Receipt - Office Supplies.pdf
```

CSV uses: accounting software import, accountant sharing, expense tracking, tax preparation.

#### 7. Provide Completion Summary
```markdown
# Organization Complete! 📊

## Summary
- Processed: [X] invoices
- Date range: [earliest] to [latest]
- Total amount: $[sum] (if amounts extracted)
- Vendors: [Y] unique vendors

## New Structure
Invoices/
├── 2024/ (45 files)
│   ├── Software/ (23 files)
│   ├── Services/ (12 files)
│   └── Office/ (10 files)
└── 2023/ (12 files)

## Files Created
- /Invoices/ - Organized invoices
- /Invoices/invoice-summary.csv - Spreadsheet for accounting
- /Invoices/originals/ - Original files (if copied)

## Files Needing Review
[List any files where information couldn't be extracted completely]
```

## Common Invoice Organization Patterns

### By Vendor (Simple)
```
Invoices/
├── Adobe/
├── Amazon/
├── Google/
└── Microsoft/
```

### By Year and Category (Tax-Friendly)
```
Invoices/
├── 2023/
│   ├── Software/
│   ├── Hardware/
│   ├── Services/
│   └── Travel/
└── 2024/
    └── ...
```

### By Quarter (Detailed Tracking)
```
Invoices/
├── 2024/
│   ├── Q1/
│   │   ├── Software/
│   │   ├── Office/
│   │   └── Travel/
│   └── Q2/
│       └── ...
```

### By Tax Category (Accountant-Ready)
```
Invoices/
├── Deductible/
│   ├── Software/
│   ├── Office/
│   └── Professional-Services/
├── Partially-Deductible/
│   └── Meals-Travel/
└── Personal/
```

## Handling Special Cases

### Missing Information
- Flag file for manual review
- Use file modification date as fallback
- Create "Needs-Review/" folder

### Duplicate Invoices
- Compare file hashes
- Keep highest quality version
- Note duplicates in summary

### Multi-Page Invoices
- Merge PDFs if needed
- Use consistent naming for parts
- Note in CSV if invoice is split

### Non-Standard Formats
- Extract what's possible
- Standardize what you can
- Flag for review if critical info missing

## Best Practices

### Folder Naming
- Use clear, descriptive names
- Avoid spaces (use hyphens or underscores)
- Be specific: "client-proposals" not "docs"
- Use prefixes for ordering: "01-current", "02-archive"

### File Naming
- Include dates: "2024-10-17-meeting-notes.md"
- Be descriptive: "q3-financial-report.xlsx"
- Avoid version numbers in names (use version control instead)
- Remove download artifacts: "document-final-v2 (1).pdf" → "document.pdf"

### When to Archive
- Projects not touched in 6+ months
- Completed work that might be referenced later
- Old versions after migration to new systems
- Files you're hesitant to delete (archive first)

### Invoice-Specific Tips
- Scan emails to PDF first
- Save all invoices to one folder for batch processing
- Organize invoices monthly, not annually
- Backup originals before reorganizing
- Include amounts in CSV for budget tracking
- Tag by deductibility for tax purposes
- Keep receipts 7 years (standard audit period)

## Automation Setup
For ongoing invoice organization:

```bash
# Create a watch script for ~/Downloads/invoices
# Auto-organizes new invoice files using standard naming and folder structure
```

## Checklist

### Before Starting
- [ ] Confirm target directory with user
- [ ] Identify files/folders to exclude
- [ ] Determine organization aggressiveness

### General Organization
- [ ] Run analysis commands
- [ ] Identify duplicates
- [ ] Propose structure
- [ ] Get user approval
- [ ] Execute with logging
- [ ] Provide summary and maintenance commands

### Invoice Organization
- [ ] Scan for PDF/JPG/PNG files
- [ ] Extract metadata from each file
- [ ] Confirm organization strategy
- [ ] Generate standardized filenames
- [ ] Show plan with before/after examples
- [ ] Execute (copy preferred over move)
- [ ] Generate CSV summary
- [ ] List files needing review
- [ ] Provide completion summary

### After Completion
- [ ] Verify user can navigate new structure
- [ ] Share maintenance commands
- [ ] Offer to organize another folder
- [ ] For invoices: remind about CSV import and 7-year retention

## Related skills

Load these when the task spans more than this skill.

- [`pdf`](../pdf/SKILL.md) — Process PDF files: extract text and tables, merge, split, rotate, create, watermark, encrypt, extract images,…
- [`xlsx`](../xlsx/SKILL.md) — Handles creation, editing, analysis, formatting, and conversion of spreadsheet files (.xlsx, .xlsm, .csv, .tsv…
- [`docx`](../docx/SKILL.md) — Create, read, edit, and analyze Word .docx files using docx‑js (JavaScript) or python‑docx, covering page layo…
- [`image-enhancer`](../image-enhancer/SKILL.md) — Enhances image resolution, sharpness, and reduces compression artifacts for screenshots, photos, and graphics.…
- [`agent-instructions-refactor`](../agent-instructions-refactor/SKILL.md) — Refactor a bloated AGENTS.md, CLAUDE.md, or similar file into a minimal root file and a set of linked topic fi…
- [`obsidian`](../obsidian/SKILL.md) — Create, edit, and validate Obsidian Flavored Markdown, .base files, .canvas JSON files, and Web Clipper templa…
- [`video-downloader`](../video-downloader/SKILL.md) — Downloads videos or audio from YouTube and other platforms. Choose resolution, format, single video, playlist,…
