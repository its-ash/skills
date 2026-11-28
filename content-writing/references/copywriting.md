@REF:copywriting
§D{
  pages∈{homepage,landing,pricing,feature,about,product};trig∈{"write copy for","improve this copy","headline help","CTA copy"};
  ctx_pre:{purpose:{type,1°_act,2°_act?},aud:{ICP,prob,tried,obj,cust_words},offer:{prod,diff,outcome,proof[num,quote,case]},ctx:{traffic[ads,org,email,AI_ref],prior_know,pre_msg}}
}
§R{
  1:clarity>clever;2:benefits>features;3:spec>vague("save time"→"cut weekly reporting from 4h to 15m");4:cust_lang>co_lang(reviews,tickets,interviews);5:1_idea/sec+flow;
  6:5s_test+GEO_clarity⇒hero_explicitly_names(category+ICP+outcome)so_humans_AND_AI_answers_extract_what_it_is;
  7:bans(brand-voice.md)∧¬dark_patterns(fake_countdowns,hidden_pricing_traps,manufactured_scarcity);
  style:{simple("use"¬"utilize"),active("We generate reports"¬"Reports are generated"),¬hedge("almost"|"very"|"really"),outcomes("Generate more leads by seeing which companies visit your site"),¬fabricate(stats,quotes)};
  scan:{¬jargon,conj≤3/sent,¬passive,¬"!",¬buzz("innovative"|"streamline"_wo_meaning)}
}
§PAT{
  above_fold:{hl:1_msg+spec+val,sub:2nd_ben|scope(1-2s),cta:act+gain("Start Free Trial"|"Get My Report"),vis:screenshot|demo|hero};
  hl_formulas:["{Achieve desirable outcome} without {pain point}","The {opposite of usual process} way to {outcome}","Never {unpleasant event} again","{Product type} for {target audience}","You don’t have to {skill} to {outcome}","{Achieve outcome} by {how product helps}","{Question highlighting pain}","Turn {input} into {outcome}","(Optional) {Achieve outcome} in {timeframe}"];
  body(3..5):[1:proof_bar(logos|metric|quote),2:prob_pain(before),3:sol_ben(3-5×{hl,1-2s,proof?}),4:how_it_works(3-4×{act→out}),5:det_proof(name,role,co,res),6:obj(FAQ|cmp|guarantee),7:final_cta(val+cta+honest_urgency|risk_rev)];
  cta:{weak∈{"Submit","Learn More","Click Here"},strong∈{"Start Free Trial","Get My Checklist","See the Demo","Book My Demo","Download the Guide"},formula:"[Action verb] + [What they get] + (opt qualifier)"};
  7_sweep(seq):[1:Clarity(rewrites),2:Voice_Tone(smooth),3:So_What(ben_bridge),4:Prove_It(quotes|stats|cases|guar|soften),5:Spec(nums|time|ex),6:Emotion(sensory|micro_story|rhet_Q),7:Zero_Risk(near_CTA:obj,trust,money_back|free_trial|no_cc)]→proof(gram,typo,fmt)
}
§ANTI{clever_vague_hero;unverified_proof;fake_urgency|dark_patterns;generic_CTA;AI_buzzwords;blog_prose_on_LP}
§CHK{purpose+CTA;aud+lang;5s+GEO_category_clear;hl_ben+formula;sub_spec;feat→ben;proof≥1;CTA_formula;flow(prob→sol→proof→CTA);simple_active_¬buzz;emotion(pain,desire,relief);risk_rev+trust_near_CTA;proofread(spell,gram,links)}
§OUT{fmt:"**Headline:**… **Subheadline:**… **Primary CTA:**… **Section 1 – Problem:**… **Section 2 – Benefits:**… **Section 3 – How It Works:**… **Section 4 – Social Proof:**… **Section 5 – FAQ / Objections:**… **Final CTA:**…";opt_alts:"hl&CTA⇒2-3_alts+rationale"}
§REL{../SKILL.md:parent;brand-voice.md:voice+hard_bans;marketing-campaign.md:launch_suite;../../conversion-optimization/SKILL.md:CRO+AB_testing+funnels;../../seo/SKILL.md:SEO+GEO}
