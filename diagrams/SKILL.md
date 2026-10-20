---
name: diagrams
description: "Edits draw.io .drawio XML files, exports PNGs, renders JSON-spec SVGs via diagrammer, and delegates Excalidraw JSON operations to sub-agents for architecture, flow, sequence, network, and infrastructure diagrams. Use when users request drawio XML editing, PNG conversion, SVG rendering, Excalidraw delegation, diagram layout adjustment, coordinate positioning, font configuration for Quarto slides, technical schematics, system blueprints, flowchart creation, diagram review, conversion, or visualization tasks."
---

# Diagrams Skill

Create, edit, convert, and verify technical diagrams. Supports three common formats:
- **draw.io** (`.drawio` XML files) – edit source and generate PNG.
- **Excalidraw** (`.excalidraw` / `.excalidraw.json`) – never read directly; delegate to a sub‑agent.
- **diagrammer** – render a clean SVG from a small JSON spec.

---

## When to Use
- User provides or requests a `.drawio` file, needs layout tweaks, font changes, or PNG export.
- User mentions *Excalidraw*, *flowchart*, *architecture diagram*, or supplies a `.excalidraw` JSON file.
- User asks for a quick SVG diagram of a request flow, system architecture, state machine, or data pipeline.

---

## draw.io Workflow & Rules
### Editing Rules
- Edit only the `.drawio` XML file. Do **not** edit the generated `.drawio.png`.
- Keep the PNG generation to the pre‑commit hook or manual conversion command.

### Font Settings (Quarto Slides)
```xml
<mxGraphModel defaultFontFamily="Noto Sans JP" ...>
```
Add `fontFamily` to each text element:
```xml
style="text;html=1;fontSize=27;fontFamily=Noto Sans JP;"
```

### PNG Conversion Command
```sh
# Convert a single file
drawio -x -f png -s 2 -t -o output.drawio.png input.drawio
```
Options:
- `-x` – export mode
- `-f png` – PNG output
- `-s 2` – 2× scale for high resolution
- `-t` – transparent background
- `-o` – output path

### Layout Adjustment (XML Editing)
1. Open the `.drawio` file in a text editor.
2. Locate the `<mxCell>` with the desired `value` (text label).
3. Edit the `<mxGeometry>` attributes:
   - `x` – left offset
   - `y` – top offset
   - `width`, `height` – size
4. Re‑run the conversion command and verify the PNG.

#### Coordinate Tips
- Element centre = `y + (height / 2)`.
- Align multiple elements by matching centre coordinates.

### Design Principles
- **Clarity** – keep diagrams simple and readable.
- **Consistency** – use the same fonts, colors, line thickness, and official icons.
- **Accuracy** – do not omit essential components.
- **Accessibility** – ensure sufficient colour contrast; add patterns for colour‑blind users.
- **Progressive Disclosure** – use layered diagrams (Context → System → Component → Deployment → Data Flow → Sequence).
- **Metadata** – embed title, description, author, version, and last‑updated date.

### Best‑Practice Details
- Remove any `background="#ffffff"`. Use transparent background for theme flexibility.
- Font size: ~18 px (1.5× standard) for PDF readability.
- Japanese text: allocate 30‑40 px per character to avoid line breaks.
- Arrow placement: keep arrows in a back layer (place their `<mxCell>` after the title element). Keep at least **20 px** distance from label edges.
- Arrow connection: use explicit `sourcePoint` / `targetPoint` coordinates; `exitX/exitY` do not work for text elements.
- Edge label offset: adjust `<mxPoint x="0" y="-40" as="offset"/>` (negative = above arrow, positive = below).
- Background frames: maintain **≥30 px** margin between frame border and internal elements. Verify PNG for overflow.

### Checklist (draw.io)
- [ ] No background colour set; PNG is transparent.
- [ ] Font family and size follow guidelines.
- [ ] Arrows are in the back layer and do not overlap labels.
- [ ] Arrow start/end are ≥20 px from label edges.
- [ ] No arrows penetrate boxes or icons.
- [ ] Internal elements respect 30 px margin inside frames.
- [ ] AWS service names use official abbreviations; icons are latest (`mxgraph.aws4.*`).
- [ ] Unnecessary decorative icons removed.
- [ ] PNG visually verified after conversion.

---

## Excalidraw Delegation Rules
### Core Principle
**Never read Excalidraw JSON directly in the main agent.** Always delegate all operations to a sub‑agent to protect the main context budget.

### Why Delegation?
- A single file can contain 4 k–22 k tokens (≈10 % of a typical 200 k token budget).
- Most tokens are visual metadata; only text labels matter.
- Loading multiple diagrams quickly exhausts the budget.
- Delegation isolates the heavy JSON processing to a sub‑agent, returning only concise summaries.

### When to Delegate
Trigger on any of the following:
- File path ends with `.excalidraw` or `.excalidraw.json`.
- User asks to *explain*, *update*, *create*, or *compare* a diagram.
- User mentions *flowchart*, *architecture diagram*, or *visualize*.

