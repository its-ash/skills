---
name: d3-visualization
description: "Build interactive D3.js data visualizations with SVG, Canvas, scales, axes, transitions, tooltips, zoom, brush, force layouts, maps, and custom charts. Use when creating bar, line, scatter, network, tree, choropleth, or dashboard graphics, binding data to DOM, animating updates, handling responsive resize, or debugging D3 errors like undefined scales, missing keys, NaN coordinates, and transition conflicts."
---

# D3.js Visualization

D3.js binds data to DOM elements and applies data-driven transformations. Use it for custom, interactive, publication-quality visualizations in any JavaScript environment.

## When to use

- Custom visual encodings or layouts.
- Complex pan, zoom, or brush behavior.
- Network, graph, hierarchy, tree, or chord diagrams.
- Geographic visualizations with custom projections.
- Choreographed transitions.
- Publication-quality graphics with fine-grained styling.
- Novel chart types not available in standard libraries.
- Use Three.js for 3D visualizations.

## Setup

```javascript
import * as d3 from 'd3';
```

CDN:

```html
<script src="https://d3js.org/d3.v7.min.js"></script>
```

## Integration patterns

Pattern A: direct DOM manipulation. Recommended for complex visualizations with transitions or interactions.

```javascript
function drawChart(data) {
  if (!data || data.length === 0) return;
  const svg = d3.select('#chart');
  svg.selectAll('*').remove();
  const width = 800;
  const height = 400;
  const margin = { top: 20, right: 30, bottom: 40, left: 50 };
  // scales, axes, elements...
}
drawChart(myData);
```

Pattern B: declarative rendering. Use D3 for calculations; render with your framework.

```javascript
function getChartElements(data) {
  const xScale = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.value)])
    .range([0, 400]);
  return data.map((d, i) => ({
    x: 50,
    y: i * 30,
    width: xScale(d.value),
    height: 25
  }));
}
```

Use Pattern A for complex interactions. Use Pattern B for simpler charts or framework-preferred rendering.

## Standard structure

```javascript
function drawVisualization(data) {
  if (!data || data.length === 0) return;
  const svg = d3.select('#chart');
  svg.selectAll('*').remove();

  const width = 800;
  const height = 400;
  const margin = { top: 20, right: 30, bottom: 40, left: 50 };
  const innerWidth = width - margin.left - margin.right;
  const innerHeight = height - margin.top - margin.bottom;

  const g = svg.append('g')
    .attr('transform', `translate(${margin.left},${margin.top})`);

  const xScale = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.x)])
    .range([0, innerWidth]);

  const yScale = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.y)])
    .range([innerHeight, 0]);

  g.append('g')
    .attr('transform', `translate(0,${innerHeight})`)
    .call(d3.axisBottom(xScale));

  g.append('g')
    .call(d3.axisLeft(yScale));

  g.selectAll('circle')
    .data(data)
    .join('circle')
    .attr('cx', d => xScale(d.x))
    .attr('cy', d => yScale(d.y))
    .attr('r', 5)
    .attr('fill', 'steelblue');
}
```

## Responsive sizing

Use window resize:

```javascript
function setupResponsiveChart(containerId, data) {
  const container = document.getElementById(containerId);
  const svg = d3.select(`#${containerId}`).append('svg');

  function updateChart() {
    const { width, height } = container.getBoundingClientRect();
    svg.attr('width', width).attr('height', height);
    drawChart(data, svg, width, height);
  }

  updateChart();
  window.addEventListener('resize', updateChart);
  return () => window.removeEventListener('resize', updateChart);
}
```

Or ResizeObserver:

```javascript
function setupResponsiveChartWithObserver(svgElement, data) {
  const observer = new ResizeObserver(() => {
    const { width, height } = svgElement.getBoundingClientRect();
    d3.select(svgElement).attr('width', width).attr('height', height);
    drawChart(data, d3.select(svgElement), width, height);
  });
  observer.observe(svgElement.parentElement);
  return () => observer.disconnect();
}
```

Debounce resize handlers for performance.

## Common patterns

Bar chart:

```javascript
function drawBarChart(data, svgElement) {
  if (!data || data.length === 0) return;
  const svg = d3.select(svgElement);
  svg.selectAll('*').remove();

  const width = 800, height = 400;
  const margin = { top: 20, right: 30, bottom: 40, left: 50 };
  const innerWidth = width - margin.left - margin.right;
  const innerHeight = height - margin.top - margin.bottom;

  const g = svg.append('g')
    .attr('transform', `translate(${margin.left},${margin.top})`);

  const xScale = d3.scaleBand()
    .domain(data.map(d => d.category))
    .range([0, innerWidth])
    .padding(0.1);

  const yScale = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.value)])
    .range([innerHeight, 0]);

  g.append('g')
    .attr('transform', `translate(0,${innerHeight})`)
    .call(d3.axisBottom(xScale));

  g.append('g')
    .call(d3.axisLeft(yScale));

  g.selectAll('rect')
    .data(data)
    .join('rect')
    .attr('x', d => xScale(d.category))
    .attr('y', d => yScale(d.value))
    .attr('width', xScale.bandwidth())
    .attr('height', d => innerHeight - yScale(d.value))
    .attr('fill', 'steelblue');
}
```

Line chart:

```javascript
const line = d3.line()
  .x(d => xScale(d.date))
  .y(d => yScale(d.value))
  .curve(d3.curveMonotoneX);

