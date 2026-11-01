# Quarkus Testing and Verification

Test-first workflow and pre-PR verification loop for Quarkus 3.x services with 80%+ coverage (unit + integration), tuned for event-driven services with Apache Camel.

## When to use

- Before you open a pull request, after large refactors or dependency upgrades, and before deployment
- To make sure that build, static analysis, tests, coverage, security scans, and native compilation pass
- New features or REST endpoints
- Bug fixes or refactors
- Adding data access logic, security rules, or reactive streams
- Testing Apache Camel routes and event handlers
- Testing event-driven services with RabbitMQ
- Testing conditional flow logic
- Validating CompletableFuture async operations
- Testing LogContext propagation

## Workflow

1. Write tests first (they should fail)
2. Implement minimal code to pass
3. Refactor with tests green
4. Enforce coverage with JaCoCo (80%+ target)

## Unit Tests with @Nested Organization

Follow this structured approach for comprehensive, readable tests:

```java
@ExtendWith(MockitoExtension.class)
@DisplayName("OrderService Unit Tests")
class OrderServiceTest {

  @Mock
  private OrderRepository orderRepository;

  @Mock
  private EventService eventService;

  @Mock
  private FulfillmentPublisher fulfillmentPublisher;

  @InjectMocks
  private OrderService orderService;

  private CreateOrderCommand validCommand;

  @BeforeEach
  void setUp() {
    validCommand = new CreateOrderCommand(
        "customer-123",
        List.of(new OrderLine("sku-123", 2))
    );
  }

  @Nested
  @DisplayName("Tests for createOrder")
  class CreateOrder {

    @Test
    @DisplayName("Should persist order and publish fulfillment event")
    void givenValidCommand_whenCreateOrder_thenPersistsAndPublishes() {
      // ARRANGE
      doNothing().when(orderRepository).persist(any(Order.class));

      // ACT
      OrderReceipt receipt = orderService.createOrder(validCommand);

      // ASSERT
      assertThat(receipt).isNotNull();
      assertThat(receipt.customerId()).isEqualTo("customer-123");
      verify(orderRepository).persist(any(Order.class));
      verify(fulfillmentPublisher).publishAsync(receipt);
      verify(eventService).createSuccessEvent(receipt, "ORDER_CREATED");
    }

    @Test
    @DisplayName("Should reject missing customer id")
    void givenMissingCustomerId_whenCreateOrder_thenThrowsBadRequest() {
      // ARRANGE
      CreateOrderCommand invalid = new CreateOrderCommand("", validCommand.lines());

      // ACT & ASSERT
      WebApplicationException exception = assertThrows(
          WebApplicationException.class,
          () -> orderService.createOrder(invalid)
      );

      assertThat(exception.getResponse().getStatus()).isEqualTo(400);
      verify(orderRepository, never()).persist(any(Order.class));
      verify(fulfillmentPublisher, never()).publishAsync(any());
    }

    @Test
    @DisplayName("Should record error event when persistence fails")
    void givenPersistenceFailure_whenCreateOrder_thenRecordsErrorEvent() {
      // ARRANGE
      doThrow(new PersistenceException("database unavailable"))
          .when(orderRepository).persist(any(Order.class));

      // ACT & ASSERT
      PersistenceException exception = assertThrows(
          PersistenceException.class,
          () -> orderService.createOrder(validCommand)
      );

      assertThat(exception.getMessage()).contains("database unavailable");
      verify(eventService).createErrorEvent(
          eq(validCommand),
          eq("ORDER_CREATE_FAILED"),
          contains("database unavailable")
      );
      verify(fulfillmentPublisher, never()).publishAsync(any());
    }

    @Test
    @DisplayName("Should reject null commands")
    void givenNullCommand_whenCreateOrder_thenThrowsNullPointerException() {
      // ACT & ASSERT
      assertThrows(
          NullPointerException.class,
          () -> orderService.createOrder(null)
      );

      verify(orderRepository, never()).persist(any(Order.class));
    }
  }
}
```

### Key Testing Patterns

