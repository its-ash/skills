@REF:kotlin-idioms
§REL{../SKILL.md:core_rules;kotlin-coroutines-flows.md:coroutines_flow}
§R{
  null:?: throw ...∨?.prop ?: def;java_interop⇒nullable(s:String?→s?.length?:0);¬!!;
  immut:data class User(val id:String,val name:String,val email:String)+.copy(email=e);filter{}→List<T>(¬mutableListOf);¬var_dto∧¬top_var;
  expr:fun isAdult(age:Int)=age>=18;when(code){200->"OK";404->"Not Found";else->"Unknown: $code"};
  when_guards(2.2+):when(x){is Int if x>0->"pos";is Int->"non_pos";else->"other"}(¬nested_if);
  context_params(stable_2.4):context(log:Logger) fun runOp(){log.info("ok")};invoke⇒context(impl){runOp()}(¬deprecated_context_receivers);
  backing_fields(stable_2.4):val state:StateFlow<UiState> field = MutableStateFlow(UiState())(mutate_internally,readonly_externally;¬_state+asStateFlow_boilerplate);
  stdlib_kmp:kotlin.time.{Instant,Clock}(stable_2.3+)∧kotlin.uuid.Uuid(stable_2.4+,Uuid.generateV7())∧isSorted()/isSortedBy{}/isSortedDescending()(2.4+);
  unused_return(2.3+/2.4+):enable_unused_return_value_checker⇒catch_dropped_Result∨pure_fn_vals;
  value:@JvmInline value class UserId(val value:String){init{require(value.isNotBlank()){"blank"}}};
  sealed:sealed class Result<out T>{Success<T>(data:T),Failure(error:AppError),Loading};sealed interface ApiError{val message:String;NotFound(message),Validation(message,field:String)};exhaustive_when(¬else);
  scope:let(it→λ:nullable_tx)|apply(this→obj:cfg)|also(it→obj:side_fx)|run(this→λ:compute)|with(arg→λ:non_ext_run);¬nested_let⇒user?.address?.city?.let{process(it)};
  ext:String.toSlug()=lowercase().replace(Regex("[^a-z0-9\\s-]"),"").replace(Regex("\\s+"),"-").trim('-');scoped:class Svc{private fun User.isActive()=...}(¬global_pollution);
  delegate:by lazy{}|Delegates.observable("initial"){_,o,n->...}|Config(map:Map<String,Any?>){val host:String by map;val port:Int by map}|class LogRepo(d:UserRepository):UserRepository by d{override suspend fun findById(id)=...};
  dsl:@DslMarker annotation class HtmlDsl(blocks_inner→outer);@HtmlDsl class HTML{head(Head.()->Unit),body(Body.()->Unit)};html(HTML.()->Unit)=HTML().apply(init);ServerConfigBuilder{host="0.0.0.0",port=8080,ssl:SslConfig?=null,ssl(cert,key),build()=ServerConfig(host,port,ssl)};serverConfig(ServerConfigBuilder.()->Unit);
  colls:filter{}.sortedBy{}.map{}|groupBy{}.mapValues{(_,us)->us.minByOrNull{it.createdAt}}|associateBy{it.id}|(a,b)=partition{it.isActive};
  seq:large_or_multi_step⇒.asSequence()...take(10).toList()(lazy,¬intermediate_lists);sequence{var a=0L;var b=1L;while(true){yield(a);a=b.also{b+=a}}};
  err:runCatching{}.map{}.getOrElse{};require(cond)→IllegalArgumentException(arg);check(cond)→IllegalStateException(state);¬try{findUser(id)}catch(e:NotFoundException){}⇒findUserOrNull(id);
  k2_baseline:K1_removed_in_2.4⇒¬languageVersion(1.9)∧invokedynamic_when@JVM_21+_default
}
§CFG{
  releases:"https://kotlinlang.org/docs/releases.html";catalog:"gradle/libs.versions.toml"(preferred);gradle_props:"org.gradle.configuration-cache=true"(Gradle_9);
  gradle:{
    plugins:{kotlin("jvm"|"plugin.serialization"):"2.4.21",id("io.ktor.plugin"):"3.6.2",id("org.jetbrains.kotlinx.kover"):"0.9.11",id("dev.detekt"):"2.0.0-alpha.6",id("io.kotest"):"6.2.7"};
    detekt_note:Detekt_2.0_migrated_id(io.gitlab.arturbosch.detekt→dev.detekt)∧Analysis_API(¬K1)∧req(JDK_17+,Gradle_8.14+/9);
    toolchain:kotlin{jvmToolchain(21)};
    impl:{"io.ktor:ktor-server-{core,netty,content-negotiation,serialization-kotlinx-json,di}:3.6.2","org.jetbrains.exposed:exposed-{core,dao,jdbc,r2dbc,kotlin-datetime,json}:1.6.1","io.insert-koin:koin-ktor:4.2.2","org.jetbrains.kotlinx:kotlinx-coroutines-core:1.11.0"};
    testImpl:{"io.kotest:kotest-{runner-junit5,assertions-core,property}:6.2.7","io.mockk:mockk:1.14.12","io.ktor:ktor-server-test-host:3.6.2","org.jetbrains.kotlinx:kotlinx-coroutines-test:1.11.0","app.cash.turbine:turbine:1.2.1"};
    tasks:tasks.withType<Test>{useJUnitPlatform()};
    detekt:detekt{config.setFrom(files("config/detekt/detekt.yml"));buildUponDefaultConfig=true}
  }
}
