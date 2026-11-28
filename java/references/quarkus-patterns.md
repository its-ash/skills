@REF:quarkus-patterns
§SCOPE{Quarkus_4.0(Java_21+_min/25_rec,Vertx_5,Netty_4.2,Hibernate_ORM_8,Jakarta_Data_1.1/Quarkus_Data/Panache_2,Jackson_3,HTTP/3)∨Quarkus_3_LTS(3.40_LTS/3.33_LTS;Hibernate_ORM_7):quarkus-rest,@RunOnVirtualThread,Resource→Service→PanacheRepository,Apache_Camel+RabbitMQ,Bean_Validation,@ServerExceptionMapper,Logback/Logstash,CompletableFuture,Cache,YAML_profiles,Health,GraalVM_native}

§DEPS{
  props:quarkus.platform.version=4.0.x|3.40.x(LTS),lombok.version=1.18.42,assertj-core.version=3.27.7(CVE-2026-24400),jacoco-maven-plugin.version=0.8.16,maven.compiler.release=25(min_21_Q4);
  boms(import/pom):io.quarkus.platform:quarkus-bom,io.quarkus.platform:quarkus-camel-bom;
  core:io.quarkus:quarkus-arc,io.quarkus:quarkus-rest,io.quarkus:quarkus-rest-jackson,io.quarkus:quarkus-config-yaml;
  data:io.quarkus:quarkus-hibernate-orm-panache(∨Quarkus_Data_Jakarta_Data_1.1_on_Q4);
  camel:org.apache.camel.quarkus:camel-quarkus-{spring-rabbitmq,direct,bean};
  lombok:org.projectlombok:lombok(scope=provided);
  log:io.quarkiverse.logging.logback:quarkus-logging-logback,net.logstash.logback:logstash-logback-encoder;
  test:io.quarkus:quarkus-junit(3.31+_renamed_from_quarkus-junit5),io.quarkus:quarkus-junit-mockito,camel-quarkus-junit5,AssertJ≥3.27.7
}

§SVC{
  di:@ApplicationScoped+@RequiredArgsConstructor(Lombok)+@Slf4j;keep service thin(delegate complex logic);
  tx:@Transactional on write methods;keep short;¬async ops inside @Transactional;
  flow:validate(command)→if !valid: eventService.createErrorEvent(cmd,"ORDER_REJECTED",msg)+throw WebApplicationException(msg,BAD_REQUEST)→repo.persist(entity)→publisher.publishAsync(receipt)→auditPublisher.publish("ORDER_ACCEPTED",receipt)→eventService.createSuccessEvent(receipt,"ORDER_ACCEPTED")
}

§LOG{
  scope:`LogContext ctx = CustomLog.getCurrentContext(); try (SafeAutoCloseable _ = CustomLog.startScope(ctx)) { ctx.put("documentId",...); ctx.put("documentType",...); ctx.put("userId",SecurityContext.getUserId()); ... }` (all logs in scope inherit ctx);
  async:pass `LogContext` into `CompletableFuture.supplyAsync`+reopen `startScope(logContext)`
}
```xml
<!-- logback.xml -->
<configuration>
  <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="net.logstash.logback.encoder.LogstashEncoder"><includeContext>true</includeContext><includeMdc>true</includeMdc></encoder>
  </appender>
  <logger name="com.example" level="INFO"/>
  <root level="WARN"><appender-ref ref="CONSOLE"/></root>
</configuration>
```

§EVT{
  deps:EventRepository,ObjectMapper(Jackson_3:tools.jackson.databind.ObjectMapper_on_Q4);
  createSuccessEvent(payload,eventType):Objects.requireNonNull(payload)→Event(type,EventStatus.SUCCESS,serializePayload(payload),Instant.now())→persist;
  createErrorEvent(payload,eventType,errorMsg):Objects.requireNonNull(payload)∧reject(errorMsg==null||isBlank⇒IllegalArgumentException)→Event(type,EventStatus.ERROR,errorMsg,serializePayload(payload),Instant.now())→persist;
  serializePayload:objectMapper.writeValueAsString(payload) catch Exception⇒throw IllegalStateException
}

§CAMEL{
  pub:ProducerTemplate.sendBody("direct:...",payload)(sync) | ProducerTemplate.asyncSendBody(...)(async);
  route_base:@ApplicationScoped extends RouteBuilder;inject `@ConfigProperty(name="...")`;
  rabbitmq:from("direct:...").routeId(...).marshal().json(JsonLibrary.Jackson).toF("spring-rabbitmq:%s?hostname=%s&portNumber=%d",queue,host,port);
  direct_cbr:onException(ValidationException.class).handled(true).to("direct:validation-error-handler")...;choice().when(header("documentType").isEqualTo("INVOICE")).to(...)...otherwise().to(...).end();
  file:from("file:"+inDir+"?move="+doneDir+"&moveFailed="+errDir+"&delay=5000").routeId("file-monitor")...to("direct:process-file");
  bean_expr:.bean(BeanClass.class,"method") | .bean(EventService.class,"createSuccessEvent(${body}, 'PUBLISHED')")
}

