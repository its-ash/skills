@REF:on-page-content
§REL{../SKILL.md:parent;schema-markup.md:schema;generative-engine-optimization.md:GEO_answer_blocks}
§R{
  title:50-60c(~580px)∧primary_kw_start∧unique∧intent_aligned(limits_Google_rewrites)∧brand_end_opt;
  meta_desc:150-160c(~920px)∧unique∧value_prop+CTA(CTR_signal,≠direct_rank_factor);
  h1:1/pg∧intent_aligned;headings:H1→H2→H3∧¬skip∧descriptive/Q_headings+40-60w_direct_answer_below(SERP+AI_Overviews);
  url:short(<75c)∧lowercase∧hyphen_sep∧kw_rich;lead:core_answer+topic∈1st_100w;
  img:desc_name∧meaningful_alt∧(AVIF|WebP)∧w∧h∧LCP_hero(`fetchpriority="high"`∧¬`loading="lazy"`)∧below_fold(`loading="lazy"`);
  discover:`<meta name="robots" content="max-image-preview:large">`∧hero_img≥1200px
}
§PAT{
  head:`<title>`,`<meta name="description">`,`<meta name="robots" content="max-image-preview:large">`,`<link rel="canonical" href="https://example.com/current-page">`;
  hero_img:`<img src="hero.avif" alt="..." width="1200" height="675" fetchpriority="high">`;
  below_fold_img:`<img src="diagram.webp" alt="..." width="800" height="600" loading="lazy">`;
  social:og:{title,description,image(≥1200x630),url,type=website|article}∧twitter:{card=summary_large_image,title,description,image}
}
§D{
  content:{info_gain(orig_data,1st_hand_proof,benchmarks);entities+semantic_variants(¬kw_density_targets);intent_complete_depth(heuristics:prod~300-500w,guide~1500-2500w,pillar~3000+w;never_pad);cover_fan-out_followups;refresh≤1y(fast_topics:qtr);¬thin∧¬dup};
  spam_policy:{AI_assisted_ok⇔human_fact_check+editorial_value;¬scaled_content_abuse(method_agnostic:AI|human|pSEO);¬site_reputation_abuse(3rd_party_parasite_pages);¬expired_domain_abuse};
  EEAT:{Trust(most_critical:HTTPS,contact,editorial_policy,accurate_citations);Exp(1st_hand_tests,screenshots,cases,orig_data);Expertise(author_bios,creds,ProfilePage_schema,sameAs);Auth(industry_cites,brand_mentions,editorial_backlinks)};
  links:{contextual_descriptive_anchors(¬"click here");hub↔spoke_clusters;strong_pages→new_target(backfill);fix_broken/301_internal_links;¬excess_nav_footer};
  kw_map:1:seed(ICP_goals)→2:expand(GSC_Query_Groups,Ahrefs,Semrush,Keyword_Planner)→3:topic_clusters(pillar↔spokes+fan-out_Qs)→4:prio(intent,biz_val,diff)→5:1_primary_intent→1_URL→6:¬cannibalize;
  local:{NAP_consistent;Google_Business_Profile(categories,photos,posts,Q&A,real_reviews);LocalBusiness_JSON-LD@schema-markup.md}
}
