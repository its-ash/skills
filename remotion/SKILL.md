---
name: remotion
description: "Remotion enables programmatic video creation in React and TypeScript using compositions, frame-based animations, and a rendering pipeline that outputs MP4, WebM, or image sequences via FFmpeg. Use when building video generation pipelines, automating video rendering, creating motion graphics, generating social media clips, or writing TypeScript code that calls renderMedia, renderFrames, or renderStill with composition components, sequence hooks, and media assets like mp4, webm, png, jpg, wav, mp3, or ttf files."
---

# Remotion - Programmatic Video Creation in React

Remotion enables creating videos programmatically using React components with frame-accurate animations, media composition, and server-side rendering. Use this skill when building video generation systems, animated explanations, data-driven videos, or any content requiring precise timeline control.

## When to use

- Creating video compositions with React components and TypeScript
- Frame-based animations driven by `useCurrentFrame()`
- Importing, trimming, and manipulating video, audio, images, and fonts
- Building data visualizations and charts that animate over time
- Generating captions from audio or SRT files
- Integrating 3D content via Three.js / React Three Fiber
- Applying scene transitions and sequencing multiple clips
- Rendering videos programmatically via CLI or Node API

## Core Concepts

### Compositions
Define a composition with duration, dimensions, FPS, and default props:

```tsx
import { Composition } from "remotion";
import { MyVideo } from "./MyVideo";

export const RemotionRoot = () => (
  <Composition
    id="my-video"
    component={MyVideo}
    durationInFrames={180}
    fps={30}
    width={1920}
    height={1080}
    defaultProps={{ title: "Hello" }}
  />
);
```

### Frame-Based Animation
All animations derive from the current frame. Use `useCurrentFrame()` and `useVideoConfig()`:

```tsx
import { useCurrentFrame, useVideoConfig, interpolate } from "remotion";

const { fps, durationInFrames } = useVideoConfig();
const frame = useCurrentFrame();

// Map frame to 0-1 over 2 seconds
const progress = interpolate(frame, [0, 2 * fps], [0, 1], {
  extrapolateRight: "clamp",
});
```

**Key rule**: Never use CSS animations or `requestAnimationFrame`. Drive everything from `frame`.

### Interpolation & Easing
`interpolate(input, inputRange, outputRange, options)` supports:
- `extrapolateLeft` / `extrapolateRight`: `"clamp"` | `"extend"` | `"identity"`
- `easing`: `linear`, `easeIn`, `easeOut`, `easeInOut`, `spring`

```tsx
// Spring animation
const scale = interpolate(frame, [0, 30], [0, 1], {
  easing: spring({ stiffness: 200, damping: 20 }),
});
```

## Media Handling

### Images
Use `<Img src={...} />` for proper preloading and sizing:

```tsx
import { Img } from "remotion";
import image from "./image.png";

<Img src={image} style={{ width: 500, height: 300 }} />
```

### Video
`<Video />` component with frame-accurate control:

```tsx
import { Video } from "remotion";
import clip from "./clip.mp4";

<Video
  src={clip}
  playing={true}
  volume={0.8}
  playbackRate={1.2}
  startFrom={30}        // trim start (frames)
  endAt={180}           // trim end (frames)
  loop={false}
  muted={false}
  onLoad={handleLoad}
/>
```

**Properties**: `src`, `playing`, `volume` (0-1), `playbackRate`, `startFrom`, `endAt`, `loop`, `muted`, `onLoad`, `onError`.

### Audio
`<Audio />` component:

```tsx
import { Audio } from "remotion";
import track from "./music.mp3";

<Audio
  src={track}
  startFrom={0}
  endAt={durationInFrames}
  volume={0.5}
  playbackRate={1}
/>
```

### Fonts
Register fonts before use:

```tsx
import { registerFont } from "remotion";

registerFont({
  family: "Inter",
  src: url("./Inter-Regular.ttf"),
  weight: 400,
});
registerFont({
  family: "Inter",
  src: url("./Inter-Bold.ttf"),
  weight: 700,
});
```

Google Fonts: use `@remotion/google-fonts` package.

## Sequencing & Trimming

### Delay, Trim, Limit Duration
Wrap components to control their active window:

