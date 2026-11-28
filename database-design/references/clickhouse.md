@REF:clickhouse
§USE{ClickHouse(25/26):schema(SharedMergeTree|MergeTree)∨analytics_qry(agg,window,join)∨qry_opt(partition_prune,projections,MV,Refreshable_MV)∨bulk_ingest(batch,async_insert,Kafka)∨migrate(PG|MySQL→ClickHouse)∨realtime_dashboards|timeseries}
§CORE{columnar_OLAP_DBMS;compression;parallel_exec;distributed_qry;compute_storage_sep(SharedMergeTree);realtime_analytics}
§ENG{
  SharedMergeTree(cloud_native_def):replaces_`ReplicatedMergeTree`_on_shared_object_storage(S3/GCS/Azure)+ClickHouse_Keeper(¬replica_to_replica_comm,higher_insert_throughput,fast_merges,100s_replicas);
  MergeTree(single_node)|ReplicatedMergeTree(self_hosted_HA):`CREATE TABLE markets_analytics(date Date,market_id LowCardinality(String),market_name String,volume UInt64,trades UInt32,unique_traders UInt32,avg_trade_size Float64,created_at DateTime) ENGINE=MergeTree() PARTITION BY toYYYYMM(date) ORDER BY (market_id,date) SETTINGS index_granularity=8192`;
  ReplacingMergeTree(async_dedup):`CREATE TABLE user_events(event_id String,user_id String,event_type LowCardinality(String),timestamp DateTime,properties JSON,ver UInt64) ENGINE=ReplacingMergeTree(ver) PARTITION BY toYYYYMM(timestamp) ORDER BY (event_type,user_id,event_id)` (dedup_on_bg_merge⇒query_w/_`argMax(col,ver)`∨scoped_`FINAL`);
  AggregatingMergeTree(pre_agg):`CREATE TABLE market_stats_hourly(hour DateTime,market_id LowCardinality(String),total_volume AggregateFunction(sum,UInt64),total_trades AggregateFunction(count,UInt32),unique_users AggregateFunction(uniq,String)) ENGINE=AggregatingMergeTree() PARTITION BY toYYYYMM(hour) ORDER BY (market_id,hour)`→`sumMerge(total_volume),countMerge(total_trades),uniqMerge(unique_users) WHERE hour>=toStartOfHour(now()-INTERVAL 24 HOUR) GROUP BY hour,market_id ORDER BY hour DESC`;
  native_JSON:v25+/26_`JSON`_column_type⇒columnar_semi_structured_storage(¬`String`+`JSONExtract*`_parse_overhead)
}
§QRY{
  filter:order_key_prefix_first(`market_id='m123' AND date>='2026-01-01' AND volume>1000 ORDER BY date DESC LIMIT 100`)∧¬non_indexed_scan_only;
  agg:`toStartOfDay(created_at) day,market_id,sum(volume),count(),uniq(trader_id),avg(trade_size) WHERE created_at>=today()-INTERVAL 7 DAY GROUP BY day,market_id ORDER BY day DESC,sum(volume) DESC`;
  pct:`quantile(0.50|0.95|0.99)(trade_size) WHERE created_at>=now()-INTERVAL 1 HOUR`≻`percentile`;
  window:`sum(volume) OVER (PARTITION BY market_id ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) WHERE date>=today()-INTERVAL 30 DAY ORDER BY market_id,date`
}
§ING{
  client:`@clickhouse/client`:`createClient({url:CLICKHOUSE_URL??'http://localhost:8123',username:CLICKHOUSE_USER,password:CLICKHOUSE_PASSWORD})`;
  batch:`clickhouse.insert({table:'trades',values:rows.map(r=>({...r,timestamp:r.timestamp.toISOString()})),format:'JSONEachRow'})`;
  stream:`node:stream`:`Readable.from(asyncIter,{objectMode:true})`→`values` (`format:'JSONEachRow'`);
  async_insert:high_concurrency_small_writes⇒enable_`async_insert=1`(buffers_in_mem→batched_parts,adaptive_busy_timeout,`wait_for_async_insert=1` for_durability)¬unbatched_sync_1row_inserts
}
§MV{
  incremental(on_INSERT,pre_agg):`CREATE MATERIALIZED VIEW market_stats_hourly_mv TO market_stats_hourly AS SELECT toStartOfHour(timestamp) hour,market_id,sumState(amount),countState(),uniqState(user_id) FROM trades GROUP BY hour,market_id`→query_target_with_`sumMerge`|`countMerge`|`uniqMerge`;
  refreshable(v26+_GA,scheduled_joins_or_global_agg):`CREATE MATERIALIZED VIEW mv_daily_rollup REFRESH EVERY 1 HOUR TO daily_rollup AS SELECT ...` (atomic_swap_or_`APPEND`,experimental_flags_deprecated,native_`Atomic`/`Replicated`_DBs)
}
§MON{
  slow:`system.query_log`(`query_id,user,query,query_duration_ms,read_rows,read_bytes,memory_usage WHERE type='QueryFinish' AND query_duration_ms>1000 AND event_time>=now()-INTERVAL 1 HOUR ORDER BY query_duration_ms DESC LIMIT 10`);
  stats:`system.parts`(`database,table,formatReadableSize(sum(bytes)) size,sum(rows) rows,max(modification_time) latest_mod WHERE active GROUP BY database,table ORDER BY sum(bytes) DESC`)
}
§ANL{
  DAU:`toDate(timestamp) d,uniq(user_id) WHERE timestamp>=today()-INTERVAL 30 DAY GROUP BY d`;
  retention:`signup,countIf(days=0|1|7|30)`←sub(`min(toDate(timestamp)) signup,toDate(timestamp) act,dateDiff('day',signup,act) days GROUP BY user_id,act`)` GROUP BY signup ORDER BY signup DESC`;
  funnel:`countIf(step='viewed_market') v,countIf(step='clicked_trade') c,countIf(step='completed_trade') d,round(c/v*100,2),round(d/c*100,2) WHERE event_date=today() GROUP BY session_id`;
  cohort:`toStartOfMonth(signup) cohort,toStartOfMonth(act) month,dateDiff('month',cohort,month) m,count(DISTINCT user_id)`←sub(`min(toDate(timestamp)) OVER (PARTITION BY user_id) signup,toDate(timestamp) act`)` GROUP BY cohort,month,m ORDER BY cohort,m`
}
§PIPE{
  ETL:PG_extract→transform→bulkInsert(10k-100k_rows/batch)∨ClickPipes/PeerDB;
  CDC:Kafka_engine|ClickPipes|PeerDB_preferred;if_app_buffer⇒batch_events_or_`async_insert=1`(¬sync_1row_insert_per_NOTIFY)
}
§R{partition:by_time(month|day)∧Date_type∧¬many_partitions(100s_max,not_1000s);order_key:most_filtered_first∧low_to_high_cardinality(better_prefix_skip+columnar_compression);types:smallest(`UInt32`<`UInt64`)∧`LowCardinality`(repeated_str)∧`Enum`(categorical)∧native_`JSON`(semi_structured);monitor:{qry_perf,disk,merges,parts_count,slow_log}}
§ANTI{`SELECT *`|blind_`FINAL`_on_huge_tbls|excess_JOINs(denormalize_or_Refreshable_MV)|sync_1row_inserts(batch_or_`async_insert=1`)|high_card_first_ORDER_BY|JSON_as_raw_String}
§REL{../SKILL.md;database-optimization.md;schema-design.md}