g.append('path')
  .datum(data)
  .attr('fill', 'none')
  .attr('stroke', 'steelblue')
  .attr('stroke-width', 2)
  .attr('d', line);
```

Scatter plot:

```javascript
g.selectAll('circle')
  .data(data)
  .join('circle')
  .attr('cx', d => xScale(d.x))
  .attr('cy', d => yScale(d.y))
  .attr('r', d => sizeScale(d.size))
  .attr('fill', d => colourScale(d.category))
  .attr('opacity', 0.7);
```

Pie chart:

```javascript
const pie = d3.pie().value(d => d.value).sort(null);
const arc = d3.arc().innerRadius(0).outerRadius(Math.min(width, height) / 2 - 20);
const colourScale = d3.scaleOrdinal(d3.schemeCategory10);

const g = svg.append('g')
  .attr('transform', `translate(${width / 2},${height / 2})`);

g.selectAll('path')
  .data(pie(data))
  .join('path')
  .attr('d', arc)
  .attr('fill', (d, i) => colourScale(i))
  .attr('stroke', 'white')
  .attr('stroke-width', 2);
```

Heatmap:

```javascript
function drawHeatmap(data) {
  if (!data || data.length === 0) return;
  const svg = d3.select('#chart');
  svg.selectAll('*').remove();

  const width = 800, height = 600;
  const margin = { top: 100, right: 30, bottom: 30, left: 100 };
  const innerWidth = width - margin.left - margin.right;
  const innerHeight = height - margin.top - margin.bottom;

  const rows = Array.from(new Set(data.map(d => d.row)));
  const columns = Array.from(new Set(data.map(d => d.column)));

  const g = svg.append('g')
    .attr('transform', `translate(${margin.left},${margin.top})`);

  const xScale = d3.scaleBand().domain(columns).range([0, innerWidth]).padding(0.01);
  const yScale = d3.scaleBand().domain(rows).range([0, innerHeight]).padding(0.01);
  const colourScale = d3.scaleSequential(d3.interpolateYlOrRd)
    .domain([0, d3.max(data, d => d.value)]);

  g.selectAll('rect')
    .data(data)
    .join('rect')
    .attr('x', d => xScale(d.column))
    .attr('y', d => yScale(d.row))
    .attr('width', xScale.bandwidth())
    .attr('height', yScale.bandwidth())
    .attr('fill', d => colourScale(d.value));
}
```

Chord diagram:

```javascript
function drawChordDiagram(data) {
  if (!data || data.length === 0) return;
  const svg = d3.select('#chart');
  svg.selectAll('*').remove();

  const width = 600, height = 600;
  const innerRadius = Math.min(width, height) * 0.3;
  const outerRadius = innerRadius + 30;

  const nodes = Array.from(new Set(data.flatMap(d => [d.source, d.target])));
  const matrix = Array.from({ length: nodes.length }, () => Array(nodes.length).fill(0));

  data.forEach(d => {
    const i = nodes.indexOf(d.source);
    const j = nodes.indexOf(d.target);
    matrix[i][j] += d.value;
    matrix[j][i] += d.value;
  });

  const chord = d3.chord().padAngle(0.05).sortSubgroups(d3.descending);
  const arc = d3.arc().innerRadius(innerRadius).outerRadius(outerRadius);
  const ribbon = d3.ribbon().source(d => d.source).target(d => d.target);
  const colourScale = d3.scaleOrdinal(d3.schemeCategory10).domain(nodes);

  const g = svg.append('g')
    .attr('transform', `translate(${width / 2},${height / 2})`);

  const chords = chord(matrix);

  g.append('g')
    .attr('fill-opacity', 0.67)
    .selectAll('path')
    .data(chords)
    .join('path')
    .attr('d', ribbon)
    .attr('fill', d => colourScale(nodes[d.source.index]))
    .attr('stroke', d => d3.rgb(colourScale(nodes[d.source.index])).darker());

  const group = g.append('g')
    .selectAll('g')
    .data(chords.groups)
    .join('g');

  group.append('path')
    .attr('d', arc)
    .attr('fill', d => colourScale(nodes[d.index]))
    .attr('stroke', d => d3.rgb(colourScale(nodes[d.index])).darker());

  group.append('text')
    .each(d => { d.angle = (d.startAngle + d.endAngle) / 2; })
    .attr('dy', '0.31em')
    .attr('transform', d => `rotate(${(d.angle * 180 / Math.PI) - 90})translate(${outerRadius + 30})${d.angle > Math.PI ? 'rotate(180)' : ''}`)
    .attr('text-anchor', d => d.angle > Math.PI ? 'end' : null)
    .text((d, i) => nodes[i])
    .style('font-size', '12px');
}
```

Force-directed network:

```javascript
const simulation = d3.forceSimulation(nodes)
  .force('link', d3.forceLink(links).id(d => d.id).distance(100))
  .force('charge', d3.forceManyBody().strength(-300))
  .force('center', d3.forceCenter(width / 2, height / 2));

