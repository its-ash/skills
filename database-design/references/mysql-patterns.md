@REF:mysql-patterns
§SCOPE{MySQL∨MariaDB:schema,migrations,slow_queries,txns/queues,pools,replicas,TLS,slow_log}
§R{
  ver_1st:MySQL≠MariaDB⇒`SELECT VERSION(); SHOW VARIABLES LIKE 'version_comment';`;
  upsert_eng:MySQL⇒`AS new`+`new.col`(`VALUES(col)` deprecated);MariaDB∨mixed⇒`VALUES(col)`;
  skip_locked:queue_only(skips_locked⇒inconsistent_view)⇒¬accounting∧¬integrity_reads;
  idx:¬blind_idx(↑writes,mig_time,backup_size,buffer_pool);index_FK_cols;order:eq→range/sort(`(account_id,status,created_at)`);
  json:ext_data_only;relational:{FKs,ownership,tenancy,lifecycle};
  fts_limit:built_in_FTS⇒¬(typo_tolerance∨complex_ranking∨cross_table_facets∨lang_analysis)⇒ext_search;
  txn:short_txns∧deterministic_lock_order∧ext_API_BEFORE_txn∧index(UPDATE/DELETE/locking_WHERE);
  deadlock:rollback+retry_whole_txn(bounded_budget);capture_promptly(`SHOW ENGINE INNODB STATUS\G` overwritten_fast);
  pool:`pool_recycle<wait_timeout`(e.g.300s⇒240s)∧`pool_pre_ping=True`;
  explain_analyze:executes_stmt⇒safe_env_only(expensive_prod);
  replica:pin_to_primary(read_your_own_write,checkout,authz,idempotency_reads);monitor(SQL_thread,IO_thread,lag)¬TCP_only;`SHOW SLAVE STATUS\G`(legacy_MySQL)⊕`SHOW REPLICA STATUS\G`(newer);
  sec:¬`ALL PRIVILEGES`∧¬`*.*`→app_user;¬DML_on_`mysql.user`(use_`CREATE/ALTER/DROP USER`);TLS_cross_host;secrets∈secret_manager(¬repo/scripts/examples);split(admin/mig,runtime);audit_bind_addr_&_exposure_before_perf;
  hot_path:¬`SELECT *`(explicit_cols);¬deep_`OFFSET`(use_keyset);
  cfg_size:size_from(workload,hardware,backup,RPO/RTO)¬preset
}
§D{
  PK:BIGINT UNSIGNED AUTO_INCREMENT ¬INT(>2B_rows);
  UUID:BINARY(16)+helpers ¬VARCHAR(36)_PK_hot;
  money:DECIMAL(p,s) ¬FLOAT/DOUBLE;
  text:utf8mb4(tbl+idx) ¬utf8/utf8mb3;
  ts:DATETIME(app_UTC)∧¬TZ_meta;
  soft_del:deleted_at DATETIME NULL+scoped_idx ¬unindexed_filter;
  enum:lookup_tbl⊕constrained_VARCHAR ¬ENUM(volatile)
}
§PAT{
  tbl:`CREATE TABLE orders(id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,account_id BIGINT UNSIGNED NOT NULL,status VARCHAR(32) NOT NULL,total DECIMAL(15,2) NOT NULL,created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,deleted_at DATETIME NULL,KEY(account_id,status,created_at),KEY(account_id,deleted_at)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;`;
  upsert:`INSERT INTO t(k1,k2,v) VALUES(?,?,?) [AS new] ON DUPLICATE KEY UPDATE v={VALUES(v)|new.v},updated_at=CURRENT_TIMESTAMP;`;
  keyset:`CREATE INDEX idx_cr_id ON products(created_at,id); SELECT id,name,created_at FROM products WHERE(created_at,id)<(?,?) ORDER BY created_at DESC,id DESC LIMIT 50;`;
  json_idx:`event_type VARCHAR(64) GENERATED ALWAYS AS(JSON_UNQUOTE(JSON_EXTRACT(payload,'$.type'))) STORED,KEY(event_type)`;
  fts:`ALTER TABLE articles ADD FULLTEXT KEY ft_art(title,body); SELECT id,title,MATCH(title,body) AGAINST(? IN NATURAL LANGUAGE MODE) AS score FROM articles WHERE MATCH(title,body) AGAINST(? IN NATURAL LANGUAGE MODE) ORDER BY score DESC LIMIT 20;`;
  txn:`START TRANSACTION; SELECT id,balance FROM accounts WHERE id IN(?,?) ORDER BY id FOR UPDATE; UPDATE accounts SET balance=balance±? WHERE id=?; COMMIT;`;
  queue:`START TRANSACTION; SELECT id FROM jobs WHERE status='pending' ORDER BY created_at LIMIT 1 FOR UPDATE SKIP LOCKED; UPDATE jobs SET status='processing',started_at=CURRENT_TIMESTAMP WHERE id=?; COMMIT;`;
  pool_py:`sqlalchemy.create_engine("mysql+mysqlconnector://...",pool_size=10,max_overflow=5,pool_timeout=30,pool_recycle=240,pool_pre_ping=True,connect_args={"connect_timeout":5})`;
  pool_js:`mysql2/promise.createPool({host,user,password,database,waitForConnections:true,connectionLimit:10,queueLimit:0,enableKeepAlive:true,keepAliveInitialDelay:30000})`+`pool.execute('SELECT ... WHERE account_id=? LIMIT 50',[accountId])`
}
§CMD{
  diag:`SHOW FULL PROCESSLIST; SHOW ENGINE INNODB STATUS\G; SHOW VARIABLES LIKE 'slow_query_log'; SHOW VARIABLES LIKE 'long_query_time';`;
  explain_warn:{`type=ALL`(large_tbl),`key=NULL`(selective_pred),`rows`≫interactive,`Extra`∈{`Using temporary`,`Using filesort`,broad `Using where`}};
  slow_on:`SET GLOBAL slow_query_log='ON'; SET GLOBAL long_query_time=1; SET GLOBAL log_queries_not_using_indexes='ON';`;
  sec:`CREATE USER 'app'@'%' IDENTIFIED BY '<secret>'; GRANT SELECT,INSERT,UPDATE,DELETE ON appdb.* TO 'app'@'%'; ALTER USER 'app'@'%' REQUIRE SSL; SELECT user,host FROM mysql.user WHERE user=''; DROP USER IF EXISTS ''@'localhost',''@'%';`
}
§CFG{`[mysqld]`:`innodb_buffer_pool_size=4G;innodb_flush_log_at_trx_commit=1;sync_binlog=1;max_connections=300;thread_cache_size=50;wait_timeout=300;interactive_timeout=300;innodb_lock_wait_timeout=10;slow_query_log=ON;long_query_time=1;log_queries_not_using_indexes=ON;log_bin=mysql-bin;binlog_format=ROW;binlog_expire_logs_seconds=604800`}
§OUT{review:[engine/ver,top_risks(correctness,lock,sec,migration),exact_SQL/code_fixes,validation(EXPLAIN,mig_dry_run,lock/deadlock_chk,rollback),MySQL_vs_MariaDB_diffs]}
§REL{database-design/references/postgresql.md;database-design/references/database-migration.md;backend-development/SKILL.md;secure-coding/SKILL.md}
