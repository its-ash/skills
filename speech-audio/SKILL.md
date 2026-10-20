---
name: speech-audio
description: "Transcribe audio to text with Whisper (local, faster-whisper, whisper.cpp) or OpenAI API including speaker diarization, and generate speech from text via OpenAI TTS or Atlas Cloud for voiceovers, IVR prompts, and accessibility reads. Use when you need speech-to-text, audio transcription, whisper, faster-whisper, whisper.cpp, openai-whisper, diarization, speaker identification, text-to-speech, tts, voice synthesis, speech generation, podcast editing, meeting notes, subtitles, captions, voiceover production, IVR recording, screen reader content, audio accessibility, batch processing, streaming transcription, gpu acceleration, cuda, ffmpeg, mp3, wav, m4a, flac, ogg, webm."
---

# Speech‑Audio (Transcription & Text‑to‑Speech)

This skill provides end‑to‑end handling of audio and text. It covers high‑quality speech‑to‑text using OpenAI Whisper or the OpenAI API (with optional speaker diarization) and text‑to‑speech generation using the OpenAI TTS model or Atlas Cloud. Follow the workflows, rules, and checklists to obtain accurate transcripts and natural‑sounding voice output.

---

## When to use
- Convert podcast, video, or meeting recordings to searchable text.
- Translate spoken content to English.
- Generate subtitles (SRT, VTT, or plain text).
- Produce narration, product‑demo voiceovers, IVR prompts, or accessibility reads.
- Need speaker labels (diarization) for interviews or multi‑speaker meetings.
- Require fast batch processing of many audio files or many TTS clips.

---

## Transcription
### Installation
```bash
# Python 3.8‑3.11
pip install -U openai-whisper openai
# ffmpeg is required for most audio formats
# macOS: brew install ffmpeg
# Ubuntu: sudo apt install ffmpeg
# Windows: choco install ffmpeg
```

### Choose the engine
| Engine | When to pick |
|--------|--------------|
| **Whisper (local)** | You have a GPU/CPU and want full control, no API cost, or need custom model size. |
| **OpenAI API** | You prefer a managed service, need speaker diarization, or lack GPU resources. |

### Basic Whisper transcription (Python)
```python
import whisper
model = whisper.load_model("turbo")  # fast, good quality
result = model.transcribe("audio.mp3")
print(result["text"])  # full transcript
# optional: iterate over segments for timestamps
for seg in result["segments"]:
    print(f"[{seg['start']:.2f}s-{seg['end']:.2f}s] {seg['text']}")
```

### Advanced Whisper options
- **Language** – Auto‑detect (default) or specify `language="en"` for speed.
- **Task** – `task="transcribe"` (default) or `task="translate"` to output English.
- **Initial prompt** – Provide domain context to improve terminology.
- **Word‑level timestamps** – `word_timestamps=True`.
- **Temperature fallback** – Supply a tuple of temperatures to retry low‑confidence segments, e.g. `temperature=(0.0,0.2,0.4)`.

### Command‑line transcription (Whisper)
```bash
# Simple transcription, default model (base)
whisper audio.mp3
# Specify model and output format
whisper audio.mp3 --model turbo --output_format srt --language Spanish
# Translate to English
whisper spanish.mp3 --task translate
```

### Batch processing (Python)
```python
import os, whisper
model = whisper.load_model("base")
for file in os.listdir("samples"):
    if file.endswith('.mp3'):
        path = os.path.join('samples', file)
        res = model.transcribe(path)
        out = path.rsplit('.',1)[0] + '.txt'
        open(out,'w').write(res['text'])
```

### Real‑time / streaming (faster‑whisper)
```bash
pip install faster-whisper
```
```python
from faster_whisper import WhisperModel
model = WhisperModel("base", device="cuda", compute_type="float16")
segments, _ = model.transcribe("live.wav", beam_size=5)
for s in segments:
    print(f"[{s.start:.2f}s->{s.end:.2f}s] {s.text}")
```

