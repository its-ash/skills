@REF:springboot-patterns
§USE{REST_API(MVC∨WebFlux);Controller→Service→Repo;Spring_Data_JPA;cache(@EnableCaching);async(@EnableAsync);validation;err_handling;pagination;profiles(dev,staging,prod);events(Spring_Events∨Kafka)}
§R{thin_controllers;focused_services;simple_repos;central_errors(@ControllerAdvice);ctor_DI∧¬field_DI;@Transactional(readOnly=true)_queries;null_safety(@NonNull,Optional);spring.mvc.problemdetails.enabled=true(Boot3+,RFC7807);HikariCP(pool_size,timeouts)}

§PAT{
REST: @RestController @RequestMapping("/api/markets") @Validated, ctor DI;
  @GetMapping(@RequestParam(defaultValue="0") int page, @RequestParam(defaultValue="20") int size)→ResponseEntity.ok(svc.list(PageRequest.of(page,size)).map(MarketResponse::from));
  @PostMapping(@Valid @RequestBody CreateMarketRequest req)→ResponseEntity.status(HttpStatus.CREATED).body(MarketResponse.from(svc.create(req)))
REPO: interface MarketRepository extends JpaRepository<MarketEntity,Long>{@Query("select m from MarketEntity m where m.status = :status order by m.volume desc") List<MarketEntity> findActive(@Param("status") MarketStatus status, Pageable pageable);}
SVC_TX: @Service; @Transactional writes(Market.from(repo.save(MarketEntity.from(req)))); @Transactional(readOnly=true) reads
DTO_VAL: record CreateMarketRequest(@NotBlank @Size(max=200) String name, @NotBlank @Size(max=2000) String description, @NotNull @FutureOrPresent Instant endDate, @NotEmpty List<@NotBlank String> categories){}; record MarketResponse(Long id, String name, MarketStatus status){static MarketResponse from(Market m){return new MarketResponse(m.id(),m.name(),m.status());}}
ERR(@ControllerAdvice):
  @ExceptionHandler(MethodArgumentNotValidException.class)→ex.getBindingResult().getFieldErrors() join(e.getField()+": "+e.getDefaultMessage(), ", ")→400 ResponseEntity.badRequest().body(ApiError.validation(msg));
  @ExceptionHandler(AccessDeniedException.class)→403 HttpStatus.FORBIDDEN ApiError.of("Forbidden");
  @ExceptionHandler(Exception.class)→log stacktrace→500 HttpStatus.INTERNAL_SERVER_ERROR ApiError.of("Internal server error")
CACHE(@EnableCaching): @Cacheable(value="market",key="#id")(repo.findById(id).map(Market::from).orElseThrow(()->new EntityNotFoundException("Market not found"))); @CacheEvict(value="market",key="#id")
ASYNC(@EnableAsync): @Async CompletableFuture<Void> sendAsync(Notification n)→CompletableFuture.completedFuture(null)
LOG(SLF4J): LoggerFactory.getLogger(Cls.class); log.info("op marketId={}",id); catch Exception ex→log.error("op_failed marketId={}",id,ex);throw ex
FILTER(OncePerRequestFilter): doFilterInternal(HttpServletRequest,HttpServletResponse,FilterChain)→t=System.currentTimeMillis();try{chain.doFilter(req,res);}finally{log.info("req method={} uri={} status={} durationMs={}",req.getMethod(),req.getRequestURI(),res.getStatus(),System.currentTimeMillis()-t);}
PAGE: PageRequest.of(pageNumber, pageSize, Sort.by("createdAt").descending())
RETRY: withRetry(Supplier<T> s, int maxRetries): int a=0;while(true){try{return s.get();}catch(Exception ex){if(++a>=maxRetries)throw ex;try{Thread.sleep((long)Math.pow(2,a)*100L);}catch(InterruptedException ie){Thread.currentThread().interrupt();throw ex;}}}
RATE_LIMIT(Bucket4j+OncePerRequestFilter):
  ConcurrentHashMap<String,Bucket> keyed by clientIp=request.getRemoteAddr();
  Bucket.builder().addLimit(Bandwidth.classic(100, Refill.greedy(100, Duration.ofMinutes(1)))).build();
  bucket.tryConsume(1) ? filterChain.doFilter(req,res) : res.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
  SEC(X-Forwarded-For): untrusted/spoofable⇒¬read X-Forwarded-For directly; use request.getRemoteAddr(). Behind trusted proxy(nginx,AWS ALB) getRemoteAddr() returns client IP ONLY IF: 1) server.forward-headers-strategy=NATIVE|FRAMEWORK, 2) FRAMEWORK⇒@Bean ForwardedHeaderFilter, 3) proxy overwrites(¬appends) X-Forwarded-For, 4) server.tomcat.remoteip.trusted-proxies(or container equiv). Else getRemoteAddr() returns direct conn/proxy IP.
JOBS: @Scheduled ∨ queues(Kafka,SQS,RabbitMQ) ∧ idempotent ∧ observable
}
§CFG{observability:{logging:JSON(Logback_encoder),metrics:Micrometer+(Prometheus|OTel),tracing:Micrometer_Tracing(OpenTelemetry|Brave)}}
