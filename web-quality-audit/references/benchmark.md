@REF:benchmark
§REL{page:[performance.md](performance.md),[web-performance.md](web-performance.md);post:[canary-watch.md](canary-watch.md);pre:[browser-qa](../../unit-testing-patterns/references/browser-qa.md)}
§USE{PR_delta|baseline|"feels slow"|launch_gate|variant_speedup_loop}
§M1_PAGE{
  lab_targets:{LCP≤2.5s,CLS≤0.1,INP≤200ms,TBT≤200ms,FCP≤1.8s,TTFB≤800ms,weight<1MB,js_gz<200KB};
  log:{LH13_insights,css,img,3p_js,reqs,render_block,bfcache_status};
  ci_gate:LHCI(`@lhci/cli`+`lighthouserc.json` assertions per PR);
  field_ref:CrUX_API/CrUX_History_API(28d_rolling+40wk_history)∧CrUX_Vis(long_term_CWV_trend)
}
§M2_API{
  method:100+_req/ep→p50/p95/p99+size+status+conc→vs_SLA;
  quick_cli:oha(Rust_TUI_histograms):`oha -n 200 -c 10 http://localhost:3000/api/items`;
  scripted_ci:Grafana_k6(2.0+:JS/TS,`expect()`,OTel,Playwright_browser_perf,MCP):`k6 run --summary-export=bench.json load.js`;
  node_prog:autocannon:`npx autocannon -c 10 -a 100 http://localhost:3000/api/items`
}
§M3_BUILD{cold_build,incremental/HMR,tests,typecheck,lint,bundle_size_delta,docker_build}
§M4_DIFF{save(`benchmarks/baseline.json`∈Git)→Δ→remeasure(same_in,env,cold_vs_warm)→cmp(Metric,Before,After,Delta,Verdict∈{WARN,BETTER});CI:per_PR(LHCI+k6);post:[canary-watch.md](canary-watch.md);pre:+[browser-qa](../../unit-testing-patterns/references/browser-qa.md)}
§LOOP{
  req:{op,green_gate,metric∈{wall,p95,p99,rows/s,cost/run,mem,err_rate},baseline,budget:{max_var,time,spend,data_impact}};
  steps:1:baseline→2:bottleneck_evidence→3:1_hyp_variants→4:same_in_shape→5:reject_fail(correct|safe|repro)→6:promote_fast_safe→7:record(script/cmd/test/cfg/doc)→8:rerun_base+win;
  ledger:Variant|Hypothesis|Command|Time|Correct?|Notes;
  search:log_all;cmp_vs_last_winner(¬prev_only);holdout/replay;stop_if(noise∨fail_correct∨over_budget∨>1_unexplained_var);
  claim:"best measured safe variant"(¬"global optimum"_unless_exhaustive);
  gate:tests_pass∧delta_rep/explained∧rollback_clear∧in_VCS/runbook∧exact(cmds,metrics)
}
