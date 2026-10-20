# Exploratory Data Analysis (EDA) for Scientific Files

**Purpose** – Quickly understand the structure, content, and quality of a scientific data file. The skill auto‑detects the file format, runs format‑specific checks, and produces a markdown report that can be used for documentation, quality control, and planning downstream analysis.

## When to Use
- You have a path to a scientific data file and need a summary before any further work.
- You are asked to *explore*, *analyze*, or *summarize* a dataset.
- You need to assess data quality, completeness, or suitability for a particular analysis.
- You want a ready‑to‑share markdown report that lists key characteristics and recommendations.

## Supported File Categories
| Category | Typical Extensions |
|---|---|
| Chemistry & Molecular | `.pdb`, `.cif`, `.mol`, `.mol2`, `.sdf`, `.xyz`, `.smi`, `.gro`, `.log`, `.fchk`, `.cube`, `.dcd`, `.xtc`, `.trr`, `.prmtop`, `.psf` |
| Bioinformatics & Genomics | `.fasta`, `.fastq`, `.sam`, `.bam`, `.vcf`, `.bed`, `.gff`, `.gtf`, `.bigwig`, `.h5ad`, `.loom`, `.counts`, `.mtx` |
| Microscopy & Imaging | `.tif`, `.nd2`, `.lif`, `.czi`, `.ims`, `.dcm`, `.nii`, `.mrc`, `.dm3`, `.vsi`, `.svs`, `.ome.tiff` |
| Spectroscopy & Analytical | `.fid`, `.mzml`, `.mzxml`, `.raw`, `.mgf`, `.spc`, `.jdx`, `.xy`, `.wdf` |
| Proteomics & Metabolomics | `.mzml`, `.pepxml`, `.protxml`, `.mzid`, `.mztab`, `.sky`, `.msp`, `.h5ad` |
| General Scientific | `.npy`, `.npz`, `.csv`, `.xlsx`, `.json`, `.hdf5`, `.zarr`, `.parquet`, `.mat`, `.fits`, `.nc`, `.xml` |

## Workflow
### 1. Detect File Type
1. Extract the file extension.
2. Match the extension to one of the categories above.
3. Record the category and a short description of the format.

**Example**
```
User: "Explore sample.fastq"
→ Extension: .fastq
→ Category: Bioinformatics & Genomics
→ Format: FASTQ (sequencing reads with quality scores)
```

### 2. Load Format‑Specific Information
For each category keep a small in‑memory table that maps extensions to:
- Typical data contained
- Common use cases
- Recommended Python library
- Suggested EDA steps

**Sample table entry**
```json
{".fastq": {"description": "Sequencing reads with per‑base quality scores",
            "library": "biopython",
            "eda": ["read count", "length distribution", "GC content", "quality score summary"]}}
```

### 3. Perform Analysis
Implement the analysis directly in the conversation. Use the library from the table.

#### a. Tabular data (CSV, TSV, Excel)
```python
import pandas as pd

df = pd.read_csv('data.csv')  # or pd.read_excel for .xlsx

# Basic structure
rows, cols = df.shape
print(f"Rows: {rows}, Columns: {cols}")

# Data types
print(df.dtypes)

# Missing values
missing = df.isnull().sum()
print("Missing per column:\n", missing)

# Summary statistics
print(df.describe(include='all'))

# Outliers (simple IQR method for numeric columns)
numeric = df.select_dtypes(include='number')
Q1 = numeric.quantile(0.25)
Q3 = numeric.quantile(0.75)
IQR = Q3 - Q1
outliers = ((numeric < (Q1 - 1.5 * IQR)) | (numeric > (Q3 + 1.5 * IQR))).sum()
print("Outlier count per column:\n", outliers)
```

#### b. Sequence data (FASTA, FASTQ)
```python
from Bio import SeqIO

records = list(SeqIO.parse('reads.fastq', 'fastq'))
read_count = len(records)
lengths = [len(r.seq) for r in records]

# Length distribution
import numpy as np
print('Mean length:', np.mean(lengths))
print('Median length:', np.median(lengths))

# GC content
gc = [float(r.seq.count('G') + r.seq.count('C')) / len(r.seq) for r in records]
print('Mean GC%:', np.mean(gc) * 100)

# Quality scores (FASTQ only)
qualities = [np.mean(q) for r in records for q in r.letter_annotations['phred_quality']]
print('Mean quality score:', np.mean(qualities))
```

