---
name: video-downloader
description: "Downloads videos or audio from YouTube and other platforms, choosing resolution, format, single video, playlist, or batch, while preserving metadata and thumbnails for offline use. Use when downloading YouTube videos, saving MP3 audio, fetching playlists, batch downloading URLs, extracting subtitles, or archiving media with yt-dlp, ffmpeg, MP4, WebM, M4A, and subtitles."
---

# Video Downloader

Download videos or audio from YouTube and other supported platforms. Select resolution, format, and output location. Preserve title, description, and thumbnail.

## When to Use
- Need a video for offline viewing or editing.
- Want to archive educational or reference material.
- Require audio‑only files for podcasts or music.
- Need to download an entire playlist or a list of URLs.
- Want to keep original metadata (title, description, thumbnail).

## Workflow
1. **Collect URLs** – Gather one or more video URLs or a playlist URL.
2. **Decide output** – Choose resolution (e.g., 480p, 720p, 1080p, 4K) and format (MP4, WebM, MP3).
3. **Run command** – Use `yt-dlp` (or `youtube-dl`) with flags that match the chosen output.
4. **Verify** – Check the console for a success message, file size, and saved thumbnail.
5. **Organize** – Move files to a dedicated folder for easy access.

## Command Patterns
### Single Video – Default Best Quality
```bash
yt-dlp -f "best" -o "%(title)s.%(ext)s" "<VIDEO_URL>"
```
### Specific Resolution (e.g., 1080p)
```bash
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
       -o "%(title)s.%(ext)s" "<VIDEO_URL>"
```
### Audio‑Only MP3
```bash
yt-dlp -x --audio-format mp3 -o "%(title)s.%(ext)s" "<VIDEO_URL>"
```
### Playlist Download
```bash
yt-dlp -i -o "%(playlist_index)s - %(title)s.%(ext)s" "<PLAYLIST_URL>"
```
### Batch Download from a Text File
Create `urls.txt` with one URL per line, then run:
```bash
yt-dlp --batch-file urls.txt -o "%(title)s.%(ext)s"
```
### Preserve Thumbnail and Metadata
Add `--write-thumbnail --write-description` to any command to save the thumbnail image and description file alongside the video.

## Rules & Best Practices
- **Legal compliance**: Download only content you own or have explicit permission to use. Respect copyright law and platform terms of service.
- **Use a dedicated folder**: Store downloads in a separate directory to avoid clutter.
- **Check file size**: High resolutions generate large files; verify available disk space before starting.
- **Update the tool**: Keep `yt-dlp` up to date (`pip install -U yt-dlp`) to handle site changes.
- **Avoid re‑downloading**: Use `-c` (continue) to resume interrupted downloads and skip already completed files.

## Common Pitfalls
- **Age‑restricted or region‑locked videos** may require cookies or a logged‑in session.
- **4K videos** often split video and audio streams; the command above merges them automatically, but ensure `ffmpeg` is installed.
- **Rate limiting**: Excessive requests can trigger temporary bans; add `--sleep-interval` if downloading many videos.
- **Playlist changes**: If a playlist is modified during download, some videos may be missed; run the command again to capture new entries.

## Checklist
- [ ] URL(s) are correct and accessible.
- [ ] Desired resolution and format are selected.
- [ ] Output directory is set and has enough space.
- [ ] Legal right to download the content is confirmed.
- [ ] `yt-dlp` (or `youtube-dl`) is installed and up to date.
- [ ] Optional flags (`--write-thumbnail`, `--write-description`) are added if metadata is needed.
- [ ] Verify the download completed without errors.

## Related skills

Load these when the task spans more than this skill.

- [`speech-audio`](../speech-audio/SKILL.md) — Skill for robust speech‑audio processing: transcribe audio (Whisper or OpenAI API, with optional diarization)…
- [`file-organization`](../file-organization/SKILL.md) — Organizes files and folders intelligently: analyzes directory structure, finds duplicates, proposes logical fo…
- [`web-scraping-apis`](../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
- [`bash-scripting`](../bash-scripting/SKILL.md) — Bash Scripting – a concise guide for writing safe, production‑ready Bash scripts on Linux/macOS. Includes comm…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`sora`](../sora/SKILL.md) — Generates, remixes, polls, lists, downloads, or deletes short Sora videos via OpenAI’s video API using the `so…
