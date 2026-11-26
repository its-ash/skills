@REF:benchmark
§REL{page:[performance.md](performance.md),[web-performance.md](web-performance.md);post:[canary-watch.md](canary-watch.md);pre:[browser-qa](../../unit-testing-patterns/references/browser-qa.md)}
§USE{PR_delta|baseline|"feels slow"|launch_gate|variant_speedup_loop}
§M1_PAGE{targets:{LCP<2.5s,CLS<0.1,INP<200ms,FCP<1.8s,TTFB<800ms,weight<1MB,js_gz<200KB};log:{css,img,3p_js,reqs,render_block}}
§M2_API{100_req/ep→p50/p95/p99+size+status+10_conc→vs_SLA;cmd:`npx autocannon -c 10 -a 100 http://localhost:3000/api/items`}
§M3_BUILD{cold_build,HMR,tests,typecheck,lint,docker_build}
§M4_DIFF{save(`benchmarks/baseline.json`∈Git)→Δ→remeasure(same_in,env)→cmp(Metric,Before,After,Delta,Verdict∈{WARN,BETTER});CI:per_PR;post:canary-watch.md;pre:+browser-qa.md}
§LOOP{
  req:{op,green_gate,metric∈{wall,p95,rows/s,cost/run,mem,err_rate},baseline,budget:{max_var,time,spend,data_impact}};
  steps:1:baseline→2:bottleneck_evidence→3:1_hyp_variants→4:same_in_shape→5:reject_fail(correct|safe|repro)→6:promote_fast_safe→7:record(script/cmd/test/cfg/doc)→8:rerun_base+win;
  ledger:Variant|Hypothesis|Command|Time|Correct?|Notes;
  search:log_all;cmp_vs_last_winner(¬prev_only);holdout/replay;stop_if(noise∨fail_correct∨over_budget∨>1_unexplained_var);
  claim:"best measured safe variant"(¬"global optimum"_unless_exhaustive);
  gate:tests_pass∧delta_rep/explained∧rollback_clear∧in_VCS/runbook∧exact(cmds,metrics)
}
