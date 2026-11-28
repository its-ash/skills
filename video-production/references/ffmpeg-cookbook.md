@REF:ffmpeg-cookbook
§VER{baseline:FFmpeg_7.1_LTS(VVC_dec,xHE-AAC,Vulkan_enc)|8.0+(native`whisper`_filter,Vulkan_compute_FFv1/AV1,APV/ProRes_RAW)|9.x(`fruc_vulkan`_optflow)}
§R{
  1:use`-fps_mode:v`(passthrough|cfr|vfr|auto)¬deprecated`-vsync`;
  2:fast_seek⇒`-ss`PRE`-i`(keyframe_copy);frame_exact⇒re-encode(`-ss`POST`-i`∨2-step_seek);
  3:web_MP4⇒ALWAYS`-pix_fmt yuv420p -movflags +faststart`(Safari/iOS/browser_compat);
  4:master_loudness⇒2-pass`loudnorm`(`linear=true`);1-pass=draft_only;
  5:AV1_CPU⇒`libsvtav1`(`-preset 4..8`,`-crf 25..35`,`tune=0`,grain_synth_if_noisy)
}
§CMD{
  probe:`ffprobe -v error -show_format -show_streams -of json input.mp4`;
  cut_fast:`ffmpeg -ss 00:12:30 -to 00:15:45 -i raw.mp4 -c copy segment_01.mp4`;
  cut_exact:`ffmpeg -ss 00:12:30 -to 00:15:45 -i raw.mp4 -c:v libx264 -crf 18 -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 192k segment_01.mp4`;
  edl:`mkdir -p segments && while IFS=, read -r s e l; do ffmpeg -nostdin -ss "$s" -to "$e" -i raw.mp4 -c copy "segments/${l}.mp4"; done < cuts.txt` # start,end,label;
  concat:`for f in segments/*.mp4; do echo "file '$f'"; done > concat.txt && ffmpeg -f concat -safe 0 -i concat.txt -c copy assembled.mp4`;
  proxy:`ffmpeg -i raw.mp4 -vf "scale=960:-2" -c:v libx264 -preset ultrafast -crf 28 -pix_fmt yuv420p proxy.mp4`;
  webm2mp4:`ffmpeg -i demo.webm -c:v libx264 -crf 20 -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 128k demo.mp4`;
  av1_svt:`ffmpeg -i input.mp4 -c:v libsvtav1 -preset 6 -crf 28 -g 240 -svtav1-params tune=0:film-grain=18 -c:a libopus -b:a 128k output.mkv` # 1080p:crf25-32,4K:crf26-35;
  wav:`ffmpeg -i raw.mp4 -vn -acodec pcm_s16le -ar 16000 audio.wav`;
  whisper8:`ffmpeg -i input.mp4 -vn -af "highpass=f=200,lowpass=f=3000,whisper=model=ggml-base.bin" output.srt` # FFmpeg_8.0+`--enable-whisper`;
  loudnorm_draft:`ffmpeg -i segment.mp4 -af loudnorm=I=-16:TP=-1.5:LRA=11 -c:v copy normalized.mp4`;
  loudnorm_2pass:`ffmpeg -i in.mp4 -af loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json -f null -`→pass2:`loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=...:measured_TP=...:measured_LRA=...:measured_thresh=...:linear=true`;
  scenes:`ffmpeg -i input.mp4 -vf "select='gt(scene,0.3)',showinfo" -fps_mode:v vfr -f null - 2>&1|grep showinfo` # 0.3=mod;
  silence:`ffmpeg -i input.mp4 -af silencedetect=noise=-30dB:d=2 -f null - 2>&1|grep silence`;
  crop_9_16:`ffmpeg -i input.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" -c:v libx264 -crf 20 -pix_fmt yuv420p -movflags +faststart -c:a copy vertical.mp4`;
  crop_1_1:`ffmpeg -i input.mp4 -vf "crop=ih:ih,scale=1080:1080" -c:v libx264 -crf 20 -pix_fmt yuv420p -movflags +faststart -c:a copy square.mp4`
}
§SPECS{YT:16:9@1920x1080|3840x2160; TT_Reels_Shorts:9:16@1080x1920; IG:1:1@1080x1080|4:5@1080x1350; X:16:9@1280x720|1:1@720x720; smart:`video.reframe(...,mode=ReframeMode.smart)`→videodb.md}
§PROMPT{4h_transcript→8_segs_24m_vlog+ffmpeg_cuts; ts_transcript+scene_pts→5x30s_social}
§API{
  elevenlabs_rest:POST `https://api.elevenlabs.io/v1/text-to-speech/{voice_id}` `xi-api-key:$ELEVENLABS_API_KEY` `{text,model_id:"eleven_v3",voice_settings:{stability:0.5,similarity_boost:0.75}}` `timeout=60`→`voiceover.mp3` # expressive:`eleven_v3`(70+langs,inline_tags:`[whispers]`,`[laughs]`);low_lat/bulk:`eleven_flash_v2_5`(~75ms,32_langs);MCP:`uvx elevenlabs-mcp`;
  fal_thumb:`generate(app_id:"fal-ai/nano-banana-pro",input_data:{prompt,image_size:"landscape_16_9"})`
}
§ANTI{¬`-vsync`(use`-fps_mode:v`); ¬`-c copy`_for_subsec_or_beat_cuts; ¬omit`yuv420p`+`faststart`_for_web_MP4; ¬1-pass`loudnorm`_on_final_master; ¬`eleven_turbo_v2_5`(use`eleven_v3`|`eleven_flash_v2_5`)}
§REL{fal-ai-media.md:music/SFX/ThinkSound/ElevenLabs_MCP/cost; videodb.md:generate_voice/music/sound_effect,reframe; ui-demo.md:Playwright_WebM_capture}