const link = g.selectAll('line')
  .data(links)
  .join('line')
  .attr('stroke', '#999')
  .attr('stroke-width', 1);

const node = g.selectAll('circle')
  .data(nodes)
  .join('circle')
  .attr('r', 8)
  .attr('fill', 'steelblue')
  .call(d3.drag()
    .on('start', dragstarted)
    .on('drag', dragged)
    .on('end', dragended));

simulation.on('tick', () => {
  link
    .attr('x1', d => d.source.x)
    .attr('y1', d => d.source.y)
    .attr('x2', d => d.target.x)
    .attr('y2', d => d.target.y);
  node
    .attr('cx', d => d.x)
    .attr('cy', d => d.y);
});

function dragstarted(event) {
  if (!event.active) simulation.alphaTarget(0.3).restart();
  event.subject.fx = event.subject.x;
  event.subject.fy = event.subject.y;
}

function dragged(event) {
  event.subject.fx = event.x;
  event.subject.fy = event.y;
}

function dragended(event) {
  if (!event.active) simulation.alphaTarget(0);
  event.subject.fx = null;
  event.subject.fy = null;
}
```

## Interactivity

Tooltips:

```javascript
const tooltip = d3.select('body').append('div')
  .attr('class', 'tooltip')
  .style('position', 'absolute')
  .style('visibility', 'hidden')
  .style('background-color', 'white')
  .style('border', '1px solid #ddd')
  .style('padding', '10px')
  .style('border-radius', '4px')
  .style('pointer-events', 'none');

circles
  .on('mouseover', function(event, d) {
    d3.select(this).attr('opacity', 1);
    tooltip.style('visibility', 'visible')
      .html(`<strong>${d.label}</strong><br/>Value: ${d.value}`);
  })
  .on('mousemove', function(event) {
    tooltip
      .style('top', (event.pageY - 10) + 'px')
      .style('left', (event.pageX + 10) + 'px');
  })
  .on('mouseout', function() {
    d3.select(this).attr('opacity', 0.7);
    tooltip.style('visibility', 'hidden');
  });
```

Zoom and pan:

```javascript
const zoom = d3.zoom()
  .scaleExtent([0.5, 10])
  .on('zoom', (event) => {
    g.attr('transform', event.transform);
  });

svg.call(zoom);
```

Click:

```javascript
circles
  .on('click', function(event, d) {
    console.log('Clicked:', d);
    d3.selectAll('circle').attr('fill', 'steelblue');
    d3.select(this).attr('fill', 'orange');
  });
```

## Transitions

```javascript
circles.transition().duration(750).attr('r', 10);

circles.transition().duration(500).attr('fill', 'orange')
  .transition().duration(500).attr('r', 15);

circles.transition()
  .delay((d, i) => i * 50)
  .duration(500)
  .attr('cy', d => yScale(d.value));

