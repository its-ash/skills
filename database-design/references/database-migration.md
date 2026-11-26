@REF:database-migration

§USE{schema_Δ(add,rename,modify)∨data_move|transform∨ORM_switch∨rollback_plan∨zero_downtime|blue_green}
§WF{1:clarify(schema,data,ORM,downtime)→2:backup(dump|copy_tbl)→3:write(ORM_script)→4:tx(if_DB_supports)→5:staging_test(up+down,integrity)→6:deploy(CLI)→7:monitor(logs,app_compat)→8:doc(why,revert)}

§ORM{
  Sequelize:`module.exports={up:async(qi,Seq)=>{await qi.createTable('users',{id:{type:Seq.INTEGER,primaryKey:true,autoIncrement:true},email:{type:Seq.STRING,unique:true,allowNull:false},createdAt:Seq.DATE,updatedAt:Seq.DATE})},down:async(qi)=>await qi.dropTable('users')}`
    CMD:`npx sequelize-cli db:migrate` | `npx sequelize-cli db:migrate:undo`;
  TypeORM:`export class CreateUsers1701234567 implements MigrationInterface { async up(qr:QueryRunner){ await qr.createTable(new Table({name:'users',columns:[{name:'id',type:'int',isPrimary:true,isGenerated:true,generationStrategy:'increment'},{name:'email',type:'varchar',isUnique:true},{name:'created_at',type:'timestamp',default:'CURRENT_TIMESTAMP'}]})) } async down(qr:QueryRunner){ await qr.dropTable('users') } }`
    CMD:`npm run typeorm migration:run` | `npm run typeorm migration:revert`;
  Prisma:`model User { id Int @id @default(autoincrement()), email String @unique, createdAt DateTime @default(now()) }`
    CMD:`npx prisma migrate dev --name create_users` | `npx prisma migrate deploy`;
    custom_SQL(`CONCURRENTLY`|backfill):`npx prisma migrate dev --create-only --name add_email_index` → `CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);` (Prisma wraps each file in tx ⇒ isolate `CONCURRENTLY` in dedicated file, ¬mix statements);
  Drizzle:`npx drizzle-kit generate` | `npx drizzle-kit migrate` | `npx drizzle-kit push`(dev_only) ⇒ see `drizzle-orm.md`;
  Kysely(`kysely-ctl`):`kysely migrate make <name>` | `latest` | `down` | `list`;
    `export async function up(db: Kysely<any>)` / `down(db: Kysely<any>)` (MUST use `Kysely<any>`, ¬typed DB interface; `db.schema.createTable('user_profile').addColumn('id','serial',c=>c.primaryKey()).addColumn('email','varchar(255)',c=>c.notNull().unique()).addColumn('avatar_url','text').addColumn('created_at','timestamp',c=>c.defaultTo(sql`now()`).notNull()).execute()`);
    programmatic:`new Migrator({ db, provider: new FileMigrationProvider({ fs, path, migrationFolder }) }).migrateToLatest()` (halt on `error`; ¬`allowUnorderedMigrations` outside dev);
  Django:`python manage.py makemigrations` | `migrate` | `showmigrations` | `makemigrations --empty <app> -n <desc>`;
    data:`apps.get_model("accounts","User")`(historical, ¬direct_import) + `while batch := list(qs[:5000]): ... User.objects.bulk_update(batch,["display_name"])` + `migrations.RunPython(fn, migrations.RunPython.noop)`;
    decoupled_drop:`migrations.SeparateDatabaseAndState(state_operations=[migrations.RemoveField(model_name="user",name="legacy_field")], database_operations=[])` (drop col in later migration);
  golang-migrate:`migrate create -ext sql -dir migrations -seq add_user_avatar` | `migrate -path migrations -database "$DATABASE_URL" up` | `down 1` | `force VERSION`(fix dirty);
    files:`<seq>_<name>.up.sql` (`ALTER TABLE users ADD COLUMN avatar_url TEXT;`) / `.down.sql` (`ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;`)
}

