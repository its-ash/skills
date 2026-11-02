---
name: java
description: "Java 17+ standards for Spring Boot and Quarkus: naming, immutability, Optional, streams, exceptions, generics, CDI, Mutiny, layout, security, testing, JPA, Hibernate, Panache, MyBatis. Use for .java code, pom.xml, build.gradle, Spring Security, Quarkus resources, Camel routes, JUnit 5, Mockito, MockMvc, REST Assured, Testcontainers, JaCoCo, N+1 queries, GraalVM native, or tinystruct. Sub-skills: springboot-patterns, springboot-security, springboot-testing, quarkus-patterns, quarkus-security, quarkus-testing, jpa-patterns, mybatis-patterns, tinystruct-patterns."
---
# Java
Readable, maintainable Java 17+ for Spring Boot and Quarkus services.

## Core rules
- Detect the framework from the build file first: `quarkus` → [QUARKUS] rules; `spring-boot` → [SPRING] rules; neither → shared rules only.
- Prefer records and `final` fields. Minimize shared mutable state. No setters on domain types (Panache entities excepted).
- Naming: PascalCase types, camelCase members, UPPER_SNAKE constants. [SPRING] `*Controller`; [QUARKUS] `*Resource`.
- Return `Optional` from `find*`. Use `map`/`orElseThrow`, never bare `get()`.
- Keep stream pipelines short; use a loop when nesting gets deep. Use `.toList()`.
- Use constructor injection. Never `@Autowired` on fields.
- Throw unchecked, domain-specific exceptions (`MarketNotFoundException`). Wrap technical exceptions with context. Map them in one central handler.
- Catch `Exception` only to log or rethrow centrally. No silent catch blocks.
- No raw types. Use bounded generics for reusable utilities.
- Validate inputs with Bean Validation (`@NotNull`, `@NotBlank`, `@Valid`). Use `@Nullable` only when unavoidable.
- Use type-safe config: [SPRING] `@ConfigurationProperties` record; [QUARKUS] `@ConfigMapping` interface.
- Log with structured keys (`fetch_market slug={}`): [SPRING] SLF4J; [QUARKUS] JBoss Logging.
- One public top-level type per file. Member order: constants, fields, constructors, public, protected, private.
- Tests: JUnit 5 + AssertJ + Mockito. Avoid partial mocks. No sleeps; tests must be deterministic.
- [QUARKUS] Prefer build-time processing; avoid runtime reflection (native image safety).

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| [QUARKUS] CDI scope for service | `@ApplicationScoped` | `@Singleton` when interception or lazy init is needed (non-proxyable) |
| [QUARKUS] Field injection | Package-private `@Inject` field is acceptable | Private injected fields |
| [QUARKUS] Reactive endpoint | Return `Uni`/`Multi`; compose with `.chain()` | Blocking calls inside a pipeline |
| [QUARKUS] Shared `Uni` used twice | `Uni.memoize()` | Subscribing twice |
| [QUARKUS] REST stack | One stack: RESTEasy Reactive | Mixing `quarkus-resteasy-reactive` and classic `quarkus-resteasy` |
| [QUARKUS] Panache style | One per bounded context: active record or repository | Both in one context |
| Central error mapping | [SPRING] `@RestControllerAdvice`; [QUARKUS] `@ServerExceptionMapper` or `ExceptionMapper` | Per-method try/catch to HTTP codes |
| Many parameters | DTO or builder | Long parameter lists |
| Shared state | Dependency injection | Static mutable fields |

| Test scope | [SPRING] | [QUARKUS] |
|---|---|---|
| Unit | JUnit 5 + Mockito | JUnit 5 + Mockito, no `@QuarkusTest` |
| Web/controller | `@WebMvcTest` + `@MockBean` | `@QuarkusTest` + `@InjectMock` + REST Assured |
| Repository | `@DataJpaTest` | `@QuarkusTest` with Dev Services |
| Full integration | `@SpringBootTest` | `@QuarkusTest`; `@QuarkusTestResource` for custom services |
| DB/Kafka/Redis | Testcontainers | Dev Services before manual Testcontainers |

## Load on demand
| Need | Read |
|---|---|
| Code examples: naming, DI, Mutiny, exception mappers, layout, logging, config, tests | [references/java-standards.md](references/java-standards.md) |
| Spring Boot controllers, services, caching, async, pagination, Bucket4j | [references/springboot-patterns.md](references/springboot-patterns.md) |
| Spring Security, JWT filters, `@PreAuthorize`, CORS, CSRF | [references/springboot-security.md](references/springboot-security.md) |
| Spring Boot TDD, MockMvc, Testcontainers, JaCoCo, verify loop | [references/springboot-testing.md](references/springboot-testing.md) |
| Quarkus resources, CDI, Panache, Camel + RabbitMQ, health checks | [references/quarkus-patterns.md](references/quarkus-patterns.md) |
| Quarkus JWT/OIDC, `@RolesAllowed`, Vault, headers, audit logs | [references/quarkus-security.md](references/quarkus-security.md) |
| Quarkus TDD, REST Assured, Camel `AdviceWith`, native build, k6 | [references/quarkus-testing.md](references/quarkus-testing.md) |
| JPA/Hibernate entities, N+1, projections, transactions, HikariCP | [references/jpa-patterns.md](references/jpa-patterns.md) |
| MyBatis mappers, `#{}` vs `${}`, dynamic SQL, keyset pagination | [references/mybatis-patterns.md](references/mybatis-patterns.md) |
| tinystruct `@Action`, dispatcher, CLI/HTTP mode, SSE, MCP tools | [references/tinystruct-patterns.md](references/tinystruct-patterns.md) |

## Related skills
- [`backend-development`](../backend-development/SKILL.md) — API design, resilience, observability
- [`database-design`](../database-design/SKILL.md) — schema, indexes, migrations under JPA/MyBatis
- [`kotlin`](../kotlin/SKILL.md) — Kotlin on the JVM, Ktor, Android
- [`secure-coding`](../secure-coding/SKILL.md) — auth, secrets, injection review
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — general TDD and test structure
- [`clean-code`](../clean-code/SKILL.md) — nesting, magic numbers, method size