### Delegation Pattern
**Main Agent**
- ❌ Do not use the Read tool on Excalidraw files.
- ✅ Dispatch a Task to a sub‑agent with a clear template.
- ✅ Accept only a text‑only summary or confirmation.

**Sub‑agent Templates**
#### 1. Understand Diagram
```
Task: Extract and explain the components in [file.excalidraw.json]
Approach:
1. Read the JSON.
2. Pull only text elements.
3. Identify relationships.
4. Summarize architecture.
Return:
- Component list with brief description.
- Connection relationships.
- Key insights.
```
#### 2. Modify Diagram
```
Task: Add [Component] to [file.excalidraw.json] and connect to [ExistingComponent]
Approach:
1. Locate ExistingComponent.
2. Create new element JSON.
3. Add arrow elements.
4. Write updated file.
Return:
- Confirmation.
- New element position.
- IDs of created elements.
```
#### 3. Create Diagram
```
Task: Create a new Excalidraw diagram showing [description]
Approach:
1. Design layout for N components.
2. Create rectangle elements with labels.
3. Add arrows for relationships.
4. Apply consistent styling.
5. Write to [file.excalidraw.json]
Return:
- Confirmation and file location.
- Summary of components.
```
#### 4. Compare Diagrams
```
Task: Compare architecture in [fileA] vs [fileB]
Approach:
1. Read both files.
2. Extract text labels.
3. Identify structural differences.
4. Compare component relationships.
Return:
- Key differences.
- Unique components per file.
- Relationship changes.
```

### Quick Reference Table
| Operation | Main Agent Action | Sub‑agent Return |
|-----------|-------------------|-----------------|
| Understand | Dispatch "Extract and explain" template | Component list + relationships |
| Modify | Dispatch "Add component" template | Confirmation + IDs |
| Create | Dispatch "Create diagram" template | File path + summary |
| Compare | Dispatch "Compare diagrams" template | Difference summary |

---

## diagrammer SVG Rendering
### Installation
```bash
pipx install diagrammer
```
*(If `pipx` is unavailable, use `pip install diagrammer` in a virtual environment.)*

### Workflow
1. Translate the user’s natural‑language request into a JSON spec.
2. Save the spec to a file, e.g., `spec.json`.
3. Render the SVG:
```bash
diagrammer spec.json > diagram.svg
```
4. Return the SVG path or embed it in documentation.

### Spec Essentials
```json
{
  "nodes": [
    {"id": "client", "type": "box", "label": "client"},
    {"id": "api",    "type": "box", "label": "api"},
    {"id": "db",     "type": "database", "label": "postgres"}
  ],
  "edges": [
    {"from": "client", "to": "api", "label": "request"},
    {"from": "api",    "to": "db",  "label": "query"}
  ]
}
```
**Node types**: `box`, `circle`, `text`, `database`, `stack`, `group`, `note`, `custom`.
**Optional fields**:
- `direction`: `"LR"` (left‑to‑right) or `"TB"` (top‑to‑bottom).
- `router`: `"straight"` or `"ortho"`.
- `style`: `"solid"` or `"dashed"`.
- `weight`: `"thin"` or `"thick"`.
Run `diagrammer prompt` for the full reference.

### When to Choose diagrammer
- You need a **checked‑in SVG** for README, docs, slides, or posts.
- The diagram is a simple node‑and‑edge layout (architecture sketch, request flow, state machine, data pipeline, neural‑net block).
- The user does **not** request Mermaid syntax or an editable Excalidraw canvas.

---

## Pitfalls & Mitigations
- **draw.io**: Editing the PNG directly breaks the source‑of‑truth workflow. Always edit the XML and regenerate PNG.
- **Excalidraw**: Loading the JSON in the main context wastes tokens and pollutes the conversation. Use the delegation templates.
- **diagrammer**: Supplying a malformed JSON spec causes the renderer to fail. Validate JSON syntax before invoking the command.

---

## Consolidated Checklist
- **draw.io**
  - Edit only `.drawio` XML.
  - Verify transparent background.
  - Apply font family and size rules.
  - Keep arrows in back layer, ≥20 px from labels.
  - Maintain ≥30 px margin inside frames.
  - Run `drawio -x -f png -s 2 -t -o …` and check PNG.
- **Excalidraw**
  - Never read JSON directly.
  - Use sub‑agent with appropriate template.
  - Accept only concise text summaries.
- **diagrammer**
  - Install via `pipx`.
  - Convert user request to valid JSON spec.
  - Render with `diagrammer spec.json > diagram.svg`.
  - Verify SVG renders correctly before returning.

## Related skills

Load these when the task spans more than this skill.

- [`mermaid-diagrams`](../mermaid-diagrams/SKILL.md) — Generates Mermaid diagram code for flowcharts, sequence diagrams, class diagrams, ERDs, C4 architecture, state…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`cloud-architecture`](../cloud-architecture/SKILL.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`manim`](../manim/SKILL.md) — Provides concise guidance for creating mathematical animations with the Manim Community Python library, coveri…
- [`d3-visualization`](../d3-visualization/SKILL.md) — Create custom interactive D3.js visualizations, including charts, graphs, networks, maps, transitions, and SVG…
