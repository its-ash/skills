@REF:fal-ai-media
§WARN{drift_prone:model_ids,pricing,inputs,MCP_tools Δ fast ⇒ `search`/`find` current metadata pre-promising model|param|format|cost}
§WHEN{T2I|I2I|T2V|I2V|TTS|music|SFX|V2A|thumbnail|media_gen}
§CFG{
  file:"~/.claude.json",url:"https://fal.ai";
  `"fal-ai":{"command":"npx","args":["-y","fal-ai-mcp-server"],"env":{"FAL_KEY":"YOUR_FAL_KEY_HERE"}}`
}
§MCP_TOOLS{
  search:find_models_by_keyword; find:model_details+params; generate:run_model; result:async_status; status:job_status; cancel:stop_job; estimate_cost:cost_est; models:popular_list; upload:local_file→input_url
}
§IMG{
  fast:"fal-ai/nano-banana-2"(drafts,T2I,edit)∧hi_fi:"fal-ai/nano-banana-pro"(prod,realism,typography,detailed);
  params:{prompt:str_req,image_size∈{square,portrait_4_3,landscape_16_9,portrait_16_9,landscape_4_3},num_images:1..4,seed:int,guidance_scale:1..20(higher=literal)};
  edit:`upload(file_path)`→`generate(app_id:"fal-ai/nano-banana-2",input_data:{prompt,image_url:"<url>",image_size})`
}
§VID{
  seedance:"fal-ai/seedance-1-0-pro"(ByteDance;T2V/I2V_hi_motion);
  kling:"fal-ai/kling-video/v3/pro"(T2V/I2V+native_audio);
  veo3:"fal-ai/veo-3"(GoogleDeepMind;gen_sound+hi_qual);
  params:{prompt:str_req,duration∈{"5s","10s"},aspect_ratio∈{"16:9","9:16","1:1"},seed:int,image_url:url(I2V)}
}
§AUD{
  tts_fal:"fal-ai/csm-1b"{text,speaker_id:0};
  v2a_fal:"fal-ai/thinksound"{video_url,prompt};
  elevenlabs_rest(no_MCP):```python
resp = requests.post(f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
  headers={"xi-api-key":os.environ["ELEVENLABS_API_KEY"],"Content-Type":"application/json"},
  json={"text":txt,"model_id":"eleven_turbo_v2_5","voice_settings":{"stability":0.5,"similarity_boost":0.75}})
open("output.mp3","wb").write(resp.content)
```
  videodb:{`coll.generate_voice(text=...,voice="alloy")`,`coll.generate_music(prompt=...,duration=30)`,`coll.generate_sound_effect(prompt=...)`}
}
§CMD{
  cost:`estimate_cost(estimate_type:"unit_price",endpoints:{"fal-ai/nano-banana-pro":{"unit_quantity":1}})`;
  discover:`search(query:"text to video")`, `find(endpoint_ids:["fal-ai/seedance-1-0-pro"])`, `models()`
}
§R{
  1:use `seed` for reproducibility;
  2:iterate w/ Nano Banana 2 → final w/ Nano Banana Pro;
  3:video prompts concise+focus motion&scene; I2V>T2V control;
  4:run `estimate_cost` pre-expensive video;
  5:COST+PRIVACY_GATE⇒get user approval pre-paid run ∨ upload of private media(sends data→fal.ai)
}
§REL{
  ../SKILL.md:edit_real_footage_gen_only_missing;
  visual-taste.md:distill_ref_aesthetic_pre_prompt;
  ../../content-writing/references/social-content.md:platform_native_posts
}
