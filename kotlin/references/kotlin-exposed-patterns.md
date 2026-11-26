@REF:kotlin-exposed-patterns
§R{
  styles:DSL(SQL-like_expr)⊕DAO(entity_lifecycle);
  tx:∀DB_op∈newSuspendedTransaction(db=database,transactionIsolation=...){...}(coroutine_safe∧atomic∧nested_savepoints);
  repo:interface(UserRepository)←ExposedUserRepository(database)(decouple_logic∧H2_testable);
  sec:LIKE⇒escape(\,%,_)_first⇒prevent_wildcard_inj;
  migration:Flyway_startup_before_DatabaseFactory.create(config)
}
§CFG{
  hikari:{
    HikariConfig().apply{driverClassName=config.driver;jdbcUrl=config.url;username=config.username;password=config.password;maximumPoolSize=config.maxPoolSize;isAutoCommit=false;transactionIsolation="TRANSACTION_READ_COMMITTED";validate()}→Database.connect(HikariDataSource(hikariConfig));
    DatabaseConfig(url:String,driver:String="org.postgresql.Driver",username:String="",password:String="",maxPoolSize:Int=10)
  };
  flyway:{
    Flyway.configure().dataSource(url,username,password).locations("classpath:db/migration").baselineOnMigrate(true).load().migrate();
    sql_path:"src/main/resources/db/migration/V1__create_users.sql"⇒UUID PRIMARY KEY DEFAULT gen_random_uuid(),VARCHAR(100|255|20),JSONB,TIMESTAMPTZ NOT NULL DEFAULT NOW(),CREATE INDEX idx_users_{email,role}
  };
  gradle_deps:{
    exposed:"org.jetbrains.exposed:exposed-{core,dao,jdbc,kotlin-datetime,json}:1.0.0";
    driver:"org.postgresql:postgresql:42.7.5";
    pool:"com.zaxxer:HikariCP:6.2.1";
    flyway:"org.flywaydb:flyway-{core,database-postgresql}:10.22.0";
    test:"com.h2database:h2:2.3.232"
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
    ins_row:T.insert{it[col]=v}.resultedValues!!.first().toUser();
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
    ops:UserEntity.find{UsersTable.email eq email}.firstOrNull()?.toModel() | UserEntity.new{...}.toModel() | UserEntity.findById(id)?.apply{req.name?.let{name=it};updatedAt=OffsetDateTime.now(ZoneOffset.UTC)}?.toModel() | UserEntity.all()
  };
  tx:{
    safe:runCatching{newSuspendedTransaction{...}};
    isolation:newSuspendedTransaction(transactionIsolation=Connection.TRANSACTION_READ_COMMITTED|Connection.TRANSACTION_SERIALIZABLE);
    atomic:debit+credit_in_single_tx⇒both_succeed⊕both_rollback
  };
  jsonb:```kotlin
inline fun <reified T : Any> Table.jsonb(name: String, json: Json): Column<T> =
    registerColumn(name, object : ColumnType<T>() {
        override fun sqlType() = "JSONB"
        override fun valueFromDB(value: Any): T = when (value) {
            is String -> json.decodeFromString(value)
            is PGobject -> json.decodeFromString(value.value ?: throw IllegalArgumentException("PGobject null: $name"))
            else -> throw IllegalArgumentException("Unexpected value: $value")
        }
        override fun notNullValueToDB(value: T): Any =
            PGobject().apply { type = "jsonb"; this.value = json.encodeToString(value) }
    })
@Serializable data class UserMetadata(val preferences: Map<String, String> = emptyMap(), val tags: List<String> = emptyList())
```;
  test_h2:{
    beforeSpec:Database.connect(url="jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;MODE=PostgreSQL",driver="org.h2.Driver");transaction(db){SchemaUtils.create(UsersTable)};
    beforeTest:transaction(db){UsersTable.deleteAll()};
    kotest:FunSpec({test("..."){shouldBe,shouldBeNull,shouldHaveSize}})
  }
}
