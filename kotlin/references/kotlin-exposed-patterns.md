@REF:kotlin-exposed-patterns
§R{
  ver:Exposed_1.6.1⇒packages=`org.jetbrains.exposed.v1.{core,jdbc,r2dbc,dao,json,datetime}.*`;
  styles:DSL(SQL-like_expr)⊕DAO(entity_lifecycle,JDBC);
  tx_r2dbc(non_blocking):`org.jetbrains.exposed.v1.r2dbc.transactions.suspendTransaction(db=r2dbcDb){...}`⇒async_Flow(¬thread_blocking);
  tx_jdbc(blocking):`withContext(Dispatchers.IO){org.jetbrains.exposed.v1.jdbc.transactions.suspendTransaction(db=jdbcDb,transactionIsolation=...){...}}`(isolates_blocking_JDBC_off_Ktor_event_loop;¬deprecated_newSuspendedTransaction);
  jsonb:use_builtin_`exposed-json`(`org.jetbrains.exposed.v1.json.jsonb<T>(name,Json.Default)`)∧¬hand_rolled_PGobject_ColumnType;
  repo:interface(UserRepository)←ExposedUserRepository(database)(decouple_logic∧testable);
  sec:LIKE⇒escape(\,%,_)_first⇒prevent_wildcard_inj;¬`resultedValues!!`(use_insertReturning∨firstOrNull);
  migration:Flyway_13_startup_before_DatabaseFactory.create(config)
}
§CFG{
  hikari(JDBC):{
    HikariConfig().apply{driverClassName=config.driver;jdbcUrl=config.url;username=config.username;password=config.password;maximumPoolSize=config.maxPoolSize;isAutoCommit=false;transactionIsolation="TRANSACTION_READ_COMMITTED";validate()}→Database.connect(HikariDataSource(hikariConfig));
    DatabaseConfig(url:String,driver:String="org.postgresql.Driver",username:String="",password:String="",maxPoolSize:Int=10)
  };
  r2dbc:{R2dbcDatabase.connect(url="r2dbc:postgresql://host:5432/db",driver="postgresql",user=cfg.username,password=cfg.password)};
  flyway:{
    Flyway.configure().dataSource(url,username,password).locations("classpath:db/migration").baselineOnMigrate(true).load().migrate();
    sql_path:"src/main/resources/db/migration/V1__create_users.sql"⇒UUID PRIMARY KEY DEFAULT gen_random_uuid(),VARCHAR(100|255|20),JSONB,TIMESTAMPTZ NOT NULL DEFAULT NOW(),CREATE INDEX idx_users_{email,role}
  };
  gradle_deps:{
    exposed:"org.jetbrains.exposed:exposed-{core,dao,jdbc,r2dbc,kotlin-datetime,json}:1.6.1";
    driver_jdbc:"org.postgresql:postgresql:42.7.15";
    pool_jdbc:"com.zaxxer:HikariCP:7.1.0";
    flyway:"org.flywaydb:flyway-{core,database-postgresql}:13.13.0";
    test:"com.h2database:h2:2.3.232"⊕Testcontainers_PostgreSQL(JSONB/PG_parity)
  }
}
§PAT{
  tables:{
    UUIDTable("users"):{varchar("name",100),varchar("email",255).uniqueIndex(),enumerationByName<Role>("role",20),jsonb<UserMetadata>("metadata",Json.Default).nullable(),timestampWithTimeZone("created_at"|"updated_at").defaultExpression(CurrentTimestampWithTimeZone)};
    fk:uuid("order_id").references(OrdersTable.id,onDelete=ReferenceOption.CASCADE);
    composite:object UserRolesTable:Table("user_roles"){val userId=...;val roleId=...;override val primaryKey=PrimaryKey(userId,roleId)}
  };
  dsl_crud:{
    ins_id:T.insertAndGetId{it[T.col]=v}.value;
    ins_row:T.insertReturning{it[col]=v}.single().toUser();
    sel:T.selectAll().where{T.id eq id}.map{it.toUser()}.singleOrNull();
    ord:T.selectAll().where{T.role eq Role.ADMIN}.orderBy(T.name[,SortOrder.DESC]);
    upd:T.update({T.id eq id}){it[email]=v;it[updatedAt]=CurrentTimestampWithTimeZone}>0;
    del:T.deleteWhere{T.id eq id}>0;
    map:ResultRow.toUser()⇒this[T.id].value,this[T.col]
  };
  dsl_adv:{
    join:(OrdersTable innerJoin UsersTable).selectAll().where{OrdersTable.userId eq userId}.orderBy(OrdersTable.createdAt,SortOrder.DESC) (also leftJoin);
    agg:T.select(T.role,T.id.count()).groupBy(T.role).associate{it[T.role] to it[T.id.count()]} (count()|sum()|avg());
    subq:T.selectAll().where{T.id inSubQuery OrdersTable.select(OrdersTable.userId).withDistinct()};
    like:escapeLikePattern(s)=s.replace("\\","\\\\").replace("%","\\%").replace("_","\\_");val q=escapeLikePattern(query.lowercase());T.selectAll().where{(T.name.lowerCase() like "%$q%") or (T.email.lowerCase() like "%$q%")}
  };
  pagination:{
    Page<T>(data:List<T>,total:Long,page:Int,limit:Int){totalPages=((total+limit-1)/limit).toInt();hasNext=page<totalPages;hasPrevious=page>1};
    query:total=T.selectAll().count();data=T.selectAll().orderBy(T.createdAt,SortOrder.DESC).limit(limit).offset(((page-1)*limit).toLong()).map{it.toUser()}
  };
  batch:{
    ins:T.batchInsert(items){x->this[T.col]=x.col}.map{it[T.id].value};
    upsert:T.upsert(T.email){it[T.id]=EntityID(id,T);it[T.name]=name;it[T.email]=email;it[updatedAt]=CurrentTimestampWithTimeZone}
  };
  dao:{
    entity:```kotlin
class UserEntity(id: EntityID<UUID>) : UUIDEntity(id) {
    companion object : UUIDEntityClass<UserEntity>(UsersTable)
    var name by UsersTable.name; var email by UsersTable.email; var role by UsersTable.role
    var metadata by UsersTable.metadata; var createdAt by UsersTable.createdAt; var updatedAt by UsersTable.updatedAt
    val orders by OrderEntity referrersOn OrdersTable.userId
}
class OrderEntity(id: EntityID<UUID>) : UUIDEntity(id) {
    companion object : UUIDEntityClass<OrderEntity>(OrdersTable)
    var user by UserEntity referencedOn OrdersTable.userId
    val items by OrderItemEntity referrersOn OrderItemsTable.orderId
}
```;
    ops:UserEntity.find{UsersTable.email eq email}.firstOrNull()?.toModel() | UserEntity.new{...}.toModel() | UserEntity.findById(id)?.apply{req.name?.let{name=it};updatedAt=Clock.System.now().toOffsetDateTime()}?.toModel() | UserEntity.all()
  };
  tx:{
    r2dbc:`suspendTransaction(db = r2dbcDb) { UsersTable.selectAll().map { it.toUser() }.toList() }`;
    jdbc:`withContext(Dispatchers.IO) { suspendTransaction(db = jdbcDb, transactionIsolation = Connection.TRANSACTION_READ_COMMITTED) { ... } }`;
    nested:set_`useNestedTransactions = true`_on_DatabaseConfig⇒SAVEPOINT_nesting;
    atomic:debit+credit_in_single_tx⇒both_succeed⊕both_rollback
  };
  jsonb:```kotlin
import org.jetbrains.exposed.v1.json.jsonb
@Serializable data class UserMetadata(val preferences: Map<String, String> = emptyMap(), val tags: List<String> = emptyList())
// inside UsersTable: val metadata = jsonb<UserMetadata>("metadata", Json.Default).nullable()
```;
  test_db:{
    h2_fast:beforeSpec{Database.connect("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;MODE=PostgreSQL","org.h2.Driver");transaction(db){SchemaUtils.create(UsersTable)}};beforeTest{transaction(db){UsersTable.deleteAll()}};
    pg_parity:Testcontainers(`PostgreSQLContainer("postgres:17-alpine")`)+Flyway.migrate()⇒verify_JSONB,indexes,constraints
  }
}
§ANTI{¬newSuspendedTransaction(deprecated→suspendTransaction);¬blocking_JDBC_on_event_loop(→withContext(Dispatchers.IO)∨exposed-r2dbc);¬custom_PGobject_jsonb(→exposed-json);¬unescaped_LIKE;¬`!!`_on_resultedValues}
§REL{[kotlin-ktor-patterns.md](kotlin-ktor-patterns.md); [kotlin-testing.md](kotlin-testing.md)}
