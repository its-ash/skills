# Remotion Video Creation

Rules and patterns for programmatic video in React with Remotion: compositions, frame-driven animation, sequencing, transitions, media, captions, fonts, text measurement, charts, 3D, and media metadata.

## When to use
- You write or review Remotion code (`remotion`, `@remotion/*` packages).
- You build overlays, lower thirds, animated charts, captions, explainers, or reusable video templates in React.
- You need dynamic duration or dimensions from data or from a source video.

Full API docs: [remotion.dev/docs](https://www.remotion.dev/docs).

## Hard rules

1. **Drive all animation from `useCurrentFrame()`.** Write timings in seconds and multiply by `fps` from `useVideoConfig()`.
2. **CSS transitions, CSS animations, and Tailwind `transition-*` / `animate-*` classes are forbidden.** They do not render correctly.
3. **Third-party animation must be off.** Chart libraries, shaders, Lottie loaders, and 3D models must not animate by themselves. `useFrame()` from `@react-three/fiber` is forbidden.
4. **Use Remotion media components**, which wait until assets load: `<Img>` (not `<img>`, Next.js `<Image>`, or CSS `background-image`), `<Video>` and `<Audio>` from `@remotion/media`, `<AnimatedImage>` for GIF, APNG, AVIF, and WebP.
5. **Reference `public/` files with `staticFile()`.** Remote URLs work directly but need CORS.
6. **Premount every `<Sequence>`** with `premountFor`.
7. **Install Remotion packages with `npx remotion add <pkg>`** (or `bunx`, `yarn`, `pnpm exec`) so versions match.

## Compositions

```tsx
import { Composition, Folder, Still } from "remotion";
import { MyComposition, type MyCompositionProps } from "./MyComposition";

export const RemotionRoot = () => (
  <>
    <Folder name="Marketing">
      <Composition
        id="Promo"
        component={MyComposition}
        durationInFrames={100}
        fps={30}
        width={1080}
        height={1080}
        defaultProps={{ title: "Hello World", color: "#ff0000" } satisfies MyCompositionProps}
      />
    </Folder>
    <Still id="Thumbnail" component={MyComposition} width={1280} height={720} />
  </>
);
```

- Put it in `src/Root.tsx`. Use `type` (not `interface`) for props so `defaultProps` is type-safe. Props must be JSON-serializable (`Date`, `Map`, `Set`, `staticFile()` are allowed).
- Folder names: letters, numbers, and hyphens only.
- Render: `npx remotion render src/index.ts Promo out.mp4`.

### calculateMetadata

Set duration, size, fps, props, `defaultOutName`, or `defaultCodec` from data before render. All fields are optional and override the `<Composition>` props. `abortSignal` cancels stale fetches in the Studio.

```tsx
import type { CalculateMetadataFunction } from "remotion";

const calculateMetadata: CalculateMetadataFunction<Props> = async ({ props, abortSignal }) => {
  const data = await fetch(props.dataUrl, { signal: abortSignal }).then((r) => r.json());
  const { durationInSeconds, dimensions } = await getMediaMetadata(props.videoSrc);
  return {
    durationInFrames: Math.ceil(durationInSeconds * 30),
    width: dimensions?.width ?? 1920,
    height: dimensions?.height ?? 1080,
    props: { ...props, fetchedData: data },
    defaultOutName: `video-${props.id}.mp4`,
  };
};
```

## Animation and timing

```tsx
import { interpolate, spring, Easing, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps, durationInFrames } = useVideoConfig();

const opacity = interpolate(frame, [0, 2 * fps], [0, 1], {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
  easing: Easing.inOut(Easing.quad),
});

const scale = spring({ frame, fps, config: { damping: 200 } });
const rotation = interpolate(scale, [0, 1], [0, 360]);

const inAnim = spring({ frame, fps });
const outAnim = spring({ frame, fps, durationInFrames: fps, delay: durationInFrames - fps });
const visible = inAnim - outAnim;
```

- `interpolate` does not clamp by default.
- Spring defaults (`mass: 1, damping: 10, stiffness: 100`) bounce. Presets: smooth `{damping: 200}`, snappy `{damping: 20, stiffness: 200}`, bouncy `{damping: 8}`, heavy `{damping: 15, stiffness: 80, mass: 2}`.
- `delay` shifts a spring; `durationInFrames` stretches it to a fixed length.
- Easing = convexity (`Easing.in`, `Easing.out`, `Easing.inOut`) combined with a curve (`quad`, `sin`, `exp`, `circle`), or `Easing.bezier(x1, y1, x2, y2)`. Default is linear.

## Sequencing and trimming

```tsx
import { Sequence, Series } from "remotion";

<Sequence from={1 * fps} durationInFrames={2 * fps} premountFor={1 * fps}>
  <Title />
</Sequence>

<Series>
  <Series.Sequence durationInFrames={60}><SceneA /></Series.Sequence>
  <Series.Sequence offset={-15} durationInFrames={60}><SceneB /></Series.Sequence>
</Series>
```

- `<Sequence>` and `<Series.Sequence>` wrap children in an absolute fill. Use `layout="none"` to stop that (required inside `<ThreeCanvas>`).
- Inside a Sequence, `useCurrentFrame()` is local (starts at 0).
- Negative `from` trims the start (`from={-0.5 * fps}`); `durationInFrames` unmounts at the end; nest an outer `from` to trim and delay.
- A negative `offset` in `<Series>` overlaps scenes.

## Transitions

```tsx
import { TransitionSeries, linearTiming, springTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={60}><SceneA /></TransitionSeries.Sequence>
  <TransitionSeries.Transition presentation={fade()} timing={linearTiming({ durationInFrames: 15 })} />
  <TransitionSeries.Sequence durationInFrames={60}><SceneB /></TransitionSeries.Sequence>
  <TransitionSeries.Transition
    presentation={slide({ direction: "from-left" })}
    timing={springTiming({ config: { damping: 200 } })}
  />
  <TransitionSeries.Sequence durationInFrames={60}><SceneC /></TransitionSeries.Sequence>
</TransitionSeries>
```

- Presentations: `fade`, `slide` (`from-left`, `from-right`, `from-top`, `from-bottom`), `wipe`, `flip`, `clockWipe`.
- Transitions overlap scenes, so total length = sum of scenes minus each transition. Get a transition length with `timing.getDurationInFrames({ fps })`; a `springTiming` without `durationInFrames` depends on `fps`.

## Media

```tsx
import { Img, AnimatedImage, staticFile, interpolate } from "remotion";
import { Video, Audio } from "@remotion/media";

<Img src={staticFile("logo.png")} style={{ width: 500, height: 300, objectFit: "cover" }} />
<AnimatedImage src={staticFile("anim.gif")} width={500} height={500} fit="contain" playbackRate={1} loopBehavior="loop" />
<Video
  src={staticFile("clip.mp4")}
  trimBefore={2 * fps}
  trimAfter={10 * fps}
  volume={(f) => interpolate(f, [0, fps], [0, 1], { extrapolateRight: "clamp" })}
  playbackRate={1}
/>
<Audio src={staticFile("music.mp3")} volume={0.5} loop toneFrequency={1} />
```

- `trimBefore` and `trimAfter` are in frames. Wrap media in a `<Sequence>` to delay it. Layer audio with more than one `<Audio>`.
- Other props: `muted`, `loop`, `loopVolumeCurveBehavior` (`"repeat"` resets the frame count per loop, `"extend"` keeps counting), `toneFrequency` (pitch 0.01 to 2 without speed change).
- `<AnimatedImage>` `loopBehavior`: `loop`, `pause-after-finish`, `clear-after-finish`; `fit`: `fill`, `contain`, `cover`.
- Lottie (`@remotion/lottie`): fetch the JSON inside `delayRender()` / `continueRender()` (call `cancelRender(err)` on failure), keep it in state, then render `<Lottie animationData={data} />`.

## Fonts

```tsx
import { loadFont } from "@remotion/google-fonts/Roboto";
const { fontFamily, waitUntilDone } = loadFont("normal", { weights: ["400", "700"], subsets: ["latin"] });
```

Load only the weights and subsets you need. For local files use `@remotion/fonts` (`loadFont({ family, url: staticFile("font.woff2") })`) or a `FontFace` with `staticFile()`.

## Text

- Typewriter: slice the string by frame. Never animate per-character opacity.
- `@remotion/layout-utils`: `measureText({ text, fontFamily, fontSize, fontWeight })` (cached), `fitText({ text, withinWidth, fontFamily, fontWeight })` (cap the result, for example `Math.min(fontSize, 80)`), `fillTextBox()` to detect overflow.
- DOM measurement: Remotion scales the container, so divide `getBoundingClientRect()` values by `useCurrentScale()`.

## Captions

- Transcribe: `@remotion/install-whisper-cpp` (local server, free), `@remotion/whisper-web` (browser WASM, slower), `@remotion/openai-whisper` (paid API).
- Import `.srt`: fetch `staticFile("subs.srt")` inside `useDelayRender()` and parse with `parseSrt({ input })` from `@remotion/captions`.
- Display: group with `createTikTokStyleCaptions({ captions, combineTokensWithinMilliseconds: 1200 })` (higher value = more words per page), then render each page in a `<Sequence>` from `page.startMs / 1000 * fps` to the next page start, and highlight the active token by its `fromMs` and `toMs`.

## Charts

Use plain HTML, SVG, or D3 with library animations off. Stagger bars with `spring({ frame, fps, delay: i * 5, config: { damping: 200 } })`. For pie segments, animate `strokeDashoffset` from the segment length to 0 and rotate by -90 degrees so it starts at 12 o'clock.

## 3D

```tsx
import { ThreeCanvas } from "@remotion/three";

const { width, height } = useVideoConfig();
<ThreeCanvas width={width} height={height}>
  <ambientLight intensity={0.4} />
  <directionalLight position={[5, 5, 5]} intensity={0.8} />
  <mesh rotation={[0, frame * 0.02, 0]}>
    <boxGeometry args={[2, 2, 2]} />
    <meshStandardMaterial color="#4a9eff" />
  </mesh>
</ThreeCanvas>
```

`<ThreeCanvas>` needs `width`, `height`, and lighting. Any `<Sequence>` inside it needs `layout="none"`.

## Tailwind

Use Tailwind if the project has it enabled (see the Remotion Tailwind docs), but never its transition or animation classes.

## Media metadata with Mediabunny

`mediabunny` works in the browser, Node.js, and Bun. Use `UrlSource` for URLs (and `staticFile()` paths) and `FileSource` for `File` objects.

```tsx
import { Input, ALL_FORMATS, UrlSource } from "mediabunny";

const open = (src: string) =>
  new Input({ formats: ALL_FORMATS, source: new UrlSource(src, { getRetryDelay: () => null }) });

export const getMediaMetadata = async (src: string) => {
  const input = open(src);
  const durationInSeconds = await input.computeDuration();
  const track = await input.getPrimaryVideoTrack();
  return {
    durationInSeconds,
    dimensions: track ? { width: track.displayWidth, height: track.displayHeight } : null,
  };
};

export const canDecode = async (src: string) => {
  const input = open(src);
  try {
    await input.getFormat();
  } catch {
    return false;
  }
  const video = await input.getPrimaryVideoTrack();
  if (video && !(await video.canDecode())) return false;
  const audio = await input.getPrimaryAudioTrack();
  return !(audio && !(await audio.canDecode()));
};
```

For audio duration use the same `computeDuration()`. To extract frames for thumbnails or filmstrips, use `VideoSampleSink` on the primary video track and iterate the samples at the timestamps you need; close each `VideoSample` after use.