circles.transition()
  .duration(1000)
  .ease(d3.easeBounceOut)
  .attr('r', 10);
```

## Scales

Quantitative:

```javascript
const xScale = d3.scaleLinear().domain([0, 100]).range([0, 500]);
const logScale = d3.scaleLog().domain([1, 1000]).range([0, 500]);
const powScale = d3.scalePow().exponent(2).domain([0, 100]).range([0, 500]);
const timeScale = d3.scaleTime()
  .domain([new Date(2020, 0, 1), new Date(2024, 0, 1)])
  .range([0, 500]);
```

Ordinal:

```javascript
const bandScale = d3.scaleBand()
  .domain(['A', 'B', 'C', 'D'])
  .range([0, 400])
  .padding(0.1);

const pointScale = d3.scalePoint()
  .domain(['A', 'B', 'C', 'D'])
  .range([0, 400]);

const colourScale = d3.scaleOrdinal(d3.schemeCategory10);
```

Sequential and diverging:

```javascript
const colourScale = d3.scaleSequential(d3.interpolateBlues).domain([0, 100]);
const divScale = d3.scaleDiverging(d3.interpolateRdBu).domain([-10, 0, 10]);
```

## Best practices

Data preparation:

```javascript
const cleanData = data.filter(d => d.value != null && !isNaN(d.value));
const sortedData = [...data].sort((a, b) => b.value - a.value);
const parsedData = data.map(d => ({
  ...d,
  date: d3.timeParse('%Y-%m-%d')(d.date)
}));
```

Performance:
- Use canvas instead of SVG for many elements.
- Use quadtree for collision detection.
- Simplify paths with `d3.line().curve(d3.curveStep)`.
- Implement virtual scrolling for large lists.
- Use `requestAnimationFrame` for custom animations.
- Limit DOM elements; consider canvas for more than 1000 items.
- Debounce resize handlers.
- Use `.join()` instead of separate enter/update/exit selections.
- Avoid unnecessary re-renders.

Accessibility:
- Add ARIA labels: `svg.attr('role', 'img').attr('aria-label', '...')`.
- Add title and description elements.
- Ensure sufficient colour contrast.
- Provide keyboard navigation for interactive elements.
- Include a data table alternative.

Styling:
- Define colour palettes upfront.
- Apply consistent typography.
- Use subtle grid lines.

```javascript
const colours = {
  primary: '#4A90E2',
  secondary: '#7B68EE',
  background: '#F5F7FA',
  text: '#333333',
  gridLines: '#E0E0E0'
};

svg.selectAll('text')
  .style('font-family', 'Inter, sans-serif')
  .style('font-size', '12px');

g.selectAll('.tick line')
  .attr('stroke', colours.gridLines)
  .attr('stroke-dasharray', '2,2');
```

Data binding:
- Use a key function for stable updates: `.data(data, d => d.id)`.
- Validate scale domains for NaN values.

## Common issues

- Axes not appearing: check scale domains for NaN, axis group, transform translations.
- Transitions not working: call `.transition()` before attribute changes, use unique keys, include changing data in dependencies.
- Responsive sizing not working: use ResizeObserver or resize listener, update dimensions, ensure SVG has width/height or viewBox.
- Performance problems: limit DOM elements, debounce resize, use `.join()`, avoid unnecessary re-renders.

## Checklist

- Validate and clean data before rendering.
- Clear previous SVG content.
- Use margins and inner dimensions.
- Use scales and axes.
- Use `.join()` for data binding.
- Add responsive sizing.
- Add tooltips, zoom, or click handlers where needed.
- Add transitions with durations.
- Check accessibility labels and contrast.
- Test with empty and large datasets.

## Related skills

Load these when the task spans more than this skill.

- [`data-science`](../data-science/SKILL.md) — Data science guide for end-to-end tasks: exploratory analysis, statistical testing, feature engineering, model…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`javascript`](../javascript/SKILL.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`diagrams`](../diagrams/SKILL.md) — Skill for creating, editing, converting, and reviewing diagram files. Handles draw.io .drawio XML editing and…
- [`generative-art`](../generative-art/SKILL.md) — Create generative art through a two-phase process: first define an algorithmic/visual philosophy (.md), then e…
- [`remotion`](../remotion/SKILL.md) — Comprehensive guide for Remotion - programmatic video creation in React. Covers compositions, frame-based anim…