```tsx
import { delayRender, continueRender } from "remotion";

// Delay start by 60 frames
<Delay startDelay={60}><Child /></Delay>

// Trim first 30 frames of child
<Trim startTrim={30}><Child /></Trim>

// Limit child to 120 frames max
<LimitDuration maxDuration={120}><Child /></LimitDuration>
```

### Sequence Multiple Clips
Use `Series` or manual frame math:

```tsx
const clip1End = 90;
const clip2End = clip1End + 60;

{frame < clip1End && <Clip1 />}
{frame >= clip1End && frame < clip2End && <Clip2 />}
```

## Text & Captions

### Text Animations
Animate per-character or per-word:

```tsx
import { useCurrentFrame, interpolate } from "remotion";

const words = text.split(" ");
return (
  <div>
    {words.map((word, i) => (
      <span
        key={i}
        style={{ opacity: interpolate(frame, [i * 10, i * 10 + 20], [0, 1]) }}
      >
        {word} 
      </span>
    ))}
  </div>
);
```

### Measuring Text
Use `measureText()` for layout:

```tsx
import { measureText } from "remotion";

const { width, height } = measureText({
  text: "Hello",
  fontSize: 48,
  fontFamily: "Inter",
  fontWeight: 700,
});
```

### Captions
Display SRT or transcribed captions with word highlighting:

```tsx
import { Caption } from "@remotion/captions";
import { parseSrt } from "@remotion/captions";

const captions = parseSrt(await fetch("captions.srt").then(r => r.text()));

<Caption
  captions={captions}
  frame={frame}
  fps={fps}
  style={{ fontSize: 60, color: "white", textShadow: "2px 2px 4px black" }}
  wordStyle={{ color: "yellow" }}
/>
```

Transcribe audio with `@remotion/transcribe` (requires API key).

## Data Visualization

Animate chart properties frame-by-frame:

```tsx
import { interpolate } from "remotion";

const barHeight = interpolate(frame, [0, 60], [0, dataValue]);

return (
  <svg width={800} height={400}>
    <rect x={50} y={400 - barHeight} width={40} height={barHeight} fill="blue" />
  </svg>
);
```

Use Recharts, Victory, or custom SVG with Remotion interpolation.

## 3D with Three.js

```tsx
import { Canvas } from "@react-three/fiber";
import { useCurrentFrame } from "remotion";

const My3D = () => {
  const frame = useCurrentFrame();
  const rotation = frame / 30; // 1 rev per second at 30fps
  
  return (
    <Canvas camera={{ position: [0, 0, 5] }}>
      <mesh rotation={[0, rotation, 0]}>
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="orange" />
      </mesh>
    </Canvas>
  );
};
```

Enable `experimental: { three: true }` in `remotion.config.ts`.

## Transitions

Crossfade between scenes:

```tsx
const opacityA = interpolate(frame, [0, 30], [1, 0], { extrapolateRight: "clamp" });
const opacityB = interpolate(frame, [0, 30], [0, 1], { extrapolateLeft: "clamp" });

<div style={{ position: "absolute", inset: 0 }}>
  <SceneA style={{ opacity: opacityA }} />
  <SceneB style={{ opacity: opacityB }} />
</div>
```

## Dynamic Metadata

Calculate duration, dimensions, or props at render time:

```tsx
import { calculateMetadata } from "remotion";

export const metadata = calculateMetadata(async () => {
  const duration = await getAudioDuration("audio.mp3");
  return {
    durationInFrames: Math.ceil(duration * 30),
    props: { audioDuration: duration },
  };
});
```

## Mediabunny Utilities (Media Analysis)

```tsx
import {
  getVideoDuration,
  getVideoDimensions,
  getAudioDuration,
  extractFrames,
  canDecode,
} from "@remotion/mediabunny";

const duration = await getVideoDuration("video.mp4"); // seconds
const { width, height } = await getVideoDimensions("video.mp4");
const frames = await extractFrames("video.mp4", { timestamps: [1, 2, 3] });
const decodable = await canDecode("video.mp4");
```

## Tailwind CSS

Configure `remotion.config.ts`:

