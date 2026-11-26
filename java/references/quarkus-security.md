@REF:quarkus-security
§SCOPE{use∈{JWT(MP/SmallRye),OIDC,BasicAuth,@RolesAllowed,SecurityIdentity,BeanValidation,custom_@Constraint,CORS,sec_headers,Vault/env_secrets,rate_limit,audit_log,CVE_scan}}
§CFG{
  properties:```properties
mp.jwt.verify.publickey.location=publicKey.pem
mp.jwt.verify.issuer=https://auth.example.com
quarkus.oidc.auth-server-url=https://auth.example.com/realms/myrealm
quarkus.oidc.client-id=backend-service
quarkus.oidc.credentials.secret=${OIDC_SECRET}
quarkus.http.cors=true
quarkus.http.cors.origins=https://app.example.com,https://admin.example.com
quarkus.http.cors.methods=GET,POST,PUT,DELETE
quarkus.http.cors.headers=accept,authorization,content-type,x-requested-with
quarkus.http.cors.exposed-headers=Content-Disposition
quarkus.http.cors.access-control-max-age=24H
quarkus.http.cors.access-control-allow-credentials=true
quarkus.datasource.username=${DB_USER}
quarkus.datasource.password=${DB_PASSWORD}
quarkus.oidc.credentials.secret=${OIDC_CLIENT_SECRET}
quarkus.vault.url=https://vault.example.com
quarkus.vault.authentication.kubernetes.role=my-role
```;
  rule:¬hardcode_secrets(application.properties)⇒env_vars∨Vault
}
§AUTH{
  jwt:`@Path("/api/protected") @Authenticated`+`@Inject JsonWebToken jwt`(`getName()`,`getGroups()`)+`@Inject SecurityIdentity si`(`getPrincipal().getName()`);
  custom_filter:`@Provider @Priority(Priorities.AUTHENTICATION) implements ContainerRequestFilter`→`h=ctx.getHeaderString(HttpHeaders.AUTHORIZATION)`;`h==null||!h.startsWith("Bearer ")||!validateToken(h.substring(7))`⇒`ctx.abortWith(Response.status(Response.Status.UNAUTHORIZED).build())`
}
§AUTHZ{
  rbac:`@RolesAllowed("ADMIN")`(class/method);method_override:`@RolesAllowed({"ADMIN","SUPER_ADMIN"})`;
  ownership:`@RolesAllowed("USER")`+`!si.hasRole("ADMIN")&&!isOwner(id,si.getPrincipal().getName())`⇒`Response.status(Response.Status.FORBIDDEN).build()`;
  programmatic(`@ApplicationScoped`):`si.isAnonymous()`⇒`false`;`si.hasRole("ADMIN")`⇒`true`;else→`resourceRepository.isOwner(resourceId,si.getPrincipal().getName())`
}
§VAL{
  dto:`record CreateUserDto(@NotBlank @Size(max=100) String name,@NotBlank @Email String email,@NotNull @Min(18) @Max(150) Integer age,@Pattern(regexp="^\\+?[1-9]\\d{1,14}$") String phone)`→`@POST @Path("/users") createUser(@Valid CreateUserDto dto)`→`201 CREATED`;
  custom:`@Target({ElementType.FIELD,ElementType.PARAMETER}) @Retention(RetentionPolicy.RUNTIME) @Constraint(validatedBy=UsernameValidator.class) @interface ValidUsername{String message() default "Invalid username format";Class<?>[] groups() default {};Class<? extends Payload>[] payload() default {};}`+`ConstraintValidator<ValidUsername,String>:isValid(v,ctx)=>v!=null&&v.matches("^[a-zA-Z0-9_-]{3,20}$")`;
  rule:∀endpoint_input⇒`@Valid`(¬unvalidated_DTO)
}
§SQLI{
  panache_pos:`User.list("email = ?1 and active = ?2",email,true)`;`User.find("username",username).firstResultOptional()`;
  panache_named:`User.list("email = :email and age > :minAge",Parameters.with("email",email).and("minAge",18))`;
  native:`getEntityManager().createNativeQuery("SELECT * FROM users WHERE email = :email",User.class).setParameter("email",email).getResultList()`;
  anti:¬concat_SQL(`"SELECT ... '" + name + "'"`)
}
§PASS{
  hash:`BcryptUtil.bcryptHash(plainPassword)`;verify:`BcryptUtil.matches(plainPassword,hashedPassword)`;
  flow:`@Transactional register(dto)`→`hash(dto.password())`→`user.persist()`;`authenticate(email,pw)`→`User.find("email",email).firstResultOptional().map(u->verify(pw,u.password)).orElse(false)`;
  rule:¬plaintext_passwords
}
§SECRETS{vault_read:`@ConfigProperty(name="api-key") String apiKey;`∨`ConfigProvider.getConfig().getValue(key,String.class)`}
§RATELIMIT{
  rule:¬trust(`X-Forwarded-For`,client_spoofable);use(`servletRequest.getRemoteAddr()`∨auth_id∈{API_key,JWT_sub});
  proxy_cfg:behind_trusted_proxy⇒`quarkus.http.proxy.proxy-address-forwarding=true`→`getRemoteAddr()`_real_IP;
  filter:`@ApplicationScoped implements ContainerRequestFilter`+`ConcurrentHashMap<String,RateLimiter> limiters`+`@Inject HttpServletRequest servletRequest`:`!limiters.computeIfAbsent(servletRequest.getRemoteAddr(),k->RateLimiter.create(100.0)).tryAcquire()`⇒`ctx.abortWith(Response.status(429).entity(Map.of("error","Too many requests")).build())`
}
§HEADERS{
  filter:`@Provider ContainerResponseFilter`→`response.getHeaders().putSingle(k,v)`:
  `X-Frame-Options`:"DENY",`X-Content-Type-Options`:"nosniff",`X-XSS-Protection`:"1; mode=block",`Strict-Transport-Security`:"max-age=31536000; includeSubDomains",`Content-Security-Policy`:"default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'";
  csp_rule:¬`'unsafe-inline'`∈`script-src`⇒nonces∨hashes;`'unsafe-inline'`∈`style-src`⇔CSS_fw_requires(prefer_nonces)
}
§AUDIT{
  svc:`Logger.getLogger(AuditService.class)`+`@Inject SecurityIdentity si`;`user=si.isAnonymous()?"anonymous":si.getPrincipal().getName()`;`LOG.infof("AUDIT: user=%s action=%s resource=%s timestamp=%s",user,action,resource,Instant.now())`
}
§CMD{maven_cve:`mvn org.owasp:dependency-check-maven:check`;gradle_cve:`./gradlew dependencyCheckAnalyze`;quarkus_ext:`quarkus extension list --installable`}
§R{1:prod⇒HTTPS;2:stateless_auth∈{JWT,OIDC};3:declarative(`@RolesAllowed`)∧programmatic(`SecurityIdentity`);4:validate_all_inputs(BeanValidation);5:hash_passwords(BCrypt);6:secrets∈{Vault,env_vars};7:parameterized_queries(¬concat);8:all_responses⇒security_headers;9:public_endpoints⇒rate_limit;10:sensitive_ops⇒audit_log;11:deps_updated∧CVE_scan;12:explicit_CORS_policy;13:test(authn∧authz_paths)}
