@REF:data-throughput-accelerator
§CTX{Data movement(ingest|backfill|export|ETL|wh_load|manifest_catchup|sync)⇒max_speed∧correct(counts∧ts_agree+proof)}

§D{
  isolate:{src_extract,net_xfer,wh_load,transform,serving_freshness,live_tail_growth};
  tail_trap:arrival_rate>catchup_win⇒fast_pipe_looks_behind;
  fast:{compute→data_locality;wh_native(scans|joins|appends)_large_files;manifest|ckpt→skip_done;part+cluster∼read_append;batch(files|reqs|writes);idemp(uniq_keys|manifest|replace_stage);sep_acct(raw,derived,serving)}
}

§PAT:wf{
  1:read_contracts(src,tgt,manifest)→2:measure_backlog(ext_files,manifest_rows,raw_rows,derived_rows,min_max_ts,unprocessed)→3:bench(catchup∨sample)→4:compare(batch,workers,wh_sql,file_grp,stage_shape,manifest_upd)→5:promote⇔(counts∧ts_coherent)→6:codify(CLI|sched|wf|runbook)→7:rerun_final_acct
}

§CHK:acct{Data throughput result: Source files discovered:<N> | Files processed this run:<N> | Raw rows added:<N> | Derived rows added:<N> | Remaining tail:<N> files at readback time | Runtime:<t> | Correctness gate: manifest counts and table max timestamps match}

§ANTI{¬del_raw_for_metrics;¬silent_skip_failed;¬mix(backfill,live_tail);¬done_until(tgt≡manifest);regulated∈{finance,healthcare,customer_impacting}⇒preserve(replay_evidence∧approval_gates)}
