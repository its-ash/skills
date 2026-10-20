---
name: motion-canvas
description: "Configure Motion Canvas projects with Vite, write TypeScript animation scenes using generator functions, signals, and refs, resolve ESM and CommonJS plugin import errors, and export rendered video or image sequences for motion graphics and generative art. Use when setting up motion-canvas, debugging vite plugin imports, authoring animation timelines with yield signals, creating programmatic motion graphics, exporting mp4 webm gif frames, fixing module resolution errors, or building generative art visualizations with typescript animation code."
---

# Motion Canvas

Motion Canvas creates programmatic videos with TypeScript. Animations use generator functions, reactive signals, and a Vite-powered preview editor.

## When to use

- Set up a Motion Canvas project from scratch.
- Write animation scenes in TypeScript.
- Fix Motion Canvas setup, import, or build errors.
- Animate shapes, text, and custom components.
- Synchronize animations with audio or voice-over.

## Setup

1. Create and enter the project directory.

```bash
mkdir my-motion-canvas-project
cd my-motion-canvas-project
npm init -y
```

2. Add `"type": "module"` to `package.json`.

3. Add `dev`, `build`, and `preview` scripts.

4. Install dependencies.

```bash
npm install --save-dev @motion-canvas/core @motion-canvas/2d @motion-canvas/vite-plugin @motion-canvas/ui vite typescript
```

5. Create `vite.config.js`. Do not use `vite.config.ts`.

```javascript
import {defineConfig} from 'vite';
import {createRequire} from 'module';

const require = createRequire(import.meta.url);
const motionCanvasModule = require('@motion-canvas/vite-plugin');
const motionCanvas = motionCanvasModule.default || motionCanvasModule;

export default defineConfig({
  plugins: [
    motionCanvas({
      project: './src/project.ts',
    }),
  ],
});
```

6. Create `tsconfig.json`.

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ES2020",
    "lib": ["ES2020", "DOM"],
    "jsx": "react-jsx",
    "jsxImportSource": "@motion-canvas/2d/lib",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

7. Create `index.html`.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Motion Canvas Project</title>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/project.ts"></script>
</body>
</html>
```

8. Create `src/project.ts`.

```typescript
import {makeProject} from '@motion-canvas/core';
import example from './scenes/example?scene';

export default makeProject({
  scenes: [example],
});
```

9. Create `src/scenes/example.tsx`.

```tsx
import {makeScene2D} from '@motion-canvas/2d/lib/scenes';
import {Circle} from '@motion-canvas/2d/lib/components';
import {createRef} from '@motion-canvas/core/lib/utils';
import {all} from '@motion-canvas/core/lib/flow';

export default makeScene2D(function* (view) {
  const circleRef = createRef<Circle>();

  view.add(
    <Circle
      ref={circleRef}
      size={70}
      fill="#e13238"
    />,
  );

  yield* circleRef().size(140, 1);
  yield* circleRef().position.x(300, 1);
  yield* circleRef().fill('#e6a700', 1);

  yield* all(
    circleRef().scale(1.5, 0.5),
    circleRef().rotation(360, 1),
  );
});
```

10. Run the development server.

```bash
npm run dev
```

Open `http://localhost:5173`.

## Core concepts

- Generator functions describe the animation timeline. Use `function*` and `yield*`.
- Signals store reactive values that update dependent properties.
- Refs provide direct control over nodes after they are added to the view.
- `all` runs animations in parallel.
- Property animations take the target value first and duration in seconds second.

## Animation patterns

Animate one property at a time:

```tsx
yield* circleRef().size(140, 1);
```

Run animations together:

```tsx
yield* all(
  circleRef().scale(1.5, 0.5),
  circleRef().rotation(360, 1),
);
```

Add a node and animate it:

```tsx
const circleRef = createRef<Circle>();

view.add(<Circle ref={circleRef} size={70} fill="#e13238" />);
yield* circleRef().size(140, 1);
```

## Troubleshooting

- `TypeError: motionCanvas is not a function`: use the `createRequire` workaround. Do not use a standard ESM import for `@motion-canvas/vite-plugin`.
- `Cannot find module '@motion-canvas/ui'`: install `@motion-canvas/ui`.
- `Property 'default' does not exist`: enable `esModuleInterop` and `allowSyntheticDefaultImports` in `tsconfig.json`.
- CJS Vite warning: this warning is known and can be ignored.
- `Failed to resolve import "*.tsx?scene"`: verify the plugin configuration and the `?scene` suffix.
- TypeScript build errors: verify `tsconfig.json`, `jsxImportSource`, and installed dependencies.

## Best practices

- Use `vite.config.js`, not `vite.config.ts`.
- Keep `"type": "module"` in `package.json`.
- Install `@motion-canvas/core`, `@motion-canvas/2d`, `@motion-canvas/vite-plugin`, and `@motion-canvas/ui`.
- Use generator functions for scene logic.
- Use refs for node control.
- Specify durations in seconds.
- Split complex animations into multiple scenes.
- Use TypeScript strict mode.

## Common pitfalls

- Missing `"type": "module"`.
- Standard import for `@motion-canvas/vite-plugin`.
- Missing `@motion-canvas/ui`.
- Missing `esModuleInterop`.
- Using `vite.config.ts`.
- Missing `?scene` in scene imports.

## Checklist

- [ ] `package.json` has `"type": "module"`.
- [ ] All dependencies are installed.
- [ ] `vite.config.js` uses `createRequire`.
- [ ] `tsconfig.json` has `esModuleInterop` and `jsxImportSource`.
- [ ] `index.html` loads `/src/project.ts`.
- [ ] Scene imports use `?scene`.
- [ ] `npm run dev` opens the editor.

## Resources

- Documentation: https://motioncanvas.io/docs
- Repository: https://github.com/motion-canvas/motion-canvas

## Related skills

Load these when the task spans more than this skill.

- [`generative-art`](../generative-art/SKILL.md) — Create generative art through a two-phase process: first define an algorithmic/visual philosophy (.md), then e…
- [`remotion`](../remotion/SKILL.md) — Comprehensive guide for Remotion - programmatic video creation in React. Covers compositions, frame-based anim…
- [`manim`](../manim/SKILL.md) — Provides concise guidance for creating mathematical animations with the Manim Community Python library, coveri…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`d3-visualization`](../d3-visualization/SKILL.md) — Create custom interactive D3.js visualizations, including charts, graphs, networks, maps, transitions, and SVG…
- [`slack-gif-creator`](../slack-gif-creator/SKILL.md) — Create animated GIFs optimized for Slack emoji (128x128) and message (480x480) formats. Provides Slack constra…
- [`design`](../design/SKILL.md) — Unified frontend design skill covering the full lifecycle from brief inference to production. Combines anti-sl…