#### c. Microscopy / Imaging data
```python
from tifffile import imread
import numpy as np

img = imread('sample.tif')  # works for most TIFF‑based formats
print('Shape (Z, Y, X, C):', img.shape)
print('Data type:', img.dtype)

# Intensity statistics
print('Min:', img.min())
print('Max:', img.max())
print('Mean:', img.mean())
```
*For ND2, CZI, or other vendor formats, install the appropriate reader (e.g., `pip install nd2reader`).*

#### d. Array / Binary data (NPY, HDF5)
```python
import numpy as np
import h5py

# NPY example
arr = np.load('data.npy')
print('Shape:', arr.shape, 'dtype:', arr.dtype)
print('Stats:', arr.min(), arr.max(), arr.mean())

# HDF5 example
with h5py.File('data.h5', 'r') as f:
    for name in f:
        ds = f[name]
        print(f"Dataset {name}: shape={ds.shape}, dtype={ds.dtype}")
        # Simple stats on a slice to avoid loading huge data
        sample = ds[0:100] if ds.shape[0] > 100 else ds[...]
        print('Sample mean:', sample.mean())
```

### 4. Generate Markdown Report
Create a markdown document with the following sections:

```
# EDA Report – <filename>

**Generated:** <timestamp>

## 1. File Overview
- Path: <full path>
- Size: <human‑readable size>
- Detected format: <category> – <extension description>

## 2. Format Details
- Typical data: …
- Common use cases: …
- Recommended Python library: …

## 3. Data Characteristics
- Dimensions / shape
- Data types
- Number of records / rows (if applicable)
- Summary statistics (mean, median, std, min, max)
- Missing / null values
- Quality metrics (e.g., FASTQ quality, image bit depth)
- Outlier count

## 4. Key Findings
- Notable patterns (e.g., bimodal length distribution)
- Potential issues (high missing rate, unexpected value ranges)
- Any compliance warnings (e.g., missing required metadata)

## 5. Recommendations
- Pre‑processing steps (normalization, imputation, filtering)
- Suggested downstream analyses (e.g., differential expression, clustering, image segmentation)
- Recommended tools or libraries for next steps
- Visualization ideas (histograms, box plots, heatmaps, intensity maps)

---
*Report generated automatically by the Exploratory Data Analysis skill.*
```
Save the file as `<original_name>_eda_report.md`.

## Rules & Best Practices
- **Always verify the library is installed** before importing. Provide a clear pip command if missing.
- **Sample large files** (e.g., >1 M records) to keep runtime reasonable. Use `head`, `pandas.read_csv(..., nrows=10000)`, or chunked iteration.
- **Cache format metadata** when analyzing multiple files of the same type to avoid repeated look‑ups.
- **Validate metadata** (e.g., image pixel size vs reported dimensions) and note mismatches.
- **Handle errors gracefully** – catch `ImportError` and suggest installation, catch file‑read errors and report the problem.
- **Respect data provenance** – record instrument, software version, and any processing steps mentioned in the file header.
- **Do not modify the original file**; all analysis should be read‑only.

## Common Pitfalls
| Pitfall | How to Avoid |
|---|---|
| Missing specialized library | Wrap imports in `try/except` and print `pip install <package>` instructions. |
| Extremely large files causing memory overflow | Use chunked reading (`pandas.read_csv(..., chunksize=…)`) or sample a subset. |
| Unknown file extension | Ask the user for a brief description, then fall back to generic text/binary heuristics. |
| Ignoring units or calibration metadata (e.g., pixel size) | Extract and display units; flag if absent. |
| Overlooking duplicate records | Run `df.duplicated().sum()` for tabular data and report the count. |

## Checklist
- [ ] Extract file extension and map to a known category.
- [ ] Load the format‑specific metadata table.
- [ ] Verify required Python library is installed; give install command if not.
- [ ] Read a representative sample (or full file if small).
- [ ] Compute dimensions, data types, and basic statistics.
- [ ] Assess missing values, duplicates, and outliers.
- [ ] For sequence data, compute length distribution, GC content, and quality scores.
- [ ] For imaging data, report shape, bit depth, and intensity stats.
- [ ] For array data, report shape, dtype, and sample statistics.
- [ ] Compile findings into the markdown template.
- [ ] Save report as `<original>_eda_report.md`.
- [ ] Provide next‑step recommendations and relevant library links.

## Installation Tips for Common Libraries
```bash
# Bioinformatics
pip install biopython pysam pybigwig

# Chemistry / Molecular
pip install rdkit-pypi mdanalysis cclib

# Microscopy & Imaging
pip install tifffile nd2reader aicsimageio pydicom

# Spectroscopy & Mass Spec
pip install nmrglue pymzml pyteomics

# General scientific data
pip install pandas numpy h5py scipy matplotlib seaborn
```

---
*End of Exploratory Data Analysis skill.*
