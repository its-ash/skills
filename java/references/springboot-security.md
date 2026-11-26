@REF:springboot-security
§USE{auth(JWT,OAuth2,session);authz(@PreAuthorize,RBAC);input_val(BeanValidation,custom);CORS;CSRF;headers;secrets(Vault,env);rate_limit/brute_force;CVE_scan}
§R{deny_by_default;least_privilege;validate_inputs;secure_by_config;¬secrets_in_src;¬log(secrets,tokens,passwords,full_PAN);¬string_concat_SQL;¬wildcard_CORS_prod;sanitize_HTML_whitelist}

§PAT{
AUTH: stateless JWT ∨ opaque tokens w/ revocation list; session cookies⇒httpOnly∧Secure∧SameSite=Strict; OncePerRequestFilter ∨ resource server:
  h=req.getHeader(HttpHeaders.AUTHORIZATION); if(h!=null&&h.startsWith("Bearer ")) SecurityContextHolder.getContext().setAuthentication(jwtService.authenticate(h.substring(7))); chain.doFilter(req,res);
AUTHZ: @EnableMethodSecurity; @PreAuthorize("hasRole('ADMIN')") | @PreAuthorize("@authz.canEdit(#id)") | @PreAuthorize("@authz.isOwner(#id, authentication)"); expose min required scopes
INPUT_VAL: @Valid on @RequestBody DTOs: record CreateUserDto(@NotBlank @Size(max=100) String name, @NotBlank @Email String email, @NotNull @Min(0) @Max(150) Integer age){}→ResponseEntity.status(HttpStatus.CREATED).body(...)
SQLI: Spring Data derived(findByEmailAndActiveTrue(String)) ∨ parameterized @Query(value="SELECT * FROM users WHERE name = :name", nativeQuery=true) w/ @Param("name"); ¬concat strings in @Query
PASSWORD: @Bean PasswordEncoder: new BCryptPasswordEncoder(12)(cost 12) ∨ Argon2; passwordEncoder.encode(dto.password()); ¬plaintext, ¬manual hash
CSRF: browser sessions⇒CSRF enabled + token in forms/headers; stateless Bearer APIs⇒http.csrf(c->c.disable()).sessionManagement(sm->sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
SECRETS: env ${DB_PASSWORD}(spring.datasource.password) ∨ Spring Cloud Vault(spring.cloud.vault.{uri,token:${VAULT_TOKEN}}); ¬hardcode in application.yml; rotate tokens & DB creds regularly
HEADERS: http.headers(h->h.contentSecurityPolicy(c->c.policyDirectives("default-src 'self'")).frameOptions(HeadersConfigurer.FrameOptionsConfig::sameOrigin).xssProtection(Customizer.withDefaults()).referrerPolicy(r->r.policy(ReferrerPolicyHeaderWriter.ReferrerPolicy.NO_REFERRER)))
CORS: filter-level(http.cors(c->c.configurationSource(corsConfigurationSource()))), ¬per-controller; UrlBasedCorsConfigurationSource.registerCorsConfiguration("/api/**",cfg): allowedOrigins(List.of("https://app.example.com"))(¬* prod), allowedMethods(GET,POST,PUT,DELETE), allowedHeaders(Authorization,Content-Type), allowCredentials(true), maxAge(3600L)
RATE_LIMIT: Bucket4j(Bandwidth.classic(100, Refill.intervally(100, Duration.ofMinutes(1)))) in OncePerRequestFilter(ConcurrentHashMap<String,Bucket> keyed by request.getRemoteAddr()) ∨ gateway-level on expensive endpoints; limit⇒429+{"error": "Rate limit exceeded"}+retry hints; log+alert bursts
DEPS: OWASP Dependency Check ∨ Snyk in CI; supported Spring Boot & Spring Security versions; fail build on known CVEs
LOG_PII: redact sensitive fields; structured JSON logging
UPLOADS: validate size, content-type, extension; store outside web root; scan if required
}
§CHK{release:[tokens_validated_expired,authz_sensitive_paths,inputs_validated_sanitized,¬concat_SQL,CSRF_app_type,secrets_externalized_none_committed,sec_headers_set,rate_limit_APIs,deps_scanned_current,logs_no_sensitive_data]}
§REL{secure-coding/SKILL.md}
