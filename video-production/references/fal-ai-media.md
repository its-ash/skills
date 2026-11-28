@REF:fal-ai-media
§WARN{drift_prone:model_ids,pricing,inputs,MCP_pkgs Δ fast ⇒ ALWAYS`search`/`find` current metadata pre-promising model|slug|param|cost}
§WHEN{T2I|I2I|T2V|I2V|TTS|music|SFX|V2A|thumbnail|media_gen}
§CFG{
  fal_mcp:`"fal-ai":{"command":"npx","args":["-y","fal-ai-mcp"],"env":{"FAL_KEY":"YOUR_FAL_KEY"}}` # alt:`fal-ai-mcp-server`; url:"https://fal.ai";
  elevenlabs_mcp_local:`"ElevenLabs":{"command":"uvx","args":["elevenlabs-mcp"],"env":{"ELEVENLABS_API_KEY":"YOUR_KEY"}}`;
  elevenlabs_mcp_remote:`"ElevenLabs":{"url":"https://api.elevenlabs.io/v1/mcp"}` # hosted+OAuth
}
§MCP_TOOLS{
  fal:{search:find_models_by_keyword; find:model_details+params; generate:run_model; result:async_status; status:job_status; cancel:stop_job; estimate_cost:cost_est; models:popular_list; upload:local_file→input_url};
  elevenlabs:{TTS,voice_design,voice_library,audio_processing}
}
§IMG{
  nano_banana:{fast:"fal-ai/nano-banana-2"(drafts,T2I,edit), hi_fi:"fal-ai/nano-banana-pro"(prod,realism,sharp_text,reasoning)};
  flux:{family:"Black_Forest_Labs_FLUX(FLUX.2|FLUX.3|flux/schnell|flux-pro)", discover:`search(query:"flux")`};
  params:{prompt:str_req,image_size∈{square,portrait_4_3,landscape_16_9,portrait_16_9,landscape_4_3},num_images:1..4,seed:int,guidance_scale:1..20(higher=literal)};
  edit:`upload(file_path)`→`generate(app_id:"fal-ai/nano-banana-2",input_data:{prompt,image_url:"<url>",image_size})`
}
§VID{
  veo:{model:"Google_Veo_3/3.1", slug:"fal-ai/veo3.1"(verify:`search(query:"veo")`), caps:1080p+native_sync_audio+T2V/I2V};
  kling:{model:"Kling_3.0/4.0", discover:`search(query:"kling-video")`, caps:multi_shot+start/end_frame+native_audio+extended_dur};
  seedance:{model:"Seedance_2.x(up_to_2.5)", discover:`search(query:"seedance")`, caps:continuous_long_single_clip+hi_motion};
  other:{Wan:"2.7/3.0", MiniMax:"H3_Max", FLUX_I2V:"FLUX_3", discover:`search(query:"text to video")`};
  params:{prompt:str_req,duration:model_dep(check`find`),aspect_ratio∈{"16:9","9:16","1:1"},seed:int,image_url:url(I2V)}
}
§AUD{
  elevenlabs_models:{
    expressive:"eleven_v3"(flagship,70+langs,multi-speaker,inline_tags:`[whispers]`,`[laughs]`,`[sighs]`,`[excited]`;also_fal:`fal-ai/elevenlabs/tts/eleven-v3`);
    realtime_bulk:"eleven_flash_v2_5"(~75-100ms_lat,32_langs,lower_cost)
  };
  elevenlabs_rest_fallback:```python
resp = requests.post(f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
  headers={"xi-api-key":os.environ["ELEVENLABS_API_KEY"],"Content-Type":"application/json"},
  json={"text":txt,"model_id":"eleven_v3","voice_settings":{"stability":0.5,"similarity_boost":0.75}},timeout=60)
open("output.mp3","wb").write(resp.content)
```;
  fal_tts:"fal-ai/csm-1b"{text,speaker_id:0};
  fal_v2a:"fal-ai/thinksound"{video_url,prompt};
  videodb:{`coll.generate_voice(text=...,voice="alloy")`,`coll.generate_music(prompt=...,duration=30)`,`coll.generate_sound_effect(prompt=...)`}
}
§CMD{
  cost:`estimate_cost(estimate_type:"unit_price",endpoints:{"fal-ai/nano-banana-pro":{"unit_quantity":1}})`;
  discover:`search(query:"text to video")`, `find(endpoint_ids:["fal-ai/veo3.1"])`, `models()`
}
§R{
  1:use`seed`for_reproducibility;
  2:iterate_cheap(Nano_Banana_2|FLUX_schnell)→final_hi_fi(Nano_Banana_Pro|FLUX_Pro);
  3:video_prompts_concise+focus_motion&scene; I2V>T2V_control;
  4:run`search`+`find`+`estimate_cost`_pre_expensive_video;
  5:prefer`elevenlabs-mcp`(local`uvx`|remote_OAuth)_or`eleven_v3`/`eleven_flash_v2_5`¬legacy`eleven_turbo_v2_5`;
  6:COST+PRIVACY_GATE⇒get_user_approval_pre_paid_run∨upload_of_private_media(sends_data→fal.ai|ElevenLabs)
}
§ANTI{¬hardcode_unverified_fal_slugs; ¬skip`estimate_cost`_on_video; ¬`eleven_turbo_v2_5`(use`eleven_v3`|`eleven_flash_v2_5`); ¬upload_private_footage_without_consent}
§REL{
  ../SKILL.md:edit_real_footage_gen_only_missing;
  visual-taste.md:distill_ref_aesthetic_pre_prompt;
  ../../content-writing/references/social-content.md:platform_native_posts
}
