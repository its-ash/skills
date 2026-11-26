@REF:brand-voice
§D{
  use∈{X,LinkedIn,email,launch,threads,updates,outreach};
  goal:reusable_sys(¬mimic,¬re_derive,¬generic_AI);
  src_prio:[1:orig_X_posts_threads,2:articles|essays|memos|launch|newsletters,3:replied_emails|DMs,4:docs|changelogs|README|site];
  ¬generic_platform_ex
}
§PAT{
  collect:samples(5..20)→recent(older_iff_canonical)→split⇒sep("public launch voice","private working voice")→live_X⇒orig_first([social-publishing.md](social-publishing.md))→site_imp⇒incl_landing+framing;
  extract:{rhythm_len,comp_vs_expl,caps,parens,Q_freq_purpose,claim_sharp,freq(num|mech|receipt),trans,never_does};
  default_op(∅_refs|thin):{direct,compressed,concrete,{spec,mech,receipt,num}>adj,parens∈{qualify,narrow,clarify}(¬joke),conv_caps,Q_rare∧¬bait,tone∈{sharp,blunt,skeptical,dry},earned_trans}
}
§OUT{
  contract:bullets(¬prose),operational(¬lit_crit),src_backed,banned∈{src|req},conflict⇒split(¬avg);
```text
VOICE PROFILE
Author: | Goal: | Confidence: | Source Set: s1..s3
Rhythm: | Compression: | Capitalization: conv|mixed|sit
Parentheticals: | Question Use: rare|freq|rhet|dir|absent
Claim Style: | Preferred Moves: | Banned Moves: | CTA Rules:
Channel Notes: X: | LinkedIn: | Email:
```
}
§ANTI{
  del_rewrite∀workflow:["In today's rapidly evolving landscape"&openers,"game-changer"|"revolutionary"|"cutting-edge"|"world-class","here's why this matters"(bridge),"Excited to share"|"Here's what I learned"|"I'd love to connect","not X, just Y"|"no fluff",curiosity_hooks|bait_Q("What do you think?"),reply_bait_closing_Q,forced_lower|casual,LinkedIn_thought_leader|praise_stack|"journey"_filler,fake_vuln|founder_journey,corny_parens,bio_pad_¬arg,fake_urgency_wo_deadline,unspec_proof("thousands trust us")]
}
§R{persist:reuse_session_VOICE_PROFILE;durable⇒user_path;¬repo_fingerprint_unless_req;source_of_truth_overrides_partial}
§REL{[article-writing.md](article-writing.md);[social-content.md](social-content.md);[lead-intelligence.md](lead-intelligence.md);[investor-materials.md](investor-materials.md);[marketing-campaign.md](marketing-campaign.md)}