§XFORM{
  add_default:`qi.addColumn('users','status',{type:Seq.STRING,defaultValue:'active',allowNull:false})` / `removeColumn`;
  rename_2step:1.`addColumn('users','full_name')`+`UPDATE users SET full_name=name` → 2.deploy code R/W `full_name` → 3.`removeColumn('users','name')`;
  change_type_large:`addColumn('age_new',INT)` → `UPDATE users SET age_new=CAST(age AS INTEGER) WHERE age IS NOT NULL` → `removeColumn('age')` → `renameColumn('age_new','age')`;
  data_split:select rows → `UPDATE users SET street=:street, city=:city, state=:state WHERE id=:id` (`{replacements}`) → `removeColumn('address_string')` (`down`: re-add `address_string`, `CONCAT(street, ', ', city, ', ', state)`, drop split cols)
}

§ROLL{
  atomic_tx:`t=await qi.sequelize.transaction()` → pass `{transaction:t}` to all DDL/DML → `t.commit()` / `catch` `t.rollback()`;
  checkpoint_tbl:`CREATE TABLE users_backup AS SELECT * FROM users` → migrate + verify(`SELECT COUNT(*) as cnt ... WHERE new_field IS NULL` ⇒ throw if `>0`) → `DROP TABLE users_backup` | catch: `DROP TABLE users; CREATE TABLE users AS SELECT * FROM users_backup; DROP TABLE users_backup`
}

§ZDT{
  blue_green:P1_add_compatible_col→P2_deploy_dual_write(old+new)→P3_backfill→P4_deploy_read_new_only→P5_drop_old_col;
  expand_contract:D1_add_nullable(`new_status`)+deploy_v2(write_old+new)→D2_backfill+verify_consistency→D3_deploy_v3(R/W_new_only)→D7_drop_old(`status`)
}

§XDB{dialect_branch:`const jsonType = qi.sequelize.getDialect() === 'postgres' ? Seq.JSONB : Seq.JSON`; test_all_target_dialects_pre_prod}

§PG{
  `ALTER TABLE users ADD COLUMN avatar_url TEXT;` (nullable=instant);
  `ALTER TABLE users ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;` (PG11+ const default=instant, no rewrite);
  ¬`ADD COLUMN role TEXT NOT NULL` w/o default on populated tbl (add nullable → backfill → `SET NOT NULL`);
  `CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);` (¬inside tx block);
  `ALTER TABLE orders DROP COLUMN legacy_status;` (only after code refs removed & deployed);
  batched_backfill(PG11+ `COMMIT` in `DO $$` only outside tx):
  ```sql
  DO $$ DECLARE batch_size INT := 10000; rows_updated INT; BEGIN LOOP
    UPDATE users SET normalized_email = LOWER(email)
    WHERE id IN (SELECT id FROM users WHERE normalized_email IS NULL LIMIT batch_size FOR UPDATE SKIP LOCKED);
    GET DIAGNOSTICS rows_updated = ROW_COUNT; EXIT WHEN rows_updated = 0; COMMIT;
  END LOOP; END $$;
  ```
}

§R{
  prod_rules:{migrations_only(¬manual_DB_edits),forward_only_prod(rollback=new_forward_migration),separate_DDL_and_DML,test_on_prod_size(100_rows≠10M_lock),¬edit_deployed_migration};
  best:{provide_down(or_mark_irreversible),test_staging,use_tx_when_supported,backup_before_destructive,incremental_changes,monitor_logs,document_intent+revert,ensure_idempotence}
}
§ANTI{
  manual_prod_SQL(no_audit/repeat)⇒migrations_only;
  edit_deployed_migration(env_drift)⇒new_migration;
  NOT_NULL_no_default(fails/rewrites)⇒nullable→backfill→constraint;
  inline_index_large_tbl(locks_writes)⇒`CREATE INDEX CONCURRENTLY`;
  DDL+DML_in_one_migration(long_tx/timeouts/hard_rollback)⇒separate_migrations;
  drop_col_still_in_code(missing_col_err)⇒remove_code_first→drop_next_deploy;
  pitfalls:{skip_down_test,no_ZDT_plan,ignore_NULLs,ignore_FK_on_rename,oversized_single_tx}
}
§CHK{goal+scope;full_backup;up+down(or_irreversible);tx_wrapped(if_supported∧¬CONCURRENTLY);no_full_tbl_lock;new_cols_nullable∨default;concurrent_indexes;separate_data_backfill;tested_on_prod_copy(up+down+integrity);rollback_plan;deploy_CLI;monitor_logs;doc_updated}
§REL{[database-design](../SKILL.md)|[database-optimization](database-optimization.md)|[prisma](prisma.md)|[backend-development](../../backend-development/SKILL.md)}
