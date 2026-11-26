@REF:prediction-market-oracle-research
§SCOPE{pred_mkts∈{data,forecast,oracle_sig,decision_intel}→{prod,agent,dash};grounded(probs+caveats)}
§R{¬(px≡truth);¬inv_advice∧¬trade_recs;sep({venue_mech,liq,incentives,res_rules},sig);flag({manip,thin_liq,stale,ambig});onchain∨exec⇒apply([llm-trading-agent-security.md](llm-trading-agent-security.md)∧[prediction-market-risk-review.md](prediction-market-risk-review.md))@pre_write_auth}
§WF{1:def(decision);2:find(mkts,events,tags,venues);3:log(probs+ts+links);4:eval({liq,spread,age,conc?,res_auth,geo_acct_lim});5:cmp(filings,news,polls,research,cust_data,KPIs);6:rate∈{usable,weak,unsuitable}}
§PAT{asst:ctx→analyst;dash:prob+KPI;mem:ts_sig;alert:thresh(prob|spread|liq);scenario:cmp_outcomes∧¬auto_trade}
§OUT{1:decision_context,2:market_sources,3:signal_quality,4:comparison_sources,5:integration_recommendation,6:caveats;end:`Prediction-market signals are informational inputs, not investment advice.`}
