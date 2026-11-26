@REF:latency-critical-systems
§SCOPE{target:realtime_dashboards∨market_data_feeds∨streaming_agents∨exec_gateways∨queues∨caches;use⇔(p50|p95|p99_latency∨throughput∨freshness_age)∈critical∨opt(hot_path|stream|queue|cache)∨post_deploy_verify(realtime);boundary:eng_only∧¬authorize(live_trading)∧¬financial_advice}
§MTR{¬collapse:"fast";track:{p50,p95,p99_latency,throughput,freshness_age,queue_depth,cache_hit_rate,provider_api_rt,browser_render_time,load_correctness,failure_retry}}
§PATH{hot:src_event→provider_API→ingest_worker→queue→cache→edge_route→client_stream→browser_render→visible_state;rule:measure(∀segment)∈separate}
§OPT{1:rm(unneeded_round_trips);2:cache(stable_reads)+freshness_meta;3:batch(small_calls∧writes);4:compute_closer(data∨user);5:split(hot,cold);6:backpressure(pre_unbounded_queue);7:stream⇔improves(freshness∨UX);8:canary({stale_data,degraded_provider,bad_cache})}
§CHK{deployed⇒live_readback:{http_timing∧resp_hdrs,provider_freshness_ts,queue|job_state,edge|cache_state,browser_UI_freshness,logs(retries∧degraded_mode)};mkt_data∨exec_adj⇒verify:{orderbook_age,VWAP_assumptions,provider_status,kill_switch}}
§ANTI{¬drop(req_val)→opt_latency;¬hide(stale_data)∈fast_cache_hits;¬claim(ms)←client_labels∧¬measured;¬run({live_orders,destructive_migrations,cust_impacting_deploys})∧¬approval_gate;{secrets,private_payloads}∉{logs,bench_artifacts}}
§REL{[benchmark.md](benchmark.md):baselines∧opt_loop;[canary-watch.md](canary-watch.md):stale_data∧degraded_provider_canaries;[observability](../../devops-iac/references/observability.md):latency_dashboards∧alerts}
