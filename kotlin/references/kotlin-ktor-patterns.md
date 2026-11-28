@REF:kotlin-ktor-patterns
§CTX{Ktor_3.6.2 HTTP server+coroutines+DSLs:REST,Auth,CORS,ContentNegotiation,RequestValidation,StatusPages,ktor-server-di/Koin,WebSockets,testApplication}

§R{
  routes≡thin∧logic→services∧DI→(ktor-server-di_lightweight⊕Koin_4.2.2_complex/KMP)∧integration_test→testApplication;
  validate_input→RequestValidation_plugin⇒RequestValidationException→StatusPages:400;
  params⇒safe_null_guard(`?: return@put call.respond(400)`)∧¬`!!`;
  ws_cancel⇒catch(e:CancellationException){throw e}_before_catch(e:Exception)∧broadcast⇒snapshot(synchronized(conns){conns.toList()})
}

§PAT:layout{
  src/main/kotlin/com/example/:Application.kt(main,Application.module);plugins/{Routing,Serialization,Authentication,Validation,StatusPages,CORS,DI}.kt;routes/{User,Auth,Health}Routes.kt;models/{User,ApiResponse}.kt;services/{User,Auth}Service.kt;repositories/{UserRepository,ExposedUserRepository}.kt;di/AppModule.kt
  src/test/kotlin/com/example/:routes/UserRoutesTest.kt,services/UserServiceTest.kt
}

§PAT:entry_routing{
```kotlin
fun main() { embeddedServer(Netty, port = 8080, module = Application::module).start(wait = true) }
fun Application.module() { configureSerialization(); configureValidation(); configureAuthentication(); configureStatusPages(); configureCORS(); configureDI(); configureRouting() }
fun Application.configureRouting() = routing { userRoutes(); authRoutes(); healthRoutes() }
fun Route.userRoutes() {
  val svc by inject<UserService>()
  route("/users") {
    get { call.respond(svc.getAll()) }
    get("/{id}") {
      val id = call.parameters["id"] ?: return@get call.respond(HttpStatusCode.BadRequest, "Missing id")
      call.respond(svc.getById(id) ?: return@get call.respond(HttpStatusCode.NotFound))
    }
    authenticate("jwt") {
      post { call.respond(HttpStatusCode.Created, svc.create(call.receive<CreateUserRequest>())) }
      put("/{id}") {
        val id = call.parameters["id"] ?: return@put call.respond(HttpStatusCode.BadRequest, "Missing id")
        call.respond(svc.update(id, call.receive<UpdateUserRequest>()) ?: HttpStatusCode.NotFound)
      }
      delete("/{id}") {
        val id = call.parameters["id"] ?: return@delete call.respond(HttpStatusCode.BadRequest, "Missing id")
        call.respond(if (svc.delete(id)) HttpStatusCode.NoContent else HttpStatusCode.NotFound)
      }
    }
  }
}
```
  dsl:{route("/p"){}|call.receive<T>()|call.respond(status,body)|call.parameters["id"]|call.request.queryParameters["q"]|install(Plugin){}|authenticate("name"){}|by inject<T>()|dependencies.create()|testApplication{}}
}

§PAT:serialization{
```kotlin
fun Application.configureSerialization() = install(ContentNegotiation) {
  json(Json { prettyPrint = false; isLenient = false; ignoreUnknownKeys = true; encodeDefaults = true; explicitNulls = false })
}
// Prefer kotlin.time.Instant (stdlib 2.3+, ISO-8601); custom serializer only for java.time.Instant
@Serializable data class UserResponse(val id: String, val name: String, val email: String, val role: Role, val createdAt: kotlin.time.Instant)
@Serializable data class CreateUserRequest(val name: String, val email: String, val role: Role = Role.USER)
@Serializable data class ApiResponse<T>(val success: Boolean, val data: T? = null, val error: String? = null) {
  companion object { fun <T> ok(d: T) = ApiResponse(true, d); fun <T> error(m: String) = ApiResponse<T>(false, error = m) }
}
@Serializable data class PaginatedResponse<T>(val data: List<T>, val total: Long, val page: Int, val limit: Int)
```
}

§PAT:validation{
```kotlin
fun Application.configureValidation() = install(RequestValidation) {
  validate<CreateUserRequest> { req ->
    when {
      req.name.isBlank() || req.name.length > 100 -> ValidationResult.Invalid("Invalid name")
      !req.email.matches(Regex(".+@.+\\..+")) -> ValidationResult.Invalid("Invalid email")
      else -> ValidationResult.Valid
    }
  }
}
```
}

§PAT:auth_jwt{
```kotlin
fun Application.configureAuthentication() {
  val (secret, issuer, audience, realmName) = listOf("jwt.secret", "jwt.issuer", "jwt.audience", "jwt.realm").map { environment.config.property(it).getString() }
  install(Authentication) {
    jwt("jwt") {
      realm = realmName
      verifier(JWT.require(Algorithm.HMAC256(secret)).withAudience(audience).withIssuer(issuer).build())
      validate { if (it.payload.audience.contains(audience)) JWTPrincipal(it.payload) else null }
      challenge { _, _ -> call.respond(HttpStatusCode.Unauthorized, ApiResponse.error<Unit>("Invalid or expired token")) }
    }
  }
}
fun ApplicationCall.userId() = principal<JWTPrincipal>()?.payload?.getClaim("userId")?.asString() ?: throw AuthenticationException("No userId in token")
```
  routes:/auth→{post("/login")⇒LoginRequest→authService.login(email,pw)?:401|ApiResponse.ok(TokenResponse(token));post("/register")⇒RegisterRequest→201|ApiResponse.ok(user);authenticate("jwt"){get("/me")⇒call.userId()→ApiResponse.ok(authService.getProfile(userId))}}
}

