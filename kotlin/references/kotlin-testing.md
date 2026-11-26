@REF:kotlin-testing
§CTX{Kotlin TDD + Kotest + MockK + Coroutines/Flow + Property/Data-driven + Kover + Ktor testApplication}

§R{
  tdd_loop:RED(failing_test)→GREEN(minimal_impl)→REFACTOR→REPEAT;
  consistent_framework:pick(Kotest)∧¬mix_frameworks;
  suspend_mocks⇒coEvery/coVerify(¬every/verify);
  coroutines⇒runTest+advanceTimeBy(¬Thread.sleep);
  targets:{critical_biz:100%,public_api:90%+,general:80%+,generated_or_config:exclude}
}

§ANTI{
  ¬skip_RED_phase;¬mock_data_classes(use_real_instances);¬test_private_fns_directly;¬Thread.sleep;¬ignore_flaky_tests;¬test_impl_details(test_behavior)
}

§PAT:tdd_cycle{
  1_stub:`fun validateEmail(email: String): Result<String> = TODO("not implemented")`
  2_red:StringSpec{`validateEmail("user@example.com").shouldBeSuccess(...)`;`"".shouldBeFailure()`;`"userexample.com").shouldBeFailure()`}→`./gradlew test`⇒FAIL(`kotlin.NotImplementedError`)
  3_green:`isBlank()`/`'@' !in email`/`Regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")`→`Result.success|failure`→`./gradlew test`⇒PASS
  4_refactor→keep_green
}

§PAT:kotest_specs{
  StringSpec:`class C : StringSpec({ "desc" { ... } })`
  FunSpec:`class S : FunSpec({ beforeSpec{}; afterSpec{}; beforeTest{}; test("desc") { ... } })`
  BehaviorSpec:`class O : BehaviorSpec({ Given("...") { When("...") { Then("...") { ... } } } })`
  DescribeSpec:`class V : DescribeSpec({ describe("fn") { context("case") { it("spec") { ... } } } })`
}

§PAT:matchers{
  imports:`io.kotest.matchers.{shouldBe,shouldNotBe,string.*,collections.*,nulls.*,result.{shouldBeSuccess,shouldBeFailure}}`
  eq:`x shouldBe y; x shouldNotBe z`
  str:`shouldStartWith|shouldEndWith|shouldContain|shouldMatch Regex(...)|shouldBeBlank()`
  col:`shouldContain|shouldHaveSize|shouldBeSorted()|shouldContainAll(...)|shouldBeEmpty()|shouldNotBeEmpty()|shouldContainInOrder`
  null_type:`shouldNotBeNull()|shouldBeNull()|shouldBeInstanceOf<T>()`
  num:`shouldBeGreaterThan|shouldBeInRange(1.0..100.0)`
  ex:`shouldThrow<E> { ... }.message shouldBe "..."`;`shouldNotThrow<Exception> { ... }`
```kotlin
fun beActiveUser() = object : Matcher<User> {
  override fun test(value: User) = MatcherResult(
    value.isActive && value.lastLogin != null,
    { "User ${value.id} should be active with a last login" },
    { "User ${value.id} should not be active" },
  )
} // usage: user should beActiveUser()
```
}

§PAT:mockk{
  create:`mockk<T>()`|`mockk<T>(relaxed = true)`|`spyk(realObj)`(overrides stubbed fns, keeps real rest)
  reset:`beforeTest { clearMocks(repo, logger) }`
  sync:`every { repo.findById("1") } returns expected`;`every { repo.findById(any()) } returns null`;`verify(exactly = 1) { repo.findById("1") }`
  async:`coEvery { repo.findById("1") } returns u`;`coEvery { repo.save(any()) } answers { firstArg() }`;`coEvery { repo.findById("1") } coAnswers { delay(100); u }`;`coVerify(exactly = 1) { repo.findById("1") }`
  capture:`val slot = slot<User>(); coEvery { repo.save(capture(slot)) } returns Unit; slot.captured.name shouldBe "Alice"`
}

