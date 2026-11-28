@REF:competitor-pages
§REL{../programmatic-seo.md:pSEO_parent;../../SKILL.md:seo_core;../schema-markup.md:schema;../generative-engine-optimization.md:GEO_compare}
§USE{kw∈{"[X] alternative","[X] vs [Y]","best [X] alternatives"}∨convert_switchers∨GEO_comparison_citations∨scalable_multi_comp_arch}
§INIT{
  you:{value_prop,diffs,ICP,pricing_model,honest_pros_cons};
  landscape:{direct_indirect_comps,positioning,kw_vol};
  goals:{SEO,GEO_AI_citations,sales_enablement,switcher_conv,brand_pos}
}
§R{
  1:honesty⇒ack(comp_strengths∧own_limits)∧verifiable_sources(prevents_AI_hallucination);
  2:depth⇒hands_on_trial_use_cases∧why_diff_matters(¬bare_checklists∧¬Scaled_Content_Abuse);
  3:decision⇒crisp_TLDR_verdict_under_H1(who_best_for)∧reduce_eval_friction;
  4:modular⇒central_data→reuse(∀pages)+semantic_HTML_tables(AI_extractable)
}
§FMT{
  singular_alt:{intent:switch;url:"/alternatives/[comp]"⊕"/[comp]-alternative";kw:["[comp] alternative","alternative to [comp]","switch from [comp]"];flow:TLDR→pain_pts→pos(you)→cmp(features,service,pricing)→who_switch/¬switch→migration→switcher_proof→CTA};
  plural_alts:{intent:early_research;url:"/alternatives/[comp]-alternatives"⊕"/best-[comp]-alternatives";kw:["[comp] alternatives","best [comp] alternatives","tools like [comp]"];flow:TLDR→pain_pts→eval_fw→4-7_alts(you_first)→summary_table→per_alt→rec_by_use_case→CTA};
  you_vs_comp:{intent:head_to_head;url:"/vs/[comp]"⊕"/compare/[you]-vs-[comp]";kw:["[you] vs [comp]","[comp] vs [you]","compare [you] and [comp]"];flow:TLDR(2-3_sent)→at_a_glance_table→cat_cmp(features,pricing,service,ease_of_use,integrations)→honest_who_for→switcher_quotes→migration→CTA};
  compA_vs_compB:{intent:3rd_opt;url:"/compare/[comp-a]-vs-[comp-b]";kw:["[A] vs [B]","[A] or [B]","[A] compared to [B]"];flow:TLDR→overview_both→cat_cmp→who_for→intro_you_3rd_opt→3way_table→CTA}
}
§HUB{
  idx:{alt_singular,alt_plural,vs};
  R:immediate_update_on_add∧bi_link(hub↔page)∧show(last_updated,count)∧self_ref_canonical_if_paginated∧opt_filters(popularity,category,date)
}
§ARCH{
  store:`competitor_data/{<comp>.yaml,you.yaml}`(YAML∨JSON);
  schema:{basic(name,website,tagline,founded,HQ),positioning(use_case,audience,market_pos),pricing(model,tiers,free_tier,hidden_costs,verified_date),features(ratings,desc),strengths_weaknesses,ICP∧non_ICP,review_complaints,migration(export,difficulty,time_est)};
  flow:pull(comp+you)→fill(tpl)→auto_render(semantic_HTML_tables,TLDR,migration)→human_review(tone,accuracy,voice)→publish→hub
}
§TPL{
  TLDR:"Comp excels at [strength] but struggles with [weakness]. You focuses on [focus], offering [diff]. Choose Comp if [their_ICP]; You if [your_ICP].";
  narrative:"Comp:[desc](strength X→Y; limit L hinders Z). You:[approach]→benefit+trade-off.";
  feature_tbl:semantic_`<table>`+descriptive_cells(¬bare_✓/✗),group(Core,Collaboration,Integrations,Security,Support),Notes_col,opt_⭐+reason;
  pricing:tiers(Free,Starter,Biz,Ent)+annual_TCO(e.g.10u:Comp~$1,800/yr vs You~$1,440/yr)+source_date;
  service:rows(Docs,SLA,Channels);
  who_for:explicit(Choose_Comp ∧ Choose_You);
  migration:{transfers(Pages→MD,DB→CSV_reimport),reconfig(Automations→workflow,Integrations→API_keys),support(free_import,opt_white_glove,"1-3d/10u")};
  proof:≥2_switcher_quotes(metric+role)
}
§OPS{
  research:trial(UX,limits)→pricing_audit(tiers,hidden_fees,terms)→review_mining(G2,Capterra,TrustRadius)→interviews→comp_messaging(self_cmp)→central_file;
  cadence:{quarterly:pricing+features,on_notif:immediate(new_tier|feature),annual:full_refresh}
}
§SEO{
  cross_link(related+hub)∧SSR_semantic_tables∧visible_Q&A(opt_FAQPage_GEO_context;SERP_rich_result=gov_health_only)∧Article+BreadcrumbList_schema(dateModified)∧kw∈(title≤60c∧desc≤160c)∧visible("Last updated")
}
§CHK{3-5_comps∧central_files∧format/kw∧TLDR+narrative+semantic_tables∧honest_who_for∧verified_pricing_TCO∧migration+offers∧≥2_quotes∧URL/title/meta/H*∧Article+BreadcrumbList+visible_Q&A∧publish+hub∧quarterly_reminder}
