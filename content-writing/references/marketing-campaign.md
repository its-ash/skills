@REF:marketing-campaign
§USE{launch,1brief_suite,pos+angle≺copy,xch_coord,CRO+brand_rev}
§R{pos≺copy(all←angle);res_aud≺assume(lang|fears);1_deliv=1_arc_purp;spec>adj(∀ch);inv(voice,∀ch);gate≺ship}
§PAT{
  P1@[../../product-strategy/references/market-research.md](../../product-strategy/references/market-research.md):{aud(JTBD,fears,lang,alts);≥3_comp(pos,gaps,weak);1-3_ins→angle;out:brief(aud,comp,ins)};
  P2:{benefit(1_sent,¬feat,¬jarg);"[Product] helps [audience] [achieve outcome] by [mechanism]";angle(tens|ins|mom);tone@[brand-voice.md](brand-voice.md);GATE:approve(pos+angle)≺copy};
  P3(order):1:LP@[copywriting.md](copywriting.md):{hero,prob,sol,feat,how,proof,CTA}→2:email(1_purp/ea):{prob→edu→agit→sol→proof→urg→final_CTA}→3:soc@[social-content.md](social-content.md):nat(LI≠X)→4:vid:{ts,scr+ear}→5:ads:{3-4_var(ang|seg)}→6:cal:{daily(ch,type,t,deps)};
  P4:{5s(hero+fold:who,what,why_now);CTA(1/pc,spec,earn);tone_xch;claims(spec,supp);xch(ad≡LP,subj≡body)};
}
§OUT{1:pos_brief(angle,benefit,tone);2:LP(all);3:email(∀:{d,purp,subj,prev,body,CTA});4:LI(≥3_ang);5:X(≥5+1_thd);6:vid(≥2,ts,vis);7:ads(s_hl,l_hl,body);8:cal(d,ch,type,t,deps);9:rev(issues,Qs)}
§CHK{1_voice;¬{superlatives,filler};CTA_spec+earn∧∉{"learn more","find out more","click here"};¬verb_dup(xplat);5s_pass;subj≡body∧ad≡LP;¬gen_cat;bans@[brand-voice.md](brand-voice.md)+SEO@[../../seo/SKILL.md](../../seo/SKILL.md)}