1. **@Nested Classes**: Group tests by method being tested
2. **@DisplayName**: Provide readable test descriptions for test reports
3. **Naming Convention**: `givenX_whenY_thenZ` for clarity
4. **AAA Pattern**: Explicit `// ARRANGE`, `// ACT`, `// ASSERT` comments
5. **@BeforeEach**: Setup common test data to reduce duplication
6. **assertDoesNotThrow**: Test success scenarios without catching exceptions
7. **assertThrows**: Test exception scenarios with message validation using AssertJ
8. **Comprehensive Coverage**: Test happy paths, null inputs, edge cases, exceptions
9. **Verify Interactions**: Use Mockito `verify()` to ensure methods are called correctly
10. **Never Verify**: Use `never()` to ensure methods are NOT called in error scenarios

## Testing Camel Routes

```java
@QuarkusTest
@DisplayName("Business Rules Camel Route Tests")
class BusinessRulesRouteTest {

  @Inject
  CamelContext camelContext;

  @Inject
  ProducerTemplate producerTemplate;

  @InjectMock
  EventService eventService;

  @InjectMock
  DocumentValidator documentValidator;

  private BusinessRulesPayload testPayload;

  @BeforeEach
  void setUp() {
    // ARRANGE - Test data
    testPayload = new BusinessRulesPayload();
    testPayload.setDocumentId(1L);
    testPayload.setFlowProfile(FlowProfile.BASIC);
  }

  @Nested
  @DisplayName("Tests for business-rules-publisher route")
  class BusinessRulesPublisher {

    @Test
    @DisplayName("Should successfully publish message to RabbitMQ")
    void givenValidPayload_whenPublish_thenMessageSentToQueue() throws Exception {
      // ARRANGE
      MockEndpoint mockRabbitMQ = camelContext.getEndpoint("mock:rabbitmq", MockEndpoint.class);
      mockRabbitMQ.expectedMessageCount(1);

      // Replace real endpoint with mock for testing
      camelContext.getRouteController().stopRoute("business-rules-publisher");
      AdviceWith.adviceWith(camelContext, "business-rules-publisher", advice -> {
        advice.replaceFromWith("direct:business-rules-publisher");
        advice.weaveByToString(".*spring-rabbitmq.*").replace().to("mock:rabbitmq");
      });
      camelContext.getRouteController().startRoute("business-rules-publisher");

      // ACT
      producerTemplate.sendBody("direct:business-rules-publisher", testPayload);

      // ASSERT — body is a JSON String after .marshal().json(JsonLibrary.Jackson)
      mockRabbitMQ.assertIsSatisfied(5000);

      assertThat(mockRabbitMQ.getExchanges()).hasSize(1);
      String body = mockRabbitMQ.getExchanges().get(0).getIn().getBody(String.class);
      assertThat(body).contains("\"documentId\":1");
    }

    @Test
    @DisplayName("Should handle marshalling to JSON")
    void givenPayload_whenPublish_thenMarshalledToJson() throws Exception {
      // ARRANGE
      MockEndpoint mockMarshal = new MockEndpoint("mock:marshal");
      camelContext.addEndpoint("mock:marshal", mockMarshal);
      mockMarshal.expectedMessageCount(1);

      camelContext.getRouteController().stopRoute("business-rules-publisher");
      AdviceWith.adviceWith(camelContext, "business-rules-publisher", advice -> {
        advice.weaveAddLast().to("mock:marshal");
      });
      camelContext.getRouteController().startRoute("business-rules-publisher");

      // ACT
      producerTemplate.sendBody("direct:business-rules-publisher", testPayload);

      // ASSERT
      mockMarshal.assertIsSatisfied(5000);

      String body = mockMarshal.getExchanges().get(0).getIn().getBody(String.class);
      assertThat(body).contains("\"documentId\":1");
      assertThat(body).contains("\"flowProfile\":\"BASIC\"");
    }
  }

  @Nested
  @DisplayName("Tests for document-processing route")
  class DocumentProcessing {

    @Test
    @DisplayName("Should route invoice to correct processor")
    void givenInvoiceType_whenProcess_thenRoutesToInvoiceProcessor() throws Exception {
      // ARRANGE
      MockEndpoint mockInvoice = camelContext.getEndpoint("mock:invoice", MockEndpoint.class);
      mockInvoice.expectedMessageCount(1);

      camelContext.getRouteController().stopRoute("document-processing");
      AdviceWith.adviceWith(camelContext, "document-processing", advice -> {
        advice.weaveByToString(".*direct:process-invoice.*").replace().to("mock:invoice");
      });
      camelContext.getRouteController().startRoute("document-processing");

      // ACT
      producerTemplate.sendBodyAndHeader("direct:process-document",
          testPayload, "documentType", "INVOICE");

      // ASSERT
      mockInvoice.assertIsSatisfied(5000);
    }

    @Test
    @DisplayName("Should handle validation errors gracefully")
    void givenValidationError_whenProcess_thenRoutesToErrorHandler() throws Exception {
      // ARRANGE
      MockEndpoint mockError = camelContext.getEndpoint("mock:error", MockEndpoint.class);
      mockError.expectedMessageCount(1);

      camelContext.getRouteController().stopRoute("document-processing");
      AdviceWith.adviceWith(camelContext, "document-processing", advice -> {
        advice.weaveByToString(".*direct:validation-error-handler.*")
            .replace().to("mock:error");
      });
      camelContext.getRouteController().startRoute("document-processing");

      // Mock validator bean to throw exception
      when(documentValidator.validate(any())).thenThrow(new ValidationException("Invalid document"));

      // ACT
      producerTemplate.sendBody("direct:process-document", testPayload);

      // ASSERT
      mockError.assertIsSatisfied(5000);

      Exception exception = mockError.getExchanges().get(0).getException();
      assertThat(exception).isInstanceOf(ValidationException.class);
      assertThat(exception.getMessage()).contains("Invalid document");
    }
  }
}
```

