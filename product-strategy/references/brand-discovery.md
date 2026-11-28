@REF:brand-discovery
§D{
  8mod_resumable_interview→`90_SYNTHESIS.md`(brandbook_design/copy/collabs);
  use⇔brand_{create|reposition|id_ref}∨multi_sess∨multi_founder(indiv_pre_reconcile)∨repeatable∨implicit_knowledge∨pos_brief_pre([competitive-platform-analysis.md](competitive-platform-analysis.md));
  persist_to_disk;
}
§R{
  start(pre_Q):1:chk(brand_dir/{modules/*,state.json});∅⇒confirm({brand_name,participants,save_loc})∧start(`10_purpose-why.md`);2:read(inProgressModule)∧scan(`## Raw`);3:report(2-3sent:{mod,status,rem})→"Continue here, or switch module?";
  interview:1:1_Q@time(¬lists);2:post_ans⇒paraphrase+(1_probe⊕close_sat);¬silent_next;3:ladder(post-what)⇒"Why does that matter to you?"×2..4→core_val;4:5_Whys(beliefs|claims)⇒root(¬surface);5:thin(generic|jargon|vague)⇒req(1_ex|story|num);6:projective(1/mod@plateau):{room:"If the brand were a person, how would they walk into a room?",obit:"If the organization closed in five years, what would customers miss? What would you regret not having said?",contrast:"Name one peer you admire but would never want to become. What specifically makes them the wrong model?"};7:sat⇔2_consec_probes==∅_new⇒summarize∧close;8:end_mod⇒write(`## Raw`{verbatim,ex},`## Synthesis`{interp,3_cands,open_Qs,contradictions})→upd(`state.json`);
  AI_mirror_rule(Dunford):LLMs_act_as_positioning_mirror(¬distortion);if_ChatGPT/Claude/Perplexity_misframe_brand⇒fix_positioning_clarity+third_party_consensus_not_prompts;
}
§PAT{
  seq(ordered;jump⇒skip∈`state.json`):1:`10_purpose-why.md`(Sinek_Golden_Circle,Lencioni);2:`20_positioning.md`(Dunford_Obviously_Awesome+Sales_Pitch,Moore,JTBD);3:`30_audience-niche.md`(Baker_Business_of_Expertise,ICP/HXC);4:`40_personality-archetype.md`(Mark&Pearson_12,J.Aaker_5);5:`50_voice-tone.md`(spectrum,tone_matrix);6:`60_narrative-story.md`(Neumeier_trueline,arc);7:`70_founder-tension.md`(Enns_Win_Without_Pitching);8:`90_SYNTHESIS.md`(Kapferer_prism,Aaker_sys);
  M10(belief¬sold):Raw{why,How(¬slogans),refusals(¬be/do),quotes}→Syn{2-3_Why(vary_reg&spec),open_Qs,contradictions,pos_impact};
  M20(Dunford_5_comp+frame):Raw{comp_alts(incl"do nothing","spreadsheets","DIY_ChatGPT","in-house"),unique_attrs,diff_value_themes,best_fit_chars,mkt_cat,AI_mirror_output(how_LLMs_describe_us_now),phrases}→Syn{"For **[target ICP]** who **[situation / JTBD]**, **[brand]** is the **[category]** that **[unique value]**. Unlike **[alternatives]**, we **[key differentiator]**.",alts,unique_attrs→value_map,white_space,AI_mirror_gap,open_Qs,M10_tensions};
  M30(ICP+HXC+dark_funnel):Raw{person/HXC,trigger_event,dark_funnel_research_spots(communities,peers,AI_engines),prior_fails,success_words,fears,worst_fit&why,stories}→Syn{ICP(role,org_type&size,trigger,pain,outcome,budget_sig,red_flag),HXC_profile,2-3sent_psychographic,niche_hyp(smallest_ownable_mkt),dark_funnel_channels,test_segs};
  M40(person):Raw{room,arch∈{Creator,Caregiver,Ruler,Jester,Regular_Person,Lover,Hero,Outlaw,Magician,Innocent,Sage,Explorer},3_adj,anti_model,asp_reg,client_feel}→Syn{prim+shadow,J.Aaker_1-5+evid(sincerity,excitement,competence,sophistication,ruggedness),3_behaviors,anti_personality};
  M50(voice=const,tone=ctx):Raw{admired(+src),disliked(+flaw),always_words,avoid_words,sound(sales,error,proposal),"We always..."/"We never..."}→Syn{1-5_spec(formal/casual,serious/playful,distant/warm,conventional/irreverent,minimal/expressive),1para_voice,tone_matrix(headline,case_study,proposal,error/apology,social),3_checks;src→[brand-voice.md](../../content-writing/references/brand-voice.md)};
  M60(story):Raw{origin,frustration,world_post,1_story,obit,invite}→Syn{"[Brand] is the only [category] that [unique claim]"+2-3_alts,arc(context,conflict,resolution,invitation),brand=guide∧client=hero};
  M70(founder↔org):Raw{vis&how,buy_founder_vs_org(evid¬instinct),step_back,3-5yr_goals,org_solo_reqs,helps|constrains}→Syn{1-5_spec("founder IS brand"↔"org stands alone",curr&3yr),ownership,transition,inaction_risk};
  M90(reconcile_M10-70,min_new):1:Why(belief,How,refusals);2:Pos(stmt,Dunford_5_comp,white_space,AI_mirror_corroboration_plan);3:Audience(ICP/HXC,niche,dark_funnel,disq);4:Kapferer(physique,personality,culture,relationship,reflection,self-image);5:Aaker(prim+sec_arch,as_{product,org,person,symbol},3-5_assoc,equity_sigs);6:Voice&Tone(stmt,3_checks);7:Narrative(trueline,1para_About_arc);8:Founder_org_bound;9:Tensions(tension,modA,modB,res);10:Open_Qs+3-5_next;
}
§CFG{
  state:write(`modules/{moduleFile}`)→upd(`state.json`)→"Module X saved. State updated. Next: Y.";
  ```json
  {"session":"{brand_name}-brand-{YYYY-MM}","outputPath":"{path_to_brand_identity_directory}","completedModules":[],"inProgressModule":"10_purpose-why.md","nextModule":"20_positioning.md","participants":["founder-A"],"lastUpdated":"{ISO-8601}"}
  ```
  terminal(`90_SYNTHESIS.md`):pre⇒inProgressModule="90_SYNTHESIS.md",nextModule=null;post⇒append("90_SYNTHESIS.md"→completedModules),inProgressModule=null→"Brandbook complete. All modules saved.";
  multi(>1):write→`founders/{participant}.md`(¬main);val:{participant∈`^[A-Za-z0-9-]+$`(¬`/`,`\`,`..`,special),moduleFile∈seq,outputPath=abs_in_proj(¬rel,¬`..`)};post_all⇒reconcile(conv/div→mod_file)∧flag("productive tensions"→workshop);
}
§CHK{
  state_read_before_asking;
  1_Q_per_turn_enforced;
  Dunford_alternatives_include_status_quo_and_DIY_AI;
  AI_mirror_gap_checked;
  multi_founder_interviews_isolated_pre_reconcile;
}
§ANTI{
  start¬state_read;
  >1_Q/turn;
  Syn_pre_sat;
  skip_reconcile(group_first⇒anchoring);
  1_sess_rush_M90;
  generic_category_positioning_that_LLMs_blur;
}
§REL{
  comp_scope:[competitive-platform-analysis.md](competitive-platform-analysis.md);
  voice:[brand-voice.md](../../content-writing/references/brand-voice.md);
  geo:[seo](../../seo/SKILL.md);
}
