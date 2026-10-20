---
name: scientific-figures
description: "Generate publication-ready scientific figures using matplotlib, seaborn, and Plotly with multi-panel layouts, colorblind-safe palettes, statistical annotations, and export to PDF, EPS, TIFF, PNG at correct DPI. Use when creating journal plots, manuscript figures, conference posters, thesis graphics, or supplement visuals; need matplotlib rcParams, seaborn themes, plotly express, subplots, gridspec, dpi 300 600 1200, vector pdf eps svg, raster png tiff, colorbrewer viridis cividis, accessibility, error bars, significance brackets, p-value stars, latex text, font embedding, figure sizing inches cm, multi-panel, shared axes, inset axes, twin axes, log scale, heatmaps, violin plots, box plots, scatter matrices, regression lines, confidence intervals."
---

# Scientific Figures

Create clear, accurate, publication-ready figures for scientific manuscripts and reports. Use matplotlib for full control, seaborn for statistical graphics, and Plotly for interactive exploration. Apply colorblind-safe palettes, journal dimensions, readable typography, and correct export settings.

## When to use

- Creating plots for manuscripts, reports, posters, or presentations
- Preparing figures for journal submission
- Need colorblind-friendly and grayscale-safe visualizations
- Building multi-panel figures with consistent styling
- Exporting at publication resolution and format
- Working with matplotlib, seaborn, or Plotly

## Core principles

### Resolution and format

- Raster images (photos, microscopy): 300-600 DPI
- Line art: 600-1200 DPI or vector format
- Preferred vector formats: PDF, EPS, SVG
- Raster formats: TIFF, PNG
- Never use JPEG for scientific data
- Save with bbox_inches='tight'
- Use facecolor='white' for a white background

### Color and accessibility

Use colorblind-friendly palettes. Okabe-Ito:

```python
okabe_ito = ['#E69F00', '#56B4E9', '#009E73', '#F0E442',
             '#0072B2', '#D55E00', '#CC79A7', '#000000']
plt.rcParams['axes.prop_cycle'] = plt.cycler(color=okabe_ito)
sns.set_palette(okabe_ito)
```

- Continuous data: use viridis, plasma, or cividis
- Diverging data: use PuOr, RdBu, BrBG, or RdBu_r
- Avoid jet, rainbow, and red-green pairs
- Test every figure in grayscale
- Add redundant encoding:

```python
line_styles = ['-', '--', '-.', ':']
markers = ['o', 's', '^', 'v']
```

### Typography

- Use sans-serif fonts: Arial, Helvetica, Calibri
- Axis labels: 7-9 pt at final print size
- Tick labels: 6-8 pt at final print size
- Panel labels: 8-12 pt, bold
- Use sentence case with units: Time (hours)

### Figure dimensions

- Nature: single 89 mm, double 183 mm
- Science: single 55 mm, double 175 mm
- Cell: single 85 mm, double 178 mm
- Convert millimeters to inches: inches = mm / 25.4
- Check size with fig.get_size_inches()

### Multi-panel figures

- Label panels with bold letters: A, B, C
- Use uppercase for most journals
- Use lowercase for Nature
- Keep styling consistent across panels
- Align panels and add adequate white space

```python
from string import ascii_uppercase

fig = plt.figure(figsize=(7, 4))
gs = fig.add_gridspec(2, 2, hspace=0.4, wspace=0.4)
axes = [fig.add_subplot(gs[0, 0]), fig.add_subplot(gs[0, 1]),
        fig.add_subplot(gs[1, 0]), fig.add_subplot(gs[1, 1])]
for i, ax in enumerate(axes):
    ax.text(-0.15, 1.05, ascii_uppercase[i], transform=ax.transAxes,
            fontsize=10, fontweight='bold', va='top')
```

### Statistical rigor

- Include error bars and state SD, SEM, or CI in the caption
- Include sample size (n)
- Mark significance with *, **, ***
- Show individual data points when possible

```python
ax.scatter(x_jittered, individual_points, alpha=0.4, s=8)
ax.errorbar(x, means, yerr=sems, fmt='o', capsize=3)
ax.text(1.5, max_y * 1.1, '***', ha='center', fontsize=8)
```

## Matplotlib

### Interface and basic workflow

Use the object-oriented interface for production code.