§REST{
  cls:@Path("/api/documents") @Produces(APPLICATION_JSON) @Consumes(APPLICATION_JSON) @RequiredArgsConstructor;
  vt:blocking_IO_endpoints⇒@RunOnVirtualThread(Java_21+/25;avoids_blocking_event_loop_or_platform_worker_pool);
  list:@GET (@QueryParam("page") @DefaultValue("0") int page, @QueryParam("size") @DefaultValue("20") int size)→RestResponse.ok(list);
  create:@POST (@Valid CreateDocumentRequest req, @Context UriInfo uriInfo)→URI loc=uriInfo.getAbsolutePathBuilder().path(String.valueOf(doc.id)).build(); RestResponse.created(loc); // or Response.created(loc).entity(DocumentResponse.from(doc)).build()
  getById:@GET @Path("/{id}") (@PathParam("id") Long id)→findById(id).map(DocumentResponse::from).map(Response::ok).orElse(Response.status(NOT_FOUND)).build()
}

§REPO{
  cls:@ApplicationScoped implements PanacheRepository<Document>; // Q4_alt:Quarkus_Data(@Repository+Jakarta_Data_1.1)
  queries:
    find("status = ?1 order by createdAt desc",status).page(page,size).list();
    find("referenceNumber",ref).firstResultOptional();
    count("status = ?1 and createdAt >= ?2",status,date.atStartOfDay());
    findByIdOptional(id);
    findAll().page(page,size).list()
}

§DTO_VAL_ERR{
  dto:Java `record` + Bean Validation(@NotBlank,@Size(max=200|2000),@NotNull,@FutureOrPresent,@NotEmpty List<@NotBlank String>) + static `from(Entity)`;
  val_mapper(quarkus-rest_pref):@ServerExceptionMapper RestResponse<Map<String,String>> map(ConstraintViolationException e)→RestResponse.status(Status.BAD_REQUEST, Map.of("error","validation_error","message",violations.stream().map(cv→cv.getPropertyPath()+": "+cv.getMessage()).collect(joining(", "))));
  gen_mapper:@ServerExceptionMapper RestResponse<Map<String,String>> map(Exception e)→log.error, RestResponse.status(Status.INTERNAL_SERVER_ERROR, Map.of("error","internal_error","message","An unexpected error occurred")) // alt:@Provider ExceptionMapper<X>
}

§ASYNC_S3{
  pattern:CompletableFuture.supplyAsync(()->{ try(SafeAutoCloseable _=CustomLog.startScope(logCtx)){ s3Client.putObject(PutObjectRequest.builder().bucket(bucket).key(path).contentLength(size).build(), RequestBody.fromInputStream(in,size)); return new StoredDocumentInfo(path,size,Instant.now()); } catch(Exception e){ throw new StorageException("Upload failed",e); } }, executorService);
  rules:use for non-blocking I/O;`.join()` when waiting;handle exceptions;propagate `LogContext`
}

§CACHE{
  read:@CacheResult(cacheName="document-cache") Optional<Document> getById(@CacheKey Long id);
  evict:@CacheInvalidate(cacheName="document-cache") void evict(@CacheKey Long id);
  evictAll:@CacheInvalidateAll(cacheName="document-cache") void evictAll()
}

§CFG_YAML{
  `%dev`:quarkus.datasource.{jdbc.url:"jdbc:postgresql://localhost:5432/dev_db",username:dev_user,password:${DB_PASSWORD}}, hibernate-orm.database.generation:drop-and-create, rabbitmq:{host:localhost,port:5672,username:${RABBITMQ_USER},password:${RABBITMQ_PASSWORD}};
  `%test`:prefer_Dev_Services(auto_PostgreSQL_container≡prod;omit_jdbc.url)∨fallback_H2_only_if_no_Docker;
  `%prod`:quarkus.datasource.{jdbc.url:${DATABASE_URL},username:${DB_USER},password:${DB_PASSWORD}}, hibernate-orm.database.generation:validate, rabbitmq:{host:${RABBITMQ_HOST},port:${RABBITMQ_PORT},username:${RABBITMQ_USER},password:${RABBITMQ_PASSWORD}};
  camel:camel.rabbitmq.queue.{business-rules:business-rules-queue,invoice-processing:invoice-processing-queue}
}

§HEALTH{
  readiness:@Readiness @ApplicationScoped HealthCheck(AgroalDataSource)→try(Connection c=ds.getConnection()){return HealthCheckResponse.named("Database connection").status(c.isValid(2)).build();} catch(SQLException e){return HealthCheckResponse.down("Database connection");};
  liveness:@Liveness @ApplicationScoped HealthCheck(@Inject CamelContext)→HealthCheckResponse.named("Camel Context").status(camelContext.getStatus().isStarted()).build()
}

§OPS{
  stream:stay on Quarkus 4.0(upgrade:`quarkus update --stream=4.0`)∨active 3.x LTS(3.40/3.33);use Quarkus dev mode(hot reload);Leyden_AOT_cache∨GraalVM_native;add health checks;
  test:quarkus-junit+camel-quarkus-junit5+AssertJ≥3.27.7;mock external deps;test conditional Camel flow logic thoroughly
}