## Testing Event Services

```java
@ExtendWith(MockitoExtension.class)
@DisplayName("EventService Unit Tests")
class EventServiceTest {

  @Mock
  private EventRepository eventRepository;

  @Mock
  private ObjectMapper objectMapper;

  @InjectMocks
  private EventService eventService;

  private BusinessRulesPayload testPayload;

  @BeforeEach
  void setUp() {
    // ARRANGE
    testPayload = new BusinessRulesPayload();
    testPayload.setDocumentId(1L);
  }

  @Nested
  @DisplayName("Tests for createSuccessEvent")
  class CreateSuccessEvent {

    @Test
    @DisplayName("Should create success event with correct attributes")
    void givenValidPayload_whenCreateSuccessEvent_thenEventPersisted() throws Exception {
      // ARRANGE
      when(objectMapper.writeValueAsString(testPayload)).thenReturn("{\"documentId\":1}");

      // ACT
      assertDoesNotThrow(() ->
          eventService.createSuccessEvent(testPayload, "DOCUMENT_PROCESSED"));

      // ASSERT
      verify(eventRepository).persist(argThat(event ->
          event.getType().equals("DOCUMENT_PROCESSED") &&
          event.getStatus() == EventStatus.SUCCESS &&
          event.getPayload().equals("{\"documentId\":1}") &&
          event.getTimestamp() != null
      ));
    }

    @Test
    @DisplayName("Should throw exception when payload is null")
    void givenNullPayload_whenCreateSuccessEvent_thenThrowsException() {
      // ARRANGE
      Object nullPayload = null;

      // ACT & ASSERT
      NullPointerException exception = assertThrows(
          NullPointerException.class,
          () -> eventService.createSuccessEvent(nullPayload, "EVENT_TYPE")
      );

      assertThat(exception.getMessage()).isEqualTo("Payload cannot be null");
      verify(eventRepository, never()).persist(any());
    }
  }

  @Nested
  @DisplayName("Tests for createErrorEvent")
  class CreateErrorEvent {

    @Test
    @DisplayName("Should create error event with error message")
    void givenError_whenCreateErrorEvent_thenEventPersistedWithMessage() throws Exception {
      // ARRANGE
      String errorMessage = "Processing failed";
      when(objectMapper.writeValueAsString(testPayload)).thenReturn("{\"documentId\":1}");

      // ACT
      assertDoesNotThrow(() ->
          eventService.createErrorEvent(testPayload, "PROCESSING_ERROR", errorMessage));

      // ASSERT
      verify(eventRepository).persist(argThat(event ->
          event.getType().equals("PROCESSING_ERROR") &&
          event.getStatus() == EventStatus.ERROR &&
          event.getErrorMessage().equals(errorMessage) &&
          event.getPayload().equals("{\"documentId\":1}")
      ));
    }

    @ParameterizedTest
    @DisplayName("Should reject invalid error messages")
    @ValueSource(strings = {"", " "})
    void givenBlankErrorMessage_whenCreateErrorEvent_thenThrowsException(String blankMessage) {
      // ACT & ASSERT
      IllegalArgumentException exception = assertThrows(
          IllegalArgumentException.class,
          () -> eventService.createErrorEvent(testPayload, "ERROR", blankMessage)
      );

      assertThat(exception.getMessage()).contains("Error message cannot be blank");
    }
  }
}
```

