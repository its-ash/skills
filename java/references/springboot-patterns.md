@REF:springboot-patterns
§STACK{SpringBoot_4(4.2.x;Boot_3.5=last_3.x_bridge),SpringFramework_7,JakartaEE_11(Tomcat_11+/Jetty_12.1+;Undertow_rm),Jackson_3(tools.jackson.*),JSpecify,Java_17+(25_LTS_rec)}
§USE{REST_API(MVC∨WebFlux);Controller→Service→Repo;Spring_Data_JPA_4;RestClient/@ImportHttpServices;core_resilience(@Retryable,@ConcurrencyLimit);cache(@EnableCaching);async(@EnableAsync);validation;RFC9457_ProblemDetail;pagination;profiles(dev,staging,prod);events(Spring_Events∨Kafka)}
§R{thin_controllers;focused_services;simple_repos;central_errors(@RestControllerAdvice+ProblemDetail);ctor_DI∧¬field_DI;@Transactional(readOnly=true)_queries;null_safety(JSpecify:@NullMarked/@Nullable,Optional;¬legacy_Spring_@NonNull);spring.mvc.problemdetails.enabled=true(RFC9457);modular_starters(classic=migration_escape_hatch);Jackson3_ISO8601_dates∧sorted_props(compat:spring.jackson.use-jackson2-defaults=true);HikariCP(pool_size≤DB_cap,timeouts);virtual_threads(spring.threads.virtual.enabled=true)+@ConcurrencyLimit}

§PAT{
REST: @RestController @RequestMapping("/api/markets") @Validated, ctor DI;
  @GetMapping(version="1.0")(@RequestParam(defaultValue="0") int page, @RequestParam(defaultValue="20") int size)→ResponseEntity.ok(svc.list(PageRequest.of(page,size)).map(MarketResponse::from)); // native API versioning (Framework 7)
  @PostMapping(@Valid @RequestBody CreateMarketRequest req)→ResponseEntity.status(HttpStatus.CREATED).body(MarketResponse.from(svc.create(req)))
HTTP_CLIENT: RestClient(sync/virtual_threads) ∨ declarative @HttpExchange interface + @ImportHttpServices(group="pricing",types=PricingClient.class)(Framework_7/Boot_4;¬RestTemplate)
REPO: interface MarketRepository extends JpaRepository<MarketEntity,Long>{@Query("select m from MarketEntity m where m.status = :status order by m.volume desc") List<MarketEntity> findActive(@Param("status") MarketStatus status, Pageable pageable);}
SVC_TX: @Service; @Transactional writes(Market.from(repo.save(MarketEntity.from(req)))); @Transactional(readOnly=true) reads
DTO_VAL: record CreateMarketRequest(@NotBlank @Size(max=200) String name, @NotBlank @Size(max=2000) String description, @NotNull @FutureOrPresent Instant endDate, @NotEmpty List<@NotBlank String> categories){}; record MarketResponse(Long id, String name, MarketStatus status){static MarketResponse from(Market m){return new MarketResponse(m.id(),m.name(),m.status());}}
ERR(@RestControllerAdvice+RFC9457):
  @ExceptionHandler(MethodArgumentNotValidException.class)→ProblemDetail pd=ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST,msg); pd.setTitle("Validation Error"); return pd;
  @ExceptionHandler(AccessDeniedException.class)→ProblemDetail.forStatusAndDetail(HttpStatus.FORBIDDEN,"Forbidden");
  @ExceptionHandler(Exception.class)→log stacktrace→ProblemDetail.forStatusAndDetail(HttpStatus.INTERNAL_SERVER_ERROR,"Internal server error")
CACHE(@EnableCaching): @Cacheable(value="market",key="#id")(repo.findById(id).map(Market::from).orElseThrow(()->new EntityNotFoundException("Market not found"))); @CacheEvict(value="market",key="#id")
ASYNC(@EnableAsync): @Async CompletableFuture<Void> sendAsync(Notification n)→CompletableFuture.completedFuture(null)
RESILIENCE(Framework_7_core,@EnableResilientMethods):
  @Retryable(includes=TransientException.class,maxAttempts=3,delay=100,multiplier=2.0) // built-in Framework 7 (replaces manual Thread.sleep loops & standalone Spring Retry)
  @ConcurrencyLimit(10) // throttles concurrent calls under Virtual Threads to protect downstream DB/APIs
LOG(SLF4J): LoggerFactory.getLogger(Cls.class); log.info("op marketId={}",id); catch Exception ex→log.error("op_failed marketId={}",id,ex);throw ex
FILTER(OncePerRequestFilter): doFilterInternal(HttpServletRequest,HttpServletResponse,FilterChain)→t=System.nanoTime();try{chain.doFilter(req,res);}finally{log.info("req method={} uri={} status={} durationMs={}",req.getMethod(),req.getRequestURI(),res.getStatus(),(System.nanoTime()-t)/1_000_000);}
PAGE: PageRequest.of(pageNumber, pageSize, Sort.by("createdAt").descending())
RATE_LIMIT(Bucket4j_8.21+:com.bucket4j:bucket4j_jdk17-core+OncePerRequestFilter):
  bounded_cache(Caffeine/Redis;¬unbounded_ConcurrentHashMap_OOM) keyed by clientIp=request.getRemoteAddr()∨auth_id;
  Bucket.builder().addLimit(Bandwidth.builder().capacity(100).refillGreedy(100, Duration.ofMinutes(1)).build()).build(); // Bandwidth.classic() deprecated
  bucket.tryConsume(1) ? filterChain.doFilter(req,res) : res.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
  SEC(X-Forwarded-For): untrusted/spoofable⇒¬read X-Forwarded-For directly; use request.getRemoteAddr(). Behind trusted proxy(nginx,AWS ALB) getRemoteAddr() returns client IP ONLY IF: 1) server.forward-headers-strategy=NATIVE|FRAMEWORK, 2) FRAMEWORK⇒@Bean ForwardedHeaderFilter, 3) proxy overwrites(¬appends) X-Forwarded-For, 4) server.tomcat.remoteip.trusted-proxies(or container equiv). Else getRemoteAddr() returns direct conn/proxy IP.
JOBS: @Scheduled ∨ queues(Kafka,SQS,RabbitMQ) ∧ idempotent ∧ observable
}
§CFG{observability:{otel:spring-boot-starter-opentelemetry(Boot4_native),logging:JSON(Logback_encoder),metrics:Micrometer+(Prometheus|OTel),tracing:Micrometer_Tracing(OpenTelemetry|Brave)}}
