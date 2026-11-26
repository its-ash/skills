@REF:postgresql
§SCOPE{PostgreSQL:schema,types,constraints,indexes,partitioning,RLS,extensions,evolution,diagnostics,tuning}
§R{
  pk:ref_tbls_req_PK;`BIGINT GENERATED ALWAYS AS IDENTITY` default;`UUID`(`uuid_generate_v4()`∨`gen_random_uuid()`) only_if(opaque∨global_uniq);
  norm:3NF_1st;denormalize_only_after_measured_read_gain;
  null_def:`NOT NULL`_req;`DEFAULT`_common;
  idx:actual_paths_only(PK/uniq,FK_cols,filters,sorts,joins);
  naming:unquoted_lower_snake_case(tbl,col);¬mixed_case∧¬quoted_ids;
  ver:migration_files;stage_before_prod;
  fk:explicit_idx_on_ref_col;`ON DELETE/UPDATE`;circular⇒`DEFERRABLE INITIALLY DEFERRED`;
  uniq_null:allows_multi_NULL;PG15+⇒`NULLS NOT DISTINCT`;
  chk_null:NULL_passes_`CHECK`⇒pair_`NOT NULL`;
  excl:overlap_guard(double_booking)⇒req_GiST;
  part:declarative_only(¬inheritance) if(rows>100M∨always_filter_part_key);part_key∈PK/UNIQUE(¬global_uniq);FKs_FROM_part_unsupported⇒triggers;
  rls:per_op(SELECT,INSERT,UPDATE,DELETE);session_id_via_`current_setting`∨fn;wrap_fn_in_`SELECT`(`(SELECT auth.uid())=user_id`)⇒eval_1x/query_¬1x/row;
  ddl:test_rollback(`BEGIN;ALTER TABLE...;ROLLBACK;`);`CREATE INDEX CONCURRENTLY`(¬blocks_writes,∉txn);volatile_default+`NOT NULL`⇒full_rewrite⇒stable_default⊕nullable→backfill→`SET NOT NULL`;drop_constraints_before_cols;`CREATE OR REPLACE FUNCTION` adds_overload⇒drop_old_sig;
  gen_col:`GENERATED ALWAYS AS(expr) STORED`;PG18+⇒`VIRTUAL`(on_read,0_storage);
  pool:`max_connections`~100+pooler(PgBouncer∨platform);size_from(RAM,workload)
}
§D{
  id:`BIGINT GENERATED ALWAYS AS IDENTITY`⊕`UUID` ¬`SERIAL`;
  int:`BIGINT`⊕`INTEGER`(small) ¬`SMALLINT`(unless_certain);
  float:`DOUBLE PRECISION`;exact⇒`NUMERIC`;
  str:`TEXT`+`CHECK(length(col)<=n)` ¬`VARCHAR(n)` ¬`CHAR(n)`;
  ci_text:`CITEXT`(CI_constraints)⊕expr_idx_`LOWER(col)`;
  money:`NUMERIC(p,s)` ¬`money`;
  ts:`TIMESTAMPTZ`(`now()`=txn_start,`clock_timestamp()`=wall_clock) ¬`timestamp` ¬`timetz`;
  bool:`BOOLEAN NOT NULL`(omit_NOT_NULL_if_tri_state);
  enum:`CREATE TYPE...AS ENUM`(stable_small)⊕`TEXT`+`CHECK`⊕lookup(evolving);
  array:`TYPE[]`+GIN(containment);ordered_lists_only¬relations;
  range:`tstzrange`,`daterange`,`numrange`+GiST;default_`[)`;
  net:`INET`,`CIDR`,`MACADDR`;
  geom:`POINT`,`LINE`,`POLYGON`,`CIRCLE`+GiST;GIS⇒PostGIS;
  fts:`TSVECTOR`+`TSQUERY`+GIN;always_lang(`to_tsvector('english',col)`);
  json:`JSONB`+GIN(plain_`JSON`_only_if_key_order_matters);
  vec:`vector`(pgvector);
  domain:`CREATE DOMAIN`(reusable_val);composite:`CREATE TYPE`(structured_col)
}
§PAT{
  idx:{`col=v∨col>v`:B-tree(`(col)`); `a=x AND b>y`:Composite(eq_1st,range_2nd→`(status,created_at)`); covering:`INCLUDE(name,created_at)`⇒index_only; partial:`WHERE deleted_at IS NULL`; expr:`LOWER(email)`(query_matches_expr); GIN:`JSONB`(@>⇒`jsonb_path_ops`_smaller),arrays,FTS; GiST:range,geom,`EXCLUDE`; BRIN:ordered_time_series(best_post_`CLUSTER`)};
  part:{RANGE:`PARTITION BY RANGE(created_at)`+`FOR VALUES FROM...TO...`; LIST:discrete(region); HASH:even_dist};
  rls:`ALTER TABLE tbl ENABLE ROW LEVEL SECURITY; CREATE POLICY user_access ON orders FOR SELECT TO app_user USING(user_id=current_setting('app.current_user_id')::bigint);`;
  jsonb_gen:`ALTER TABLE tbl ADD COLUMN price INT GENERATED ALWAYS AS((jsonb_col->>'price')::INT) STORED; CREATE INDEX ON tbl(price); -- CHECK(jsonb_typeof(col)='object')`;
  ins_heavy:{min_idx;`COPY`∨multi_row_`INSERT`;`UNLOGGED`_staging;drop_idx→load→recreate;part_time/hash};
  upd_heavy:{split_hot_cols(↓bloat);`fillfactor=90`_on_idx(HOT);¬update_indexed_cols;part_by_update_pattern};
  upsert:`UNIQUE`_idx_on_target→`ON CONFLICT(col1,col2) DO UPDATE SET...`(`EXCLUDED.col`)⊕`DO NOTHING`;
  keyset:`SELECT * FROM products WHERE id>$1 ORDER BY id LIMIT 20;` (¬`OFFSET`);
  queue:`UPDATE jobs SET status='processing' WHERE id=(SELECT id FROM jobs WHERE status='pending' ORDER BY created_at LIMIT 1 FOR UPDATE SKIP LOCKED) RETURNING *;`
}
§EXT{pgcrypto:`crypt()`,prefer_over_`uuid-ossp`;`uuid-ossp`:legacy_UUID;pg_trgm:fuzzy_`%`+GIN;citext:CI_col;`btree_gin`/`btree_gist`:mixed_GIN/GiST;hstore:KV(superseded_by_`jsonb`);timescaledb:auto_time_part,compression,continuous_aggs;postgis:GIS;pgvector:embeddings;pgaudit:audit_log}
§CMD{
  unindexed_fks:`SELECT c.conrelid::regclass AS tbl,a.attname AS col FROM pg_constraint c JOIN pg_attribute a ON a.attrelid=c.conrelid AND a.attnum=ANY(c.conkey) WHERE c.contype='f' AND NOT EXISTS(SELECT 1 FROM pg_index i WHERE i.indrelid=c.conrelid AND a.attnum=ANY(i.indkey));`;
  slow_q:`SELECT query,mean_exec_time,calls FROM pg_stat_statements WHERE mean_exec_time>100 ORDER BY mean_exec_time DESC;`;
  bloat:`SELECT relname,n_dead_tup,last_autovacuum FROM pg_stat_user_tables WHERE n_dead_tup>1000 ORDER BY n_dead_tup DESC;`
}
§CFG{`ALTER SYSTEM SET idle_in_transaction_session_timeout='30s'; ALTER SYSTEM SET statement_timeout='30s'; ALTER SYSTEM SET work_mem='8MB'; CREATE EXTENSION IF NOT EXISTS pg_stat_statements; REVOKE ALL ON SCHEMA public FROM public; SELECT pg_reload_conf();` (+`shared_preload_libraries` for `pg_stat_statements`)}
§CHK{capture(entities,access_patterns,rows,QPS,retention);`EXPLAIN`_confirms_idx;backup+rollback_before_destructive_DDL;doc_extensions+ver_reqs}
