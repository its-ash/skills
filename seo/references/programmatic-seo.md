@REF:programmatic-seo
§REL{programmatic-seo/competitor-pages.md:competitor_alt_vs;../SKILL.md:seo_core;../../content-writing/SKILL.md:copy_blog;../../web-scraping-apis/SKILL.md:data_scrape}
// related: seo-audit, schema-markup, copywriting, analytics-tracking

§R{
  when:repeatable_intent(`"[service] in [city]"`,`"[tool] vs [tool]"`,`"convert [X] to [Y]"`)∧defensible_data∧(local|compare|utility);
  unique_val/pg:Δ(data,analysis,insights);
  data_prio:proprietary→product_derived→UGC→licensed→public;
  url:subfolders>subdomains∧short∧descriptive∧kw_rich;
  intent:complete_answer|tool;quality>qty(100_good>10000_thin);¬{doorway,kw_stuffing,dup}
}

§D{
  playbooks:{
    Templates:(`"free [type] template"`,`/templates/resume/`,downloadable_usable);
    Curation:(`"best [category]"|"top 10…"`,`/best/website-builders/`,expert_tested_ranks);
    Conversions:(`"[X] to [Y]"`,`/convert/usd-to-gbp/`,realtime_tool);
    Comparisons:(`"[X] vs [Y]"`,`/compare/webflow-vs-wordpress/`,feature_analysis);
    Examples:(`"[type] examples"`,`/examples/landing-page/`,screenshots+commentary);
    Locations:(`"[service] in [city]"`,`/coworking/spokane/`,providers+city_stats);
    Personas:(`"[product] for [audience]"`,`/for/freelancers/`,benefits+testimonials);
    Integrations:(`"[product] + [product] integration"`,`/integrations/slack/`,setup+demos);
    Glossary:(`"what is [term]"`,`/glossary/seo/`,def+examples);
    Translations:(l10n_copy,`/es/que-es-seo/`,high_quality_l10n);
    Directory:(`"[category] tools"`,`/directory/ai-copywriting/`,filterable_list);
    Profiles:(`"[person/company]"`,`/people/elon-musk/`,bio+sourced_data)
  };
  combos:{Loc+Persona:`/marketing-agencies/startups/austin/`;Cur+Loc:`/best/coworking-spaces/san-diego/`;Int+Persona:`/integrations/slack/for/sales-teams/`}
}

§FLOW{
  1_kw:pattern+vars→(vol,head/tail,seasonality)→comp(DA,depth,backlinks)→pick_winnable;
  2_data:{src:DB|API|licensed|scrape;cadence:daily|weekly|monthly;schema:`city{name:str,population:int,stats:{average_price:num,regulation:str}}, service{name:str,description:str}, providers[{name:str,rating:num,reviews:int,specialty:str}]`};
  3_tpl:{sections:[`# {{service}} in {{city}} – {{year}}`,`{{intro_paragraph}}`,`## Why {{city}}… {{city_insights}}`,`## Top {{service}} Providers (%for p in providers%: name,rating,reviews,specialty)`,`## Pricing {{pricing_table}}`,`## FAQ {{faq_section}}`,`[Related: {{related_links}}]`];rules:conditional_blocks∧intent_CTA(download|sign-up|contact)};
  4_links:{hub_and_spoke:hub→all_spokes;cross_link:shared_var;breadcrumbs:structured_data;¬orphans(hub∨sitemap)};
  5_index:{XML_sitemap(split_by_playbook_if_large);`noindex`(low_vol|thin);`robots.txt`(block_traps+params);GSC(crawl_err,index_rate)}
}

§CHK{
  pre:{unique_intro+data+intent+¬dup_p;title≤60c∧meta_desc≤160c(unique+kw);H1-H3(1_H1);schema(`LocalBusiness`,`Product`,`FAQ`);canonical_ok(¬loops);mobile<3s+img_opt+lazy;links(hub+related,¬broken);sitemap_prio};
  post:{index_pct(indexed/submitted);avg_pos;traffic(sessions,bounce,time/playbook);conversions(lead,download,sign-up);GSC(thin,manual,crawl_err);freshness};
  launch:[kw(>50/mo)→data+schema→cond_tpl→subfolders→batch_100+audit→sitemap+GSC→hub+cross_links→pre_QA→launch+monitor→refresh_sched]
}

§ANTI{
  thin_var_swap⇒doorway_deindex⇒add(city_stats,analysis,UGC_reviews);
  kw_cannibal⇒split_signal⇒consolidate∨canonical;
  over_gen(low_vol)⇒dilute_auth+crawl_waste⇒min_vol(>50/mo);
  bad_data⇒bounce+rank_drop⇒auto_val+audits;
  poor_UX(bot_only,¬CTA)⇒high_bounce+low_conv⇒user_journey+CTA
}

§INTK{patterns?;data_src+cadence?;phase1_pages?;DA+backlinks?;competitors?;CMS|SSG?}
