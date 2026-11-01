# Spring Boot Testing and Verification

Test-first workflow and pre-PR verification loop for Spring Boot services with 80%+ coverage (unit + integration).

## When to use

- New features or endpoints
- Bug fixes or refactors
- Adding data access logic or security rules
- Before you open a pull request, after large refactors or dependency upgrades, and before deployment
- To make sure that build, static analysis, tests, coverage, and security scans pass

## Workflow

1) Write tests first (they should fail)
2) Implement minimal code to pass
3) Refactor with tests green
4) Enforce coverage (JaCoCo)

## Unit Tests (JUnit 5 + Mockito)

```java
@ExtendWith(MockitoExtension.class)
class MarketServiceTest {
  @Mock MarketRepository repo;
  @InjectMocks MarketService service;

  @Test
  void createsMarket() {
    CreateMarketRequest req = new CreateMarketRequest("name", "desc", Instant.now(), List.of("cat"));
    when(repo.save(any())).thenAnswer(inv -> inv.getArgument(0));

    Market result = service.create(req);

    assertThat(result.name()).isEqualTo("name");
    verify(repo).save(any());
  }
}
```

Patterns:
- Arrange-Act-Assert
- Avoid partial mocks; prefer explicit stubbing
- Use `@ParameterizedTest` for variants

## Web Layer Tests (MockMvc)

```java
@WebMvcTest(MarketController.class)
class MarketControllerTest {
  @Autowired MockMvc mockMvc;
  @MockBean MarketService marketService;

  @Test
  void returnsMarkets() throws Exception {
    when(marketService.list(any())).thenReturn(Page.empty());

    mockMvc.perform(get("/api/markets"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.content").isArray());
  }
}
```

## Integration Tests (SpringBootTest)

```java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class MarketIntegrationTest {
  @Autowired MockMvc mockMvc;

  @Test
  void createsMarket() throws Exception {
    mockMvc.perform(post("/api/markets")
        .contentType(MediaType.APPLICATION_JSON)
        .content("""
          {"name":"Test","description":"Desc","endDate":"2030-01-01T00:00:00Z","categories":["general"]}
        """))
      .andExpect(status().isCreated());
  }
}
```

## Persistence Tests (DataJpaTest)

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import(TestContainersConfig.class)
class MarketRepositoryTest {
  @Autowired MarketRepository repo;

  @Test
  void savesAndFinds() {
    MarketEntity entity = new MarketEntity();
    entity.setName("Test");
    repo.save(entity);

    Optional<MarketEntity> found = repo.findByName("Test");
    assertThat(found).isPresent();
  }
}
```

## Testcontainers

- Use reusable containers for Postgres/Redis to mirror production
- Wire via `@DynamicPropertySource` to inject JDBC URLs into Spring context

```java
@SpringBootTest
@Testcontainers
class UserRepositoryIntegrationTest {

  @Container
  static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
      .withDatabaseName("testdb");

  @DynamicPropertySource
  static void configureProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
  }

  @Autowired private UserRepository userRepository;

  @Test
  void findByEmail_existingUser_returnsUser() {
    userRepository.save(new User("Alice", "alice@example.com"));

    var found = userRepository.findByEmail("alice@example.com");

    assertThat(found).isPresent();
    assertThat(found.get().getName()).isEqualTo("Alice");
  }
}
```

## Coverage (JaCoCo)

Maven snippet:
```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.14</version>
  <executions>
    <execution>
      <goals><goal>prepare-agent</goal></goals>
    </execution>
    <execution>
      <id>report</id>
      <phase>verify</phase>
      <goals><goal>report</goal></goals>
    </execution>
  </executions>
</plugin>
```

## Assertions

- Prefer AssertJ (`assertThat`) for readability
- For JSON responses, use `jsonPath`
- For exceptions: `assertThatThrownBy(...)`

## Test Data Builders

```java
class MarketBuilder {
  private String name = "Test";
  MarketBuilder withName(String name) { this.name = name; return this; }
  Market build() { return new Market(null, name, MarketStatus.ACTIVE); }
}
```

## CI Commands

- Maven: `mvn -T 4 test` or `mvn verify`
- Gradle: `./gradlew test jacocoTestReport`

## Verification Loop

Do these phases before a PR, after large changes, and before deployment. If a phase fails, stop and fix it.

### Phase 1: Build

```bash
mvn -T 4 clean verify -DskipTests
# or
./gradlew clean assemble -x test
```

### Phase 2: Static Analysis

```bash
mvn -T 4 spotbugs:check pmd:check checkstyle:check
# or (if configured)
./gradlew checkstyleMain pmdMain spotbugsMain
```

### Phase 3: Tests and Coverage

```bash
mvn -T 4 test
mvn jacoco:report   # verify 80%+ coverage
# or
./gradlew test jacocoTestReport
```

Record the total tests, the passed and failed counts, and the line and branch coverage.

### Phase 4: Security Scan

```bash
# Dependency CVEs
mvn org.owasp:dependency-check-maven:check
# or
./gradlew dependencyCheckAnalyze

# Secrets in source
grep -rn "password\s*=\s*\"" src/ --include="*.java" --include="*.yml" --include="*.properties"
grep -rn "sk-\|api_key\|secret" src/ --include="*.java" --include="*.yml"

# Secrets (git history)
git secrets --scan  # if configured

# Common findings
grep -rn "System\.out\.print" src/main/ --include="*.java"      # use a logger
grep -rn "e\.getMessage()" src/main/ --include="*.java"         # raw messages in responses
grep -rn "allowedOrigins.*\*" src/main/ --include="*.java"      # wildcard CORS
```

### Phase 5: Lint and Format (optional gate)

```bash
mvn spotless:apply   # if you use the Spotless plugin
./gradlew spotlessApply
```

### Phase 6: Diff Review

```bash
git diff --stat
git diff
```

Checklist:
- No debug logs stay in the code (`System.out`, `log.debug` without guards)
- Errors and HTTP statuses are correct and clear
- Transactions and validation are present where necessary
- Configuration changes are documented

### Output Template

```
VERIFICATION REPORT
===================
Build:     [PASS/FAIL]
Static:    [PASS/FAIL] (spotbugs/pmd/checkstyle)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (CVE findings: N)
Diff:      [X files changed]

Overall:   [READY / NOT READY]

Issues to Fix:
1. ...
2. ...
```

### Continuous Mode

- Do the phases again after large changes, or each 30–60 minutes in long sessions.
- For fast feedback, use a short loop: `mvn -T 4 test` + SpotBugs.

**Remember**: Keep tests fast, isolated, and deterministic. Test behavior, not implementation details. Treat warnings as defects in production systems.