§PAT:coroutines_flows{
```kotlin
runTest {
  val service = DataService(testScope = this)
  shouldThrow<TimeoutCancellationException> { withTimeout(100) { SlowService().slowOperation() } }
  val emissions = UserFlowService().observeUsers().take(3).toList()
  // Debounce test with MutableSharedFlow:
  val queries = MutableSharedFlow<String>(); val results = mutableListOf<List<User>>()
  val job = launch { SearchService().searchUsers(queries).collect { results.add(it) } }
  queries.emit("a"); queries.emit("ab"); queries.emit("abc")
  advanceTimeBy(500); results shouldHaveSize 1; job.cancel()
}
// Controlled execution:
val dispatcher = StandardTestDispatcher() // import advanceUntilIdle, StandardTestDispatcher
runTest(dispatcher) { launch { delay(1000); done = true }; done shouldBe false; advanceTimeBy(1000); done shouldBe true }
```
}

§PAT:property_data_driven{
```kotlin
// Property-based (io.kotest.property.{Arb,arbitrary.*,forAll,checkAll}; roundtrip req @Serializable on User):
forAll<String> { s -> s.reversed().reversed() == s }
forAll(Arb.list(Arb.int())) { l -> l.sorted() == l.sorted().sorted() }
checkAll(Arb.bind(Arb.string(1..50), Arb.string(5..100)) { n, e -> User(name = n, email = "$e@test.com") }) { u ->
  Json.decodeFromString<User>(Json.encodeToString(u)) shouldBe u
}
val userArb = Arb.bind(Arb.string(minSize = 1, maxSize = 50), Arb.email(), Arb.enum<Role>()) { n, e, r -> User(UserId(UUID.randomUUID().toString()), n, Email(e), r) }
val moneyArb = Arb.bind(Arb.long(1L..1_000_000L), Arb.enum<Currency>()) { a, c -> Money(a, c) }
// Data-driven (withData):
context("valid") { withData("2026-01-15" to LocalDate(2026, 1, 15)) { (i, exp) -> parseDate(i) shouldBe exp } }
context("invalid") { withData(nameFn = { "rejects '$it'" }, "not-a-date", "2026-13-01", "2026-00-15", "") { shouldThrow<DateParseException> { parseDate(it) } } }
```
}

§PAT:fixtures_extensions{
  h2_lifecycle:`beforeSpec { db = Database.connect("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1"); transaction(db) { SchemaUtils.create(UsersTable) } }` + `afterSpec { SchemaUtils.drop(...) }` + `beforeTest { UsersTable.deleteAll() }`
```kotlin
class DatabaseExtension : BeforeSpecListener, AfterSpecListener {
  lateinit var db: Database
  override suspend fun beforeSpec(spec: Spec) { db = Database.connect("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1") }
  override suspend fun afterSpec(spec: Spec) { /* cleanup */ }
}
class UserRepositoryTest : FunSpec({ val dbExt = DatabaseExtension(); register(dbExt) })
```
}

§CFG:kover_ci{
```kotlin
// build.gradle.kts
plugins { id("org.jetbrains.kotlinx.kover") version "0.9.7" }
kover {
  reports {
    total { html { onCheck = true }; xml { onCheck = true } }
    filters { excludes { classes("*.generated.*", "*.config.*") } }
    verify { rule { minBound(80) } }
  }
}
```
```yaml
# GitHub Actions
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v4
      with: { distribution: 'temurin', java-version: '21' }
    - run: ./gradlew test koverXmlReport
    - run: ./gradlew koverVerify
    - uses: codecov/codecov-action@v5
      with: { files: build/reports/kover/report.xml, token: "${{ secrets.CODECOV_TOKEN }}" }
```
}

§PAT:ktor_test_app{
```kotlin
testApplication {
  application { configureRouting(); configureSerialization() }
  client.get("/users").run { status shouldBe HttpStatusCode.OK; body<List<UserResponse>>().shouldNotBeEmpty() }
  client.post("/users") { contentType(ContentType.Application.Json); setBody(CreateUserRequest("Alice", "alice@example.com")) }.status shouldBe HttpStatusCode.Created
}
```
}

§CMD{
  ./gradlew test
  ./gradlew test --tests "com.example.UserServiceTest"
  ./gradlew test --tests "com.example.UserServiceTest.getUser returns user when found"
  ./gradlew test --info
  ./gradlew test --continuous
  ./gradlew koverHtmlReport   # report: build/reports/kover/html/index.html (open|xdg-open|start)
  ./gradlew koverVerify
  ./gradlew koverXmlReport
  ./gradlew detekt
  ./gradlew ktlintCheck
}
