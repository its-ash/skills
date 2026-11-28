@REF:docker
§SCOPE{Dockerfile_opt,multistage,size,hardening,Compose_V2,BuildKit,SBOM/provenance,perf,debug(build|runtime|net)}
§FLOW{1:`docker --version && docker compose version && docker info|grep -E "Server Version|Storage Driver|Runtime"`;2:`find . -name "Dockerfile*" -type f; find . -name "*compose*.yml" -o -name "*compose*.yaml" -type f; ls -1 .dockerignore 2>/dev/null`;3:inspect(base,layers,stages,`.dockerignore`);4:apply(§PAT);5:`docker build --no-cache -t test-build . && docker run --rm -d --name tmp test-build && docker exec tmp ps aux|head -3 && docker stop tmp && docker compose config`;6:`trivy image test-build`⊕`docker scout quickview test-build`}
§R{
  cache:COPY_lockfiles→install(`--mount=type=cache`)→COPY_src;
  ms:build≠runtime,artifacts_only;
  base:Distroless(debian12/nonroot)|Alpine(3.24)|scratch|slim;pin_semver_or_@sha256(¬`:latest`);
  user:non_root(UID/GID+`USER`,Distroless:`USER nonroot`);
  secrets:¬`ENV`∧¬layers⇒Docker_secrets∨`RUN --mount=type=secret`;
  npm:`npm ci --omit=dev`(¬deprecated`--only=production`);
  compose:Compose_V2(`docker compose`,¬`docker-compose`v1);OMIT_top-level`version:`(obsolete);
  pg18+:PostgreSQL_18+_changed_VOLUME⇒mount`/var/lib/postgresql`(¬`/var/lib/postgresql/data`;`PGDATA=/var/lib/postgresql/18/docker`);
  clean:rm_tools+caches_same_RUN;health:`HEALTHCHECK`∀runtime;res:`deploy.resources`(CPU+mem);net:split(fe,be),¬def_bridge;
  supply_chain:multiarch(`docker buildx`)∧`--provenance=mode=max --sbom=true`∧scan(Trivy|Scout)
}
§PAT{
  node_ms:```dockerfile
FROM node:26-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev

FROM node:26-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN npm run build

FROM node:26-alpine AS runtime
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD node -e "fetch('http://127.0.0.1:3000/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node","dist/index.js"]
```;
  distroless:`FROM node:26-bookworm-slim AS builder`→`npm ci && npm run build && npm prune --omit=dev`→`FROM gcr.io/distroless/nodejs26-debian12`→`WORKDIR /app`→COPY `package.json`,`node_modules`,`dist`→`USER nonroot`→`EXPOSE 3000`→`CMD ["dist/index.js"]`;
  py_uv:`FROM python:3.15-slim AS b`→`COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/`(pin_tag_in_prod)→COPY `pyproject.toml uv.lock ./`→`RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-dev --no-install-project`→COPY `. .`→`uv sync --frozen --no-dev`→runtime_copies`.venv`+`app`+non_root;
  harden:non_root(1001)+`--chown`+`--cap-drop=ALL`+`--read-only`+`--security-opt=no-new-privileges:true`;
  bk_secret:`RUN --mount=type=secret,id=api_key API_KEY=$(cat /run/secrets/api_key) && ...`;
  compose_prod(¬`version:`):{app:{build:{context:.,target:runtime},depends_on:{db:{condition:service_healthy}},networks:[frontend,backend],read_only:true,tmpfs:["/tmp"],cap_drop:[ALL],security_opt:["no-new-privileges:true"],deploy.resources:{limits:{cpus:"0.5",memory:512M},reservations:{cpus:"0.25",memory:256M}}};db:{image:`postgres:18-alpine`,env:{POSTGRES_DB_FILE:`/run/secrets/db_name`,POSTGRES_USER_FILE:`/run/secrets/db_user`,POSTGRES_PASSWORD_FILE:`/run/secrets/db_password`},secrets:[db_name,db_user,db_password],volumes:[`postgres_data:/var/lib/postgresql`],networks:[backend],healthcheck:{test:["CMD-SHELL","pg_isready -U $$(cat /run/secrets/db_user)"],interval:10s,timeout:5s,retries:5}};nets:{frontend:bridge,backend:{bridge,internal:true}};vols:[postgres_data];secrets:{db_name,db_user,db_password:{external:true}}};
  compose_dev:{app:{build:{context:.,target:development},volumes:[".:/app","/app/node_modules"],env:[NODE_ENV=development,"DEBUG=app:*"],ports:["9229:9229"],command:"npm run dev"}};
  buildx:`docker buildx create --name multiarch --use && docker buildx build --platform linux/amd64,linux/arm64 --provenance=mode=max --sbom=true -t ghcr.io/org/app:1.0.0 --push .`;
  net_dns:svc_name(`postgres://db:5432/app`,`redis://redis:6379/0`)|frontend∈`[frontend-net]`,api∈`[frontend-net,backend-net]`,db∈`[backend-net]`(dev_only:`127.0.0.1:5432:5432`,omit_prod);
  vols:{named_pg18:`pgdata:/var/lib/postgresql`(pg<=17:`/var/lib/postgresql/data`);bind:`.:/app`(hot_reload);anon:`/app/node_modules`,`/app/.next`(preserve_under_bind);init:`./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql`(1st_start)};
  dockerignore:`node_modules .git .env .env.* dist coverage *.log .next .cache compose*.yml docker-compose*.yml Dockerfile* tests/`
}
§DBG{`docker compose logs -f app`;`docker compose logs --tail=50 db`;`docker compose exec app sh`;`docker compose exec db psql -U postgres`;`docker compose ps && docker compose top`;`docker stats`;`docker compose build --no-cache app`;`docker compose down -v`(DESTRUCTIVE);net:`docker compose exec app nslookup db`;`docker compose exec app wget -qO- http://api:3000/health`;`docker network inspect <project>_default`}
§ANTI{src_before_deps;no_dockerignore;root;secrets_in_ENV|Dockerfile;top-level`version:`_in_Compose(obsolete);`docker-compose`_v1_CLI;`--only=production`(deprecated⇒`--omit=dev`);`/var/lib/postgresql/data`_on_Postgres_18+(⇒`/var/lib/postgresql`);EOL_Node_18/20;leftover_caches;oversized_base;no_HEALTHCHECK;`curl`_in_Alpine_without_installing;extra_ports|def_bridge_prod;no_res_limits;ignore_ARM;`:latest`;multi_proc_container(1/container);stateful_no_vol;plain_compose_prod_multicontainer(K8s|ECS|Uncloud)}
§CHK{§R;compose:{no_version_key,depends_on_healthy,split_nets,pg18_mount_root,named|bind_vols,res_limits+restart,secrets_ref};run:{no_cache_ok,<200MB_Node,healthy,0_high_crit_CVEs,multiarch+SBOM_if_req}}
§REL{[devops-iac](../SKILL.md);[backend-development](../../backend-development/SKILL.md);[observability](observability.md);[golang](../../golang/SKILL.md)}
