---
name: voice-ai
description: "This skill teaches building low-latency production voice agents using speech-to-speech via OpenAI Realtime API or pipeline architectures combining Deepgram STT, any LLM inference, and ElevenLabs TTS or Vapi hosted phone agents with voice activity detection and turn-taking logic. Use when implementing voice activity detection VAD turn-taking barge-in interruption handling latency budgeting streaming audio real-time transcription speech synthesis phone-based conversational assistants OpenAI Realtime API Deepgram STT ElevenLabs TTS Vapi WebSocket audio streaming speech-to-text text-to-speech conversational AI voice bots assistants."
---

# Voice AI Development

Create voice agents that feel natural and responsive. Use this skill when you need real‑time speech interaction, phone‑based assistants, or custom pipelines that combine transcription, language models, and speech synthesis.

## When to Use
- You need sub‑800 ms round‑trip latency for a conversational experience.
- You want to process audio directly (speech‑to‑speech) or control each stage (STT → LLM → TTS).
- Your application runs on Python or Node.js and can call external APIs.
- You must handle interruptions, background noise, and turn‑taking.

---

## Architecture Overview
| Architecture | Latency | Control | Typical Use |
|---|---|---|---|
| **Speech‑to‑Speech (S2S)** | Lowest (single round‑trip) | Low | Quick prototypes, when emotion preservation matters |
| **Pipeline** | Higher (STT + LLM + TTS) | High | Need custom prompts, tool calls, or multi‑modal logic |

Both architectures require a **latency budget**. Measure each component and keep the total under 800 ms for a smooth conversation.

---

## Latency Budgeting
1. **Measure** round‑trip time of each API (use a stopwatch or `time` command).
2. **Allocate** budget:
   - Network round‑trip: ≤ 100 ms
   - STT processing: ≤ 150 ms
   - LLM inference: ≤ 300 ms
   - TTS synthesis: ≤ 150 ms
3. **Monitor** jitter. Aim for < 30 ms variance.
4. **Optimize** by:
   - Using streaming endpoints.
   - Reducing audio sample rate to 16 kHz PCM16 when possible.
   - Selecting the fastest model tier that meets quality needs.

---

## Speech‑to‑Speech with OpenAI Realtime API
Use the OpenAI Realtime API for a single WebSocket that handles transcription, LLM reasoning, and synthesis.

```python
import asyncio, websockets, json, base64

OPENAI_API_KEY = "sk-..."

async def realtime_voice():
    url = "wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview"
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "OpenAI-Beta": "realtime=v1"
    }
    async with websockets.connect(url, extra_headers=headers) as ws:
        # Configure session
        await ws.send(json.dumps({
            "type": "session.update",
            "session": {
                "modalities": ["audio"],
                "voice": "alloy",
                "input_audio_format": "pcm16",
                "output_audio_format": "pcm16",
                "turn_detection": {
                    "type": "server_vad",
                    "threshold": 0.5,
                    "prefix_padding_ms": 300,
                    "silence_duration_ms": 500
                }
            }
        }))

        async def send_audio(chunk: bytes):
            await ws.send(json.dumps({
                "type": "input_audio_buffer.append",
                "audio": base64.b64encode(chunk).decode()
            }))

        # Example: stream microphone audio here (omitted for brevity)
        # await send_audio(mic_chunk)

        async for message in ws:
            event = json.loads(message)
            if event["type"] == "response.audio.delta":
                audio = base64.b64decode(event["audio"])
                # Play audio to speaker (implementation dependent)

asyncio.run(realtime_voice())
```

**Key points**
- Set `turn_detection.type` to `server_vad` for server‑side VAD.
- Use PCM16, 16 kHz, mono audio for minimal payload.
- The API streams partial audio (`response.audio.delta`) so the user hears speech before the LLM finishes.

---

## Pipeline Architecture
### 1. Real‑time Transcription with Deepgram
```python
import asyncio
from deepgram import DeepgramClient, LiveTranscriptionEvents

deepgram = DeepgramClient(api_key="DG_API_KEY")

async def transcribe(stream):
    conn = deepgram.listen.live.v("1")

    async def on_transcript(event):
        text = event.channel.alternatives[0].transcript
        if text:
            print("Heard:", text)
            if event.is_final:
                await handle_user_input(text)

    conn.on(LiveTranscriptionEvents.Transcript, on_transcript)

    await conn.start({
        "model": "nova-2",
        "language": "en",
        "smart_format": True,
        "interim_results": True,
        "utterance_end_ms": 1000,
        "vad_events": True,
        "encoding": "linear16",
        "sample_rate": 16000
    })

    async for chunk in stream:
        await conn.send(chunk)
    await conn.finish()
```
- Enable `interim_results` to receive partial transcripts.
- `vad_events` provides voice‑activity timestamps useful for turn‑taking.

### 2. Language Model Inference (any LLM)
Stream tokens from the LLM to reduce perceived latency. Example using OpenAI Chat Completion:
```python
import openai, asyncio

async def stream_llm(prompt):
    response = await openai.ChatCompletion.acreate(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        stream=True
    )
    async for chunk in response:
        if "content" in chunk["choices"][0]["delta"]:
            yield chunk["choices"][0]["delta"]["content"]
```
- Forward each token to the TTS step as soon as it arrives.

