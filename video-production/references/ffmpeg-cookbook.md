@REF:ffmpeg-cookbook
§CMD{
  cut:`ffmpeg -i raw.mp4 -ss 00:12:30 -to 00:15:45 -c copy segment_01.mp4` # frame-exact:`-c:v libx264 -c:a aac`
  edl:`mkdir -p segments && while IFS=, read -r s e l; do ffmpeg -nostdin -i raw.mp4 -ss "$s" -to "$e" -c copy "segments/${l}.mp4"; done < cuts.txt` # start,end,label
  concat:`for f in segments/*.mp4; do echo "file '$f'"; done > concat.txt && ffmpeg -f concat -safe 0 -i concat.txt -c copy assembled.mp4`
  proxy:`ffmpeg -i raw.mp4 -vf "scale=960:-2" -c:v libx264 -preset ultrafast -crf 28 proxy.mp4`
  wav:`ffmpeg -i raw.mp4 -vn -acodec pcm_s16le -ar 16000 audio.wav`
  loudnorm:`ffmpeg -i segment.mp4 -af loudnorm=I=-16:TP=-1.5:LRA=11 -c:v copy normalized.mp4`
  scenes:`ffmpeg -i input.mp4 -vf "select='gt(scene,0.3)',showinfo" -vsync vfr -f null - 2>&1|grep showinfo` # 0.3=mod
  silence:`ffmpeg -i input.mp4 -af silencedetect=noise=-30dB:d=2 -f null - 2>&1|grep silence`
  crop_9_16:`ffmpeg -i input.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" vertical.mp4`
  crop_1_1:`ffmpeg -i input.mp4 -vf "crop=ih:ih,scale=1080:1080" square.mp4`
}
§SPECS{YT:16:9@1920x1080; TT_Reels:9:16@1080x1920; IG:1:1@1080x1080; X:16:9@1280x720|1:1@720x720; smart:`video.reframe(...,mode=ReframeMode.smart)`→videodb.md}
§PROMPT{4h_transcript→8_segs_24m_vlog+ffmpeg_cuts; ts_transcript+scene_pts→5x30s_social}
§API{
  elevenlabs:POST `https://api.elevenlabs.io/v1/text-to-speech/{voice_id}` `xi-api-key:$ELEVENLABS_API_KEY` `{text,model_id:"eleven_turbo_v2_5",voice_settings:{stability:0.5,similarity_boost:0.75}}` `timeout=60`→`voiceover.mp3`
  fal_thumb:`generate(app_id:"fal-ai/nano-banana-pro",input_data:{prompt,image_size:"landscape_16_9"})`
}
§REL{fal-ai-media.md:music/SFX/ThinkSound/cost; videodb.md:generate_voice/music/sound_effect,reframe}
