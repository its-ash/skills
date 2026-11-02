---
name: video-production
description: "AI-assisted editing of real footage: transcript planning, FFmpeg cuts, Remotion composition, generated voice, music, and b-roll, Descript or CapCut polish, Manim explainers, Playwright UI demos, VideoDB, Blender checks, visual taste. Use to edit or cut video, make a vlog, tutorial, demo, launch video, or reel, reframe for TikTok, Reels, or YouTube, add subtitles, overlays, or voiceover, detect scenes or silence, write Remotion or Manim code, use fal.ai, or match a reference look. Sub-skills: remotion, manim-video, fal-ai-media, ui-demo, videodb, blender-motion-state-inspection, visual-taste."
---
# Video Production
Edit real footage fast: compress, structure, and augment it. Do not generate the whole video.

## Core rules
- Run the pipeline in order; one job per layer, skip none: capture (Screen Studio, Playwright, camera) → plan (Claude/Codex) → cut (FFmpeg) → compose (Remotion) → generate (ElevenLabs/fal.ai) → polish (Descript/CapCut).
- Fix structure before style: transcript → topics → dead sections (pauses, tangents, retakes) → edit decision list (EDL) with timestamps.
- Reference-driven work: set the look first with [visual-taste](references/visual-taste.md), then edit.
- Use FFmpeg for all deterministic work: split, trim, concat, proxy, audio extract, loudness.
- `-c copy` cuts on keyframes only; re-encode for frame-exact cuts.
- Turn any repeated overlay or scene into a Remotion component.
- Generate only assets that do not exist. Get user approval first; generation costs money and uploads data.
- Leave pacing, caption cleanup, color, final mix, and export to the human polish layer.
- Before live editor or DAW changes, save a versioned checkpoint and verify the file exists; repeat after. An API readback proves memory state, not a save.
- Track rendered media, editable project, and creative approval as separate states in the handoff.
- MIDI audio: match pitches to the receiving instrument's note map and audition; a created clip can be silent.
- Reconstructed projects: native load and save, sort events by time, verify sample links and mutes, audition export for silence.
- Check an editor bridge's capability handshake before newer commands. Never enable upload or training telemetry as a side effect.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Long recording to short clips | Transcript + scene/silence detect → EDL → FFmpeg batch cut | Scrubbing by hand |
| Overlays, lower thirds, charts, templates | Remotion | Manual keyframes per video |
| Precise technical or diagram animation | Manim | Remotion or real footage |
| Scripted web app demo | Playwright recording ([ui-demo](references/ui-demo.md)) | Unscripted screen capture |
| Polished ad-hoc screen recording | Screen Studio | Raw OS recorder |
| Narration | ElevenLabs or VideoDB `generate_voice` | Synthetic voice for the whole video |
| Music, SFX, b-roll, thumbnails | fal.ai | Generating footage you can shoot |
| Server-side search, timeline, smart reframe | VideoDB (uploads media) | Local tools when upload is not allowed |
| 9:16 or 1:1 from 16:9 | FFmpeg center crop; VideoDB smart reframe to track subject | Letterbox |
| Blender rig or pose looks wrong | Inspect state ([blender](references/blender-motion-state-inspection.md)) | Trust the render |

## Load on demand
| Need | Read |
|---|---|
| FFmpeg commands, scene/silence detect, platform sizes and crops, planning prompts, ElevenLabs and fal.ai snippets | [references/ffmpeg-cookbook.md](references/ffmpeg-cookbook.md) |
| Remotion: compositions, calculateMetadata, springs, sequencing, transitions, media, captions, fonts, charts, 3D | [references/remotion.md](references/remotion.md) |
| Manim explainer: scene plan, render conventions, starter scene | [references/manim-video.md](references/manim-video.md) |
| fal.ai MCP: Nano Banana, Seedance, Kling, Veo 3, CSM-1B, ThinkSound, cost checks | [references/fal-ai-media.md](references/fal-ai-media.md) |
| Playwright demo: discover, rehearse, record, cursor overlay, pacing, subtitles | [references/ui-demo.md](references/ui-demo.md) |
| VideoDB: ingest, spoken/scene search, timeline edits, transcode, reframe, generative audio, RTSP alerts | [references/videodb.md](references/videodb.md) |
| Blender rig, pose, retarget, ground contact, facing checks | [references/blender-motion-state-inspection.md](references/blender-motion-state-inspection.md) |
| Genre direction, mood, palette, beat-synced cuts, match a reference grade | [references/visual-taste.md](references/visual-taste.md) |

## Related skills
- [`content-writing`](../content-writing/SKILL.md) — scripts, captions, platform distribution
- [`design`](../design/SKILL.md) — motion design, motion-canvas, visual direction
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — Playwright setup for UI demos
- [`screenshot`](../screenshot/SKILL.md) — stills and thumbnails
