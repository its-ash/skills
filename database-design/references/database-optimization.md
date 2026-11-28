@REF:database-optimization
§USE{slow_queries|`EXPLAIN (ANALYZE,BUFFERS)`∨indexing(high_traffic)∨N+1(ORM/GraphQL)∨scaling(partition/shard/read_replicas)∨prod_tuning∨vector_HNSW∨multi_tier_cache}
§WF{
  1:assess(slow_qry_logs,`pg_stat_statements`[PG],Performance_Schema[MySQL],`system.query_log`[ClickHouse],Cloud_Insights[AWS/Azure/GCP]);
  2:plan(PG⇒`EXPLAIN (ANALYZE,BUFFERS)`[check_shared_hit_vs_read,Seq_vs_Index,Hash_vs_NestedLoop,row_est_drift,disk_spill];MySQL⇒`EXPLAIN`[safe_env_for_`EXPLAIN ANALYZE`]);
  3:rewrite(subquery→JOIN|CTE,opt_window/recursive,keyset_pagination>`OFFSET`,explicit_cols¬`SELECT *`);
  4:index(B-tree[EQ_first→range/sort],covering[`INCLUDE`],GIN|GiST[FTS/JSONB/range],BRIN[append_only_ts],partial[↓size,↑write_perf],HNSW[pgvector/MariaDB_Vector]);
  5:validate(benchmark_old_vs_new@realistic_volume+concurrent_load)
}
§PAT{
  index_storage:{ESR_order(EQ_cols_first→range/sort_last;sel_tiebreak_among_EQ;PG18+_skip_scan_helps_trailing_cols_on_low_card_prefix),covering_indexes(avoid_heap_fetches),¬over_index(read_vs_write_overhead;drop_unused/redundant_idx),UUIDv7_over_UUIDv4(sequential_B-tree/clustered_locality),smallest_sufficient_types(↓I/O+RAM)};
  app:{N+1_fix(eager_load:`JOIN FETCH`|`select_related`|`prefetch_related`|Drizzle_`db.query.*`∨GraphQL_`DataLoader`),conn_pool(PgBouncer/Supavisor_txn_mode∨driver_pool;watch_prepared_stmts_&_session_vars),short_tx(↓lock_contention,¬ext_HTTP_in_tx,¬deadlocks)};
  scale_cache:{read_replicas(pin_read_your_own_write_to_primary),write_scale(batch,async_writes,sharding),partitioning(range|hash|list→pruning+retention_drops),cache_tiers:{L1:app_in_memory,L2:Redis_8|Valkey_9(Cache-Aside|Write-Through+stampede_lock),L3:DB_buffer_pool}};
  vector:{pgvector_HNSW(tune_`m`,`ef_construction`,`hnsw.ef_search`;filter_selectivity⇒iterative_scans_or_pre-partition);MariaDB_11.8+_SIMD_Vector;Redis_8/Valkey_9_Vector_Sets_for_low_latency}
}
§DB{
  PG(18/19):{tune(`shared_buffers`,`work_mem`,`effective_cache_size`∝RAM),PG18+_AsyncIO(`io_method`⇒faster_scans/vacuum),PG19+_parallel_idx_autovacuum+native_`REPACK`(¬`VACUUM FULL`),`ANALYZE`(fresh_planner_stats)};
  MySQL/MariaDB:{`innodb_buffer_pool_size`(~60-75%_RAM),`io_uring`,clustered_PK_sequential(BIGINT|UUIDv7),`Performance_Schema`+slow_log};
  Cloud/OLAP(ClickHouse,Aurora,Snowflake,BigQuery):{columnar_storage(ClickHouse_SharedMergeTree,low_to_high_card_ORDER_BY),auto_scale(elastic_pools|serverless),cost_ctrl(track_read_bytes)}
}
§ANTI{index_every_col(↑write_latency+storage)|range_col_before_EQ_in_composite|random_UUIDv4_clustered_PK|ignore_BUFFERS_or_row_est_drift|over_normalize(excessive_JOINs→measured_denormalize)|heavy_OLAP_on_OLTP_primary(read_replicas|ClickHouse)|deep_OFFSET_pagination}
§CHK{slow_queries_profiled;plans_with_BUFFERS_analyzed;indexes_follow_EQ→range/sort;unused_indexes_pruned;N+1_eliminated;pool_tuned(serverless/txn_mode);DB_config_tuned(RAM/AsyncIO);Vacuum/Analyze/Repack_automated;regression_alerts_configured}
§REL{../SKILL.md;postgresql.md;mysql-patterns.md;clickhouse.md;redis.md;database-migration.md;prisma.md;../../web-quality-audit/references/performance.md;../../backend-development/references/django.md}
