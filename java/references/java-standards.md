# Java standards: examples

Tags: **[SPRING]**, **[QUARKUS]**, untagged = shared.

## Naming

```java
public class MarketService {}                         // PascalCase types
public record Money(BigDecimal amount, Currency currency) {}
private final MarketRepository marketRepository;      // camelCase members
private static final int MAX_PAGE_SIZE = 100;         // UPPER_SNAKE constants
public class MarketController {}                      // [SPRING] *Controller
public class MarketResource {}                        // [QUARKUS] JAX-RS *Resource
```

## Immutability and entities

```java
public record MarketDto(Long id, String name, MarketStatus status) {}

// [QUARKUS] Panache active record: public fields are idiomatic (accessors generated at build time)
@Entity public class Market extends PanacheEntity { public String name; public MarketStatus status; }
@MongoEntity(collection = "markets")
public class Market extends PanacheMongoEntity { public String name; public MarketStatus status; }
```

## Optional and streams

```java
Optional<Market> m = marketRepository.findBySlug(slug);                    // [SPRING]
Optional<Market> m = Market.find("slug", slug).firstResultOptional();      // [QUARKUS]
return m.map(MarketResponse::from).orElseThrow(() -> new EntityNotFoundException("Market not found"));

List<String> names = markets.stream().map(Market::name).filter(Objects::nonNull).toList();
```

## Dependency injection

```java
// [SPRING] constructor injection (single constructor, no @Autowired needed)
@Service public class MarketService {
  private final MarketRepository repo;
  public MarketService(MarketRepository repo) { this.repo = repo; }
}
// [QUARKUS] constructor injection, or package-private field injection (avoids proxy issues)
@ApplicationScoped public class MarketService {
  @Inject MarketRepository repo;
}
// FAIL [SPRING]: @Autowired private MarketRepository repo;
// FAIL [QUARKUS]: @Singleton when interception or lazy init is needed (non-proxyable) -> @ApplicationScoped
```

## Reactive (Mutiny) [QUARKUS]

```java
@GET @Path("/{slug}")
public Uni<Market> findBySlug(@PathParam("slug") String slug) {
  return Market.find("slug", slug).<Market>firstResult()
      .onItem().ifNull().failWith(() -> new MarketNotFoundException(slug));
}
public Uni<OrderConfirmation> placeOrder(OrderRequest req) {
  return validateOrder(req).chain(this::persistOrder).chain(this::notifyFulfillment);
}
// FAIL: blocking call inside Uni (Market.find(...).firstResult() then Uni.createFrom().item(m)) breaks event loop
// FAIL: subscribing twice to one Uni -> use Uni.memoize()
```

## Centralized exception handling

```java
// [SPRING]
@RestControllerAdvice public class GlobalExceptionHandler {
  @ExceptionHandler(MarketNotFoundException.class)
  public ResponseEntity<ErrorResponse> handle(MarketNotFoundException ex) {
    return ResponseEntity.status(404).body(ErrorResponse.from(ex));
  }
}
// [QUARKUS] A: ExceptionMapper
@Provider public class MarketNotFoundMapper implements ExceptionMapper<MarketNotFoundException> {
  public Response toResponse(MarketNotFoundException ex) {
    return Response.status(404).entity(ErrorResponse.from(ex)).build();
  }
}
// [QUARKUS] B: RESTEasy Reactive
@ServerExceptionMapper
public RestResponse<ErrorResponse> handle(MarketNotFoundException ex) {
  return RestResponse.status(Status.NOT_FOUND, ErrorResponse.from(ex));
}
```

## Null handling

- Prefer `@NonNull`; accept `@Nullable` only when unavoidable. Bean Validation (`@NotNull`, `@NotBlank`) on inputs.
- [QUARKUS] Put `@Valid` on `@BeanParam`, `@RestForm`, and request body parameters.

## Generics

```java
public <T extends Identifiable> Map<Long, T> indexById(Collection<T> items) { ... }
```

## Project layout

```
[SPRING]                              [QUARKUS]
src/main/java/com/example/app/        src/main/java/com/example/app/
  config/ controller/ service/          config/   (@ConfigMapping, producers)
  repository/ domain/ dto/ util/       resource/ (JAX-RS, not "controller")
src/main/resources/application.yml     service/ repository/ (PanacheRepository) domain/ dto/ util/ mapper/ (MapStruct)
src/test/java/... mirrors main         src/main/resources/application.properties (YAML needs quarkus-config-yaml)
                                       src/main/resources/import.sql (dev/test auto-import)
```

## Logging

```java
// [SPRING] SLF4J
private static final Logger log = LoggerFactory.getLogger(MarketService.class);
log.info("fetch_market slug={}", slug);
log.error("failed_fetch_market slug={}", slug, ex);
// [QUARKUS] JBoss Logging
private static final Logger log = Logger.getLogger(MarketService.class);
log.infof("fetch_market slug=%s", slug);
log.errorf(ex, "failed_fetch_market slug=%s", slug);
@Inject Logger log;   // CDI-injected, scoped to declaring class
```

## Configuration

```java
@ConfigurationProperties(prefix = "market")                         // [SPRING]
public record MarketProperties(int maxPageSize, Duration cacheTtl) {}

@ConfigMapping(prefix = "market")                                   // [QUARKUS] build-time validated
public interface MarketConfig { int maxPageSize(); Duration cacheTtl(); }
@ConfigProperty(name = "market.max-page-size", defaultValue = "100") int maxPageSize;
```

## Tests

```java
@WebMvcTest(MarketController.class)                                 // [SPRING] slice
class MarketControllerTest { @Autowired MockMvc mockMvc; @MockBean MarketService svc; }

@QuarkusTest                                                         // [QUARKUS] CDI integration
class MarketResourceTest {
  @InjectMock MarketService svc;
  @Test void should_return_404_when_market_not_found() {
    given().when().get("/markets/unknown").then().statusCode(404);
  }
}

@ExtendWith(MockitoExtension.class)                                  // unit, no CDI
class MarketServiceTest { @Mock MarketRepository repo; @InjectMocks MarketService svc; }
```