### 3. Speech Synthesis with ElevenLabs
```python
from elevenlabs import ElevenLabs

eleven = ElevenLabs(api_key="ELEVEN_API_KEY")

def stream_tts(text_iter):
    for chunk in text_iter:
        audio_stream = eleven.text_to_speech.convert_as_stream(
            voice_id="21m00Tcm4TlvDq8ikWAM",  # Rachel
            model_id="eleven_turbo_v2_5",
            text=chunk,
            output_format="pcm_24000"
        )
        for audio in audio_stream:
            yield audio
```
- Use `pcm_24000` for low‑latency raw PCM.
- Yield audio chunks immediately; the caller can play them while the LLM continues.

### 4. Barge‑in Detection
```python
# Pseudocode for interrupt handling
if vad.detect_user_speech():
    tts.stop()          # Cancel current audio output
    audio_queue.clear() # Remove pending chunks
    # Optionally restart STT to capture the interruption
```
- Use the same VAD that powers Deepgram or the server VAD in OpenAI Realtime.
- Stop TTS instantly to avoid talking over the user.

---

## Vapi Phone‑Based Voice Agent (Hosted Solution)
Vapi hosts the full pipeline and provides a Webhook for events.
```python
from flask import Flask, request, jsonify
import vapi

app = Flask(__name__)
client = vapi.Vapi(api_key="VAPI_KEY")

assistant = client.assistants.create(
    name="Support Agent",
    model={"provider": "openai", "model": "gpt-4o"},
    voice={"provider": "11labs", "voiceId": "21m00Tcm4TlvDq8ikWAM"},
    transcriber={"provider": "deepgram", "model": "nova-2"},
    firstMessage="Hi! How can I help you today?"
)

@app.route("/vapi/webhook", methods=["POST"])
def webhook():
    ev = request.json
    if ev["type"] == "function-call":
        name = ev["functionCall"]["name"]
        args = ev["functionCall"]["parameters"]
        if name == "check_order":
            result = check_order(args["order_id"])
            return jsonify({"result": result})
    elif ev["type"] == "end-of-call-report":
        transcript = ev["transcript"]
        save_transcript(ev["call"]["id"], transcript)
    return jsonify({"ok": True})

# Start an outbound call
client.calls.create(
    assistant_id=assistant.id,
    customer={"number": "+1234567890"},
    phoneNumber={"twilioPhoneNumber": "+0987654321"}
)
```
- Vapi handles scaling, telephony, and WebRTC endpoints.
- Use the webhook to process tool calls and store transcripts.

---

## Voice Activity Detection (VAD) & Turn‑Taking
- **Server VAD** (`type: server_vad`) works for OpenAI Realtime.
- **Deepgram VAD** (`vad_events: true`) emits `start` and `end` timestamps.
- **Threshold**: 0.5 works for typical office noise; adjust per environment.
- **Prefix padding**: 300 ms of audio before speech helps the model capture the first words.
- **Silence duration**: 500 ms signals the end of a turn.
- Implement a state machine:
  1. **Listening** – VAD active, no audio playing.
  2. **Speaking** – TTS output active.
  3. **Interrupted** – VAD fires while speaking; stop TTS and switch to Listening.

---

## Anti‑Patterns and How to Avoid Them
| Anti‑Pattern | Why It Fails | Remedy |
|---|---|---|
| Non‑streaming pipeline | Adds seconds of latency; breaks conversation flow | Stream STT interim results, stream LLM tokens, stream TTS chunks |
| Ignoring interruptions | User must wait for the agent to finish speaking | Detect barge‑in with VAD, stop TTS immediately, clear audio queue |
| Single‑provider lock‑in | Limits quality, creates single point of failure | Mix providers: Deepgram for STT, ElevenLabs for TTS, OpenAI/Anthropic for LLM |
| Long LLM responses | Increases latency and may exceed turn budget | Constrain response length in prompts; ask LLM to speak concisely |
| Silence‑only turn detection | Misinterprets pauses as end of user turn | Use VAD with both energy threshold and minimum speech duration |

---

## Checklist for Production Voice Agents
- [ ] Define a **latency budget** and measure each component.
- [ ] Choose architecture: **S2S** for lowest latency, **pipeline** for custom control.
- [ ] Enable **streaming** at every stage (STT, LLM, TTS).
- [ ] Configure **server VAD** or provider VAD with appropriate thresholds.
- [ ] Implement **barge‑in**: stop TTS on user speech detection.
- [ ] Limit LLM response length; add a prompt instruction like "Reply in ≤ 30 words."
- [ ] Test under realistic network conditions (cellular, Wi‑Fi, high latency).
- [ ] Monitor **jitter** and **error rates**; set alerts for latency spikes.
- [ ] Log raw audio, transcripts, and LLM outputs for debugging.
- [ ] Secure all API keys; rotate regularly.
- [ ] Verify compliance with privacy regulations for recorded speech.

---

## Related Skills
- `agent-tool-builder` – add function calling to voice agents.
- `multi-agent-orchestration` – coordinate several voice agents.
- `latency-optimisation` – deeper dive into network and compute latency.
- `structured-output` – enforce JSON responses from LLMs for downstream processing.

## Related skills

Load these when the task spans more than this skill.

- [`speech-audio`](../speech-audio/SKILL.md) — Skill for robust speech‑audio processing: transcribe audio (Whisper or OpenAI API, with optional diarization)…
- [`twilio`](../twilio/SKILL.md) — Implements Twilio communication features: sending SMS, performing phone/email verification with Verify, and bu…
- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
