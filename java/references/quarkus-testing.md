@REF:quarkus-testing
@VERSION:Quarkus_4.0|3.40_LTS(Java_21+/25,JUnit_6)
§SCOPE{
  use∈{pre_PR,post_refactor,dep_upgrade,pre_deploy,new_feature,REST,bug_fix,data_access,security,reactive,CompletableFuture,LogContext,Camel_routes,RabbitMQ,conditional_flow};
  tdd:1:write_failing_test→2:minimal_code→3:refactor_green→4:jacoco_enforce(LINE≥0.80,BRANCH≥0.70)
}
§DEPS{
  maven_test_scope:[
    `io.quarkus:quarkus-junit` (3.31+_renamed_from_quarkus-junit5),
    `io.quarkus:quarkus-junit-mockito` (3.31+_renamed_from_quarkus-junit5-mockito),
    `org.mockito:mockito-core` (5.24+),
    `org.assertj:assertj-core:3.27.7` (CVE-2026-24400_fix),
    `io.rest-assured:rest-assured`,
    `org.apache.camel.quarkus:camel-quarkus-junit5`
  ]
}
§UNIT{
  struct:`@ExtendWith(MockitoExtension.class)`+`@DisplayName`+`@Mock`/`@InjectMocks`+`@BeforeEach`+`@Nested`(per_method)+`@ParameterizedTest`/`@ValueSource(strings={""," "})`;
  naming:`givenX_whenY_thenZ`;
  body:AAA(`// ARRANGE`,`// ACT`,`// ASSERT`);
  assert:{
    values:AssertJ_`assertThat(...)`∈{`isNotNull`,`isEqualTo`,`contains`,`hasSize`,`extracting`,`filteredOn`,`containsExactly`};
    success:JUnit_`assertDoesNotThrow(() -> ...)`;
    throws:JUnit_`assertThrows(Ex.class, () -> ...)`→AssertJ_on_`getMessage()`∨`assertThatThrownBy(...)`
  };
  verify:{
    called:`verify(mock).method(...)`,matcher:`argThat(...)`/`eq(...)`/`contains(...)`,
    error_path:`verify(mock, never()).method(...)`,
    order:`InOrder`
  };
  coverage:∀public_method⇒{happy_path,null_input,empty_coll,boundary_vals,negative_IDs,blank_strings,exceptions};mock_all_external(repo,svc,Camel,S3,RabbitMQ)
}
§CAMEL{
  setup:`@QuarkusTest`(∨`@CamelQuarkusTest`_standalone)+`@Inject CamelContext`+`@Inject ProducerTemplate`+`@InjectMock`(¬`@MockBean`);
  advice:```java
MockEndpoint mock = camelContext.getEndpoint("mock:rabbitmq", MockEndpoint.class);
mock.expectedMessageCount(1);
camelContext.getRouteController().stopRoute("business-rules-publisher");
AdviceWith.adviceWith(camelContext, "business-rules-publisher", a -> {
  a.replaceFromWith("direct:business-rules-publisher");
  a.weaveByToString(".*spring-rabbitmq.*").replace().to("mock:rabbitmq");
});
camelContext.getRouteController().startRoute("business-rules-publisher");
producerTemplate.sendBody("direct:business-rules-publisher", payload);
mock.assertIsSatisfied(5000);
String body = mock.getExchanges().get(0).getIn().getBody(String.class);
```;
  variants:{
    add_endpoint:`MockEndpoint m = new MockEndpoint("mock:marshal"); camelContext.addEndpoint("mock:marshal", m);`+`a.weaveAddLast().to("mock:marshal")`;
    headers:`producerTemplate.sendBodyAndHeader("direct:process-document", payload, "documentType", "INVOICE")`;
    err_route:`a.weaveByToString(".*direct:validation-error-handler.*").replace().to("mock:error")`→`mock.getExchanges().get(0).getException()`
  };
  note:`.marshal().json(JsonLibrary.Jackson)`⇒exchange_body_is_JSON_String;test(routing,marshalling,headers,error_handlers,DLQ)
}
§ASYNC{
  sync_exec:```java
AtomicReference<LogContext> ctx = new AtomicReference<>();
doAnswer(inv -> {
  ctx.set(CustomLog.getCurrentContext());
  ((Runnable) inv.getArgument(0)).run();
  return null;
}).when(executorService).execute(any(Runnable.class));
```;
  join_ok:`StoredDocumentInfo res = svc.uploadOriginalFile(is, 1024L, logCtx, InvoiceFormat.UBL).join();`→assert(`res`∧`ctx.get().get("traceId")`);
  join_fail:`assertThatThrownBy(() -> future.join()).isInstanceOf(CompletionException.class).hasCauseInstanceOf(StorageException.class).hasMessageContaining("S3 unavailable");`
}
§REST_IT{
  unit_api:`@QuarkusTest`+`@InjectMock`+REST_Assured:
  ```java
given().contentType(ContentType.JSON).body(json)
  .when().post("/api/documents")
  .then().statusCode(201).header("Location", containsString("/api/documents/1")).body("referenceNumber", equalTo("DOC-001"));
```;
  it_db:`@QuarkusTest @TestProfile(IntegrationTestProfile.class)`+`@Transactional`→POST_extract(`extract().path("id")`)→GET_verify(200);leverage_Quarkus_Dev_Services;
  cont_test:`mvn quarkus:test`
}
§JACOCO{
  pom:```xml
<plugin>
  <groupId>org.jacoco</groupId><artifactId>jacoco-maven-plugin</artifactId><version>0.8.16</version>
  <executions>
    <execution><id>prepare-agent</id><goals><goal>prepare-agent</goal></goals></execution>
    <execution><id>report</id><phase>verify</phase><goals><goal>report</goal></goals></execution>
    <execution><id>check</id><goals><goal>check</goal></goals>
      <configuration><rules><rule><element>BUNDLE</element><limits>
        <limit><counter>LINE</counter><value>COVEREDRATIO</value><minimum>0.80</minimum></limit>
        <limit><counter>BRANCH</counter><value>COVEREDRATIO</value><minimum>0.70</minimum></limit>
      </limits></rule></rules></configuration>
    </execution>
  </executions>
</plugin>
```;
  report:`target/site/jacoco/index.html`
}
§LOOP{
  when:{pre_PR,post_large_refactor,dep_upgrade,pre_deploy};rule:fail(phase)⇒STOP∧FIX;
  P1_build:`mvn clean verify -DskipTests` | `./gradlew clean assemble -x test`;
  P2_static:`mvn checkstyle:check pmd:check spotbugs:check`;sonar:`mvn sonar:sonar -Dsonar.projectKey=my-quarkus-project -Dsonar.host.url=http://localhost:9000 -Dsonar.login=${SONAR_TOKEN}`;fix(unused_imports/vars,high_cyclomatic_complexity,null_derefs,SpotBugs_sec);
  P3_test_cov:`mvn clean test && mvn jacoco:report && mvn jacoco:check` | `./gradlew test jacocoTestReport jacocoTestCoverageVerification`;targets:LINE≥0.80,BRANCH≥0.70;
  P4_sec:{
    cve:`mvn org.owasp:dependency-check-maven:check`→`target/dependency-check-report.html`;
    quarkus:`mvn quarkus:audit`∧`mvn quarkus:list-extensions`;
    zap:`docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py -t http://localhost:8080/q/openapi -f openapi`;
    chk:{secrets∈env,input_val_all,authn+authz,CORS+headers,BCrypt,parameterized_SQL,rate_limit_public}
  };
  P5_native:{
    cmd:`mvn package -Dnative` | `mvn package -Dnative -Dquarkus.native.container-build=true`;
    smoke:`./target/*-runner`→`curl http://localhost:8080/q/health/live`∧`/q/health/ready`;
    fixes:{reflection:`@RegisterForReflection(targets={MyDynamicClass.class})`,resources:`quarkus.native.resources.includes`,JNI:register_JNI_classes}
  };
  P6_perf:{
    cmd:`k6 run load-test.js`;
    stages:`[{30s→50},{1m→100},{30s→0}]`;checks:`r.status===200 && r.timings.duration<200`;
    monitor:{p50,p95,p99,throughput,error_rate,memory,CPU}
  };
  P7_health:{
    urls:[`/q/health/live`,`/q/health/ready`,`/q/health`,`/q/metrics`];
    expect:`{"status":"UP","checks":[{"name":"Database connection","status":"UP"}]}`
  };
  P8_container:{
    build:`mvn package -Dquarkus.container-image.build=true [-Dquarkus.container-image.registry=docker.io -Dquarkus.container-image.group=myorg -Dquarkus.container-image.tag=1.0.0]`;
    run:`docker run -p 8080:8080 myorg/my-quarkus-app:1.0.0`;
    scan:`trivy image myorg/my-quarkus-app:1.0.0`∧`grype myorg/my-quarkus-app:1.0.0`
  };
  P9_cfg:{
    cmd:`mvn quarkus:info`∧`curl http://localhost:8080/q/dev/io.quarkus.quarkus-vertx-http/config`;
    chk:{env_DB_URLs,external_secrets(Vault/env),log_levels,CORS+rate_limits,monitoring+tracing}
  };
  P10_docs:{
    openapi:`/q/swagger-ui`∧`curl http://localhost:8080/q/openapi -o openapi.json`;
    chk:{README_setup,API+breaking_changes,config_properties}
  }
}
§AUTO{
  bash_gate:```bash
#!/bin/bash
set -e
mvn clean verify -DskipTests
mvn checkstyle:check pmd:check spotbugs:check
mvn test jacoco:report jacoco:check
mvn org.owasp:dependency-check-maven:check
mvn package -Dnative -Dquarkus.native.container-build=true
```;
  ci_gh_actions:`on:[push,pull_request]`→`actions/checkout@v6`→`actions/setup-java@v5(java-version:'25',distribution:'temurin',cache:maven)`→P1(`mvn clean verify -DskipTests`)→P3(`mvn test jacoco:report jacoco:check`)→P4(`mvn org.owasp:dependency-check-maven:check`)
}
§CHK{
  build:0_warnings∧0_high_or_medium_static_issues;
  tests:all_pass∧cov≥0.80∧IT_uses_real_DB;
  sec:0_dep_CVEs∧auth_tested∧0_secrets_in_src;
  native:builds∧native_tests_pass∧startup_and_mem_ok;
  ops:container_builds∧health_UP∧config_valid_for_env
}
