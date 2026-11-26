@REF:springboot-testing
§USE{feature/endpoint;bug_fix/refactor;data_access/security;pre-PR;post-refactor/dep-up;pre-deploy;verify(build,static,test,cov,sec)}
§R{TDD:[1:failing_test,2:minimal_pass,3:refactor_green,4:enforce_cov(JaCoCo≥80%)];fast∧isolated∧deterministic;test_behavior_¬impl;warnings≡defects}

§PAT{
UNIT: @ExtendWith(MockitoExtension.class), @Mock, @InjectMocks, AAA, ¬partial_mocks, explicit stubbing(when(repo.save(any())).thenAnswer(inv->inv.getArgument(0))), verify(...), @ParameterizedTest
WEB: @WebMvcTest(MarketController.class), @Autowired MockMvc, @MockBean MarketService, mockMvc.perform(get("/api/markets")).andExpect(status().isOk()).andExpect(jsonPath("$.content").isArray())
INT: @SpringBootTest @AutoConfigureMockMvc @ActiveProfiles("test"), mockMvc.perform(post("/api/markets").contentType(MediaType.APPLICATION_JSON).content(json)).andExpect(status().isCreated())
JPA: @DataJpaTest @AutoConfigureTestDatabase(replace=AutoConfigureTestDatabase.Replace.NONE) @Import(TestContainersConfig.class)
TC: reusable(Postgres,Redis)≡prod; @SpringBootTest @Testcontainers; @Container static PostgreSQLContainer<?> pg=new PostgreSQLContainer<>("postgres:16-alpine").withDatabaseName("testdb"); @DynamicPropertySource static void props(DynamicPropertyRegistry r){r.add("spring.datasource.url",pg::getJdbcUrl);r.add("spring.datasource.username",pg::getUsername);r.add("spring.datasource.password",pg::getPassword);}
ASSERT: AssertJ(assertThat), JSON(jsonPath), exceptions(assertThatThrownBy(...)); Builder(MarketBuilder .withName(...).build())
}
§CFG{jacoco:org.jacoco:jacoco-maven-plugin:0.8.14 goals=[prepare-agent,report@phase=verify]}

§CMD{
CI: mvn -T 4 test | mvn verify | ./gradlew test jacocoTestReport
LOOP(pre-PR|post-large-Δ|pre-deploy|30-60m;fail⇒stop&fix):
  P1_BUILD: mvn -T 4 clean verify -DskipTests | ./gradlew clean assemble -x test
  P2_STATIC: mvn -T 4 spotbugs:check pmd:check checkstyle:check | ./gradlew checkstyleMain pmdMain spotbugsMain
  P3_COV(≥80%;log total,passed,failed,line%,branch%): mvn -T 4 test && mvn jacoco:report | ./gradlew test jacocoTestReport
  P4_SEC:
    CVE: mvn org.owasp:dependency-check-maven:check | ./gradlew dependencyCheckAnalyze
    SECRETS: grep -rn "password\s*=\s*\"" src/ --include="*.java" --include="*.yml" --include="*.properties" | grep -rn "sk-\|api_key\|secret" src/ --include="*.java" --include="*.yml" | git secrets --scan
    CODE: grep -rn "System\.out\.print" src/main/ --include="*.java"(logger) | grep -rn "e\.getMessage()" src/main/ --include="*.java"(¬raw_errs) | grep -rn "allowedOrigins.*\*" src/main/ --include="*.java"(¬wildcard_CORS)
  P5_FMT(opt): mvn spotless:apply | ./gradlew spotlessApply
  P6_DIFF: git diff --stat && git diff
  FAST: mvn -T 4 test + SpotBugs
}
§CHK{diff:[¬System.out,¬unguarded_log.debug,correct_errs_HTTP_status,tx+val_present,config_Δ_documented]}
§OUT{VERIFICATION REPORT: Build[PASS/FAIL], Static[PASS/FAIL](spotbugs/pmd/checkstyle), Tests[PASS/FAIL](X/Y passed,Z% cov), Security[PASS/FAIL](CVE:N), Diff[X files changed], Overall[READY/NOT READY], Issues to Fix}
