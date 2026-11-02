# FFmpeg cookbook and asset snippets

## Cuts and assembly
```bash
# Segment by timestamp (keyframe-accurate only; re-encode with -c:v libx264 -c:a aac for frame-exact)
ffmpeg -i raw.mp4 -ss 00:12:30 -to 00:15:45 -c copy segment_01.mp4

# Batch cut from EDL (cuts.txt: start,end,label)
mkdir -p segments
while IFS=, read -r start end label; do
  ffmpeg -nostdin -i raw.mp4 -ss "$start" -to "$end" -c copy "segments/${label}.mp4"
done < cuts.txt

# Concatenate
for f in segments/*.mp4; do echo "file '$f'"; done > concat.txt
ffmpeg -f concat -safe 0 -i concat.txt -c copy assembled.mp4
```

## Prep
```bash
ffmpeg -i raw.mp4 -vf "scale=960:-2" -c:v libx264 -preset ultrafast -crf 28 proxy.mp4   # edit proxy
ffmpeg -i raw.mp4 -vn -acodec pcm_s16le -ar 16000 audio.wav                             # audio for transcription
ffmpeg -i segment.mp4 -af loudnorm=I=-16:TP=-1.5:LRA=11 -c:v copy normalized.mp4        # loudness normalize
```

## Detect scenes and silence
```bash
ffmpeg -i input.mp4 -vf "select='gt(scene,0.3)',showinfo" -vsync vfr -f null - 2>&1 | grep showinfo  # 0.3 = moderate
ffmpeg -i input.mp4 -af silencedetect=noise=-30dB:d=2 -f null - 2>&1 | grep silence                 # dead air
```

## Reframe for platforms
| Platform | Aspect | Resolution |
|---|---|---|
| YouTube | 16:9 | 1920x1080 |
| TikTok / Reels | 9:16 | 1080x1920 |
| Instagram feed | 1:1 | 1080x1080 |
| X | 16:9 or 1:1 | 1280x720 or 720x720 |

```bash
ffmpeg -i input.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" vertical.mp4   # 16:9 → 9:16 center crop
ffmpeg -i input.mp4 -vf "crop=ih:ih,scale=1080:1080" square.mp4          # 16:9 → 1:1 center crop
```
Subject-tracking reframe: VideoDB `video.reframe(..., mode=ReframeMode.smart)` ([videodb.md](videodb.md)).

## Planning prompts
- "Here is the transcript of a 4-hour recording. Identify the 8 strongest segments for a 24-minute vlog. Give FFmpeg cut commands for each."
- "Given this timestamped transcript and these scene-change points, identify the 5 most engaging 30-second clips for social media."

## ElevenLabs voiceover
```python
import os, requests
resp = requests.post(
    f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
    headers={"xi-api-key": os.environ["ELEVENLABS_API_KEY"], "Content-Type": "application/json"},
    json={"text": text, "model_id": "eleven_turbo_v2_5",
          "voice_settings": {"stability": 0.5, "similarity_boost": 0.75}},
    timeout=60,
)
resp.raise_for_status()
open("voiceover.mp3", "wb").write(resp.content)
```

## fal.ai still (thumbnail / b-roll)
```
generate(app_id: "fal-ai/nano-banana-pro", input_data: {
  "prompt": "professional thumbnail for tech vlog, dark background, code on screen",
  "image_size": "landscape_16_9"})
```
Music, SFX, ThinkSound video-to-audio, cost checks: [fal-ai-media.md](fal-ai-media.md). VideoDB `generate_voice` / `generate_music` / `generate_sound_effect`: [videodb.md](videodb.md).
