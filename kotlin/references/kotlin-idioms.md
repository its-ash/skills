# Kotlin Idioms: Examples

Compact good/bad pairs for the core rules in [../SKILL.md](../SKILL.md). Coroutines and Flow: [kotlin-coroutines-flows.md](kotlin-coroutines-flows.md).

## Null safety

```kotlin
fun getUser(id: String): User = repo.findById(id) ?: throw UserNotFoundException("User $id not found")
fun email(id: String): String = repo.findById(id)?.email ?: "unknown@example.com"
// Bad: repo.findById(id)!!.email
// Java interop: treat platform types as nullable -> fun len(s: String?) = s?.length ?: 0
```

## Immutability, expression bodies, value types

```kotlin
data class User(val id: String, val name: String, val email: String)
fun updateEmail(u: User, e: String): User = u.copy(email = e)
val active = users.filter { it.email.isNotBlank() }      // List<T>, not mutableListOf
// Bad: data class MutableUser(var name: String); top-level `var currentUser: User?`

fun isAdult(age: Int): Boolean = age >= 18
fun statusMessage(code: Int): String = when (code) {
    200 -> "OK"; 404 -> "Not Found"; else -> "Unknown status: $code"
}

@JvmInline
value class UserId(val value: String) {
    init { require(value.isNotBlank()) { "UserId cannot be blank" } }
}
```

## Sealed hierarchies

```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Failure(val error: AppError) : Result<Nothing>()
    data object Loading : Result<Nothing>()
}
fun <T> Result<T>.getOrNull(): T? = when (this) {
    is Result.Success -> data
    is Result.Failure, is Result.Loading -> null
}

sealed interface ApiError {
    val message: String
    data class NotFound(override val message: String) : ApiError
    data class Validation(override val message: String, val field: String) : ApiError
}
fun ApiError.toStatusCode(): Int = when (this) { is ApiError.NotFound -> 404; is ApiError.Validation -> 422 }
```

## Scope functions

| Fn | Receiver | Returns | Use for |
|---|---|---|---|
| `let` | `it` | lambda result | transform a nullable |
| `apply` | `this` | object | configure an object |
| `also` | `it` | object | side effects (log) |
| `run` | `this` | lambda result | compute with receiver |
| `with` | `this` (arg) | lambda result | non-extension `run` |

```kotlin
val len = name?.let { it.trim().length }
val user = createUser(req).also { log.info("Created ${it.id}") }
// Bad: user?.let { u -> u.address?.let { a -> a.city?.let { process(it) } } }
user?.address?.city?.let { process(it) }
```

## Extensions

```kotlin
fun String.toSlug(): String = lowercase().replace(Regex("[^a-z0-9\\s-]"), "").replace(Regex("\\s+"), "-").trim('-')

class UserService {
    private fun User.isActive(): Boolean = status == Status.ACTIVE   // scoped, no global pollution
    fun activeUsers() = repo.findAll().filter { it.isActive() }
}
```

## Delegation

```kotlin
val data: List<User> by lazy { repo.findAll() }
var name: String by Delegates.observable("initial") { _, old, new -> log.info("$old -> $new") }
class Config(map: Map<String, Any?>) { val host: String by map; val port: Int by map }

class LoggingUserRepository(private val d: UserRepository, private val log: Logger) : UserRepository by d {
    override suspend fun findById(id: String): User? = d.findById(id).also { log.info("findById $id -> ${it?.name}") }
}
```

## DSL builders

Mark the DSL with `@DslMarker` so inner blocks cannot call outer receivers by accident.

```kotlin
@DslMarker annotation class HtmlDsl

@HtmlDsl class HTML {
    private val children = mutableListOf<Element>()
    fun head(init: Head.() -> Unit) { children += Head().apply(init) }
    fun body(init: Body.() -> Unit) { children += Body().apply(init) }
}
fun html(init: HTML.() -> Unit): HTML = HTML().apply(init)

class ServerConfigBuilder {
    var host = "0.0.0.0"; var port = 8080
    private var ssl: SslConfig? = null
    fun ssl(cert: String, key: String) { ssl = SslConfig(cert, key) }
    fun build() = ServerConfig(host, port, ssl)
}
fun serverConfig(init: ServerConfigBuilder.() -> Unit) = ServerConfigBuilder().apply(init).build()
```

## Collections and sequences

```kotlin
val adminEmails = users.filter { it.role == Role.ADMIN && it.isActive }.sortedBy { it.name }.map { it.email }
val byRole = users.groupBy { it.role }
val oldestByRole = byRole.mapValues { (_, us) -> us.minByOrNull { it.createdAt } }
val byId = users.associateBy { it.id }
val (active, inactive) = users.partition { it.isActive }

// Large input + several steps -> sequence (lazy, no intermediate lists)
val first10 = users.asSequence().filter { it.isActive }.map { it.email }.take(10).toList()
val fib = sequence { var a = 0L; var b = 1L; while (true) { yield(a); a = b.also { b += a } } }
```

## Errors

```kotlin
suspend fun createUser(req: CreateUserRequest): Result<User> = runCatching {
    require(req.name.isNotBlank()) { "Name cannot be blank" }
    User(UserId(UUID.randomUUID().toString()), req.name, Email(req.email)).also { repo.save(it) }
}
val shown = createUser(req).map { it.name }.getOrElse { "Unknown" }

fun withdraw(acc: Account, amt: Money): Account {
    require(amt.value > 0) { "Amount must be positive: $amt" }          // bad argument -> IllegalArgumentException
    check(acc.balance >= amt) { "Insufficient balance: ${acc.balance}" } // bad state -> IllegalStateException
    return acc.copy(balance = acc.balance - amt)
}
// Bad: try { findUser(id) } catch (e: NotFoundException) {}  -> use findUserOrNull(id)
```

## Gradle Kotlin DSL (`build.gradle.kts`)

Check current versions at https://kotlinlang.org/docs/releases.html.

```kotlin
plugins {
    kotlin("jvm") version "2.3.10"
    kotlin("plugin.serialization") version "2.3.10"
    id("io.ktor.plugin") version "3.4.0"
    id("org.jetbrains.kotlinx.kover") version "0.9.7"
    id("io.gitlab.arturbosch.detekt") version "1.23.8"
}
kotlin { jvmToolchain(21) }
dependencies {
    implementation("io.ktor:ktor-server-core:3.4.0")            // + netty, content-negotiation, serialization-kotlinx-json
    implementation("org.jetbrains.exposed:exposed-core:1.0.0")  // + dao, jdbc, kotlin-datetime
    implementation("io.insert-koin:koin-ktor:4.2.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
    testImplementation("io.kotest:kotest-runner-junit5:6.1.4")  // + assertions-core, property
    testImplementation("io.mockk:mockk:1.14.9")
    testImplementation("io.ktor:ktor-server-test-host:3.4.0")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.10.2")
}
tasks.withType<Test> { useJUnitPlatform() }
detekt { config.setFrom(files("config/detekt/detekt.yml")); buildUponDefaultConfig = true }
```
