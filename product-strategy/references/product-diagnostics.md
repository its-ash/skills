@REF:product-diagnostics
§R{∀mode→actionable_doc;∀rec→1_next_step}
§PAT{
  M1_YC(1_Q/turn):[1:who(person,¬"developers"),2:pain(freq,sev,workaround),3:why_now,4:10star(∞_$/t),5:MVP(min_proof),6:anti_goal(¬build),7:metric(¬vibes)]→`PRODUCT-BRIEF.md`({ans,risks,go/no-go});ask_pre_write;"go"→[product-capability.md](product-capability.md);
  M2_founder:[1:read(README,CLAUDE.md,package.json,commits),2:intent,3:PMF(0-10):{growth,retention(contribs,ret),rev(pricing,billing,Stripe),moat},4:1_10x_lever,5:flag_waste];
  M3_journey:[1:install_new,2:friction(confuse,err,docs),3:time_steps,4:cmp_comp,5:TTV(1st_win),6:top3_fixes];qa→[browser-qa.md](../../unit-testing-patterns/references/browser-qa.md);
  M4_ICE:[1:feats,2:ICE=impact(1-5)×confidence(1-5)÷effort(1-5),3:rank,4:constraints(runway,team,deps),5:roadmap+rationale];
}
