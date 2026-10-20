---
name: java
description: "Provides best practices and checklists for modern Java 21+ development, covering language features, virtual threads, Spring Boot 3.x, GraalVM native images, JVM tuning, testing, security, and cloud-native deployment. Use when writing Java or JDK code, debugging Maven or Gradle builds, configuring Spring Boot applications, optimizing JVM performance, building GraalVM native images, writing JUnit or Mockito tests, securing Java services, or deploying Java containers to Kubernetes."
---

# Java 21+ Development Guide

Expert guidance for building, modernising, and deploying Java applications with Java 21 or later. Includes language features, virtual threads, Spring Boot 3.x, GraalVM native images, performance tuning, testing, security, and cloud‑native patterns.

## When to use
- You are starting a new Java project with Java 21+.
- You need to modernise an existing Java 17+ codebase.
- You are building micro‑services with Spring Boot 3.x.
- You want to run Java in containers or as a GraalVM native image.
- You need massive concurrency with low overhead.
- You require performance tuning, comprehensive testing, or security hardening.

## Modern Language Features
- Use **record** for immutable data carriers.
  ```java
  public record UserDto(Long id, String name) {}
  ```
- Use **sealed** classes to restrict inheritance.
  ```java
  public sealed interface Shape permits Circle, Rectangle {}
  final class Circle implements Shape { /* ... */ }
  final class Rectangle implements Shape { /* ... */ }
  ```
- Use **pattern matching** for `instanceof` and `switch`.
  ```java
  if (obj instanceof String s) {
      System.out.println(s.toUpperCase());
  }

  switch (obj) {
      case Integer i -> System.out.println(i * 2);
      case String s -> System.out.println(s.length());
      default -> System.out.println("unknown");
  }
  ```
- Use **text blocks** for multiline strings.
  ```java
  String json = """
      {"name":"Alice","age":30}
  """;
  ```
- Use **var** for local type inference when the type is obvious.
- Use the **Foreign Function & Memory API** for native interop.

## Virtual Threads & Structured Concurrency
- Create a virtual thread directly:
  ```java
  Thread.startVirtualThread(() -> {
      // I/O‑bound work
  });
  ```
- Use an executor for many tasks:
  ```java
  try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
      List<Future<String>> futures = List.of(
          executor.submit(() -> fetchData("A")),
          executor.submit(() -> fetchData("B"))
      );
      // process results
  }
  ```
- Apply structured concurrency for reliable shutdown:
  ```java
  try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
      scope.fork(() -> task1());
      scope.fork(() -> task2());
      scope.join();
      scope.throwIfFailed();
  }
  ```
- Prefer non‑blocking I/O libraries (e.g., `java.net.http.HttpClient`) to avoid blocking virtual threads.

## Spring Boot 3.x Practices
- Set Java version to 21 in `pom.xml` or `build.gradle`.
- Add Spring Boot 3 starter dependencies.
- Enable native image support with `spring-graalvm-native`.
- Use **Spring Data JPA** with Hibernate 6 for ORM.
- Secure APIs with **Spring Security 6** (OAuth2, JWT).
- Expose health and metrics via **Actuator**.
- Externalise configuration with profiles, ConfigMaps, and Secrets.
- Use **Spring Cloud** for service discovery, distributed tracing, and resilience patterns.

## GraalVM Native Image
- Install GraalVM 22+ and set `JAVA_HOME`.
- Build a native image:
  ```bash
  native-image --no-fallback -cp target/app.jar
  ```
- Tune container JVM flags for native images:
  ```bash
  -XX:MaxRAMPercentage=80 -XX:ActiveProcessorCount=$(nproc)
  ```
- Avoid reflection and dynamic proxies unless configured with `--initialize-at-run-time`.

## Performance & JVM Tuning
- Choose a GC based on workload:
  - **G1** for balanced throughput and latency.
  - **ZGC** for ultra‑low pause times.
- Set RAM percentages:
  ```bash
  -XX:InitialRAMPercentage=50 -XX:MaxRAMPercentage=80
  ```
- Use **JMH** for micro‑benchmarks.
- Profile with VisualVM, JProfiler, or async‑profiler.
- Reduce startup time with class‑data sharing:
  ```bash
  -XX:+UseAppCDS -XX:SharedArchiveFile=app.jsa
  ```

## Testing Strategy
- Write unit tests with **JUnit 5**.
- Use **parameterized tests** for data‑driven scenarios.
- Mock collaborators with **Mockito**.
- Write integration tests with `@SpringBootTest`.
- Use **Testcontainers** for databases and external services.
- Apply **Spring Cloud Contract** for contract testing.
- Measure coverage with **JaCoCo**.
- Run performance tests with **Gatling** or **JMeter**.

## Security Best Practices
- Validate input with **Bean Validation** (`@Valid`).
- Use prepared statements or JPA parameters to prevent SQL injection.
- Enable CSRF protection in Spring Security.
- Store secrets in environment variables, Kubernetes Secrets, or HashiCorp Vault.
- Scan dependencies with **OWASP Dependency‑Check** or **GitHub Dependabot**.
- Apply OWASP Top 10 mitigations (XSS, insecure deserialization, etc.).

## Cloud‑Native Deployment
- Containerise with Docker. Example Dockerfile snippet:
  ```dockerfile
  FROM ghcr.io/graalvm/graalvm-ce:java21
  COPY target/app.jar /app.jar
  ENTRYPOINT ["java","-XX:MaxRAMPercentage=80","-jar","/app.jar"]
  ```
- Deploy to Kubernetes with liveness/readiness probes.
- Use **Spring Cloud Config** for centralized configuration.
- Add a service mesh (e.g., Istio) for traffic management and resilience.
- Enable distributed tracing with **Micrometer** and **OpenTelemetry**.

## Common Pitfalls
- Mixing virtual threads with blocking I/O without adapters can waste resources.
- Heavy use of reflection breaks GraalVM native images.
- Over‑using `var` can hide important type information.
- Ignoring GC tuning leads to latency spikes.
- Skipping native‑image testing may hide runtime errors.

## Checklist
- [ ] Set Java version to 21 in build configuration.
- [ ] Use records, sealed classes, and pattern matching where appropriate.
- [ ] Replace platform threads with virtual threads for I/O‑bound work.
- [ ] Add Spring Boot 3.x starters and configure profiles.
- [ ] Enable Actuator endpoints for health and metrics.
- [ ] Configure Spring Security with OAuth2/JWT.
- [ ] Add GraalVM native‑image plugin and verify native build.
- [ ] Choose GC (G1 or ZGC) and set RAM percentages.
- [ ] Write unit, integration, and contract tests.
- [ ] Run JMH benchmarks for critical paths.
- [ ] Apply OWASP security checks and manage secrets securely.
- [ ] Containerise with optimized JVM flags.
- [ ] Deploy to Kubernetes with probes, limits, and service mesh.
- [ ] Enable distributed tracing and observability.

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`performance`](../performance/SKILL.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`dependency-updates`](../dependency-updates/SKILL.md) — Automates detection, safe updating, and security auditing of project dependencies across major languages. Use…
- [`salesforce`](../salesforce/SKILL.md) — Salesforce Development skill provides concrete patterns for Lightning Web Components, bulkified Apex triggers…
