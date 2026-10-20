---
name: figma
description: "Fetches design context, screenshots, and assets from a Figma MCP server and translates a Figma node URL or node ID into production-ready React, Next.js, or TypeScript components that follow project design-system conventions and achieve 1:1 visual parity. Use when converting Figma designs to code, implementing design-system tokens, extracting SVG icons or image assets, generating pixel-perfect UI components, validating against screenshots, handling responsive breakpoints, applying brand theming, or automating design-to-code workflows for frontend development."
---

# Figma MCP Design‑to‑Code Workflow

Translate a Figma frame, component, or variant into production code with pixel‑perfect visual fidelity. Use this workflow whenever a task includes a Figma URL, node ID, or a request to implement a design.

## When to use
- The user supplies a Figma link or node ID.
- You need to generate React (or other framework) code that matches the design.
- A Figma MCP server is reachable and configured.
- The project has an existing design system or component library.

---

## Prerequisites
- Figma MCP server reachable (e.g., `https://mcp.figma.com/mcp`).
- `codex` CLI installed.
- Project design‑system tokens and components are defined.

## Setup (run once per environment)
```bash
codex mcp add figma --url https://mcp.figma.com/mcp
# Enable remote MCP client if required
codex --enable rmcp_client   # or set [features].rmcp_client = true in config.toml
codex mcp login figma        # OAuth login, then restart codex
```
If any MCP call fails, pause, run the steps above, then continue with the workflow.

---

## Workflow
### 1. Identify the node
- **From a Figma URL**: extract `fileKey` (segment after `/design/`) and `node-id` query value.
  - Example URL: `https://figma.com/design/kL9xQn2VwM8pYrTb4ZcHjF/DesignSystem?node-id=42-15`
  - `fileKey = kL9xQn2VwM8pYrTb4ZcHjF`
  - `nodeId = 42-15`
- **From Figma Desktop (figma‑desktop MCP)**: the server uses the currently open file, so only `nodeId` is needed.

### 2. Fetch design context
```bash
get_design_context(fileKey="<fileKey>", nodeId="<nodeId>")
```
The response includes layout, typography, colors, component hierarchy, and spacing.

**If the response is truncated**:
```bash
get_metadata(fileKey="<fileKey>", nodeId="<nodeId>")
# Identify needed child nodes
get_design_context(fileKey="<fileKey>", nodeId="<childNodeId>")
```
### 3. Capture a screenshot
```bash
get_screenshot(fileKey="<fileKey>", nodeId="<nodeId>")
```
Keep the image for visual validation.

### 4. Download assets
- Use the MCP assets endpoint to retrieve images, SVGs, or icons.
- **Important rules**:
  - If the asset URL is a `localhost` address, use it directly.
  - Do **not** add external icon packages.
  - Do **not** create placeholder assets when a real source exists.

### 5. Translate to project conventions
1. Treat the MCP output (usually React + Tailwind) as a design blueprint, not final code.
2. Replace Tailwind utilities with the project’s design‑system tokens (color, spacing, typography).
3. Reuse existing components (buttons, inputs, icons, layout primitives) instead of creating new ones.
4. Follow the project’s routing, state‑management, and data‑fetch patterns.
5. Keep component files in the designated design‑system directory and follow naming conventions.

### 6. Achieve 1:1 visual parity
- Use design tokens from the context data wherever possible.
- Prefer project tokens for consistency; adjust spacing or size minimally to match the screenshot.
- Ensure WCAG accessibility (contrast, focus states).
- Avoid hard‑coded values; extract them to constants or token references.

### 7. Validate against the screenshot
| Check | What to verify |
|-------|----------------|
| Layout | Spacing, alignment, sizing matches |
| Typography | Font family, size, weight, line‑height |
| Colors | Exact color values |
| States | Hover, active, disabled visuals |
| Responsiveness | Breakpoints and constraints follow design |
| Assets | Images and SVGs render correctly |
| Accessibility | Contrast and ARIA attributes |

If any discrepancy appears, iterate: adjust code, re‑run the relevant step, and compare again.

---

## Implementation Rules
- **Output handling**: Treat MCP output as a reference, not as final styling.
- **Design‑system alignment**: Always map Figma tokens to project tokens before coding.
- **Component reuse**: Extend existing components; create new ones only when no suitable component exists.
- **Asset policy**: Use only assets delivered by the MCP server. Do not import external icon libraries.
- **Code quality**: Add TypeScript types, JSDoc comments, and avoid inline styles unless dynamic.
- **Documentation**: Document any new component or deviation from the Figma design in code comments.

---

## Checklist
- [ ] Figma MCP server configured and logged in.
- [ ] Node ID and file key extracted correctly.
- [ ] `get_design_context` executed and data reviewed.
- [ ] Screenshot captured and saved.
- [ ] All required assets downloaded and referenced.
- [ ] Tailwind classes replaced with project tokens.
- [ ] Existing design‑system components reused where possible.
- [ ] Visual parity validated against screenshot.
- [ ] Accessibility checks passed.
- [ ] Code passes project linting and type‑checking.
- [ ] New components documented; deviations noted.

---

## Common Issues
- **Truncated design data** – Run `get_metadata` first, then fetch needed child nodes individually.
- **Asset URLs not loading** – Verify the MCP assets endpoint is reachable; use the `localhost` URL directly.
- **Design token mismatch** – Prefer project tokens; adjust spacing minimally to keep visual fidelity.
- **Visual differences after implementation** – Compare side‑by‑side with the screenshot, check token values, and re‑align layout constraints.

---

## References
- Figma MCP Server Documentation: https://developers.figma.com/docs/figma-mcp-server/
- Design Tokens & Variables: https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma

## Related skills

Load these when the task spans more than this skill.

- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`screenshot`](../screenshot/SKILL.md) — Capture a desktop screenshot (full screen, window, region, or app) on macOS, Linux, or Windows. Use when the u…
- [`image-generation`](../image-generation/SKILL.md) — Generate or edit images using OpenAI (gpt-image-1.5) or OpenRouter (FLUX.2 Pro, Gemini 3 Pro) APIs. Use for ph…
- [`ux-research`](../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
- [`qa-test-planning`](../qa-test-planning/SKILL.md) — The qa-test-planning skill helps QA engineers design test plans, write manual test cases, build regression sui…
