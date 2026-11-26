@REF:on-page-content
§REL{../SKILL.md:parent;schema-markup.md:schema;schema-markup.md#localbusiness:local}
§R{
  title:50-60c∧kw_start∧uniq∧brand_end_opt;meta_desc:150-160c∧1st+2nd_kw∧CTA∧uniq;
  h1:1/pg∧1st_kw;headings:H1->H2->H3∧¬skip∧desc;url:short∧kw_rich;1st_p:1st_kw∈1st_100w;
  img:desc_name∧alt∧(WebP|AVIF)∧w∧h∧loading="lazy"(below_fold)
}
§PAT{
  head:<title>,<meta name="description">,<link rel="canonical" href="https://example.com/current-page">,<img src="diagram.webp" alt width=800 height=600 loading="lazy">;
  social:og:{title,description,image,url,type=website}∧twitter:{card=summary_large_image,title,description,image}
}
§D{
  content:{sem_vars;kw:~1-2%;len:{guide:1500-2500w,prod:300-500w,pillar:3000+w,cluster:1500-2000w};followups;refresh≤1y(fast:qtr);¬thin∧¬dup;kpi:time_on_page,bounce,pages/session};
  EEAT:{Exp:1st_hand,cases,orig_data;Expertise:creds,deep;Auth:cites,backlinks,recog;Trust:HTTPS,contact,privacy};
  links:{3-5/1000w_ctx;desc_anchor(¬"click here");strong→target;backfill;audit_broken;¬excess_nav_footer};
  kw_map:1:seed(goals)→2:expand(Keyword_Planner,Ahrefs,Semrush)→3:clusters(pillar↔clusters)→4:rank(intent,val,comp;long_tail)→5:1_kw→1_URL(sheet)→6:¬cannibalize(unless_intent);
  local:{NAP_consistent;Google_Business_Profile(photos,posts,reviews);LocalBusiness→schema-markup.md#localbusiness}
}