## Testing CompletableFuture

```java
@ExtendWith(MockitoExtension.class)
@DisplayName("FileStorageService Unit Tests")
class FileStorageServiceTest {

  @Mock
  private S3Client s3Client;

  @Mock
  private ExecutorService executorService;

  @InjectMocks
  private FileStorageService fileStorageService;

  private InputStream testInputStream;
  private LogContext testLogContext;

  @BeforeEach
  void setUp() {
    // ARRANGE
    testInputStream = new ByteArrayInputStream("test content".getBytes());
    testLogContext = new LogContext();
    testLogContext.put("traceId", "trace-123");
  }

  @Nested
  @DisplayName("Tests for uploadOriginalFile")
  class UploadOriginalFile {

    @Test
    @DisplayName("Should successfully upload file and return document info")
    void givenValidFile_whenUpload_thenReturnsDocumentInfo() throws Exception {
      // ARRANGE
      doAnswer(invocation -> {
        ((Runnable) invocation.getArgument(0)).run();
        return null;
      }).when(executorService).execute(any(Runnable.class));

      when(s3Client.putObject(any(PutObjectRequest.class), any(RequestBody.class)))
          .thenReturn(PutObjectResponse.builder().build());

      // ACT
      CompletableFuture<StoredDocumentInfo> future =
          fileStorageService.uploadOriginalFile(testInputStream, 1024L,
              testLogContext, InvoiceFormat.UBL);

      StoredDocumentInfo result = future.join();

      // ASSERT
      assertThat(result).isNotNull();
      assertThat(result.getPath()).isNotBlank();
      assertThat(result.getSize()).isEqualTo(1024L);
      assertThat(result.getUploadedAt()).isNotNull();

      verify(s3Client).putObject(any(PutObjectRequest.class), any(RequestBody.class));
    }

    @Test
    @DisplayName("Should handle S3 upload failure")
    void givenS3Failure_whenUpload_thenCompletableFutureFails() {
      // ARRANGE — run synchronously so exception propagates through the future
      doAnswer(invocation -> {
        ((Runnable) invocation.getArgument(0)).run();
        return null;
      }).when(executorService).execute(any(Runnable.class));

      when(s3Client.putObject(any(PutObjectRequest.class), any(RequestBody.class)))
          .thenThrow(new StorageException("S3 unavailable"));

      // ACT
      CompletableFuture<StoredDocumentInfo> future =
          fileStorageService.uploadOriginalFile(testInputStream, 1024L,
              testLogContext, InvoiceFormat.UBL);

      // ASSERT
      assertThatThrownBy(() -> future.join())
          .isInstanceOf(CompletionException.class)
          .hasCauseInstanceOf(StorageException.class)
          .hasMessageContaining("S3 unavailable");
    }

    @Test
    @DisplayName("Should propagate LogContext to async operation")
    void givenLogContext_whenUpload_thenContextPropagated() throws Exception {
      // ARRANGE
      AtomicReference<LogContext> capturedContext = new AtomicReference<>();

      doAnswer(invocation -> {
        capturedContext.set(CustomLog.getCurrentContext());
        ((Runnable) invocation.getArgument(0)).run();
        return null;
      }).when(executorService).execute(any(Runnable.class));

      // ACT
      fileStorageService.uploadOriginalFile(testInputStream, 1024L,
          testLogContext, InvoiceFormat.UBL).join();

      // ASSERT
      assertThat(capturedContext.get()).isNotNull();
      assertThat(capturedContext.get().get("traceId")).isEqualTo("trace-123");
    }
  }
}
```

## Resource Layer Tests (REST Assured)

