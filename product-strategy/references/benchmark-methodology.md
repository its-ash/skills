@REF:benchmark-methodology
§D{
  pipeline:step2/3;
  in:tiered_set([competitive-platform-analysis.md](competitive-platform-analysis.md))∧positioning_brief;
  out:1-5_scores+profile_cards→[competitive-report-structure.md](competitive-report-structure.md);
  domain:adapt_dim_evidence_to(B2B_SaaS/AI_products∨creative/advisory_studios);
}
§R{
  prereq_brief_before_scoring:{
    tension:2_axes(e.g.memorability×hireability|self_serve_speed×enterprise_trust)⇒Dim9(score∧report_poles_separately,¬avg);
    differentiator:client_moat⇒sets_dim_emphasis;
    brand_balance:intended_strategic_mix⇒¬break_wo_flag
  };
  no_composite_avg:weights_for_synthesis_only(∑=100%,¬blended_total);
  evidence_gate:record_∀dim={score(1-5),1-line_justification,source_link/screenshot}(¬score_wo_evidence);
  cross_set_calibration:re-read_side-by-side("4"_invariant_across_set;adjust_outliers);
}
§PAT{
  dims_9(weights_for_synthesis_only,∑=100%):{
    1:Positioning_clarity_distinctiveness(18%):sharp/ownable/legible_vs_generic+AI_mirror_accuracy;
    2:Brand_voice_verbal_distinctiveness(15%):ownable_register_vs_agency/AI_slop_speak;
    3:Visual_identity_and_product_site_craft(15%):visual_system+UX/site_craft=proof_of_execution;
    4:Offer_packaging_and_onboarding_clarity(12%):legible_packaging(named_sprints/PLG_tiers/clear_TTV)_vs_vague;
    5:Evidence_credibility(12%):named_clients,quantified_outcomes,case_depth,verified_G2/Clutch/community_proof(proof>assertion);
    6:Enterprise_readiness_commercial_maturity(10%):B2B/enterprise_signals(process,logos,scale,SOC2/SSO/SLAs/contracts);
    7:Thought_leadership_and_AI_citation_presence(8%):owned_POV(writing,talks,frameworks)+third_party_consensus_cited_by_LLMs(GEO);
    8:Pricing_transparency_and_value_metric(5%):transparent_vs_opaque;alignment_w_value/COGS(hybrid/credits/outcome_vs_stale_seat_or_bill_shock);
    9:Client_strategic_tension(5%_flag):score_BOTH_poles_1-5_separately;plot_2x2;target_quadrant_occupancy=#1_finding
  };
  rubric_1_to_5(adapt_specifics/dim,keep_level_constant,anchor_to_evidence):{
    1:absent/generic(template-indistinguishable,active_liability);
    2:below_par(inconsistent/derivative/unconvincing,fails_side-by-side);
    3:competent/table-stakes(solid/professional/unremarkable,ownable_by_nobody);
    4:strong/distinctive(>peers,buyer_notices∧cites);
    5:category-defining(best-in-class,ownable,hard_to_imitate,sets_bar)
  };
  dim9_ex(memorability×credibility):{
    memorability:{1:forgotten_instantly,3:recognizable_in_context,5:unforgettable/talked-about/owned},
    credibility:{1:risky/amateur,3:safe/competent/unexciting,5:enterprise-trusted/obvious_safe_choice},
    quadrants:{high/high,high-1/low-2,low-1/high-2,low/low}
  };
  collect_order(cheapest_first):{
    1:own_site+pricing+docs→positioning,voice,packaging,value_metric,clients,POV;screenshot(homepage+pricing/case_study);
    2:AI_search_mirror(ChatGPT,Claude,Gemini,Perplexity_buyer_prompts)→citation_share,recommended_use_case,framing_accuracy;
    3:case_studies/changelogs→evidence_depth,metrics,shipping_cadence;tag(asserted_vs_proven=metrics+named+verifiable);
    4:review_dirs_and_dark_funnel(G2,Capterra,Clutch.co,Reddit,HN)→corroborate_clients,real_pain,retention/support,enterprise_sig;
    5:LinkedIn→team_size/model,founder_narrative,hiring_signals,cadence;
    6:craft_and_content(Dribbble/Behance/GitHub/newsletters/talks)→craft_maturity+POV_depth
  };
  bias_guards:{
    ¬composite_score(hides_asymmetry);
    asserted_vs_proven:downgrade_uncorroborated_copy;
    AI_hype_washing:verify_workflow_depth_vs_superficial_AI_labels;
    aesthetic_affinity:score_craft⊥credibility("boring"_product/site_may_win_bigger_contracts);
    dark_funnel_blindspot:cross_check_private/community_sentiment_and_LLM_shortlists;
    recency/flashiness:verify_awards/showpieces_via_dirs/clients;
    survivorship:note_quiet_strong_operators_via_dirs/reviews
  };
}
§OUT{
  card_tpl:```
  ## <Competitor name>
  - **Profile / Tier:** <stance·specialization·size> / <Direct|Adjacent|Aspirational>
  - **One-liner:** <their words>
  - **Model / size / pricing:** <band>·<region>·<seat|hybrid|credits|outcome|productized|retainer>
  - **AI mirror / GEO read:** <cited?|how LLMs frame them>
  - **Notable clients / evidence:** <named [proven|asserted]>
  ### Dimension scores (∀dim∈dims_9[1..8]: Dim|Score(1-5)|1-line|Source)
  ### Tension plot: [Axis 1]:<1-5>—<why>; [Axis 2]:<1-5>—<why>; Quadrant:<high/high|high-1/low-2|low-1/high-2|low/low>
  ### Read for [client]: Strength:<…>; Weakness/white-space:<…>; Threat:<…>
  ```
}
§CHK{
  all_profiled_cards_scored_w_sources;
  dim9_poles_unaveraged;
  cross_set_calibration_passed;
  AI_mirror_checked_for_top_rivals;
}
§ANTI{
  ¬avg_tension_axes;
  ¬score_wo_evidence+source;
  ¬composite_score;
  ¬uncalibrated_generic_rubric;
  ¬trust_AI_marketing_claims_wo_proof;
  ¬run_before([competitive-platform-analysis.md](competitive-platform-analysis.md));
}
§REL{
  prereq:[competitive-platform-analysis.md](competitive-platform-analysis.md);
  next:[competitive-report-structure.md](competitive-report-structure.md);
  geo:[seo](../../seo/SKILL.md);
}
