@REF:marketing-campaign
§USE{launch,1brief_suite,pos+angle≺copy,xch_coord,CRO+brand_rev}
§R{pos≺copy(all←angle);res_aud≺assume(lang|fears);1_deliv=1_arc_purp;spec>adj(∀ch);inv(voice,∀ch);email_blasts⇒SPF+DKIM+DMARC+RFC8058_1click_unsub+spam<0.1%;gate≺ship}
§PAT{
  P1@../../product-strategy/references/market-research.md:{aud(JTBD,fears,lang,alts);≥3_comp(pos,gaps,weak);1-3_ins→angle;out:brief(aud,comp,ins)};
  P2:{benefit(1_sent,¬feat,¬jarg);"[Product] helps [audience] [achieve outcome] by [mechanism]";angle(tens|ins|mom);tone@brand-voice.md;GATE:approve(pos+angle)≺copy};
  P3(order):1:LP@copywriting.md:{hero(5s+GEO_cat),prob,sol,feat,how,proof,CTA}→2:email(1_purp/ea,auth_domain):{prob→edu→agit→sol→proof→honest_urg→final_CTA}→3:soc@social-content.md:nat(LI≠X≠Threads/Bluesky≠IG/TT)→4:vid@../../video-production/SKILL.md:{ts,scr+ear}→5:ads:{3-4_var(ang|seg)}→6:cal:{daily(ch,type,t,deps)};
  P4:{5s(hero+fold:who,what,why_now);GEO_consistency(LP≡docs≡launch_posts);CTA(1/pc,spec,earn);tone_xch;claims(spec,supp);xch(ad≡LP,subj≡body)};
}
§OUT{1:pos_brief(angle,benefit,tone);2:LP(all);3:email(∀:{d,purp,subj,prev,body,CTA});4:LI(≥3_ang);5:X(≥5+1_thd);6:vid(≥2,ts,vis);7:ads(s_hl,l_hl,body);8:cal(d,ch,type,t,deps);9:rev(issues,Qs)}
§ANTI{copy_before_pos_gate;fake_urgency|dark_patterns;verbatim_xpost;unauth_bulk_email;generic_cat_claims}
§CHK{1_voice;¬{superlatives,filler};CTA_spec+earn∧∉{"learn more","find out more","click here"};¬verb_dup(xplat);5s_pass;GEO_cat_consistent;subj≡body∧ad≡LP;email_auth+unsub_ok;¬gen_cat;bans@brand-voice.md+SEO@../../seo/SKILL.md}
§REL{../SKILL.md:parent;brand-voice.md:voice+hard_bans;copywriting.md:landing_page;social-content.md:social_posts;../../product-strategy/references/market-research.md:P1_research;../../seo/SKILL.md:SEO+GEO;../../video-production/SKILL.md:launch_video}