```java
@QuarkusTest
@DisplayName("DocumentResource API Tests")
class DocumentResourceTest {

  @InjectMock
  DocumentService documentService;

  @Nested
  @DisplayName("Tests for GET /api/documents")
  class ListDocuments {

    @Test
    @DisplayName("Should return list of documents")
    void givenDocumentsExist_whenList_thenReturnsOk() {
      // ARRANGE
      List<Document> documents = List.of(createDocument(1L, "DOC-001"));
      when(documentService.list(0, 20)).thenReturn(documents);

      // ACT & ASSERT
      given()
          .when().get("/api/documents")
          .then()
          .statusCode(200)
          .body("$.size()", is(1))
          .body("[0].referenceNumber", equalTo("DOC-001"));
    }
  }

  @Nested
  @DisplayName("Tests for POST /api/documents")
  class CreateDocument {

    @Test
    @DisplayName("Should create document and return 201")
    void givenValidRequest_whenCreate_thenReturns201() {
      // ARRANGE
      Document document = createDocument(1L, "DOC-001");
      when(documentService.create(any())).thenReturn(document);

      // ACT & ASSERT
      given()
          .contentType(ContentType.JSON)
          .body("""
              {
                "referenceNumber": "DOC-001",
                "description": "Test document",
                "validUntil": "2030-01-01T00:00:00Z",
                "categories": ["test"]
              }
              """)
          .when().post("/api/documents")
          .then()
          .statusCode(201)
          .header("Location", containsString("/api/documents/1"))
          .body("referenceNumber", equalTo("DOC-001"));
    }

    @Test
    @DisplayName("Should return 400 for invalid input")
    void givenInvalidRequest_whenCreate_thenReturns400() {
      // ACT & ASSERT
      given()
          .contentType(ContentType.JSON)
          .body("""
              {
                "referenceNumber": "",
                "description": "Test"
              }
              """)
          .when().post("/api/documents")
          .then()
          .statusCode(400);
    }
  }

  private Document createDocument(Long id, String referenceNumber) {
    Document document = new Document();
    document.setId(id);
    document.setReferenceNumber(referenceNumber);
    document.setStatus(DocumentStatus.PENDING);
    return document;
  }
}
```

## Integration Tests with Real Database

```java
@QuarkusTest
@TestProfile(IntegrationTestProfile.class)
@DisplayName("Document Integration Tests")
class DocumentIntegrationTest {

  @Test
  @Transactional
  @DisplayName("Should create and retrieve document via API")
  void givenNewDocument_whenCreateAndRetrieve_thenSuccessful() {
    // ACT - Create via API
    Long id = given()
        .contentType(ContentType.JSON)
        .body("""
            {
              "referenceNumber": "INT-001",
              "description": "Integration test",
              "validUntil": "2030-01-01T00:00:00Z",
              "categories": ["test"]
            }
            """)
        .when().post("/api/documents")
        .then()
        .statusCode(201)
        .extract().path("id");

    // ASSERT - Retrieve via API
    given()
        .when().get("/api/documents/" + id)
        .then()
        .statusCode(200)
        .body("referenceNumber", equalTo("INT-001"));
  }
}
```

## Coverage with JaCoCo

### Maven Configuration (Complete)

```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.13</version>
  <executions>
    <!-- Prepare agent for test execution -->
    <execution>
      <id>prepare-agent</id>
      <goals>
        <goal>prepare-agent</goal>
      </goals>
    </execution>

    <!-- Generate coverage report -->
    <execution>
      <id>report</id>
      <phase>verify</phase>
      <goals>
        <goal>report</goal>
      </goals>
    </execution>

    <!-- Enforce coverage thresholds -->
    <execution>
      <id>check</id>
      <goals>
        <goal>check</goal>
      </goals>
      <configuration>
        <rules>
          <rule>
            <element>BUNDLE</element>
            <limits>
              <limit>
                <counter>LINE</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.80</minimum>
              </limit>
              <limit>
                <counter>BRANCH</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.70</minimum>
              </limit>
            </limits>
          </rule>
        </rules>
      </configuration>
    </execution>
  </executions>
</plugin>
```

Run tests with coverage:
```bash
mvn clean test
mvn jacoco:report
mvn jacoco:check

# Report at: target/site/jacoco/index.html
```

## Test Dependencies

