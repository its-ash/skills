@REF:database-migration
§USE{schema_Δ(add,rename,modify)∨data_move|transform∨ORM_switch∨rollback_plan∨zero_downtime|blue_green|expand_contract}
§WF{1:clarify(schema,data,ORM,downtime)→2:backup(dump|snapshot)→3:write(versioned_script+lock_timeout)→4:tx(if_DB_supports∧¬CONCURRENTLY)→5:staging_test(prod_size,up+down,integrity)→6:deploy(CLI)→7:monitor(locks,logs,app_compat)→8:doc(why,revert)}
§ORM{
  Atlas(schema_as_code):`atlas migrate diff <name> --env local` | `atlas migrate lint --env local --latest 1` | `atlas migrate apply --env prod`;
  Flyway|Liquibase|Alembic:versioned_SQL/Py_migrations+CI_checksum_validation;
  Prisma_7:`prisma.config.ts`+`npx prisma migrate dev --name <name>`(local_only) | `npx prisma migrate deploy`(CI/prod);
    custom_SQL(`CONCURRENTLY`|backfill):`npx prisma migrate dev --create-only --name add_email_idx` → `CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);` (Prisma wraps file in tx ⇒ isolate `CONCURRENTLY` in dedicated file, ¬mix statements);
  Drizzle_v1:`npx drizzle-kit generate` | `npx drizzle-kit migrate`(prod) | `npx drizzle-kit push`(dev_only) ⇒ see `drizzle-orm.md`;
  Kysely(`kysely-ctl`):`kysely migrate make <name>` | `latest` | `down` | `list`;
    `export async function up(db: Kysely<any>)` / `down(db: Kysely<any>)` (MUST use `Kysely<any>`, ¬typed DB interface);
    programmatic:`new Migrator({ db, provider: new FileMigrationProvider({ fs, path, migrationFolder }) }).migrateToLatest()` (halt on `error`; ¬`allowUnorderedMigrations` outside dev);
  Django:`python manage.py makemigrations` | `migrate` | `showmigrations` | `makemigrations --empty <app> -n <desc>`;
    data:`apps.get_model("accounts","User")`(historical, ¬direct_import) + batched_`bulk_update` + `migrations.RunPython(fn, migrations.RunPython.noop)`;
    decoupled_drop:`migrations.SeparateDatabaseAndState(state_operations=[migrations.RemoveField(model_name="user",name="legacy_field")], database_operations=[])` (drop col in later migration);
  golang-migrate:`migrate create -ext sql -dir migrations -seq add_user_avatar` | `migrate -path migrations -database "$DATABASE_URL" up` | `down 1` | `force VERSION`(fix dirty);
    files:`<seq>_<name>.up.sql` / `.down.sql`;
  Sequelize:`npx sequelize-cli db:migrate` | `db:migrate:undo`; TypeORM:`npm run typeorm migration:run` | `migration:revert`
}
§XFORM{
  add_default:PG11+_const_default_instant;MySQL/MariaDB⇒`ALGORITHM=INSTANT`;
  rename_2step:1.add_`full_name`+dual_write→2.batched_backfill→3.deploy_read_`full_name`→4.drop_`name`;
  change_type_large:add_`age_new`→dual_write+batched_backfill(`CAST`)→swap_reads→drop_old;
  data_split:add_target_cols→dual_write+batched_backfill→swap_reads→drop_legacy_col
}
§ROLL{
  forward_only_prod:prod_rollback⇒new_forward_migration(¬blind_`down`_that_drops_data);
  atomic_tx:wrap_DDL_in_tx_when_supported(PG,SQLite)∧¬`CONCURRENTLY`;MySQL/MariaDB_DDL_auto_commits(¬transactional_DDL⇒design_idempotent_steps);
  checkpoint_tbl:destructive_transform⇒backup_snapshot_or_`CREATE TABLE t_bak AS SELECT ...`→verify_counts→drop_backup_after_soak
}
§ZDT{
  blue_green:P1_add_compatible_col→P2_deploy_dual_write(old+new)→P3_batched_backfill→P4_deploy_read_new_only→P5_drop_old_col;
  expand_contract:D1_add_nullable(`new_status`)+deploy_v2(write_old+new)→D2_batched_backfill+verify_consistency→D3_deploy_v3(R/W_new_only)→D7_drop_old(`status`)
}
§PG{
  lock_guard:`SET lock_timeout = '2s'; SET statement_timeout = '30s';` (abort_retry_instead_of_queuing_all_app_queries_behind_ACCESS_EXCLUSIVE);
  instant:`ALTER TABLE users ADD COLUMN avatar_url TEXT;` (nullable) | `ALTER TABLE users ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;` (PG11+_const_default=instant);
  zdt_constraint:`ALTER TABLE users ADD CONSTRAINT fk_org FOREIGN KEY (org_id) REFERENCES orgs(id) NOT VALID;` → `ALTER TABLE users VALIDATE CONSTRAINT fk_org;` (SHARE_UPDATE_EXCLUSIVE⇒allows_concurrent_R/W);
  zdt_not_null:1.add_nullable→2.batched_backfill→3.`ADD CONSTRAINT nn_x CHECK (x IS NOT NULL) NOT VALID`→4.`VALIDATE CONSTRAINT nn_x`→5.`ALTER COLUMN x SET NOT NULL`→6.`DROP CONSTRAINT nn_x`;
  concurrent_idx:`CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);` (¬inside_tx_block;check_`pg_index.indisvalid`_if_aborted);
  repack:PG19+_native_`REPACK` ⊕ `pg_repack`(online_bloat_reclaim¬`VACUUM FULL`);
  batched_backfill(PG11+_`COMMIT`_in_`DO $$`_only_outside_tx):
  ```sql
  DO $$ DECLARE batch_size INT := 10000; rows_updated INT; BEGIN LOOP
    UPDATE users SET normalized_email = LOWER(email)
    WHERE id IN (SELECT id FROM users WHERE normalized_email IS NULL LIMIT batch_size FOR UPDATE SKIP LOCKED);
    GET DIAGNOSTICS rows_updated = ROW_COUNT; EXIT WHEN rows_updated = 0; COMMIT;
  END LOOP; END $$;
  ```
}
§MYSQL{
  instant:`ALTER TABLE t ADD COLUMN col VARCHAR(64) NULL, ALGORITHM=INSTANT;` (fail_fast_if_instant_unsupported);
  inplace:`ALTER TABLE t ADD INDEX idx_col(col), ALGORITHM=INPLACE, LOCK=NONE;`;
  rebuild_large:use_`gh-ost`∨`pt-online-schema-change`(shadow_table+binlog_sync+atomic_cutover)¬blocking_`ALTER TABLE`
}
§XDB{dialect_branch:test_all_target_dialects_pre_prod;PG_DDL≡transactional,MySQL_DDL≡implicit_commit}
§R{
  prod_rules:{migrations_only(¬manual_DB_edits),always_set_`lock_timeout`,forward_only_prod(rollback=new_forward_migration),separate_DDL_and_DML,test_on_prod_size(100_rows≠10M_lock),¬edit_deployed_migration};
  best:{provide_down(or_mark_irreversible),test_staging,use_tx_when_supported,backup_before_destructive,incremental_changes,monitor_locks+logs,document_intent+revert,ensure_idempotence}
}
§ANTI{
  manual_prod_SQL(no_audit/repeat)⇒migrations_only;
  edit_deployed_migration(env_drift)⇒new_migration;
  no_lock_timeout(queued_ACCESS_EXCLUSIVE_outage)⇒`SET lock_timeout='2s'`+retry;
  NOT_NULL_no_default(fails/rewrites)⇒nullable→batched_backfill→`NOT VALID`→`VALIDATE`→`SET NOT NULL`;
  inline_index_large_tbl(locks_writes)⇒`CREATE INDEX CONCURRENTLY`(PG)|`ALGORITHM=INPLACE,LOCK=NONE`(MySQL);
  DDL+DML_in_one_migration(long_tx/timeouts/hard_rollback)⇒separate_migrations;
  drop_col_still_in_code(missing_col_err)⇒remove_code_first→drop_next_deploy;
  pitfalls:{skip_down_test,no_ZDT_plan,ignore_NULLs,ignore_FK_on_rename,oversized_single_tx}
}
§CHK{goal+scope;full_backup;lock_timeout_set;up+down(or_irreversible);tx_wrapped(if_supported∧¬CONCURRENTLY);no_full_tbl_lock;new_cols_nullable∨const_default;concurrent_indexes;NOT_VALID+VALIDATE;separate_batched_backfill;tested_on_prod_copy(up+down+integrity);rollback_plan;deploy_CLI;monitor_locks+logs}
§REL{../SKILL.md;postgresql.md;mysql-patterns.md;database-optimization.md;prisma.md;drizzle-orm.md;../../backend-development/SKILL.md}