### GPU acceleration (Whisper)
```python
model = whisper.load_model("turbo", device="cuda")   # uses GPU if available
# Force CPU
model = whisper.load_model("turbo", device="cpu")
```

### OpenAI API transcription with diarization
```bash
# Install OpenAI SDK if not already installed
pip install openai
```
```python
import openai, os
openai.api_key = os.getenv("OPENAI_API_KEY")

audio_path = "meeting.m4a"
with open(audio_path, "rb") as f:
    resp = openai.audio.transcriptions.create(
        model="gpt-4o-transcribe-diarize",
        file=f,
        response_format="diarized_json",
        chunking_strategy="auto"
    )
print(resp)
```
- Use `gpt-4o-transcribe-diarize` for speaker labels.
- For fast plain text, use `gpt-4o-mini-transcribe` with `response_format="text"`.
- Set `OPENAI_API_KEY` in the environment; never ask the user to paste the key.

### Transcription best‑practice checklist
- Choose **turbo** (or **base**) for speed; pick larger models only if VRAM permits.
- Convert source audio to WAV (PCM 16‑bit) for best compatibility.
- Split audio longer than 30 min into <30 min chunks.
- Specify language when known – reduces latency and improves accuracy.
- Provide an `initial_prompt` for technical or domain‑specific vocab.
- Enable `word_timestamps` if you need precise alignment.
- Use GPU for >2‑hour jobs; monitor VRAM to avoid OOM.
- For diarization, prefer the OpenAI API model; Whisper does not separate speakers.
- Validate output: check for missing sections, garbled words, or language mismatches.

---

## Text‑to‑Speech Generation
### Installation
```bash
pip install openai   # default provider
# Atlas Cloud uses only the standard library; no extra install needed
```

### Default provider and model
- **Provider:** OpenAI (unless user explicitly requests Atlas Cloud).
- **Model:** `gpt-4o-mini-tts-2025-12-15`.
- **Default voice:** `cedar`. Use `marin` for a brighter tone.
- **Character limit:** 4096 characters per request.
- **Rate limit:** 50 requests per minute (CLI caps `--rpm 50`).

### Single‑clip workflow (Python)
```python
import openai, os
openai.api_key = os.getenv("OPENAI_API_KEY")

text = "Welcome to the demo. Today we'll show how it works."
resp = openai.audio.speech.create(
    model="gpt-4o-mini-tts-2025-12-15",
    voice="cedar",
    input=text,
    response_format="mp3"
)
# Save the audio file
with open("welcome.mp3", "wb") as f:
    f.write(resp.content)
```

### Batch workflow (JSONL)
1. Create a temporary JSONL file where each line contains:
   ```json
   {"input": "<text>", "voice": "<voice>", "response_format": "mp3", "out": "<filename>.mp3"}
   ```
2. Run the batch script (pseudo‑CLI shown below).
3. Delete the temporary file after completion.

```bash
python - <<'PY'
import json, openai, os, sys
openai.api_key = os.getenv('OPENAI_API_KEY')
batch_path = 'tmp/batch.jsonl'
with open(batch_path) as f:
    for line in f:
        job = json.loads(line)
        resp = openai.audio.speech.create(
            model='gpt-4o-mini-tts-2025-12-15',
            voice=job.get('voice','cedar'),
            input=job['input'],
            response_format=job.get('response_format','mp3')
        )
        out_path = os.path.join('output/speech', job['out'])
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        with open(out_path, 'wb') as out_f:
            out_f.write(resp.content)
PY
```

### Instruction augmentation template
Provide concise, labeled directions to the model. Do **not** rewrite the input text.
```
Voice Affect: <overall character, e.g., warm, authoritative>
Tone: <formality, friendliness>
Pacing: <slow, steady, brisk>
Emotion: <key emotions to convey>
Pronunciation: <words to enunciate>
Pauses: <where to insert intentional pauses>
Emphasis: <words/phrases to stress>
Delivery: <cadence or rhythm notes>
```
Only include lines that the user explicitly or implicitly requested.