```xml
<dependencies>
    <!-- Quarkus Testing -->
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-junit5</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>io.quarkus</groupId>
        <artifactId>quarkus-junit5-mockito</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- Mockito -->
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- AssertJ (preferred over JUnit assertions) -->
    <dependency>
        <groupId>org.assertj</groupId>
        <artifactId>assertj-core</artifactId>
        <version>3.24.2</version>
        <scope>test</scope>
    </dependency>

    <!-- REST Assured -->
    <dependency>
        <groupId>io.rest-assured</groupId>
        <artifactId>rest-assured</artifactId>
        <scope>test</scope>
    </dependency>

    <!-- Camel Testing -->
    <dependency>
        <groupId>org.apache.camel.quarkus</groupId>
        <artifactId>camel-quarkus-junit5</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Best Practices

### Test Organization
- Use `@Nested` classes to group tests by method being tested
- Use `@DisplayName` for readable test descriptions visible in reports
- Follow `givenX_whenY_thenZ` naming convention for test methods
- Use `@BeforeEach` for common test data setup to reduce duplication

### Test Structure
- Follow AAA pattern with explicit comments (`// ARRANGE`, `// ACT`, `// ASSERT`)
- Use `assertDoesNotThrow` for success scenarios
- Use `assertThrows` for exception scenarios with message validation
- Verify exception messages match expected values using AssertJ `contains()` or `isEqualTo()`

### Test Coverage
- Test happy paths for all public methods
- Test null input handling
- Test edge cases (empty collections, boundary values, negative IDs, blank strings)
- Test exception scenarios comprehensively
- Mock all external dependencies (repositories, services, Camel endpoints)
- Aim for 80%+ line coverage, 70%+ branch coverage

### Assertions
- **Prefer AssertJ** (`assertThat`) over JUnit assertions for value checks
- Use fluent AssertJ API for readability: `assertThat(list).hasSize(3).contains(item)`
- For exceptions: use JUnit `assertThrows` to capture, then AssertJ to validate the message
- For non-throwing success paths: use JUnit `assertDoesNotThrow`
- For collections: `extracting()`, `filteredOn()`, `containsExactly()`

### Testing Integration
- Use `@QuarkusTest` for integration tests
- Use `@InjectMock` to mock dependencies in Quarkus tests
- Prefer REST Assured for API testing
- Use `@TestProfile` for test-specific configuration

### Event-Driven Testing
- Test Camel routes with `AdviceWith` and `MockEndpoint`
- Use `@CamelQuarkusTest` annotation (if using standalone Camel tests)
- Verify message content, headers, and routing logic
- Test error handling routes separately
- Mock external systems (RabbitMQ, S3, databases) in unit tests

### Camel Route Testing
- Use `MockEndpoint` for asserting message flow
- Use `AdviceWith` to modify routes for testing (replace endpoints with mocks)
- Test message transformation and marshalling
- Test exception handling and dead letter queues

### Testing Async Operations
- Test CompletableFuture success and failure scenarios
- Use `.join()` in tests to wait for async completion
- Test exception propagation from CompletableFuture
- Verify LogContext propagation to async operations

### Performance
- Keep tests fast and isolated
- Run tests in continuous mode: `mvn quarkus:test`
- Use parameterized tests (`@ParameterizedTest`) for input variations
- Build reusable test data builders or factory methods

### Quarkus-Specific
- Stay on latest LTS version (Quarkus 3.x)
- Test native compilation compatibility periodically
- Use Quarkus test profiles for different scenarios
- Leverage Quarkus dev services for local testing
- Use `@InjectMock` instead of `@MockBean` (Quarkus-specific)

### Verification Best Practices
- Always verify interactions on mocked dependencies
- Use `verify(mock, never())` to ensure methods are NOT called in error scenarios
- Use `argThat()` for complex argument matching
- Verify the order of calls when it matters: `InOrder` from Mockito

## Verification Loop

Do these phases before a PR, after large changes, and before deployment. If a phase fails, stop and fix it.

### Phase 1: Build

```bash
# Maven
mvn clean verify -DskipTests

# Gradle
./gradlew clean assemble -x test
```

### Phase 2: Static Analysis

```bash
mvn checkstyle:check pmd:check spotbugs:check

# SonarQube (if configured)
mvn sonar:sonar \
  -Dsonar.projectKey=my-quarkus-project \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=${SONAR_TOKEN}
```

Fix unused imports and variables, methods with high cyclomatic complexity, possible null dereferences, and security issues that SpotBugs finds.

### Phase 3: Tests and Coverage

```bash
mvn clean test
mvn jacoco:report
mvn jacoco:check          # enforce the threshold

# Gradle
./gradlew test jacocoTestReport jacocoTestCoverageVerification
```

Read `target/site/jacoco/index.html`. Targets: 80%+ line coverage, 70%+ branch coverage. Find the critical paths that have no coverage.

### Phase 4: Security Scanning