```ts
import { defineConfig } from "remotion";
import tailwindcss from "tailwindcss";

export default defineConfig({
  webpack: (config) => {
    config.plugins.push(tailwindcss());
    return config;
  },
});
```

Use Tailwind classes directly in JSX.

## Lottie Animations

```tsx
import { Lottie } from "@remotion/lottie";
import animation from "./animation.json";

<Lottie
  animationData={animation}
  frame={frame}
  fps={fps}
  loop={true}
/>
```

## GIFs
Synchronize GIF playback with timeline:

```tsx
import { Gif } from "@remotion/gif";

<Gif src="animation.gif" frame={frame} fps={fps} />
```

## Rendering

### CLI
```bash
npx remotion render src/index.ts my-video output.mp4
npx remotion render --concurrency=4 src/index.ts my-video output.mp4
```

### Node API
```ts
import { renderMedia, selectComposition } from "@remotion/renderer";

const composition = await selectComposition({
  serveUrl: "http://localhost:3000",
  id: "my-video",
  inputProps: { title: "Custom" },
});

await renderMedia({
  composition,
  serveUrl: "http://localhost:3000",
  codec: "h264",
  outputLocation: "output.mp4",
  inputProps: { title: "Custom" },
  onProgress: ({ overallProgress }) => console.log(overallProgress),
});
```

### Still Images
```bash
npx remotion still src/index.ts my-frame frame.png --frame=60
```

## Best Practices

- **Always use `useCurrentFrame()`** for animation timing
- **Avoid CSS animations/transitions** — they don't render in video output
- **Think in frames**: `seconds * fps = frames`
- **Clamp extrapolation** on interpolations to prevent overshoot
- **Preload assets** with `staticFile()` or import statements
- **Test in Remotion Studio** (`npx remotion studio`) before rendering
- **Use TypeScript** for prop validation and autocomplete
- **Keep compositions pure** — no side effects, same frame = same output
- **Limit concurrency** on CI/low-memory machines (`--concurrency=2`)
- **Check codec support**: H.264 for MP4, VP9/WebM for transparency

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| CSS animations don't render | Use `interpolate` + inline styles |
| Audio out of sync | Ensure audio `startFrom`/`endAt` match video timeline |
| Font not found | Register with `registerFont()` before render |
| Video won't play | Check `canDecode()`, use supported codecs (H.264) |
| Memory crash on render | Reduce `--concurrency`, lower resolution |
| Text overflow | Use `measureText()` to fit container |
| 3D not showing | Enable `experimental.three` in config |
| GIF plays wrong speed | Use `<Gif frame={frame} fps={fps} />` |

## Checklist

- [ ] Composition defined with correct `durationInFrames`, `fps`, `width`, `height`
- [ ] All animations driven by `useCurrentFrame()`
- [ ] Interpolations use `extrapolateRight: "clamp"` where needed
- [ ] Fonts registered via `registerFont()` or Google Fonts package
- [ ] Video/audio assets use `<Video />` / `<Audio />` with proper trim props
- [ ] Dynamic metadata calculated for variable-length content
- [ ] Tested in Remotion Studio at multiple timestamps
- [ ] Render command includes appropriate codec and concurrency
- [ ] Output verified for sync, quality, and duration

## Resources

- Documentation: https://www.remotion.dev/docs
- Repository: https://github.com/remotion-dev/remotion
- API Reference: https://www.remotion.dev/docs/api
- Community: Discord / GitHub Discussions
- License: MIT

## Related skills

Load these when the task spans more than this skill.

- [`motion-canvas`](../motion-canvas/SKILL.md) — Set up and troubleshoot Motion Canvas projects, write TypeScript animation scenes with generator functions, si…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`d3-visualization`](../d3-visualization/SKILL.md) — Create custom interactive D3.js visualizations, including charts, graphs, networks, maps, transitions, and SVG…
- [`generative-art`](../generative-art/SKILL.md) — Create generative art through a two-phase process: first define an algorithmic/visual philosophy (.md), then e…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`manim`](../manim/SKILL.md) — Provides concise guidance for creating mathematical animations with the Manim Community Python library, coveri…
- [`paper-to-web`](../paper-to-web/SKILL.md) — Convert academic papers (LaTeX or PDF) into interactive websites, presentation videos, and conference posters…
