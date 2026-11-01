# UI To Vue

Batch-convert UI design screenshots into Vue 3 Composition API components with the `ui-to-vue-converter` npm CLI.

## When to use

- The user supplies a directory of design screenshots or design-export images.
- The target application is Vue 3.
- The user wants a first pass of page components, shared components, and router wiring.
- The user names Vant, Element Plus, or Ant Design Vue as the component library.

## When not to use

- The user has only one screenshot and wants a custom component. Write it by hand with [vue.md](vue.md).
- The target project is not Vue.
- The design needs detailed interaction logic, data flow, or an accessibility review.
- The screenshots contain private customer data that you must not send to an external model API.

## Inputs

Group screenshots by module and page state:

```text
screenshots/
|-- HomePage/
|   |-- List/
|   |   |-- HomePage-List-Default@3x.png
|   |   `-- cut-images/
|   |-- cut-images/
|   `-- HomePage-Default@3x.png
`-- cut-images/
```

Supported cut-image directory names: `assets`, `icons`, `sprites`, `cut`, `images`, `cut-images`.

## Conversion model

- Page grouping: related screenshots (list, detail, form, loading, empty states) become one page component.
- UI library mapping: native visual elements map to Vant, Element Plus, or Ant Design Vue components where practical.
- Cut-image priority: page-level assets first, then module-level assets, then global shared assets.
- Component extraction: repeated UI regions become shared components when they occur more than once.

## CLI usage

Use `npx` with a pinned version:

```bash
export DASHSCOPE_API_KEY=your_key
npx ui-to-vue-converter@1.0.2 --input ./screenshots --ui vant --output ./src
npx ui-to-vue-converter@1.0.2 --input ./designs --ui element-plus --output ./src
npx ui-to-vue-converter@1.0.2 --input ./designs --ui antd-vue --output ./src
```

| Option | Description | Default |
| --- | --- | --- |
| `--input` | Design image directory | `./screenshots` |
| `--ui` | UI library: `vant`, `element-plus`, or `antd-vue` | `vant` |
| `--output` | Output directory | `./src` |
| `--config` | Config file path | `./.ui-to-vue.config.json` |

## API key handling

The CLI reads DashScope credentials from the environment or from a config file. Use the environment variable in repositories. If you must use a config file, keep it out of version control:

```json
{
  "apiKey": "your_dashscope_key",
  "input": "./designs",
  "ui": "vant",
  "output": "./src"
}
```

```gitignore
.ui-to-vue.config.json
```

## Security and privacy

- The CLI can send screenshots to an external model API. Get permission before you use private customer designs.
- Pin the converter version in repeatable workflows. Do not use `@latest`.
- Do not commit `.ui-to-vue.config.json`, API keys, generated secrets, or customer screenshots.
- Review the generated Vue code before you commit it.

## Output review checklist

- [ ] Page components are under `views/` or the selected output directory.
- [ ] Repeated UI regions are in `components/` only when reuse is clear.
- [ ] Router output agrees with the router style of the target project.
- [ ] Generated components use the requested UI library consistently.
- [ ] Generated CSS units agree with the design baseline.
- [ ] The code passes the project formatter, linter, type checker, and build.
- [ ] Placeholder copy, mock data, and generated assets are reviewed before commit.

## Troubleshooting

| Issue | Check |
| --- | --- |
| `401` or authentication error | Make sure `DASHSCOPE_API_KEY` is set in the shell that runs the command. |
| `command not found: ui-to-vue` | Use the `npx ui-to-vue-converter@1.0.2` form. |
| Cut images are ignored | Make sure the asset directory name is supported and is under the matching page or module. |
| Components ignore the requested UI library | Run again with an explicit `--ui` value and examine the generated imports. |
| Layout dimensions are incorrect | Make sure the screenshot export width agrees with the target library baseline. |

## Related skills

- [`vue`](vue.md) — Vue 3 patterns to refine the generated code.
- [`figma`](../../design/references/figma.md) — design handoff from Figma.
