---
name: video-production
description: "Guides AI-assisted video production that cuts, structures, and augments real footage through a layered pipeline: capture, transcript-driven planning, FFmpeg cuts, Remotion composition, generated voice, music, and b-roll, and final polish in Descript or CapCut, plus Manim explainers, Playwright UI demo recordings, VideoDB server-side indexing, Blender motion checks, and visual taste direction. Use when the user wants to edit video, cut footage, make a vlog, tutorial, demo, launch video, music video, or reel, reframe for TikTok, Reels, or YouTube, add subtitles, overlays, or voiceover, detect scenes or silence, write Remotion or Manim code, generate media with fal.ai, or match a reference look. Sub-skills: remotion, manim-video, fal-ai-media, ui-demo, videodb, blender-motion-state-inspection, visual-taste."
---

# Video Production

AI-assisted editing for real footage. Not generation from prompts: edit existing video fast.

## When to Use

- The user wants to edit, cut, or structure video footage.
- You turn long recordings into short-form content.
- You build vlogs, tutorials, or demo videos from raw capture.
- You add overlays, subtitles, music, or voiceover to existing video.
- You reframe video for other platforms (YouTube, TikTok, Instagram).
- The user says "edit video", "cut this footage", "make a vlog", or "video workflow".

## Core Thesis

AI video editing is useful when you stop asking it to create the whole video and start using it to compress, structure, and augment real footage. The value is not generation. The value is compression.

## The Pipeline

```
Screen Studio / raw footage
  → Claude / Codex
  → FFmpeg
  → Remotion
  → ElevenLabs / fal.ai
  → Descript or CapCut
```

Each layer has a specific job. Do not skip layers. Do not try to make one tool do everything. For reference-driven work, decide the look first with [references/visual-taste.md](references/visual-taste.md), then come back here for the edit.

### Project safety

- Before live editor or DAW changes, save a versioned project checkpoint and verify that the file exists. Save and verify another checkpoint after the changes. An API readback proves the in-memory state, not that it was saved.
- Keep rendered media, editable projects, and creative approval as separate states in the handoff.
- For MIDI-driven audio, check pitches against the note mapping of the receiving instrument and audition the result; a created clip can still be silent.
- For reconstructed projects, validate through a native load and save, sort events in timeline order, verify sample links and mute states, then audition the exported audio for unwanted silence.
- Check the capability handshake of an editor bridge before you call newer commands. Do not enable upload or training-data telemetry as a side effect of a creative task.

## Layer 1: Capture (Screen Studio / Raw Footage)

Collect the source material:
- **Screen Studio**: polished screen recordings for app demos, coding sessions, browser workflows
- **Scripted UI demos**: Playwright recordings with cursor and subtitles (see [references/ui-demo.md](references/ui-demo.md))
- **Raw camera footage**: vlog footage, interviews, event recordings

Output: raw files ready for organization.

## Layer 2: Organization (Claude / Codex)

Use Claude Code or Codex to:
- **Transcribe and label**: generate a transcript, identify topics and themes
- **Plan structure**: decide what stays, what gets cut, what order works
- **Identify dead sections**: find pauses, tangents, repeated takes
- **Generate an edit decision list**: timestamps for cuts, segments to keep
- **Scaffold FFmpeg and Remotion code**: generate the commands and compositions

```
Example prompt:
"Here's the transcript of a 4-hour recording. Identify the 8 strongest segments
for a 24-minute vlog. Give me FFmpeg cut commands for each segment."
```

This layer is about structure, not final creative taste.

## Layer 3: Deterministic Cuts (FFmpeg)

FFmpeg handles the boring but critical work: splitting, trimming, concatenating, and preprocessing.

### Extract segment by timestamp

```bash
ffmpeg -i raw.mp4 -ss 00:12:30 -to 00:15:45 -c copy segment_01.mp4
```

`-c copy` cuts only on keyframes. For frame-exact or sub-second cuts, re-encode (`-c:v libx264 -c:a aac`).

### Batch cut from edit decision list

```bash
#!/bin/bash
# cuts.txt: start,end,label
mkdir -p segments
while IFS=, read -r start end label; do
  ffmpeg -nostdin -i raw.mp4 -ss "$start" -to "$end" -c copy "segments/${label}.mp4"
done < cuts.txt
```

