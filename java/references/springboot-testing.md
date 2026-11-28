@REF:springboot-testing
§STACK{SpringBoot_4(4.2.x),JUnit_6(6.0.x;JUnit4_dropped),AssertJ≥3.27.7(CVE-2026-24400),Mockito_5.24+,JaCoCo_0.8.16,Testcontainers_2.0.x;Boot4_context_pausing_enabled}
§USE{feature/endpoint;bug_fix/refactor;data_access/security;pre-PR;post-refactor/dep-up;pre-deploy;verify(build,static,test,cov,sec)}
§R{TDD:[1:failing_test,2:minimal_pass,3:refactor_green,4:enforce_cov(JaCoCo≥80%)];fast∧isolated∧deterministic;test_behavior_¬impl;warnings≡defects;modular_test_starters(spring-boot-starter-{webmvc,data-jpa}-test);@MockitoBean/@MockitoSpyBean(¬removed_@MockBean/@SpyBean);RestTestClient>TestRestTemplate}

§PAT{
UNIT: @ExtendWith(MockitoExtension.class), @Mock, @InjectMocks, AAA, ¬partial_mocks, explicit stubbing(when(repo.save(any())).thenAnswer(inv->inv.getArgument(0))), verify(...), @ParameterizedTest
WEB(spring-boot-starter-webmvc-test):
  modern_RestTestClient:@WebMvcTest(MarketController.class) @AutoConfigureRestTestClient + @Autowired RestTestClient client + @MockitoBean MarketService svc → client.get().uri("/api/markets").exchange().expectStatus().isOk().expectBody().jsonPath("$.content").isArray();
  alt_MockMvc:@WebMvcTest(MarketController.class) + @Autowired MockMvcTester(∨MockMvc) + @MockitoBean MarketService
INT: @SpringBootTest(webEnvironment=WebEnvironment.RANDOM_PORT) @AutoConfigureRestTestClient @ActiveProfiles("test") + @Autowired RestTestClient → client.post().uri("/api/markets").contentType(MediaType.APPLICATION_JSON).body(req).exchange().expectStatus().isCreated()
JPA(spring-boot-starter-data-jpa-test): import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest; @DataJpaTest @AutoConfigureTestDatabase(replace=Replace.NONE) @Import(TestContainersConfig.class)
TC(Testcontainers_2:org.testcontainers:testcontainers-postgresql):
  @SpringBootTest @Testcontainers; @Container @ServiceConnection static PostgreSQLContainer pg=new PostgreSQLContainer("postgres:16-alpine"); // @ServiceConnection auto-wires spring.datasource.* (no @DynamicPropertySource boilerplate)
ASSERT: AssertJ≥3.27.7(assertThat), JSON(jsonPath), exceptions(assertThatThrownBy(...)); Builder(MarketBuilder .withName(...).build())
}
§CFG{jacoco:org.jacoco:jacoco-maven-plugin:0.8.16 goals=[prepare-agent,report@phase=verify,check(LINE≥0.80,BRANCH≥0.70)]}

§CMD{
CI: mvn -T 4 test | mvn verify | ./gradlew test jacocoTestReport
LOOP(pre-PR|post-large-Δ|pre-deploy|30-60m;fail⇒stop&fix):
  P1_BUILD: mvn -T 4 clean verify -DskipTests | ./gradlew clean assemble -x test
  P2_STATIC: mvn -T 4 spotbugs:check pmd:check checkstyle:check | ./gradlew checkstyleMain pmdMain spotbugsMain
  P3_COV(≥80%;log total,passed,failed,line%,branch%): mvn -T 4 test && mvn jacoco:report && mvn jacoco:check | ./gradlew test jacocoTestReport jacocoTestCoverageVerification
  P4_SEC:
    CVE: mvn org.owasp:dependency-check-maven:check | ./gradlew dependencyCheckAnalyze
    SECRETS: grep -rn "password\s*=\s*\"" src/ --include="*.java" --include="*.yml" --include="*.properties" | grep -rn "sk-\|api_key\|secret" src/ --include="*.java" --include="*.yml" | git secrets --scan
    CODE: grep -rn "System\.out\.print" src/main/ --include="*.java"(logger) | grep -rn "e\.getMessage()" src/main/ --include="*.java"(¬raw_errs) | grep -rn "allowedOrigins.*\*" src/main/ --include="*.java"(¬wildcard_CORS)
  P5_FMT(opt): mvn spotless:apply | ./gradlew spotlessApply
  P6_DIFF: git diff --stat && git diff
  FAST: mvn -T 4 test + SpotBugs
}
§CHK{diff:[¬System.out,¬unguarded_log.debug,¬@MockBean(use_@MockitoBean),correct_errs_HTTP_status,tx+val_present,config_Δ_documented]}
§OUT{VERIFICATION REPORT: Build[PASS/FAIL], Static[PASS/FAIL](spotbugs/pmd/checkstyle), Tests[PASS/FAIL](X/Y passed,Z% cov), Security[PASS/FAIL](CVE:N), Diff[X files changed], Overall[READY/NOT READY], Issues to Fix}
