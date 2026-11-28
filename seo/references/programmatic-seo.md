@REF:programmatic-seo
§REL{programmatic-seo/competitor-pages.md:competitor_alt_vs;../SKILL.md:seo_core;schema-markup.md:structured_data;technical-seo.md:crawl_index;../../content-writing/SKILL.md:copy_blog;../../web-scraping-apis/SKILL.md:data_scrape}
§R{
  when:repeatable_intent(`"[service] in [city]"`,`"[tool] vs [tool]"`,`"convert [X] to [Y]"`)∧defensible_unique_data∧(local|compare|utility);
  spam_gate:MUST_clear_Google_Scaled_Content_Abuse(method_agnostic:applies_to_pSEO+AI+human_mass_pages_targeting_Search_OR_AI_Overviews/AI_Mode);
  info_gain/pg:distinct_value=Δ(proprietary_data,computed_analysis,interactive_utility,verified_UGC,human_editorial);¬synonym_swap∧¬raw_unedited_AI;
  data_prio:proprietary→product_derived→verified_UGC→licensed→enriched_public;
  url:subfolders>subdomains∧short∧descriptive∧kw_rich;
  quality>qty(100_high_val>10000_thin);¬{doorway,kw_stuffing,dup,scaled_content_abuse}
}
§D{
  playbooks:{
    Templates:(`"free [type] template"`,`/templates/resume/`,downloadable_usable);
    Curation:(`"best [category]"|"top 10…"`,`/best/website-builders/`,hands_on_tested_ranks);
    Conversions:(`"[X] to [Y]"`,`/convert/usd-to-gbp/`,realtime_interactive_tool);
    Comparisons:(`"[X] vs [Y]"`,`/compare/webflow-vs-wordpress/`,verified_feature_TCO_analysis);
    Examples:(`"[type] examples"`,`/examples/landing-page/`,screenshots+expert_commentary);
    Locations:(`"[service] in [city]"`,`/coworking/spokane/`,verified_providers+local_stats);
    Personas:(`"[product] for [audience]"`,`/for/freelancers/`,tailored_workflows+proof);
    Integrations:(`"[product] + [product] integration"`,`/integrations/slack/`,live_setup+demos);
    Glossary:(`"what is [term]"`,`/glossary/seo/`,crisp_def+examples+GEO_answers);
    Translations:(l10n_copy,`/es/que-es-seo/`,native_reviewed_l10n+hreflang);
    Directory:(`"[category] tools"`,`/directory/ai-copywriting/`,filterable_curated_list);
    Profiles:(`"[person/company]"`,`/people/slug/`,sourced_data+ProfilePage_schema)
  };
  combos:{Loc+Persona:`/marketing-agencies/startups/austin/`;Cur+Loc:`/best/coworking-spaces/san-diego/`;Int+Persona:`/integrations/slack/for/sales-teams/`}
}
§FLOW{
  1_kw:pattern+vars→(demand,head/tail,seasonality)→SERP_comp(depth,intent,AI_Overviews)→pick_winnable_combos;
  2_data:{src:DB|API|licensed|scrape+verify;cadence:daily|weekly|monthly;schema:`city{name:str,population:int,stats:{average_price:num,regulation:str}}, service{name:str,description:str}, providers[{name:str,rating:num,reviews:int,specialty:str}]`};
  3_tpl:{sections:[`# {{service}} in {{city}} ({{year}})`,`{{tldr_direct_answer}}`,`## Why {{city}}… {{city_insights}}`,`## Top {{service}} Providers (%for p in providers%: verified_metrics,rating,reviews,specialty)`,`## Pricing {{semantic_pricing_table}}`,`## FAQ {{visible_faq_section}}`,`[Related: {{related_links}}]`];rules:conditional_blocks(omit_empty_sections)∧intent_CTA(download|sign-up|contact)};
  4_links:{hub_and_spoke:hub→all_spokes;cross_link:shared_var;pagination:self_ref_canonical(¬noindex_hub_pages);breadcrumbs:BreadcrumbList_JSON-LD;¬orphans};
  5_index:{XML_sitemap(split_by_playbook;≤50k_URLs/≤50MB;accurate_<lastmod>;¬<priority>);IndexNow_ping(Bing/AI);`noindex`(low_vol|thin_pre_prune;¬disallow_in_robots.txt);`robots.txt`(block_param_traps);GSC(index_rate,soft_404,Manual_Actions)}
}
§CHK{
  pre:{distinct_info_gain+verified_data+¬dup_boilerplate;title≤60c∧meta_desc≤160c(unique+kw);H1-H3(1_H1);schema(active_types:`LocalBusiness`,`Product`/`ProductGroup`,`Article`,`BreadcrumbList`;`<`→`\u003c`);canonical_ok(¬loops);CWV(LCP≤2.5s,INP≤200ms,CLS≤0.1)∧HTML≤2MB∧SSR;links(hub+related,¬broken);sitemap_<lastmod>_accurate};
  post:{index_pct(indexed/submitted);GSC_Query_Groups+GenAI_impressions;GA4(sessions,engagement,AI_referrals,conversions/playbook);GSC(soft_404,crawl_err,Manual_Actions);data_freshness};
  launch:[kw_demand(>50/mo)→unique_data+schema→cond_tpl→subfolders→pilot_50-100+GSC_index_audit→sitemap(<lastmod>)+IndexNow→hub+cross_links→pre_QA→staged_scale+monitor→refresh_sched]
}
§ANTI{
  thin_var_swap∨mass_unedited_AI⇒Scaled_Content_Abuse(algorithmic_drop∨Manual_Action)⇒proprietary_stats+analysis+human_QA;
  kw_cannibal⇒split_signal⇒consolidate∨canonical;
  over_gen(zero_demand_combos)⇒dilute_quality+crawl_waste⇒min_demand_gate(>50/mo)_before_gen;
  bad_stale_data⇒bounce+trust_loss+AI_hallucination⇒auto_validation+scheduled_refresh;
  fake_lastmod∨sitemap_priority⇒ignored_or_distrusted⇒accurate_<lastmod>_only;
  poor_UX(bot_only,¬CTA)⇒high_bounce+low_conv⇒user_journey+utility+CTA
}
§INTK{patterns?;proprietary_data_src+cadence?;pilot_batch_size?;domain_authority?;competitors?;CMS|SSG?}
