@REF:runtime-diagnostics
§R{
  Node_LTS(2026):v26_Active_LTS∧v24_v22_Maint_LTS⇒use_builtin_flags(`--inspect-wait`,`--enable-source-maps`,`--report-on-fatalerror`);
  Python_3.14_3.15⇒prefer_zero_restart_live_attach(`pdb -p`,Tachyon_`profiling.sampling`,`memray attach`)¬restart_prod;
  native_sanitizers⇒run_ASan+UBSan_separately_from_TSan(shadow_memory_conflict);
  Linux_sockets⇒use_`ss`(iproute2_netlink_sock_diag)¬deprecated_`netstat`(slow_procfs_scan);
  latency_triage⇒correlate_OTel_spans+eBPF_OBI_pre_queue_wait∧split_On-CPU_vs_Off-CPU_wall_clock
}
§D{
  short_lived_Node_script⇒`--inspect-wait`(waits_for_attach,¬forced_line1_break)¬`--inspect`;
  TS_or_bundled_Node_stack⇒`NODE_OPTIONS="--enable-source-maps"`¬debug_compiled_lines;
  Node_thrown_far_from_Error_init⇒`--trace-uncaught`(dev_only;GC/perf_cost)¬prod_always_on;
  Node_OOM_or_native_crash⇒`--report-on-fatalerror`+`--report-uncaught-exception`¬silent_exit;
  Node_prod_mem_leak⇒`--heapsnapshot-signal=SIGUSR2`∨`--heap-prof`+V8_3_snapshot¬attach_open_inspector_port;
  Node_low_overhead_telemetry⇒`node:diagnostics_channel`+`util.debuglog`¬unconditional_console_log;
  Py_3.14+_live_stuck_proc⇒`python -m pdb -p <pid>`∨`sys.remote_exec`(PEP_768)¬kill_and_restart;
  Py_3.15+_CPU_IO_GIL_profile⇒Tachyon_`python -m profiling.sampling {run|attach|dump|replay}`(PEP_799)¬heavy_`cProfile`;
  Py_segfault_or_C_ext_abort⇒`python -X faulthandler`¬unlogged_crash;
  Py_mem_leak_incl_C_ext⇒`memray attach <pid> -o out.bin`→`memray flamegraph out.bin`¬tracemalloc_only;
  C_Cpp_Rust_mem_or_UB⇒`-fsanitize=address,undefined`∨`cargo miri test`¬printf_guessing;
  C_Cpp_Go_data_race⇒`-fsanitize=thread`(TSan)∨`go test -race ./...`¬sleep_retries;
  non_deterministic_native_crash⇒`rr record`→`rr replay`(`reverse-continue`,`watch -l`)¬repeat_live_runs;
  app_logs_clean_but_tail_latency⇒`bpftrace`+`ss -tin`+Off-CPU_profiler+OTel_OBI¬optimize_On-CPU_only
}
§PAT{
  V8_3_snapshot:snap1(baseline)→run_action→snap2→repeat_or_reverse→snap3⇒inspect_objects_allocated_1→2_retained_in_3;
  Node_diag_channel:`import dc from 'node:diagnostics_channel'; const ch=dc.channel('app:db'); if(ch.hasSubscribers) ch.publish(ctx);`;
  Node_debuglog:`import {debuglog} from 'node:util'; const dbg=debuglog('app:db');`→enable_via_`NODE_DEBUG=app:*`;
  prod_triage_order:1:OTel_trace(isolate_service)→2:eBPF_OBI(check_pre_queue_pool_wait)→3:`ss -tin`(TCP_retrans_RTT)→4:`bpftrace`/wall_clock_prof;
  ptrace_guard:live_attach(`pdb -p`,`memray attach`,`rr`)⇒verify_matching_uid∧Linux_Yama_ptracer_scope(e.g.`setpriv --ptracer any`)
}
§CMD{
  node_inspect:`node --inspect-wait app.js`∧`node --inspect-brk app.js`;
  node_prof:`node --cpu-prof --cpu-prof-dir=./prof app.js`∧`node --heap-prof app.js`;
  node_snap_live:`node --heapsnapshot-signal=SIGUSR2 app.js`→`kill -SIGUSR2 <pid>`;
  node_crash_trace:`node --enable-source-maps --report-on-fatalerror --trace-uncaught app.js`;
  node_deps:`npm ls <pkg>`∧`npm ls --depth=0`;
  py_live_attach:`python -m pdb -p <pid>`∧`python -X faulthandler app.py`;
  py_tachyon:`python -m profiling.sampling attach <pid>`∧`python -m profiling.sampling dump <pid>`∧`python -m profiling.sampling run app.py`;
  py_memray:`memray attach <pid> -o leak.bin`→`memray flamegraph leak.bin`;
  py_deps:`uv tree`∧`pip show <pkg>`;
  sanitizers_cc:`clang -g -O1 -fsanitize=address,undefined -fno-omit-frame-pointer`∧`clang -g -O1 -fsanitize=thread`;
  time_travel_rr:`rr record ./bin --args`→`rr replay`(gdb:`reverse-continue`,`watch -l var`);
  go_rust:`go test -race ./...`∧`RUST_BACKTRACE=1 cargo test`∧`cargo miri test`;
  linux_net:`ss -tulpn`(listening_ports+PID)∧`ss -tin`(TCP_RTT_cwnd_retrans);
  host_sys:`lsof -i :<port>`∧`df -h`∧`free -h`(Linux)∧`vm_stat`(macOS)∧`env | grep VAR`∧`printenv VAR`
}
§CFG{
  node_env:`NODE_OPTIONS="--enable-source-maps --report-on-fatalerror --heapsnapshot-signal=SIGUSR2"`∧`NODE_DEBUG="app:*"`;
  py_monitoring:Python_3.12+_tools_use_`sys.monitoring`¬legacy_`sys.settrace`
}
§ANTI{
  combining_ASan_TSan⇒incompatible_shadow_memory⇒build_separate_ASan+UBSan_and_TSan_targets;
  netstat_on_busy_host⇒sequential_procfs_read_spikes_CPU⇒use_`ss -tulpn`/`ss -tin`;
  on_cpu_tunnel_vision⇒optimizing_hot_CPU_when_threads_block_on_locks_sockets_or_DB_pool_queues;
  OTel_SDK_blind_spot⇒assuming_in_app_span_duration≡client_latency_while_missing_pre_queue_wait;
  trace_uncaught_in_prod⇒GC_and_runtime_overhead⇒restrict_`--trace-uncaught`_to_dev_or_canary
}
§CHK{
  1:enable_source_maps_and_symbols_before_reading_traces;
  2:capture_live_state(heap/stack/trace/TCP)≺restarting_failing_process;
  3:separate_On-CPU_vs_Off-CPU_and_pre-queue_wait_for_latency;
  4:run_appropriate_sanitizer_or_replay_for_memory_and_concurrency_bugs;
  5:verify_leak_via_3_snapshot_or_allocation_flamegraph_retainer_path
}
