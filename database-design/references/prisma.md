@REF:prisma
§SCOPE{Prisma_ORM(PostgreSQL,MySQL,SQLite):schema,migrations,queries,relations,pools,txns,prod_traps}
§CMD{
  env:`npx prisma --version 2>/dev/null || echo "Prisma not installed"`; `grep "provider" prisma/schema.prisma 2>/dev/null | head -1`; `ls -la prisma/migrations/ 2>/dev/null | head -5`; `ls -la node_modules/.prisma/client/ 2>/dev/null | head -3`;
  schema:`npx prisma validate`; `npx prisma migrate diff --from-schema-datamodel prisma/schema.prisma --to-schema-datasource prisma/schema.prisma`; `npx prisma format`;
  mig:`npx prisma migrate status`; `ls -la prisma/migrations/`; `npx prisma migrate dev --name descriptive_name`; `npx prisma migrate deploy`; `npx prisma migrate reset`; `npx prisma migrate resolve --applied "name"`; `npx prisma migrate resolve --rolled-back "name"`;
  drift_ro:`npx prisma migrate diff --from-migrations ./prisma/migrations --to-schema-datamodel ./prisma/schema.prisma --shadow-database-url "$SHADOW_DATABASE_URL"`;
  pg_conns:`psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'your_db';"`
}
§R{
  ver_1st:run_`npx prisma --version` (`relationJoins` single JOIN can bloat 1:N/deep `include`⇒measure; `omit` & `$extends` in newer releases; newer installs may req driver adapter e.g.`@prisma/adapter-pg` + `prisma.config.ts`);
  fix_schema:1_fix_`@relation`→2_`@@index`_hot_cols+types→3_normalize+composite_keys+`@@map`;
  fix_mig:1_dev:`migrate reset`→2_edit_SQL+`migrate resolve`→3_squash+baseline;
  fix_query:1_`include`(1_roundtrip)→2_`select`(limit_fields)→3_`$queryRaw`(complex_aggs/cache);
  fix_pool:1_`connection_limit`_in_`DATABASE_URL`→2_singleton_`PrismaClient`+`beforeExit_$disconnect`→3_PgBouncer;
  unique_idx:`@unique` creates idx⇒¬dup_`@@index`_same_field;
  soft_del:add_`deletedAt DateTime?`+`@@index([deletedAt, createdAt])` upfront;
  dto:`include`=all_scalars+relations; `select`=named_only(hot_paths/wide_tbls); map_to_DTO(¬leak_`passwordHash`);
  url_pool:serverless=`?connection_limit=1&pool_timeout=20` ⊕ ext_pooler=`?pgbouncer=true&connection_limit=1`;std=`?connection_limit=5&pool_timeout=10`;¬string_concat_params(URL_may_have_`?schema=public`);
  txn_mode:independent⇒`$transaction([...])`;dependent⇒`$transaction(async (tx)=>...)`(ONLY_`tx`_inside);ext_calls(HTTP/email)⇒OUTSIDE_txn;
  err_sec:¬expose_raw_Prisma_errors_to_API_clients
}
§D{
  cuid:`@default(cuid())`⇒default(URL-safe,no_collision) ¬ext_needs_sequential;
  uuid:`@default(uuid())`⇒ext_readable ¬high_write_tbl(random_UUID_fragments_B-tree);
  autoinc:`@default(autoincrement())`⇒join_tbl,audit_log ¬public_ID(leaks_count)
}
§PAT{
  schema:`model User{id String @id @default(cuid()); email String @unique; posts Post[] @relation("UserPosts"); profile Profile? @relation("UserProfile"); createdAt DateTime @default(now()); updatedAt DateTime @updatedAt; @@index([email]); @@map("users")} model Post{id String @id @default(cuid()); title String; author User @relation("UserPosts",fields:[authorId],references:[id],onDelete:Cascade); authorId String; @@index([authorId]); @@map("posts")}`;
  q_log:`const p=new PrismaClient({log:[{emit:'event',level:'query'}]}); p.$on('query',e=>console.log(e.query,e.duration));`;
  select_raw:`prisma.user.findMany({select:{id:true,email:true,posts:{select:{id:true,title:true}}}})` | ``prisma.$queryRaw`SELECT u.id,u.email,COUNT(p.id) AS post_count FROM users u LEFT JOIN posts p ON p.author_id=u.id GROUP BY u.id` ``;
  singleton:```ts
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
const g = globalThis as unknown as { prisma?: PrismaClient };
export const prisma = g.prisma ?? new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL! }), // omit if adapter unneeded
  log: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
});
if (process.env.NODE_ENV !== 'production') g.prisma = prisma;
process.on('beforeExit', async () => { await prisma.$disconnect(); });
```;
  txns:`prisma.$transaction([op1,op2])` | `prisma.$transaction(async tx=>{...},{maxWait:5000,timeout:10000,isolationLevel:'Serializable'})` | `prisma.post.update({where:{id,version:curVer},data:{content,version:{increment:1}}})`;
  cursor:```ts
const items = await prisma.post.findMany({
  where: { published: true }, orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
  take: limit + 1, ...(cursor && { cursor: { id: cursor }, skip: 1 }),
});
const hasNext = items.length > limit; if (hasNext) items.pop();
// nextCursor = hasNext ? items[items.length - 1].id : null
```;
  err_codes:`Prisma.PrismaClientKnownRequestError`:`P2002`→409_Conflict(unique) | `P2025`→404_NotFound | `P2003`→400_BadRequest(FK) | `P2034`→txn_conflict
}
§ANTI{
  `updateMany`/`deleteMany`_ret:`{count}`_only(¬rows)⇒select_IDs→`where:{id:{in:ids}}`→refetch;
  `deleteMany()`_no_`where`:deletes_ALL⇒always_`where`;
  `updateMany`+`@updatedAt`:¬auto_set⇒explicit_`updatedAt: new Date()`;
  interactive_txn_timeout:5s_default("Transaction already closed")⇒ext_out;raise_`timeout`_only_bulk;
  `migrate dev`_shared/prod:resets_DB_on_drift⇒local_solo_DB_only;`migrate deploy`_elsewhere;
  edit_applied_mig:checksum_fail⇒`P3006`⇒new_migration;
  soft_del+`findUniqueOrThrow`:returns_deleted(`{id,deletedAt:null}`_¬unique)⇒`findFirstOrThrow({where:{id,deletedAt:null}})`;filter_explicit(¬middleware);
  breaking_ddl(NOT_NULL/rename):single_mig_fails⇒multi_step(add_col→backfill_script/job→add_constraint_in_new_mig,ref_`database-migration.md`)
}
§CHK{every_model_`@id`; explicit_`@relation(fields,references,onDelete,onUpdate)`; `@@index`_on_`WHERE`/composite; enums_fixed; `@@map`; ¬N+1; `select`_hot_paths; pagination(`skip`/`take`∨cursor); catch+log_errs; pool_matches_env; dev_query_log; sandbox_mig_1st+review_SQL+rollback_plan}
§REL{../SKILL.md; database-migration.md; database-optimization.md; drizzle-orm.md; ../../frontend-development/references/nextjs.md; ../../node/SKILL.md}