### Atlas Cloud (optional)
- Activate only when the user selects it.
- Model: `xai/tts-v1`.
- Default voice: `eve`.
- Language: `auto`.
- Authentication via `ATLASCLOUD_API_KEY` environment variable.
- Submit a single POST request per clip; poll the provided URL with a finite timeout.
- Download the result without an Authorization header; reject non‑HTTPS URLs.

### Validation steps
1. Play the audio to confirm intelligibility.
2. Check pacing and pronunciation against the instruction spec.
3. Re‑run with a single changed parameter (voice, speed, or added instruction) if needed.
4. Save the final file under `output/speech/` with a descriptive name.

### Text‑to‑Speech best‑practice checklist
- Verify `OPENAI_API_KEY` (or `ATLASCLOUD_API_KEY`) is set before any call.
- Keep input ≤ 4096 characters; split longer text into logical chunks.
- Use the instruction template; limit to 4‑8 short lines.
- Prefer built‑in voices; custom voices are out of scope.
- Respect the 50 RPM limit; batch scripts should throttle automatically.
- Disclose to end users that the voice is AI‑generated.
- For critical clips, listen to the output before delivery.

---

## Common pitfalls
| Area | Symptom | Remedy |
|------|---------|--------|
| **Long audio (>30 min)** | Whisper accuracy drops, OOM on GPU. | Split into ≤ 30 min chunks; process sequentially.
| **Noisy background** | High word error rate. | Use a high‑quality microphone; apply noise‑reduction with `ffmpeg -af "highpass,fir"` before transcription.
| **Incorrect language detection** | Wrong script or poor translation. | Explicitly set `language` parameter when known.
| **Speaker diarization missing** | All speech appears as a single speaker. | Use OpenAI `gpt-4o-transcribe-diarize` model; Whisper cannot diarize.
| **TTS character limit exceeded** | API returns error. | Chunk text at sentence or paragraph boundaries before calling TTS.
| **Rate‑limit errors** | `429 Too Many Requests`. | Respect 50 RPM; add `time.sleep(1.2)` between calls in loops.
| **Voice not found** | Model returns fallback voice. | Use only voices listed in the provider’s documentation (`cedar`, `marin`, `eve`).
| **Missing API key** | Calls fail with authentication error. | Instruct user to create a key in the provider console and export it as an environment variable.

---

## Combined checklist
- **Environment**: `OPENAI_API_KEY` set (and `ATLASCLOUD_API_KEY` if needed).  
- **Audio format**: Convert to WAV PCM 16‑bit for Whisper; MP3/MP4 accepted by CLI.  
- **Model selection**: `turbo` for speed; larger Whisper models only if VRAM ≥ 10 GB.  
- **Language**: Specify when known; otherwise rely on auto‑detect.  
- **Initial prompt**: Add for technical vocab.  
- **Chunking**: ≤ 30 min for transcription, ≤ 4096 chars for TTS.  
- **GPU**: Use `device="cuda"` for Whisper when available.  
- **Diarization**: Choose OpenAI API model; Whisper cannot diarize.  
- **TTS instructions**: Use the concise template; do not rewrite the source text.  
- **Rate limits**: Keep ≤ 50 requests/minute; batch scripts should throttle.  
- **Validation**: Listen to TTS output; review transcript timestamps for completeness.  
- **Saving**: Store transcripts under `output/transcribe/` and audio clips under `output/speech/` with clear filenames.
- **Disclosure**: Inform end users that generated speech is AI‑synthesized.

## Related skills

Load these when the task spans more than this skill.

- [`voice-ai`](../voice-ai/SKILL.md) — The voice‑ai skill guides you to build low‑latency, production‑grade voice agents. It covers speech‑to‑speech…
- [`meeting-insights`](../meeting-insights/SKILL.md) — Analyzes meeting transcripts (txt, md, vtt, srt, docx) to reveal communication patterns, speaking ratios, fill…
- [`web-accessibility`](../web-accessibility/SKILL.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
- [`video-downloader`](../video-downloader/SKILL.md) — Downloads videos or audio from YouTube and other platforms. Choose resolution, format, single video, playlist,…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