```python
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(3.5, 2.5), constrained_layout=True)
x = np.linspace(0, 10, 100)
ax.plot(x, np.sin(x), label='sin(x)')
ax.plot(x, np.cos(x), label='cos(x)')
ax.set_xlabel('Time (s)')
ax.set_ylabel('Amplitude (mV)')
ax.legend(frameon=False)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

fig.savefig('figure.pdf', bbox_inches='tight')
fig.savefig('figure.png', dpi=300, bbox_inches='tight')
```

### Layouts

```python
fig, axes = plt.subplots(2, 2, figsize=(7, 6), constrained_layout=True)

fig, axes = plt.subplot_mosaic([['A', 'B'], ['A', 'C']], figsize=(7, 5))

from matplotlib.gridspec import GridSpec
fig = plt.figure(figsize=(7, 5))
gs = GridSpec(2, 2, figure=fig)
ax_top = fig.add_subplot(gs[0, :])
ax_left = fig.add_subplot(gs[1, 0])
ax_right = fig.add_subplot(gs[1, 1])
```

### Common plot types

```python
ax.plot(x, y, linewidth=2, linestyle='--', marker='o')
ax.scatter(x, y, s=sizes, c=colors, alpha=0.6, cmap='viridis')
ax.bar(categories, values, edgecolor='black')
ax.hist(data, bins=30, edgecolor='black', alpha=0.7)
im = ax.imshow(matrix, cmap='viridis', aspect='auto')
fig.colorbar(im, ax=ax)
ax.boxplot([data1, data2], labels=['A', 'B'])
ax.violinplot([data1, data2], positions=[1, 2])
```

### Styling

```python
plt.rcParams.update({
    'font.family': 'sans-serif',
    'font.sans-serif': ['Arial', 'Helvetica'],
    'font.size': 8,
    'axes.labelsize': 9,
    'xtick.labelsize': 7,
    'ytick.labelsize': 7,
})
ax.text(0.5, 0.5, 'note', transform=ax.transAxes)
ax.annotate('point', xy=(x, y), xytext=(x + 1, y + 1),
            arrowprops=dict(arrowstyle='->'))
```

### Saving

```python
def save_publication_figure(fig, name, formats=('pdf', 'png'), dpi=300):
    for fmt in formats:
        fig.savefig(f'{name}.{fmt}', dpi=dpi,
                    bbox_inches='tight', facecolor='white')
```

### 3D plots

```python
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(6, 5))
ax = fig.add_subplot(111, projection='3d')
ax.plot_surface(X, Y, Z, cmap='viridis')
ax.scatter(x, y, z, c=colors, marker='o')
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
```

### Best practices

- Use the object-oriented interface for production code
- Set figsize when creating the figure
- Use constrained_layout=True to avoid overlaps
- Use perceptually uniform colormaps
- Add patterns or hatching for accessibility
- Use rasterized=True for large datasets
- Close figures with plt.close(fig)

### Common issues

- Overlapping elements: use constrained_layout or tight_layout
- State confusion: use the object-oriented interface
- Memory issues: close figures explicitly
- Font warnings: set font.sans-serif
- DPI confusion: pixels = dpi * inches

## Seaborn

Seaborn builds statistical graphics on matplotlib.

```python
import seaborn as sns
import matplotlib.pyplot as plt

sns.set_theme(style='ticks', context='paper', font_scale=1.1)
sns.set_palette('colorblind')

fig, ax = plt.subplots(figsize=(3.5, 2.5))
sns.scatterplot(data=df, x='time', y='response', hue='treatment', ax=ax)
sns.despine()
```

### Common plot types

```python
sns.boxplot(data=df, x='treatment', y='response',
            order=['Control', 'Low', 'High'], ax=ax)
sns.stripplot(data=df, x='treatment', y='response',
              order=['Control', 'Low', 'High'],
              color='black', alpha=0.3, size=3, ax=ax)
sns.violinplot(data=df, x='timepoint', y='expression',
               hue='treatment', split=True, inner='quartile', ax=ax)
sns.heatmap(corr, mask=mask, annot=True, fmt='.2f',
           cmap='RdBu_r', center=0, square=True,
           linewidths=1, cbar_kws={'shrink': 0.8}, ax=ax)
sns.lineplot(data=timeseries, x='time', y='measurement',
             hue='treatment', errorbar=('ci', 95),
             markers=True, ax=ax)
```

### Faceting

```python
g = sns.relplot(data=df, x='dose', y='response', hue='treatment',
                col='cell_line', row='timepoint', kind='line',
                height=2.5, aspect=1.2, errorbar=('ci', 95), markers=True)
g.set_axis_labels('Dose (uM)', 'Response (AU)')
g.set_titles('{row_name} | {col_name}')
sns.despine()
```