### Concatenate segments

```bash
for f in segments/*.mp4; do echo "file '$f'"; done > concat.txt
ffmpeg -f concat -safe 0 -i concat.txt -c copy assembled.mp4
```

### Create proxy for faster editing

```bash
ffmpeg -i raw.mp4 -vf "scale=960:-2" -c:v libx264 -preset ultrafast -crf 28 proxy.mp4
```

### Extract audio for transcription

```bash
ffmpeg -i raw.mp4 -vn -acodec pcm_s16le -ar 16000 audio.wav
```

### Normalize audio levels

```bash
ffmpeg -i segment.mp4 -af loudnorm=I=-16:TP=-1.5:LRA=11 -c:v copy normalized.mp4
```

## Layer 4: Programmable Composition (Remotion)

Remotion turns editing problems into composable code. Use it for:

- Overlays: text, images, branding, lower thirds
- Data visualizations: charts, stats, animated numbers
- Motion graphics: transitions, explainer animations
- Composable scenes: reusable templates across videos
- Product demos: annotated screenshots, UI highlights

```tsx
import { AbsoluteFill, Sequence, staticFile } from "remotion";
import { Video } from "@remotion/media";

export const VlogComposition: React.FC = () => (
  <AbsoluteFill>
    <Sequence from={0} durationInFrames={300} premountFor={30}>
      <Video src={staticFile("segments/intro.mp4")} />
    </Sequence>

    <Sequence from={30} durationInFrames={90} premountFor={30}>
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
        <h1 style={{ fontSize: 72, color: "white", textShadow: "2px 2px 8px rgba(0,0,0,0.8)" }}>
          The AI Editing Stack
        </h1>
      </AbsoluteFill>
    </Sequence>

    <Sequence from={300} durationInFrames={450} premountFor={30}>
      <Video src={staticFile("segments/demo.mp4")} />
    </Sequence>
  </AbsoluteFill>
);
```

```bash
npx remotion render src/index.ts VlogComposition output.mp4
```

For rules (frame-driven animation, transitions, captions, fonts, media, 3D), see [references/remotion.md](references/remotion.md). For precise technical explainers, use Manim ([references/manim-video.md](references/manim-video.md)).

## Layer 5: Generated Assets (ElevenLabs / fal.ai)

Generate only what you need. Do not generate the whole video. Generation costs money and uploads data; get user approval first.

### Voiceover with ElevenLabs

```python
import os
import requests

resp = requests.post(
    f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
    headers={"xi-api-key": os.environ["ELEVENLABS_API_KEY"], "Content-Type": "application/json"},
    json={
        "text": "Your narration text here",
        "model_id": "eleven_turbo_v2_5",
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75},
    },
    timeout=60,
)
resp.raise_for_status()
with open("voiceover.mp3", "wb") as f:
    f.write(resp.content)
```

### Music, SFX, and visuals with fal.ai

Use [references/fal-ai-media.md](references/fal-ai-media.md) for background music, sound effects (ThinkSound video-to-audio), transition sounds, and insert shots, thumbnails, or b-roll that does not exist:

```
generate(app_id: "fal-ai/nano-banana-pro", input_data: {
  "prompt": "professional thumbnail for tech vlog, dark background, code on screen",
  "image_size": "landscape_16_9"
})
```

### VideoDB generative audio

If VideoDB is configured ([references/videodb.md](references/videodb.md)):

```python
voiceover = coll.generate_voice(text="Narration here", voice="alloy")
music = coll.generate_music(prompt="lo-fi background for coding vlog", duration=120)
sfx = coll.generate_sound_effect(prompt="subtle whoosh transition")
```

## Layer 6: Final Polish (Descript / CapCut)

The last layer is human. Use a traditional editor for:
- **Pacing**: adjust cuts that feel too fast or slow
- **Captions**: auto-generated, then manually cleaned
- **Color grading**: basic correction and mood
- **Final audio mix**: balance voice, music, and SFX levels
- **Export**: platform-specific formats and quality settings

This is where taste lives. AI clears the repetitive work. You make the final calls.

## Social Media Reframing

