@REF:drizzle-orm
§USE{Drizzle_ORM_v1&Drizzle_Kit_v1:TS_schema,defineRelations(RQB_v2),pgPolicy_RLS,relational/join/agg_qry,mig,Next.js_AppRouter|tRPC|serverless(Neon,PlanetScale,Turso,Supabase)|edge_perf}
§SCH{
  imports:`drizzle-orm/pg-core` (`pgTable,pgEnum,pgPolicy,pgRole,text,uuid,timestamp,boolean,index`), `drizzle-orm` (`defineRelations,sql,eq,desc,count`), `drizzle-orm/relations` (`EmptyFilter`);
  enum:`export const roleEnum = pgEnum("role", ["admin","user","moderator"]);`;
  table:`pgTable("posts", {id:uuid("id").defaultRandom().primaryKey(), title:text("title").notNull(), content:text("content"), published:boolean("published").default(false).notNull(), authorId:uuid("author_id").references(()=>users.id,{onDelete:"cascade"}).notNull(), createdAt:timestamp("created_at").defaultNow().notNull()}, (t)=>[index("posts_author_idx").on(t.authorId), index("posts_created_idx").on(t.createdAt)])`;
  rls_v1:``pgTable.withRLS("posts", {id:uuid("id").primaryKey(), title:text("title").notNull(), authorId:uuid("author_id").notNull()}, () => [pgPolicy("user_select_own", {for:"select", to:"public", using:sql`(SELECT auth.uid()) = author_id`}), pgPolicy("user_insert_own", {for:"insert", to:"public", withCheck:sql`(SELECT auth.uid()) = author_id`})])`` (deprecates_`.enableRLS()`;Drizzle_Kit_v1_tracks_`pgPolicy`/`pgRole`_in_migrations);
  relations_v1(RQB_v2):`export const relations = defineRelations({ users, posts }, (r) => ({ users: { publishedPosts: r.many.posts({ from: r.users.id, to: r.posts.authorId, where: { published: true } }) }, posts: { author: r.one.users({ from: r.posts.authorId, to: r.users.id }) } }))` (+native_M:N_via_`through`;replaces_removed_v0.x_`relations()`);
  types:`InferSelectModel<typeof tbl>`, `InferInsertModel<typeof tbl>` (from `"drizzle-orm"`)
}
§QRY{
  select:`db.select().from(users).where(eq(users.role,"admin"))`;
  join:`db.select({title:posts.title,authorName:users.name}).from(posts).innerJoin(users,eq(posts.authorId,users.id)).where(eq(posts.published,true)).orderBy(desc(posts.createdAt)).limit(10)`;
  agg:`db.select({authorId:posts.authorId,postCount:count(posts.id)}).from(posts).groupBy(posts.authorId)`;
  nested_v2:`db.query.users.findMany({ where: { isActive: params.isActive ?? EmptyFilter, publishedPosts: true }, with: { publishedPosts: { orderBy: { createdAt: "desc" }, limit: 5 } } })` (explicit_`undefined`_in_`where`_throws_in_v1⇒omit_or_`EmptyFilter`;relation_presence:`posts:true`[`EXISTS`]|`posts:false`[`NOT EXISTS`],¬empty_`{}`);
  mutate:`db.insert(users).values({...}).returning()`(PG/SQLite) | batch:`db.insert(posts).values([...])` | `db.update(users).set({...}).where(eq(users.id,id))` | `db.delete(posts).where(eq(posts.authorId,id))`;
  tx:`db.transaction(async(tx)=>{ const [u]=await tx.insert(users).values({...}).returning(); await tx.insert(posts).values({...}); return u; })`
}
§MIG{
  `drizzle.config.ts`:`defineConfig({schema:"./db/schema.ts",out:"./drizzle",dialect:"postgresql",dbCredentials:{url:process.env.DATABASE_URL!}})`;
  CMD:`npx drizzle-kit generate` | `npx drizzle-kit migrate`(prod) | `npx drizzle-kit push`(dev_only) | `npx drizzle-kit studio`
}
§CLIENTS{
  PG_Neon:`drizzle-orm/neon-http`(`drizzle`)+`@neondatabase/serverless`(`neon(DATABASE_URL!)`)→`drizzle(sql,{relations})`;
  SQLite_Turso:`drizzle-orm/libsql`(`drizzle`)+`@libsql/client`(`createClient({url:TURSO_DATABASE_URL!,authToken:TURSO_AUTH_TOKEN})`)→`drizzle(client,{relations})`;
  MySQL_PlanetScale:`drizzle-orm/planetscale-serverless`(`drizzle`)+`@planetscale/database`(`Client({url:DATABASE_URL!})`)→`drizzle(client,{relations})`
}
§PERF{
  prepared:`db.select().from(users).where(eq(users.id,sql.placeholder("id"))).prepare("get_user_by_id")`→`.execute({id})`;
  batch:`db.batch([db.select().from(users), db.select().from(posts).orderBy(desc(posts.createdAt)).limit(10)])`
}
§NEXT{SC:`await db.select().from(users)`(from `@/db`,`@/db/schema`); SA:`"use server"`→validate_input→`await db.insert(users).values({name,email})`}
§R{
  ver_check:check_`package.json`(v1⇒`defineRelations`+`drizzle(client,{relations})`+`pgTable.withRLS`;legacy_v0.x⇒`relations()`+`drizzle(client,{schema})`);
  schema:single_`db/schema.ts`∨by_domain;types:`InferSelectModel`/`InferInsertModel`(¬manual_interfaces);
  N+1_fix:`db.query.*`(RQB_v2);hot:`.prepare()`;prod_mig:`generate`+`migrate`(¬`push`);
  rls:use_`pgTable.withRLS`+`pgPolicy`(¬deprecated_`.enableRLS()`);
  serverless:shared_`db`_singleton_in_`db/index.ts`(¬conn/req);builder>raw_SQL;
  MySQL:¬`.returning()`⇒`.execute()`+`insertId`
}
§ERR{
  `db.query.tbl≡undefined`⇒pass_`{relations}`(v1)_or_`{schema}`(v0.x)_to_`drizzle()`;
  v1_where_`undefined`_err⇒omit_optional_key_or_use_`EmptyFilter`(from_`drizzle-orm/relations`);
  v1_empty_rel_filter_`{}`_skipped⇒use_`rel:true`(`EXISTS`)_or_`rel:false`(`NOT EXISTS`);
  mig_conflict⇒`npx drizzle-kit generate`→`npx drizzle-kit migrate`;
  MySQL_`.returning()`_err⇒`.execute()`+`insertId`;
  serverless_conn/req⇒export_shared_`db`_from_`db/index.ts`
}
§CHK{check_v1_vs_v0;pgTable/pgTable.withRLS|sqliteTable|mysqlTable;defineRelations_FKs;InferSelectModel/InferInsertModel;drizzle.config.ts(dialect,schema);generate+migrate;.prepare()_hot;drizzle(client,{relations});no_undefined_in_where;tested_SC/SA}
§REL{../SKILL.md;database-migration.md;database-optimization.md;prisma.md;../../frontend-development/references/nextjs.md}
