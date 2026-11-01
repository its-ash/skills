# Visual Taste and Look Matching

Decide the creative direction of a video before anything renders (named-genre vocabulary, mood, color, light, beat-synced editing grammar), then match a reference look by measurement, not by prompt words.

## When to use

- You build a music video, lyric video, fancam, visualizer, or a short-form reel where the feel matters more than the information.
- You drive AI b-roll generation ([fal-ai-media.md](fal-ai-media.md)) and the prompts need one coherent direction.
- You assemble a moodboard or choose a visual genre before rendering.
- The user says "make it feel like X", "give it a direction", "capture the look of these clips", or "match this grade and pacing".
- The edit works but reads as flat, generic, or stylistically incoherent.

This reference sits on top of [video-production](../SKILL.md) (mechanics) and [remotion.md](remotion.md) (renderer). Use those for how; use this for what and why.

## Core thesis

1. **Decide taste first, judge it last.** If you decide taste only at the final pass, each generation and cut before it was a guess. Pick the direction before the first prompt and let it constrain all later work.
2. **Coherence beats novelty.** One look across 30 shots is better than 30 looks. A named genre is a constraint that gives coherence.
3. **Cut to the song, not to the footage.** In a music video the timeline is the waveform. Each hard cut lands on a beat or a transient.
4. **Generate selectively, edit ruthlessly.** Generate 10, keep 2. Coherence comes from rejection.
5. **The model supplies content; measurement supplies the look.** Prompts control subject, motion, framing, and light structure. Color and rhythm come from measured references.

## Genre vocabulary

A genre name is a complete prompt-and-grade preset: palette, texture, light, and subject as one unit. Pick one **primary** family and at most **one accent**.

| Family | Example genres | Reads as |
|--------|----------------|----------|
| Ethereal / divine | spiritualism, glacial folk, beacons, zen core, fairy tale, cozy blanket | weightless, holy, glowing, soft |
| Hyperpop / Y2K-cyber | cyberdelia, acid house, new liquid, 8-bit / pixel | glossy, chrome, neon, kawaii-cyber |
| Dark / occult | dark academia, smoke nostalgia, abstract tech | high-contrast, ominous, grain |
| Retro / print | retro surfers, art deco, adventure pulp, classic advertising, magazine collage, riso print | flat, graphic, halftone, nostalgic |
| Organic / textural | microbiology core, weaving patterns, fruitage retro, shape design, colour fusion | tactile, macro, woven, wet |
| Systemic / data | numbers, mazes, code web, heatmap, blueprint builds, multilayer | gridded, generative, schematic |
| Cultural / kitsch | devotional kitsch, premium brands, collectibles, preppy Americana, carnival | loud, specific, referential |

Treat individual names as inspiration tags; the families are the durable layer. Keep distinct genres in separate specs. Do not blend them into one generic look.

To use a genre as a preset: choose the genre that matches the emotional job of the section, combine its palette, texture, and subject into a prompt, add the project suffix (for example `9:16, vertical, cinematic, film grain, volumetric light, no text, no watermark`), render 6 to 10, keep 2 to 3.

## Example mood system: angelcore x cloud-trance

A worked direction (Ethereal / divine primary, Hyperpop accent). Use it as a pattern, not a default.

- **Palette:** near-black void `#05060a` and bone white `#f4f1ea` for most frames; molten gold or ember `#ffb24d` to `#ff7a18` as the one warm light in dark frames; iridescent violet, cyan, magenta bokeh `#8a6bff`, `#4fc3ff`, `#ff6ad5` in bright frames; one glowing red `#ff2a2a` on monochrome for one or two shock cuts only.
- **Rule:** one accent per shot. Gold in the dark, iridescence in the light, never both.
- **Light and texture:** darkness pierced by one warm source; crystalline bokeh, flares, bloom, light leaks; grain and slight chromatic aberration on dark frames, clean gloss on bright frames; a hero object centered on black negative space.
- **Motion:** slow, floating camera (drift, slow push, slow orbit); speed only at the drop; particles rise (ascension).

## Editing grammar

1. **Beat-locked hard cuts.** No dissolves in verse or drop. Cut on the kick.
2. **Hero-on-black macro inserts.** One sharp object centered in black, held 1 to 2 beats, then cut. A rhythmic montage of these carries a verse.
3. **Bloom reveal.** A white or ember bloom blows out the frame on a transient, then resolves into the next shot.
4. **Color-pop on monochrome.** A passage in black and white, then one colored element punches through on the downbeat.
5. **Speed-ramp into the drop.** Ramp from slow to fast across the last bar, then hard-cut to tempo on the one.
6. **Caption keyword highlight** (lyric or talking-head sections only): all caps, one or two words in the accent color, synced to the vocal.