| Platform | Aspect Ratio | Resolution |
|----------|-------------|------------|
| YouTube | 16:9 | 1920x1080 |
| TikTok / Reels | 9:16 | 1080x1920 |
| Instagram Feed | 1:1 | 1080x1080 |
| X / Twitter | 16:9 or 1:1 | 1280x720 or 720x720 |

```bash
# 16:9 to 9:16 (center crop)
ffmpeg -i input.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" vertical.mp4

# 16:9 to 1:1 (center crop)
ffmpeg -i input.mp4 -vf "crop=ih:ih,scale=1080:1080" square.mp4
```

For subject-tracking reframe, use VideoDB `video.reframe(start=0, end=60, target="vertical", mode=ReframeMode.smart)`.

## Scene Detection and Auto-Cut

```bash
# Scene changes (threshold 0.3 = moderate sensitivity)
ffmpeg -i input.mp4 -vf "select='gt(scene,0.3)',showinfo" -vsync vfr -f null - 2>&1 | grep showinfo

# Silent segments (cut dead air)
ffmpeg -i input.mp4 -af silencedetect=noise=-30dB:d=2 -f null - 2>&1 | grep silence
```

Highlight extraction prompt:
```
"Given this transcript with timestamps and these scene change points,
identify the 5 most engaging 30-second clips for social media."
```

## What Each Tool Does Best

| Tool | Strength | Weakness |
|------|----------|----------|
| Claude / Codex | Organization, planning, code generation | Not the creative taste layer |
| FFmpeg | Deterministic cuts, batch processing, format conversion | No visual editing UI |
| Remotion | Programmable overlays, composable scenes, reusable templates | Learning curve for non-devs |
| Manim | Precise technical and diagram animation | Not for real footage |
| Screen Studio | Polished screen recordings immediately | Only screen capture |
| ElevenLabs | Voice, narration, music, SFX | Not the center of the workflow |
| VideoDB | Server-side index, search, timeline, reframe | Uploads media to a service |
| Descript / CapCut | Final pacing, captions, polish | Manual, not automatable |

## Key Principles

1. **Edit, don't generate.** This workflow is for cutting real footage, not creating from prompts.
2. **Structure before style.** Get the story right in Layer 2 before you touch anything visual.
3. **FFmpeg is the backbone.** Boring but critical. It makes long footage manageable.
4. **Remotion for repeatability.** If you do it more than once, make it a Remotion component.
5. **Generate selectively.** Use AI generation only for assets that do not exist.
6. **Taste is the last layer.** AI clears repetitive work. You make the final creative calls.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/remotion.md](references/remotion.md) | Write or review Remotion code: compositions, calculateMetadata, frame-driven animation, springs, sequencing, transitions, media, captions, fonts, text fitting, charts, 3D, Mediabunny metadata. |
| [references/manim-video.md](references/manim-video.md) | Build a precise Manim explainer for a graph, workflow, architecture, or metric story, with a scene plan, render conventions, and a starter scene. |
| [references/fal-ai-media.md](references/fal-ai-media.md) | Generate images, video, speech, or video-to-audio with fal.ai MCP (Nano Banana, Seedance, Kling, Veo 3, CSM-1B, ThinkSound), with cost checks. |
| [references/ui-demo.md](references/ui-demo.md) | Record a polished web app demo or walkthrough with Playwright: discover, rehearse, record, with cursor overlay, pacing, and subtitles. |
| [references/videodb.md](references/videodb.md) | Server-side video ingest, spoken and scene search with timestamps, timeline edits, transcode, smart reframe, generative audio, and live RTSP alerts with the VideoDB SDK. |
| [references/blender-motion-state-inspection.md](references/blender-motion-state-inspection.md) | Check a Blender rig, pose, retarget, ground contact, or facing direction from structured state before you trust a render. |
| [references/visual-taste.md](references/visual-taste.md) | Pick a named-genre direction, mood, palette, and beat-synced cut grammar, or match a reference grade and pacing by measurement instead of prompt words. |

## Related skills

Load these when the task spans more than this skill.

- [`content-writing`](../content-writing/SKILL.md) — Scripts, captions, and platform-native distribution of the finished video.
- [`design`](../design/SKILL.md) — Motion design, motion-canvas, and visual direction for UI-heavy videos.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — Playwright setup used by UI demo recordings.
- [`screenshot`](../screenshot/SKILL.md) — Desktop screen capture for stills and thumbnails.