§PAT:status_pages_cors{
  StatusPages:install(StatusPages){
    exception<RequestValidationException>→400(BadRequest,cause.reasons.joinToString("; "));
    exception<ContentTransformationException>→400(BadRequest,"Invalid request body");
    exception<IllegalArgumentException>→400(BadRequest,cause.message?:"Bad request");
    exception<AuthenticationException>→401(Unauthorized,"Authentication required");
    exception<AuthorizationException>→403(Forbidden,"Access denied");
    exception<NotFoundException>→404(NotFound,cause.message?:"Resource not found");
    exception<Throwable>→call.application.log.error("Unhandled exception",cause)+500(InternalServerError,"Internal server error");
    status(HttpStatusCode.NotFound)→404("Route not found")
  }
  CORS:install(CORS){allowHost("localhost:3000");allowHost("example.com",schemes=listOf("https"));allowHeader(HttpHeaders.{ContentType,Authorization});allowMethod(HttpMethod.{Put,Delete,Patch});allowCredentials=true;maxAgeInSeconds=3600}
}

§PAT:di{
  ktor_builtin(`io.ktor:ktor-server-di:3.6.2`):
```kotlin
fun Application.configureDI() = dependencies {
  provide<UserRepository> { ExposedUserRepository(resolve()) }
  provide { UserService(resolve()) }
} // resolve inside routes/plugins via dependencies.create(UserService::class)
```
  koin(`io.insert-koin:koin-ktor:4.2.2`):
```kotlin
val appModule = module {
  single<Database> { DatabaseFactory.create(get()) }
  single<UserRepository> { ExposedUserRepository(get()) }; single<OrderRepository> { ExposedOrderRepository(get()) }
  single { UserService(get()) }; single { OrderService(get(), get()) }; single { AuthService(get(), get()) }
}
fun Application.configureDI() = install(Koin) { modules(appModule) }
```
}

§PAT:websockets{
```kotlin
fun Application.configureWebSockets() = install(WebSockets) {
  pingPeriod = 15.seconds; timeout = 15.seconds; maxFrameSize = 64 * 1024 /* 64 KiB */ ; masking = false // RFC 6455: S→C unmasked, C→S always masked
}
fun Route.chatRoutes() {
  val conns = Collections.synchronizedSet<Connection>(LinkedHashSet())
  webSocket("/chat") {
    val c = Connection(this); conns += c
    try {
      send("Connected! Users online: ${conns.size}")
      for (f in incoming) {
        val msg = Json.encodeToString(ChatMessage(c.name, (f as? Frame.Text)?.readText() ?: continue))
        synchronized(conns) { conns.toList() }.forEach { it.session.send(msg) }
      }
    } catch (e: CancellationException) { throw e } catch (e: Exception) { application.log.error("WebSocket error", e) } finally { conns -= c }
  }
}
data class Connection(val session: DefaultWebSocketSession) {
  val name = "User-${counter.getAndIncrement()}"; companion object { private val counter = AtomicInteger(0) }
}
```
}

§PAT:test_application{
```kotlin
testApplication {
  application { install(Koin) { modules(testModule) }; configureSerialization(); configureValidation(); configureStatusPages(); configureAuthentication(); configureRouting() }
  val c = createClient { install(io.ktor.client.plugins.contentnegotiation.ContentNegotiation) { json() } }
  c.post("/users") { contentType(ContentType.Application.Json); bearerAuth(generateTestJWT("test-user")); setBody(CreateUserRequest("Alice", "alice@example.com")) }.status shouldBe HttpStatusCode.Created
  c.get("/users").run { status shouldBe HttpStatusCode.OK; body<ApiResponse<List<UserResponse>>>().run { success shouldBe true; data.shouldNotBeNull().shouldNotBeEmpty() } }
}
```
  cases:no_jwt_post→401(Unauthorized);invalid_body→400(RequestValidation);unknown_id→404(NotFound)
}

§CFG:application_yaml{
```yaml
ktor: { application: { modules: [com.example.ApplicationKt.module] }, deployment: { port: 8080 } }
jwt: { secret: ${JWT_SECRET}, issuer: "https://example.com", audience: "https://example.com/api", realm: "example" }
database: { url: ${DATABASE_URL}, driver: "org.postgresql.Driver", maxPoolSize: 10 }
```
  read:`environment.config.property("database.{url|driver|maxPoolSize}").getString()`(.toInt())→`DatabaseConfig(dbUrl,dbDriver,maxPoolSize)`→`DatabaseFactory.create(get())`
}
§REL{[kotlin-exposed-patterns.md](kotlin-exposed-patterns.md); [kotlin-testing.md](kotlin-testing.md)}