```bash
# Dependency CVEs (report: target/dependency-check-report.html)
mvn org.owasp:dependency-check-maven:check

# Quarkus extension audit
mvn quarkus:audit
mvn quarkus:list-extensions

# OWASP ZAP API scan
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py \
  -t http://localhost:8080/q/openapi \
  -f openapi
```

- [ ] All secrets are in environment variables (not in code)
- [ ] All endpoints validate input
- [ ] Authentication and authorization are configured
- [ ] CORS and security headers are set
- [ ] Passwords are hashed with BCrypt
- [ ] Queries are parameterized
- [ ] Public endpoints have rate limits

### Phase 5: Native Compilation

```bash
mvn package -Dnative
# or in a container
mvn package -Dnative -Dquarkus.native.container-build=true

./target/*-runner
curl http://localhost:8080/q/health/live
curl http://localhost:8080/q/health/ready
```

Native image problems:
- **Reflection**: add reflection configuration for dynamic classes
- **Resources**: include them with `quarkus.native.resources.includes`
- **JNI**: register JNI classes if you use native libraries

```java
@RegisterForReflection(targets = {MyDynamicClass.class})
public class ReflectionConfiguration {}
```

### Phase 6: Performance Testing (k6)

```javascript
// load-test.js
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 100 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  const res = http.get('http://localhost:8080/api/markets');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });
}
```

Run `k6 run load-test.js`. Monitor response time (p50, p95, p99), throughput, error rate, memory, and CPU.

### Phase 7: Health Checks

```bash
curl http://localhost:8080/q/health/live
curl http://localhost:8080/q/health/ready
curl http://localhost:8080/q/health
curl http://localhost:8080/q/metrics   # if enabled
```

Expected response:
```json
{
  "status": "UP",
  "checks": [
    { "name": "Database connection", "status": "UP" }
  ]
}
```

### Phase 8: Container Image Build

```bash
mvn package -Dquarkus.container-image.build=true

mvn package \
  -Dquarkus.container-image.build=true \
  -Dquarkus.container-image.registry=docker.io \
  -Dquarkus.container-image.group=myorg \
  -Dquarkus.container-image.tag=1.0.0

docker run -p 8080:8080 myorg/my-quarkus-app:1.0.0

# Container security scan
trivy image myorg/my-quarkus-app:1.0.0
grype myorg/my-quarkus-app:1.0.0
```

### Phase 9: Configuration Validation

```bash
mvn quarkus:info
curl http://localhost:8080/q/dev/io.quarkus.quarkus-vertx-http/config
```

- [ ] Database URLs are set for each environment
- [ ] Secrets are external (Vault, env vars)
- [ ] Log levels are correct
- [ ] CORS origins and rate limits are set
- [ ] Monitoring and tracing are on

### Phase 10: Documentation Review

- [ ] OpenAPI docs are current (`/q/swagger-ui`); export with `curl http://localhost:8080/q/openapi -o openapi.json`
- [ ] README has setup steps
- [ ] API changes and breaking changes are documented
- [ ] Configuration properties are documented

### Verification Checklist

- [ ] Build passes with no warnings; static analysis has no high or medium issues
- [ ] All tests pass; coverage is 80% or more; integration tests use a real database
- [ ] No dependency vulnerabilities; auth is tested; secrets are not in source
- [ ] Native executable builds and native tests pass; startup and memory are acceptable
- [ ] Container image builds; health checks respond; configuration is valid for the target environment

### Automated Verification Script

```bash
#!/bin/bash
set -e

echo "=== Phase 1: Build ==="
mvn clean verify -DskipTests

echo "=== Phase 2: Static Analysis ==="
mvn checkstyle:check pmd:check spotbugs:check

echo "=== Phase 3: Tests + Coverage ==="
mvn test jacoco:report jacoco:check

echo "=== Phase 4: Security Scan ==="
mvn org.owasp:dependency-check-maven:check

echo "=== Phase 5: Native Compilation ==="
mvn package -Dnative -Dquarkus.native.container-build=true

echo "=== All Phases Complete ==="
```

### CI Integration (GitHub Actions)

```yaml
name: Verification

on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: maven

      - name: Build
        run: mvn clean verify -DskipTests

      - name: Test with Coverage
        run: mvn test jacoco:report jacoco:check

      - name: Security Scan
        run: mvn org.owasp:dependency-check-maven:check
```

Do the loop before each PR, automate it in CI, fix issues immediately, and test native compilation at regular intervals.
