@REF:schema-design
§SCOPE{engine_selection,design_workflow,keys,indexing,scaling,anti_patterns,schema_review_checklist}
§CAT{
  Rel:PostgreSQL(18/19_def),MySQL(8.4/9.x),MariaDB(11.8/12.x),SQL_Server,SQLite/libSQL(local/edge);
  Doc:MongoDB,Firestore,CouchDB;
  KV_InMem:Redis(8),Valkey(9_BSD-3),DynamoDB,Memcached;
  Wide:Cassandra,ScyllaDB,HBase;
  OLAP_TS:ClickHouse(25/26,SharedMergeTree),TimescaleDB,DuckDB(embedded_OLAP),InfluxDB;
  Graph:Neo4j,Amazon_Neptune;
  Search:Elasticsearch,OpenSearch,Meilisearch;
  Vector:pgvector(PG),MariaDB_Vector(11.8+),Redis_8/Valkey_9_Vector,Qdrant,Milvus;
  NewSQL:CockroachDB,TiDB,Google_Spanner
}
§FLOW{1:Analysis(entities,rels,R/W_access,QPS,retention)→2:Conceptual(Mermaid_ERD)→3:Logical(SQL⇒3NF,denorm⇔measured_read_gain;NoSQL⇒embed_read_together,ref_unbounded|indep_updates)→4:Physical(types,constraints,idx,partition,RLS)}
§ID{
  default:`BIGINT GENERATED ALWAYS AS IDENTITY`(PG)∨`BIGINT UNSIGNED AUTO_INCREMENT`(MySQL/MariaDB);
  distributed:`UUIDv7`(time-ordered,B-tree_friendly;PG18+_native_`uuidv7()`,MySQL_`BINARY(16)`)¬random_UUIDv4_PK_on_high_write_tbls;
  public_opaque:expose_UUID/CUID/ULID_externally_or_map_separately¬leak_sequential_counts
}
§IDX{
  B-tree:eq+range+sort;
  Composite:EQ_cols_first→range/sort_last(selectivity_tiebreak_among_EQ;PG18+_skip_scan_assists_low_card_prefix);
  Covering:`INCLUDE(cols)`⇒index_only_scan;
  Partial:`WHERE active=true`/`deleted_at IS NULL`(↓size,↑write_perf);
  GIN/GiST:JSONB,arrays,FTS,range,geo;
  BRIN:huge_append_only_time_series;
  HNSW:vector_embeddings(pgvector,MariaDB_Vector)
}
§SCALE{
  Vert:CPU,RAM,IOPS,NVMe+AsyncIO;
  Horiz:read_replicas(pin_RYOW_to_primary),declarative_partitioning(range,hash,list→pruning+fast_drops),sharding(careful_shard_key);
  Pool:PgBouncer/Supavisor(txn_mode)_or_driver_pool;
  Cache:cache_aside|write_through(Redis_8|Valkey_9→`redis.md`)
}
§ANTI{`VARCHAR(255)`_∀⇒`TEXT`+`CHECK`(PG)|sized_field;`FLOAT`_money⇒rounding_err⇒`NUMERIC`/`DECIMAL`;¬FK⇒orphans⇒FK+`ON DELETE`+idx;str_date⇒¬sort/tz⇒`TIMESTAMPTZ`/`DATETIME`(UTC);random_UUIDv4_clustered_PK⇒page_splits⇒`UUIDv7`;deep_`OFFSET`⇒slow_scan⇒keyset_pagination;irrev_mig⇒¬recov⇒forward_plan+backup;full_DB_server_for_trivial_local⇒SQLite/DuckDB;`SELECT *`⇒IO+brittle⇒list_cols;N+1⇒round_trips⇒JOIN|eager}
§CHK{PK(BIGINT_or_UUIDv7)∈∀tbl;FK+`ON DELETE`+idx∈∀rel;composite_idx≡EQ→range/sort;`NUMERIC`/`DECIMAL`_money∧`TIMESTAMPTZ`/UTC_date;`NOT NULL`_req;`created_at`∧`updated_at`∈∀tbl;mig≡versioned+lock_timeout+back_compat;access_patterns⇒norm|denorm}
§REL{../SKILL.md;postgresql.md;mysql-patterns.md;clickhouse.md;redis.md;database-migration.md;database-optimization.md;prisma.md;drizzle-orm.md}
