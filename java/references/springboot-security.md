@REF:springboot-security
§STACK{SpringSecurity_7(SpringBoot_4/Framework_7,JakartaEE_11,Jackson_3_SecurityJacksonModules);SpringAuthServer_folded_into_core_portfolio}
§USE{auth(JWT,OAuth2_ResourceServer,Passkeys/WebAuthn,session);authz(@PreAuthorize,AuthorizationManager,RBAC);input_val(BeanValidation,custom);CORS;CSRF;headers;secrets(Vault,env);rate_limit/brute_force;CVE_scan}
§R{deny_by_default;least_privilege;mandatory_Lambda_DSL(¬.and()_removed);PathPatternRequestMatcher(¬AntPathRequestMatcher/MvcRequestMatcher);AuthorizationManager#authorize(¬#check_removed);validate_inputs;secure_by_config;¬secrets_in_src;¬log(secrets,tokens,passwords,full_PAN);¬string_concat_SQL;¬wildcard_CORS_prod;sanitize_HTML_whitelist}

§PAT{
AUTH:
  resource_srv(pref):http.oauth2ResourceServer(o->o.jwt(Customizer.withDefaults())) ∨ opaqueToken(revocation);
  passkeys(Sec7):spring-security-webauthn(FIDO2/WebAuthn4J)→http.webAuthn(w->w.rpName("App").rpId("example.com").allowedOrigins("https://example.com"));
  session_cookies⇒httpOnly∧Secure∧SameSite=Strict;
  custom_filter(OncePerRequestFilter):h=req.getHeader(HttpHeaders.AUTHORIZATION); if(h!=null&&h.startsWith("Bearer ")) SecurityContextHolder.getContext().setAuthentication(jwtService.authenticate(h.substring(7))); chain.doFilter(req,res);
AUTHZ: @EnableMethodSecurity; @PreAuthorize("hasRole('ADMIN')") | @PreAuthorize("@authz.canEdit(#id)") | @PreAuthorize("@authz.isOwner(#id, authentication)"); custom:AuthorizationManager#authorize(Supplier<Authentication>,T)∧AllAuthoritiesAuthorizationManager; expose min required scopes
INPUT_VAL: @Valid on @RequestBody DTOs: record CreateUserDto(@NotBlank @Size(max=100) String name, @NotBlank @Email String email, @NotNull @Min(0) @Max(150) Integer age){}→ResponseEntity.status(HttpStatus.CREATED).body(...)
SQLI: Spring Data derived(findByEmailAndActiveTrue(String)) ∨ parameterized @Query(value="SELECT * FROM users WHERE name = :name", nativeQuery=true) w/ @Param("name"); ¬concat strings in @Query
PASSWORD: @Bean PasswordEncoder: Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8() ∨ new BCryptPasswordEncoder(12); passwordEncoder.encode(dto.password()); ¬plaintext, ¬manual hash
CSRF: browser sessions⇒CSRF enabled + token in forms/headers; stateless Bearer APIs⇒http.csrf(c->c.disable()).sessionManagement(sm->sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
SECRETS: env ${DB_PASSWORD}(spring.datasource.password) ∨ Spring Cloud Vault(spring.cloud.vault.{uri,token:${VAULT_TOKEN}}); ¬hardcode in application.yml; rotate tokens & DB creds regularly
HEADERS: http.headers(h->h.contentSecurityPolicy(c->c.policyDirectives("default-src 'self'")).frameOptions(HeadersConfigurer.FrameOptionsConfig::sameOrigin).xssProtection(Customizer.withDefaults()).referrerPolicy(r->r.policy(ReferrerPolicyHeaderWriter.ReferrerPolicy.NO_REFERRER))) // modern CSP supersedes legacy X-XSS-Protection
CORS: filter-level(http.cors(c->c.configurationSource(corsConfigurationSource()))), ¬per-controller; UrlBasedCorsConfigurationSource.registerCorsConfiguration("/api/**",cfg): allowedOrigins(List.of("https://app.example.com"))(¬* prod), allowedMethods(GET,POST,PUT,DELETE), allowedHeaders(Authorization,Content-Type), allowCredentials(true), maxAge(3600L)
RATE_LIMIT: Bucket4j_8.21+(Bandwidth.builder().capacity(100).refillIntervally(100, Duration.ofMinutes(1)).build(); ¬deprecated_Bandwidth.classic) in OncePerRequestFilter(bounded_cache_Caffeine/Redis keyed by request.getRemoteAddr()∨auth_id) ∨ gateway-level on expensive endpoints; limit⇒429+{"error":"Rate limit exceeded"}+Retry-After; log+alert bursts
DEPS: OWASP Dependency Check ∨ Trivy/Snyk in CI; supported Spring Boot 4 & Spring Security 7 versions; fail build on known CVEs
LOG_PII: redact sensitive fields; structured JSON logging
UPLOADS: validate size, content-type, extension; store outside web root; scan if required
}
§CHK{release:[Lambda_DSL∧PathPatternRequestMatcher,tokens_validated_expired,authz_sensitive_paths,inputs_validated_sanitized,¬concat_SQL,CSRF_app_type,secrets_externalized_none_committed,sec_headers_set,rate_limit_APIs,deps_scanned_current,logs_no_sensitive_data]}
§REL{../secure-coding/SKILL.md}
