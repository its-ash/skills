---
name: sora
description: "Generates, remixes, polls, lists, downloads, and deletes short Sora videos through OpenAI's video API via the sora command-line interface. Use when creating AI video clips, remixing existing footage, checking generation job status, batch producing multiple videos, downloading rendered MP4 assets, or removing unwanted outputs with commands like sora create, sora remix, sora poll, sora list, sora download, and sora delete while providing OPENAI_API_KEY authentication."
---

# Sora Video Generation Skill

Create and manage short AI‑generated video clips (product demos, cinematic shots, UI mocks, social ads) with OpenAI’s Sora models. The skill runs the `sora` command‑line tool, handles authentication, builds structured prompts, polls async jobs, and downloads assets.

## When to use
- Generate a new video from a textual prompt.
- Remix an existing video by providing its ID and a variation.
- Check the status of a running job or list recent jobs.
- Download the final video, its thumbnail, or a spritesheet.
- Run many prompts in a single batch operation.

## Workflow
1. **Identify intent** – create, remix, poll/download, or batch.
2. **Gather inputs** – prompt text, model (`sora-2` or `sora-2-pro`), size, duration, optional reference image.
3. **Prepare prompt** – use the Prompt Augmentation template (see below). Save to a file if the prompt is long.
4. **Run the CLI** – use the appropriate sub‑command and flags.
5. **Poll** – for async jobs, poll until the status is `completed`.
6. **Download** – fetch video, thumbnail, and/or spritesheet.
7. **Clean up** – delete temporary prompt files or JSONL batch files.
8. **Iterate** – make a single, targeted change and repeat.

## Authentication
- Set the environment variable `OPENAI_API_KEY` before any API call.
- If the variable is missing, instruct the user to create an API key at https://platform.openai.com/api-keys and export it, e.g.:
  ```bash
  export OPENAI_API_KEY=sk-...
  ```
- Never ask the user to paste the full key in the chat.

## Defaults & Rules
- **Model**: `sora-2` (use `sora-2-pro` for higher fidelity).
- **Resolution**: `1280x720`.
- **Duration**: `4` seconds (allowed values: `"4"`, `"8"`, `"12"`).
- **API client**: OpenAI Python SDK (`import openai`). Do not craft raw HTTP requests.
- **Reference images**: JPG, PNG, or WEBP, matching the target resolution.
- **Cache**: If UV cache permissions fail, set `UV_CACHE_DIR=/tmp/uv-cache`.
- **Download URLs** expire after ~1 hour; copy assets to permanent storage promptly.
- **Do not modify** the `sora` CLI script unless explicitly requested.

## API Limitations
- Only `sora-2` and `sora-2-pro` models are available.
- Duration must be supplied as a string enum (`"4"`, `"8"`, `"12"`).
- Output size is limited to the model’s supported resolutions.
- Video creation is asynchronous; you must poll for completion.
- Rate limits depend on the account tier (do not expose exact numbers).
- Content must comply with OpenAI guardrails (see below).

## Guardrails (must enforce)
- Content must be suitable for audiences under 18.
- No copyrighted characters, music, or brand logos.
- No depiction of real people, including public figures.
- Input images containing human faces are rejected.

## Prompt Augmentation
Convert free‑form prompts into a structured spec. Only add details the user already implied.

```
Use case: <where the clip will be used>
Primary request: <core description>
Scene/background: <location, time of day, atmosphere>
Subject: <main subject>
Action: <single clear action>
Camera: <shot type, angle, motion>
Lighting/mood: <lighting description>
Color palette: <3‑5 color anchors>
Style/format: <film, animation, format cues>
Timing/beats: <counts or beats>
Audio: <ambient cue / music / voiceover if requested>
Text (verbatim): "<exact text>"
Dialogue:
- Speaker: "Short line."
Constraints: <must keep>
Avoid: <must avoid>
```
**Augmentation rules**
- Keep the spec concise.
- For remixes, list invariants (e.g., "same shot, change palette").
- If required details are missing, ask the user before proceeding.
- When passing a ready‑made spec file to the CLI, add `--no-augment` to prevent double‑wrapping.

## CLI Usage
All commands assume the `sora` executable is in the PATH.

### Create a single video
```bash
sora create \
  --model sora-2 \
  --size 1280x720 \
  --seconds 4 \
  --prompt-file my_prompt.txt
```
- Use `--prompt-file` for long prompts.
- Add `--no-augment` if `my_prompt.txt` already follows the structured template.

### Remix an existing video
```bash
sora remix \
  --video-id <VIDEO_ID> \
  --prompt-file remix_prompt.txt
```
- Include invariants in the remix prompt.

### Poll for completion
```bash
sora poll --job-id <JOB_ID>
```
- The command returns `completed`, `failed`, or `processing`.

### Download assets
```bash
sora download \
  --job-id <JOB_ID> \
  --asset video   # options: video, thumbnail, spritesheet
```
- Files are saved in the current directory.

### Batch creation
1. Create a temporary JSONL file where each line is a JSON object with the keys `prompt`, `model`, `size`, `seconds`, and optional `image_path`.
2. Run:
```bash
sora batch --input batch_jobs.jsonl
```
3. Delete the JSONL file after the batch finishes.

## Checklist
- [ ] `OPENAI_API_KEY` is set.
- [ ] Intent (create, remix, poll, download, batch) is identified.
- [ ] Prompt follows the augmentation template or `--no-augment` is used.
- [ ] Model, size, and seconds parameters are specified.
- [ ] For remix, video ID is provided and invariants are listed.
- [ ] CLI command includes appropriate flags.
- [ ] Poll until job status is `completed`.
- [ ] Download required assets before URL expiration.
- [ ] Temporary files are removed.
- [ ] Guardrails are satisfied (no copyrighted or real‑person content).

## Related skills

Load these when the task spans more than this skill.

- [`video-downloader`](../video-downloader/SKILL.md) — Downloads videos or audio from YouTube and other platforms. Choose resolution, format, single video, playlist,…
- [`remotion`](../remotion/SKILL.md) — Comprehensive guide for Remotion - programmatic video creation in React. Covers compositions, frame-based anim…
- [`motion-canvas`](../motion-canvas/SKILL.md) — Set up and troubleshoot Motion Canvas projects, write TypeScript animation scenes with generator functions, si…
- [`generative-art`](../generative-art/SKILL.md) — Create generative art through a two-phase process: first define an algorithmic/visual philosophy (.md), then e…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