### Axes-level vs figure-level

- Axes-level functions accept ax= for custom layouts
- Figure-level functions handle automatic faceting
- Control figure-level size with height and aspect

### Statistical uncertainty

- lineplot shows mean with confidence interval by default
- Set errorbar to 'ci', 'sd', or 'se'
- barplot shows mean with bootstrapped confidence interval
- State the error type in the caption

### Common issues

- Legend outside plot: set bbox_to_anchor
- Overlapping labels: rotate and use tight_layout
- Text too small: increase font_scale

## Plotly

Plotly creates interactive, publication-quality visualizations.

```bash
uv pip install plotly
```

```python
import plotly.express as px

fig = px.scatter(df, x='x', y='y', title='Plot')
fig.show()
```

### API choice

- Use Plotly Express for quick standard charts with DataFrames
- Use graph objects for fine control and complex traces
- Combine both approaches on one figure

```python
fig = px.scatter(df, x='x', y='y')
fig.update_layout(title='Custom Title')
fig.add_hline(y=10)
```

### Subplots and templates

```python
from plotly.subplots import make_subplots
import plotly.graph_objects as go

fig = make_subplots(rows=2, cols=2, subplot_titles=('A', 'B', 'C', 'D'))
fig.add_trace(go.Scatter(x=[1, 2], y=[3, 4]), row=1, col=1)

fig = px.scatter(df, x='x', y='y', template='plotly_white')
```

### Interactivity

```python
fig.update_traces(hovertemplate='<b>%{x}</b><br>Value: %{y:.2f}<extra></extra>')
fig.update_xaxes(rangeslider_visible=True)
fig = px.scatter(df, x='x', y='y', animation_frame='year')
```

### Export

```bash
uv pip install kaleido
```

```python
fig.write_html('chart.html', include_plotlyjs='cdn')
fig.write_image('chart.png')
fig.write_image('chart.pdf')
fig.write_image('chart.svg')
```

### Common examples

```python
fig = px.scatter(df, x='temperature', y='yield', trendline='ols')
fig = px.imshow(corr, text_auto=True, color_continuous_scale='RdBu')
fig = px.histogram(df, x='values', color='group', marginal='box', nbins=30)
fig = px.box(df, x='category', y='value', points='all')
fig = px.violin(df, x='group', y='measurement', box=True)
fig = px.line(df, x='date', y='price')
```

### Dash integration

```bash
uv pip install dash
```

```python
import dash
from dash import dcc, html

app = dash.Dash(__name__)
app.layout = html.Div([html.H1('Dashboard'), dcc.Graph(figure=fig)])
app.run_server(debug=True)
```

## Recommended workflow

1. Plan the target journal, figure type, and content
2. Configure style and figure size
3. Create the figure with labels, colors, and statistics
4. Verify size, fonts, colors, and accessibility
5. Export required formats
6. Review at final size in the manuscript

## Common pitfalls

- Font too small at final size
- Using JPEG for plots
- Red-green color pairs
- Low resolution
- Missing units on axes
- 3D effects
- Chart junk
- Truncated axes without justification
- Inconsistent styling across figures
- Missing error bars

## Checklist

- Resolution meets journal requirements
- File format is correct
- Figure size matches journal specifications
- Text is readable at final size (>=6 pt)
- Colors are colorblind-friendly
- Figure works in grayscale
- All axes are labeled with units
- Error bars are present and defined
- Panel labels are present and consistent
- No chart junk or 3D effects
- Fonts are consistent across figures
- Statistical significance is marked
- Legend is clear and complete

## Related skills

Load these when the task spans more than this skill.

- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
- [`scientific-schematics`](../scientific-schematics/SKILL.md) — Create publication-quality scientific diagrams with Nano Banana Pro AI and Gemini 3 Pro quality review. Use fo…
- [`scientific-slides`](../scientific-slides/SKILL.md) — Generates scientific presentation slides (PDF, PowerPoint, or LaTeX Beamer) using AI‑generated images, provide…
- [`research-posters`](../research-posters/SKILL.md) — Create and review professional research posters in LaTeX (beamerposter, tikzposter, baposter), including sizin…
- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`manim`](../manim/SKILL.md) — Provides concise guidance for creating mathematical animations with the Manim Community Python library, coveri…
- [`image-enhancer`](../image-enhancer/SKILL.md) — Enhances image resolution, sharpness, and reduces compression artifacts for screenshots, photos, and graphics.…