Do not: crossfade in tempo sections; use more than one accent color per shot; hold a shot past its musical phrase; show readable UI chrome; mix aspect ratios in one timeline.

## Beat math

```
seconds_per_beat = 60 / BPM
frames_per_beat  = fps * 60 / BPM        # 138 BPM: 24fps 10.43, 30fps 13.04, 60fps 26.09
bar (4 beats)    = 4 * 60 / BPM          # 138 BPM: 1.739 s
```

```tsx
const FPS = 30;
const BPM = 138;
const beat = (n: number) => Math.round(n * (60 / BPM) * FPS);

<Sequence from={beat(0)} durationInFrames={beat(2)} premountFor={FPS}>
  <Video src={staticFile("selects/key.mp4")} />
</Sequence>
```

Map each song section (intro, verse, drop, bridge, outro) to a genre lean, a grammar move, and a shot list before you generate anything.

## Measure the look, do not prompt it

Prompt words cannot deliver a grade. On real footage, escalating color direction in paid generations did not move the midtone cast near its target, while a measured grade applied afterwards matched it in one deterministic pass.

- **Put zero color language in generation prompts.** Add: "Colour: none. Render neutral. Grading is applied afterwards."
- **Keep the brief and the style steer separate.** The brief says what happens (subject, action, place); the steer says how it looks. Merged, style words leak into the scene ("teal" becomes a teal object).
- **Give local, checkable rules.** "Backgrounds pure black and unlit; subjects blow toward white" works. "Extreme contrast" does not.

### What to measure in reference footage

- **Chroma by luminance zone**, not globally. Color identity often lives in one band (for example violet at L\* 25). Use zones such as L\* edges `[0, 15, 35, 55, 75, 100]` and report the whole curve, not only the end zones.
- **Median and MAD, not mean and standard deviation.** Chroma is right-skewed; a mean-based grade pushes color about 3x too hard.
- **Contrast as std(L\*)**, not white minus black (that is about 100 on almost all footage).
- **Background share:** the share of pixels below L\* 10. A grade can match mean, contrast, and chroma while it lifts blacks into grey.
- **Cadence:** detect shot boundaries with an adaptive threshold (take the highest threshold that still finds at least 90% of the shots the most sensitive setting finds; reject rates above 100 cuts per minute). Keep the shot-length distribution, not only the mean.
- **Mask interface chrome first.** Screen-recorded references carry letterbox bars, status bars, like buttons, and captions. The temporal median frame separates them: content blurs, chrome keeps sharp edges. Crop past the innermost hot edge band, and scale to cover (not pad) when portrait footage goes into landscape.

### Apply the look

- **Generate takes, not shots.** One generation per sub-second shot wastes most generated seconds and gives unrelated clips. Generate about 5-second continuous takes and cut inside them. Tell the model the take will be cut into short pieces, so framing, subject, and light must keep changing.
- **Re-encode cuts; never stream-copy.** Stream copy cuts only on keyframes and destroys sub-second rhythm.
- **When you supplement existing footage, cut on its real shot boundaries** and take every Nth shot, so consecutive picks are discontinuous.
- **Sample shot lengths from the reference distribution** so rhythm keeps its variance.
- **Anchor tone; do not force histogram matching** when the clip's histogram differs from the reference (for example a mostly black generated clip); forced matching lifts the background out of black.
- **Overlay plates are elements, not washes.** Lift flares and streaks onto black by percentile (about top 3%), reject plates that cover more than about 22% of the frame, crop each plate to its alpha bounds, and vary placement, scale, and rotation per shot from a seeded RNG.

### Verify, then believe

Check distribution shape against the reference, not only one error number: background share (vs the reference, not the source), per-zone chroma error with medians, contrast, black and white points, banding (empty L\* bins between occupied ones), and detected mean shot length. Watch Lab units: in OpenCV float32, L\* is 0 to 100 and a\*/b\* are signed; in uint8, L\* is 0 to 255 and a\*/b\* are offset by 128.

## Key principles

1. Decide the genre before the first generation: one primary family and one accent.
2. One accent color per shot.
3. Each hard cut lands on a beat.
4. Generate 10, keep 2.
5. Crop the chrome: no status bars, foreign captions, or UI in the final frame.
6. Color comes from measurement and grading, never from prompt words.
