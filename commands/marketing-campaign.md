---
description: "Plan & execute marketing campaign (positioning→landing→email→social→ads→video→calendar) or audit copy; delegates to content-marketer."
allowed-tools: ["Read", "Grep", "Glob", "WebSearch", "WebFetch", "Write", "Agent"]
---
@CMD:marketing-campaign
§ARGS{
  ∅⇒prompt(brief)
  <brief>⇒full_campaign
  copy <type∈{landing-page,email-sequence,social-posts,ads,video-scripts}>⇒single(req:positioning_first)
  review <path|copy_text>⇒copy_audit
}
§FLOW{
  1:research(target_audience,competitors)
  2:lock(positioning,tone_profile)
  3:prod(landing-page→email-sequence→social-posts→ad-copy→video-scripts→content-calendar)
  4:gate(review_checklist)∧copy_review_summary
}
§BRIEF{
  Product:{name}
  Description:{1-3_sentences}
  Audience:{specific_segment}
  Problem:{specific_pain}
  Benefit:{user_outcome}
  Tone:{adjectives+avoid}
  Channels:{landing_page,email,LinkedIn,X,ads,video}
  Goal:{launch|waitlist|signups|awareness+timeline}
}
§GATE{
  review_audit∈{5s_clarity(above_fold),CTA(specific∧earned∧1/piece),brand_tone_consistency,claim_specificity_support,platform_native_fit,cross_channel_consistency}
}
§OUT{
  dir:".claude/campaigns/{campaign-name}/"
  files:[positioning.md,landing-page.md,email-sequence.md,social-posts.md,ad-copy.md,video-scripts.md,content-calendar.md]
  rule:confirm_save_location_before_write
}
§DELEG{
  agents:{content-marketer:plan+copy,researcher:audience+competitive_intel}
  refs:content-writing/references/{brand-voice,social-content,social-publishing,copywriting}.md
  rel:{/plan,/plan-prd,/code-review}
}
