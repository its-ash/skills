---
name: docker
description: "Optimizes Dockerfiles with multi-stage builds, BuildKit cache mounts, build-time secrets, and distroless images; hardens container security through non-root users, read-only filesystems, and capability dropping; configures production Docker Compose with healthchecks, resource limits, and override patterns; enables cross-platform builds via buildx. Use when writing Dockerfile, docker-compose.yml, .dockerignore, or buildx commands; debugging image bloat, slow builds, permission errors, CVE scans, OOM kills, or architecture mismatches; optimizing layer caching, reducing attack surface, injecting SSH keys or tokens at build time, or targeting linux/amd64 and linux/arm64 simultaneously."
---

# Docker

Expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container security hardening, Docker Compose orchestration, and performance tuning.

## When to use
- You need faster, cache‑friendly Docker builds.
- Your images are larger than necessary.
- Containers run as root or expose secrets.
- You must configure a production‑ready Docker Compose stack.
- You want to enforce resource limits, health checks, or cross‑platform builds.
- You are troubleshooting build failures, runtime errors, or networking issues.

## Workflow
1. **Detect Docker environment**
   ```bash
   docker --version || echo "Docker not installed"
   docker info | grep -E "Server Version|Storage Driver|Runtime"
   ```
2. **Locate project files**
   ```bash
   find . -name "Dockerfile*" -type f
   find . -name "*compose*.yml" -o -name "*compose*.yaml" -type f
   ls -1 .dockerignore 2>/dev/null
   ```
3. **Analyze Dockerfile patterns**
   - Identify base image, number of layers, and build stages.
   - Verify `.dockerignore` excludes unnecessary files.
4. **Apply optimizations** (see Patterns section).
5. **Validate**
   ```bash
   docker build --no-cache -t test-build . && echo "Build OK"
   docker run --rm -d --name tmp test-build
   docker exec tmp ps aux | head -3
   docker stop tmp
   docker-compose config && echo "Compose OK"
   ```
6. **Scan for vulnerabilities** (optional)
   ```bash
   docker scout quickview test-build || echo "No scout installed"
   ```

## Rules & Best Practices
- **Layer caching**: Install dependencies before copying source code.
- **Multi‑stage builds**: Separate build and runtime stages; copy only required artifacts.
- **`.dockerignore`**: Exclude source control files, local caches, and build artifacts.
- **Base image**: Choose the smallest suitable image (Alpine, Distroless, or `scratch`).
- **Non‑root user**: Create a user with a fixed UID/GID and use `USER`.
- **Secrets**: Never store secrets in `ENV` or image layers. Use Docker secrets or BuildKit `--mount=type=secret`.
- **Health checks**: Add `HEALTHCHECK` to detect failed containers.
- **Resource limits**: Define CPU and memory limits in Compose `deploy.resources`.
- **Network isolation**: Use separate networks for frontend and backend services.
- **Image size**: Remove build tools and caches in the same `RUN` layer.
- **Cross‑platform**: Use `docker buildx` for multi‑arch images.

## Patterns
### Optimized Multi‑Stage Dockerfile (Node example)
```dockerfile
# ---- Dependencies ----
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# ---- Build ----
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

# ---- Runtime ----
FROM node:18-alpine AS runtime
# Create non‑root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/package*.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```
### Security‑Hardened Container
```dockerfile
FROM node:18-alpine
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
COPY --chown=appuser:appgroup package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --chown=appuser:appgroup . .
USER appuser
# Drop all capabilities and set root FS read‑only (Docker run flags)
```
### Distroless Production Image
```dockerfile
FROM gcr.io/distroless/nodejs18-debian11 AS final
COPY --from=build /app/dist /app
COPY --from=build /app/node_modules /app/node_modules
WORKDIR /app
EXPOSE 3000
CMD ["index.js"]
```
### Build Cache Mount (BuildKit)
```dockerfile
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production
```
### Build‑time Secret (BuildKit)
```dockerfile
FROM alpine AS secret-stage
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) && \
    echo "Using secret during build"
```
### Production Docker Compose
```yaml
version: "3.8"
services:
  app:
    build:
      context: .
      target: runtime
    depends_on:
      db:
        condition: service_healthy
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: 512M
        reservations:
          cpus: "0.25"
          memory: 256M
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB_FILE: /run/secrets/db_name
      POSTGRES_USER_FILE: /run/secrets/db_user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_name
      - db_user
      - db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
volumes:
  postgres_data:
secrets:
  db_name:
    external: true
  db_user:
    external: true
  db_password:
    external: true
```
### Development Override (Compose)
```yaml
services:
  app:
    build:
      context: .
      target: development
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DEBUG=app:*
    ports:
      - "9229:9229"
    command: npm run dev
```
### Cross‑Platform Build (buildx)
```bash
docker buildx create --name multiarch --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t myorg/app:latest --push .
```

## Pitfalls to Avoid
- Copying source code before installing dependencies – breaks layer caching.
- Missing or incomplete `.dockerignore` – inflates build context.
- Running containers as root – increases attack surface.
- Storing secrets in `ENV` or in the Dockerfile – leaks them in image layers.
- Leaving package manager caches after install – enlarges image.
- Using generic base images when a smaller one (Alpine, Distroless) suffices.
- Forgetting `HEALTHCHECK` – makes failure detection hard.
- Exposing unnecessary ports or using default bridge network for production.
- Not defining resource limits – containers can consume all host resources.
- Ignoring multi‑arch requirements when the target environment includes ARM devices.

## Checklist
- **Dockerfile**
  - [ ] Dependencies copied before source files.
  - [ ] Multi‑stage build separates build and runtime.
  - [ ] Only required artifacts are copied to the final stage.
  - [ ] `.dockerignore` excludes source‑control, local caches, and build output.
  - [ ] Base image is minimal and up‑to‑date.
  - [ ] `USER` directive runs container as non‑root.
  - [ ] Secrets are injected via Docker secrets or BuildKit mounts.
  - [ ] `HEALTHCHECK` is defined.
  - [ ] Unnecessary files are removed in the same `RUN` layer.
- **Compose**
  - [ ] Services declare `depends_on` with health conditions.
  - [ ] Separate networks for frontend and backend.
  - [ ] Environment‑specific overrides are isolated.
  - [ ] Volumes are named or correctly bind‑mounted.
  - [ ] Resource limits and restart policies are set.
  - [ ] Secrets are referenced, not hard‑coded.
- **Build & Run**
  - [ ] Build succeeds without cache errors.
  - [ ] Image size is reasonable for the runtime (e.g., <200 MB for Node apps).
  - [ ] Container starts and passes health check.
  - [ ] No security scanner warnings.
  - [ ] Multi‑arch images built if required.

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`java`](../java/SKILL.md) — Guidance, best practices, and checklists for modern Java 21+ development, covering language features, virtual…
- [`golang`](../golang/SKILL.md) — Provides expert guidance for Go 1.21+ development, covering concurrency patterns, performance tuning, microser…
