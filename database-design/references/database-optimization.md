@REF:database-optimization

§USE{slow_queries|`EXPLAIN ANALYZE`∨indexing(high_traffic)∨N+1(ORM/GraphQL)∨scaling(partition/shard/read_replicas)∨prod_tuning∨cloud_native/HTAP_schemas∨multi_tier_cache}

§WF{
  1:assess(slow_qry_logs,`pg_stat_statements`[PG],Performance_Schema[MySQL],Cloud_Insights[AWS/Azure/GCP]);
  2:plan(`EXPLAIN ANALYZE`→check_scan[Seq_vs_Index]+join[Hash_vs_NestedLoop]+cost_bottlenecks);
  3:rewrite(subquery→JOIN|CTE,opt_window/recursive,keyset_pagination>`OFFSET`);
  4:index(B-tree[range/eq],GIN|GiST[FTS/JSONB],BRIN[huge_seq_tbl],composite[selectivity+qry_order],partial[↓size,↑write_perf]);
  5:validate(benchmark_old_vs_new@realistic_volume+concurrent_load)
}

§PAT{
  index_storage:{selectivity_first_in_composite,covering_indexes(avoid_heap_fetches),¬over_index(read_vs_write_overhead;drop_unused/redundant),smallest_sufficient_types(↓I/O+RAM)};
  app:{N+1_fix(eager_load:`JOIN FETCH`|`select_related`|`prefetch_related`∨GraphQL_`DataLoader`),conn_pool(tune_size+timeouts→¬exhaustion),short_tx(↓lock_contention,¬deadlocks)};
  scale_cache:{read_replicas(manage_eventual_consistency),write_scale(batch,async_writes,sharding),partitioning(range|hash|list→maintainability+pruning),cache_tiers:{L1:app_in_memory,L2:Redis|Memcached(Cache-Aside|Write-Through),L3:DB_buffer_pool}}
}

§DB{
  PG:{tune(`shared_buffers`,`work_mem`,`effective_cache_size`∝RAM),`autovacuum`(¬bloat,fresh_stats),`ANALYZE`(regular_planner_stats)};
  Cloud(Aurora,Snowflake,BigQuery):{columnar_storage(OLAP),auto_scale(elastic_pools|serverless),cost_ctrl(track_resource_metrics)}
}

§ANTI{index_every_col(↑write_latency+storage)|ignore_stats_or_actual_plans|over_normalize(excessive_JOINs→strategic_denormalize)|heavy_OLAP_on_prod(use_limits|read_replicas)}
§CHK{slow_queries_profiled;plans_analyzed;indexes_match_queries;N+1_eliminated;DB_config_tuned_to_instance;Vacuum/Analyze_automated;regression_alerts_configured;partition/shard_plan_documented}
§REL{[database-design](../SKILL.md)|[database-migration](database-migration.md)|[performance](../../web-quality-audit/references/performance.md)|[django](../../backend-development/references/django.md)|[prisma](prisma.md)}
